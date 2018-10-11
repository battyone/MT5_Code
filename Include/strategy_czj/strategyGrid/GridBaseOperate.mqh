//+------------------------------------------------------------------+
//|                                              GridBaseOperate.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum GridLotsCalType
  {
   ENUM_GRID_LOTS_FIBONACCI,  // Fibo数列
   ENUM_GRID_LOTS_EXP,  // 指数
   ENUM_GRID_LOTS_GEMINATION // 双倍手数
  };
enum GridWinType
  {
   ENUM_GRID_WIN_LAST,  // 最后开仓价设置止盈位
   ENUM_GRID_WIN_COST   //  成本价设置止盈位
  };
//+------------------------------------------------------------------+
//|           网格策略基本操作集成                                   |
//+------------------------------------------------------------------+
class CGridBaseOperate:public CStrategy
  {
private:
   MqlTick           latest_price;  // 最新的tick报价
   CArrayLong        long_pos_id;   // 多头仓位的id数组
   CArrayLong        short_pos_id;   // 空头仓位的id数组
   double            last_open_long_price;   // 最后一次多头开仓价格
   double            last_open_short_price;  // 最后一次空头开仓价格
   double            cost_long_price;  // 多头成本价
   double            cost_short_price; // 空头成本价
   double            base_lots;   // 基础手数
   GridLotsCalType   lots_type;   // 计算手数的方式

                                  //int               handle_rsi;
   //double            rsi_value[];
   //int               handle_sma;
   //double            sma_value[];
public:
   PositionInfor     pos_state;   // 仓位信息
private:
   void              CalCostPrice();   // 计算成本价格
public:
                     CGridBaseOperate(void){};
                    ~CGridBaseOperate(void){};
   void              Init(double lots_=0.01,GridLotsCalType lots_type_=ENUM_GRID_LOTS_EXP);   // 初始化操作
   void              RefreshTickPrice();   // 刷新最新报价
   void              RefreshPositionState();  // 刷新仓位信息
   void              BuildLongPositionDefault();  // 多头建首仓默认方式
   void              BuildShortPositionDefault();  // 空头建首仓默认方式
   void              CloseLongPosition(); // 平多头操作
   void              CloseShortPosition();   // 平空头操作
   void              BuildLongPositionWithTP(int tp_points);  // 多头建仓带止盈点位(根据最后一次价格)
   void              BuildShortPositionWithTP(int tp_points);  // 空头建仓带止盈点位(根据最后一次价格)
   void              BuildLongPositionWithCostTP(int tp_points);  // 多头建仓带止盈点位(根据成本价格)
   void              BuildShortPositionWithCostTP(int tp_points);  // 空头建仓带止盈点位(根据成本价格)
   double            DistanceAtLastSellPrice(){return(latest_price.ask-last_open_short_price)*MathPow(10,Digits());}; // 和上次卖价比，又上升的点数
   double            DistanceAtLastBuyPrice(){return(last_open_long_price-latest_price.bid)*MathPow(10,Digits());}; // 和上次买价比，又下跌的点数
   double            CalLotsDefault(int num_pos); // 计算第num_pos个仓位对应的手数
   bool              PositionAddLongCondition();   // 多头加仓条件
   bool              PositionAddShortCondition();  // 空头加仓条件
  };
//+------------------------------------------------------------------+
//|                    初始化操作                                    |
//+------------------------------------------------------------------+
void CGridBaseOperate::Init(double lots_=0.01,GridLotsCalType lots_type_=ENUM_GRID_LOTS_EXP)
  {
//handle_rsi=iRSI(ExpertSymbol(),PERIOD_H1,12,PRICE_CLOSE);
//handle_sma=iMA(ExpertSymbol(),PERIOD_H1,800,0,MODE_SMA,PRICE_CLOSE);
   base_lots=lots_;  // 设置基本手数
   lots_type=lots_type_;   // 设置手数计算方式
  }
//+------------------------------------------------------------------+
//|                     刷新tick报价                                 |
//+------------------------------------------------------------------+
void CGridBaseOperate::RefreshTickPrice(void)
  {
   SymbolInfoTick(ExpertSymbol(),latest_price);
//CopyBuffer(handle_rsi,0,0,1,rsi_value);
//CopyBuffer(handle_sma,0,0,1,sma_value);
  }
//+------------------------------------------------------------------+
//|                  刷新仓位信息                                    |
//+------------------------------------------------------------------+
void CGridBaseOperate::RefreshPositionState(void)
  {
   RefreshTickPrice();
   long_pos_id.Clear();
   short_pos_id.Clear();
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionGetSymbol(i)!=ExpertSymbol() || PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      ulong ticket=PositionGetTicket(i);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) long_pos_id.Add(ticket);
      else short_pos_id.Add(ticket);
     }
   pos_state.Init();
   for(int i=0;i<long_pos_id.Total();i++)
     {
      PositionSelectByTicket(long_pos_id.At(i));
      pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_buy+=1;
      pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
     }
   for(int i=0;i<short_pos_id.Total();i++)
     {
      PositionSelectByTicket(short_pos_id.At(i));
      pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_sell+=1;
      pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
     }
  }
//+------------------------------------------------------------------+
//|           默认开多头仓位--不带止盈止损                           |
//+------------------------------------------------------------------+
void CGridBaseOperate::BuildLongPositionDefault(void)
  {
   double lots_current_buy=CalLotsDefault(pos_state.num_buy+1);
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,ExpertSymbol()+":long-"+string(pos_state.num_buy+1));
   if(res)
      {
       last_open_long_price=latest_price.ask;
       long_pos_id.Add(Trade.ResultOrder());
      }
  }
//+------------------------------------------------------------------+
//|            默认开空头仓位--不带止盈止损                          |
//+------------------------------------------------------------------+
void CGridBaseOperate::BuildShortPositionDefault(void)
  {
   double lots_current_sell=CalLotsDefault(pos_state.num_sell+1);
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.bid,0,0,ExpertSymbol()+":short-"+string(pos_state.num_sell+1));
   if(res)
      {
         last_open_short_price=latest_price.bid;
         short_pos_id.Add(Trade.ResultOrder());
      }

  }
//+------------------------------------------------------------------+
//|             带止盈点位开多头仓位--根据最后开多头的价格设置       |
//+------------------------------------------------------------------+
void CGridBaseOperate::BuildLongPositionWithTP(int tp_points)
  {
   double lots_current_buy=CalLotsDefault(pos_state.num_buy+1);
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,ExpertSymbol()+":long(last_price)-"+string(pos_state.num_buy+1));
   if(res)
     {
      last_open_long_price=latest_price.ask;
      long_pos_id.Add(Trade.ResultOrder());
      double tp_price=latest_price.ask+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      for(int i=0;i<long_pos_id.Total();i++) Trade.PositionModify(long_pos_id.At(i),0,tp_price);
     }
  }
//+------------------------------------------------------------------+
//|            止盈点位开空头仓位--根据最后开空头的价格设置          |
//+------------------------------------------------------------------+
void CGridBaseOperate::BuildShortPositionWithTP(int tp_points)
  {
   double lots_current_sell=CalLotsDefault(pos_state.num_sell+1);
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.bid,0,0,ExpertSymbol()+":short(last_price)-"+string(pos_state.num_sell+1));
   if(res)
      {
         last_open_short_price=latest_price.bid;
         short_pos_id.Add(Trade.ResultOrder());
         double tp_price=latest_price.bid-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         for(int i=0;i<short_pos_id.Total();i++) Trade.PositionModify(short_pos_id.At(i),0,tp_price);
      }

  }
//+------------------------------------------------------------------+
//|                 开多头--根据成本价设置止盈位                     |
//+------------------------------------------------------------------+
void CGridBaseOperate::BuildLongPositionWithCostTP(int tp_points)
  {
   double lots_current_buy=CalLotsDefault(pos_state.num_buy+1);
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,ExpertSymbol()+":long(cost_price)-"+string(pos_state.num_buy+1));
   if(res)
     {
      last_open_long_price=latest_price.ask;
      long_pos_id.Add(Trade.ResultOrder());
      CalCostPrice();
      double tp_price=cost_long_price+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      for(int i=0;i<long_pos_id.Total();i++) Trade.PositionModify(long_pos_id.At(i),0,tp_price);
     }
   
  }
//+------------------------------------------------------------------+
//|                 开空头--根据成本价设置止盈位                     |
//+------------------------------------------------------------------+
void CGridBaseOperate::BuildShortPositionWithCostTP(int tp_points)
  {
   double lots_current_sell=CalLotsDefault(pos_state.num_sell+1);
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.bid,0,0,ExpertSymbol()+":short(cost_price)-"+string(pos_state.num_sell+1));
   if(res)
      {
      last_open_short_price=latest_price.bid;
      short_pos_id.Add(Trade.ResultOrder());
      CalCostPrice();
      double tp_price=cost_short_price-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      for(int i=0;i<short_pos_id.Total();i++) Trade.PositionModify(short_pos_id.At(i),0,tp_price);
      }
   
  }
//+------------------------------------------------------------------+
//|              平多头仓位                                          |
//+------------------------------------------------------------------+
void CGridBaseOperate::CloseLongPosition(void)
  {
   for(int i=0;i<long_pos_id.Total();i++) Trade.PositionClose(long_pos_id.At(i));
   long_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|             平空头仓位                                           |
//+------------------------------------------------------------------+
void CGridBaseOperate::CloseShortPosition(void)
  {
   for(int i=0;i<short_pos_id.Total();i++) Trade.PositionClose(short_pos_id.At(i));
   short_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|            根据不同的方式计算对应手数                            |
//+------------------------------------------------------------------+
double CGridBaseOperate::CalLotsDefault(int num_pos)
  {
   double pos_lots=0.01;
   switch(lots_type)
     {
      case ENUM_GRID_LOTS_EXP :
         pos_lots=NormalizeDouble(base_lots*0.7*exp(0.4*num_pos),2);
         break;
      case ENUM_GRID_LOTS_FIBONACCI:
         pos_lots=NormalizeDouble(base_lots*(1/sqrt(5)*(MathPow((1+sqrt(5))/2,num_pos)-MathPow((1-sqrt(5))/2,num_pos))),2);
         break;
      case ENUM_GRID_LOTS_GEMINATION:
         pos_lots=NormalizeDouble(base_lots*MathPow(2,num_pos),2);
         break;
      default:
         break;
     }
   return pos_lots;
  }
//+------------------------------------------------------------------+
//|                  计算成本价格                                    |
//+------------------------------------------------------------------+
void CGridBaseOperate::CalCostPrice(void)
  {
   double sum_long_lots=0;
   double sum_short_lots=0;
   double sum_long_price=0;
   double sum_short_price=0;
   for(int i=0;i<long_pos_id.Total();i++)
     {
      PositionSelectByTicket(long_pos_id.At(i));
      sum_long_lots+=PositionGetDouble(POSITION_VOLUME);
      sum_long_price+=PositionGetDouble(POSITION_VOLUME)*PositionGetDouble(POSITION_PRICE_OPEN);
     }
   for(int i=0;i<short_pos_id.Total();i++)
     {
      PositionSelectByTicket(short_pos_id.At(i));
      sum_short_lots+=PositionGetDouble(POSITION_VOLUME);
      sum_short_price+=PositionGetDouble(POSITION_VOLUME)*PositionGetDouble(POSITION_PRICE_OPEN);
     }
   cost_long_price=sum_long_lots==0?0:sum_long_price/sum_long_lots;
   cost_short_price=sum_short_lots==0?0:sum_short_price/sum_short_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridBaseOperate::PositionAddLongCondition(void)
  {
//if(rsi_value[0]<30) return true;
//return false;
//if(latest_price.bid>sma_value[0]+5000/MathPow(10,Digits()) || latest_price.ask<sma_value[0]-5000/MathPow(10,Digits()))
//   return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridBaseOperate::PositionAddShortCondition(void)
  {
//if(rsi_value[0]>70) return true;
//return false;
//if(latest_price.bid>sma_value[0]+5000/MathPow(10,Digits()) || latest_price.ask<sma_value[0]-5000/MathPow(10,Digits()))
//   return false;
   return true;
  }
//+------------------------------------------------------------------+
