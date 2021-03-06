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
//enum GridLotsCalType
//  {
//   ENUM_GRID_LOTS_FIBONACCI,  // Fibo数列
//   ENUM_GRID_LOTS_EXP,  // 默认指数
//   ENUM_GRID_LOTS_EXP15, // 第15个仓位为1
//   ENUM_GRID_LOTS_EXP20, // 第20个仓位为1
//   ENUM_GRID_LOTS_GEMINATION, // 双倍手数
//   ENUM_GRID_LOTS_EXP_NUM,  // 第n个仓位为1手
//   ENUM_GRID_LOTS_FBS   // 同FBS账户一致
//  };
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
   CArrayLong        long_pos_level;   // 记录多头仓位的级别序列
   CArrayLong        short_pos_level;   // 记录空头仓位的级别序列
   double            last_open_long_price;   // 最后一次多头开仓价格
   double            last_open_short_price;  // 最后一次空头开仓价格
   double            cost_long_price;  // 多头成本价
   double            cost_short_price; // 空头成本价
   double            base_lots;   // 基础手数
   GridLotsCalType   lots_type;   // 计算手数的方式
   int               num_pos_max;   //  最大的仓位数(默认15)
public:
   PositionInfor     pos_state;   // 仓位信息
private:
   void              CalCostPrice();   // 计算成本价格
public:
                     CGridBaseOperate(void){};
                    ~CGridBaseOperate(void){};
   void              Init(double lots_=0.01,GridLotsCalType lots_type_=ENUM_GRID_LOTS_EXP,int pos_max=15);   // 初始化操作
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
   bool              BuildLongPositionWithCostTP(int tp_points,double open_lots);  // 指定手数多头建仓带止盈点位(根据成本价格)
   bool              BuildShortPositionWithCostTP(int tp_points,double open_lots);  // 指定手数空头建仓带止盈点位(根据成本价格)
   double            DistanceAtLastSellPrice(){return(latest_price.bid-last_open_short_price)*MathPow(10,Digits());}; // 和上次卖价比，又上升的点数
   double            DistanceAtLastBuyPrice(){return(last_open_long_price-latest_price.ask)*MathPow(10,Digits());}; // 和上次买价比，又下跌的点数
   
   double            CalLotsDefault(int num_pos); // 计算第num_pos个仓位对应的手数
   bool              PositionAddLongCondition();   // 多头加仓条件
   bool              PositionAddShortCondition();  // 空头加仓条件
   void              SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling){Trade.SetTypeFilling(filling);};
   void              ReBuildPositionState(); // 重建仓位信息
   void              ReModifyTP(int tp_points); 
   int               NumLongToShort(){return pos_state.num_buy-pos_state.num_sell;};
   bool              IsEmptyPosition();
   
   int               GetLongPositionIdAt(int index){return long_pos_id.At(index);};  // 获取多头指定索引的仓位ID
   int               GetShortPositionIdAt(int index){return short_pos_id.At(index);}; // 获取空头指定索引的仓位ID
   double            GetPartialLongPositionProfitsPerLots(const long &pos_id[]);  // 获取多头部分仓位组合的每手获利结果
   double            GetPartialShortPositionProfitsPerLots(const long &pos_id[]);  // 获取空头部分仓位组合的每手获利结果
   double            GetPartialLongPositionProfits(const long &pos_id[]);  // 获取多头部分仓位组合的获利结果
   double            GetPartialShortPositionProfits(const long &pos_id[]);  // 获取空头部分仓位组合的获利结果
   double            GetTotalPositionProfitsPerLots();   // 获取所有仓位的每手盈利情况
   double            GetAllLongPositionProfitsPerLots(); // 获取多头所有仓位的每手盈利的结果
   double            GetAllShortPositionProfitsPerLots(); // 获取空头所有仓位的每手盈利的结果
   void              ClosePartialLongPosition(const long &pos_id[]);       // 平掉部分多头仓位
   void              ClosePartialShortPosition(const long &pos_id[]);       // 平掉部分空头仓位
   void              BuildLongPosition(double build_lots);  // 多头建仓
   void              BuildShortPosition(double build_lots); // 空头建仓
   double            DistanceAtLastShortPositionPrice(); // 和当前空头最后一个仓位比，又上升的点数
   double            DistanceAtLastLongPositionPrice(); // 和当前多头最后一个仓位比，又下跌的点数
   double            GetLongPositionLotsAt(int index);   // 获取多头仓位指定索引的手数
   double            GetShortPositionLotsAt(int index);   // 获取空头仓位指定索引的手数
   long              GetLastLongLevel(){return long_pos_level.At(long_pos_level.Total()-1);};   // 获取最后一个多头仓位的级别
   long              GetLastShortLevel(){return short_pos_level.At(short_pos_level.Total()-1);};   //获取最后一个空头仓位的级别

  };
//+------------------------------------------------------------------+
//|                    初始化操作                                    |
//+------------------------------------------------------------------+
void CGridBaseOperate::Init(double lots_=0.01,GridLotsCalType lots_type_=ENUM_GRID_LOTS_EXP, int pos_max=15)
  {
//handle_rsi=iRSI(ExpertSymbol(),PERIOD_H1,12,PRICE_CLOSE);
//handle_sma=iMA(ExpertSymbol(),PERIOD_H1,800,0,MODE_SMA,PRICE_CLOSE);
   base_lots=lots_;  // 设置基本手数
   lots_type=lots_type_;   // 设置手数计算方式
   num_pos_max=pos_max; // 设置最大仓位数
  }
void CGridBaseOperate::ReBuildPositionState(void)
   {
    RefreshTickPrice();
    RefreshPositionState();
    last_open_long_price=DBL_MAX;
    last_open_short_price=DBL_MIN;
    
    if(pos_state.num_buy>0)
      {
        for(int i=0;i<long_pos_id.Total();i++)
          {
           PositionSelectByTicket(long_pos_id.At(i));
           last_open_long_price=MathMin(PositionGetDouble(POSITION_PRICE_OPEN),last_open_long_price);
          }
        Print("多头仓位数:",long_pos_id.Total()," 最后long_open_price:", DoubleToString(last_open_long_price,SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS)));
      }
    else Print("多头仓位数:0");
    if(pos_state.num_sell>0)
      {
       for(int i=0;i<short_pos_id.Total();i++)
         {
            PositionSelectByTicket(short_pos_id.At(i));
            last_open_short_price=MathMax(PositionGetDouble(POSITION_PRICE_OPEN),last_open_short_price);
         }
       Print("空头仓位数:",short_pos_id.Total()," 最后short_open_price:", DoubleToString(last_open_short_price,SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS)));
      }
    else Print("空头仓位数:0");    
   }
void CGridBaseOperate::ReModifyTP(int tp_points)
   {
    Print("TP CHECK:");
    double tp_long_price=last_open_long_price+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
    double tp_short_price=last_open_short_price-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
    for(int i=0;i<long_pos_id.Total();i++) 
         {
          int counter=0;
          bool modify_success=false;
          PositionSelectByTicket(long_pos_id.At(i));
          if(PositionGetDouble(POSITION_TP)==tp_long_price) continue;

          while(counter<50&&!modify_success)
            {
             modify_success=Trade.PositionModify(long_pos_id.At(i),0,tp_long_price);
             counter++;
             Sleep(500);
            }
          Print("modify TP Result:",modify_success, " counter num:", counter, " TP_LONG_PRICE:", tp_long_price);
         }
    for(int i=0;i<short_pos_id.Total();i++)
            {
             int counter=0;
             bool modify_success=false;
          PositionSelectByTicket(short_pos_id.At(i));
          if(PositionGetDouble(POSITION_TP)==tp_short_price) continue;
             while(counter<50&&!modify_success)
               {
                modify_success=Trade.PositionModify(short_pos_id.At(i),0,tp_short_price);
                counter++;
                Sleep(500);
               }
             Print("modify TP Result:",modify_success, " counter num:", counter, " TP_SHORT_PRICE:", tp_short_price);
            }
   }
//+------------------------------------------------------------------+
//|                     刷新tick报价                                 |
//+------------------------------------------------------------------+
void CGridBaseOperate::RefreshTickPrice(void)
  {
   SymbolInfoTick(ExpertSymbol(),latest_price);
  }
//+------------------------------------------------------------------+
//|                  刷新仓位信息                                    |
//+------------------------------------------------------------------+
void CGridBaseOperate::RefreshPositionState(void)
  {
   //RefreshTickPrice();
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
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,ExpertSymbol()+":long(lp)-"+string(pos_state.num_buy+1));
   if(res)
     {
      Print("多头开仓成功--品种对:",ExpertSymbol()," 成交价格:",Trade.ResultPrice());
      last_open_long_price=latest_price.ask;
      long_pos_id.Add(Trade.ResultOrder());
      double tp_price=latest_price.ask+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Print("long modify tp:",tp_price," latest_price:", latest_price.ask, " tp_points:", tp_points);
      for(int i=0;i<long_pos_id.Total();i++) 
         {
          int counter=0;
          bool modify_success=false;
          while(counter<50&&!modify_success)
            {
             modify_success=Trade.PositionModify(long_pos_id.At(i),0,tp_price);
             Sleep(500);
             counter++;
            }
          Print("modify TP Result:",modify_success, " counter num:", counter);
         }
     }
   else
     {
      Print("多头开仓失败--品种对:",ExpertSymbol()," 失败代码:",Trade.ResultRetcode());
     }
  }
//+------------------------------------------------------------------+
//|            止盈点位开空头仓位--根据最后开空头的价格设置          |
//+------------------------------------------------------------------+
void CGridBaseOperate::BuildShortPositionWithTP(int tp_points)
  {
   double lots_current_sell=CalLotsDefault(pos_state.num_sell+1);
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.bid,0,0,ExpertSymbol()+":short(lp)-"+string(pos_state.num_sell+1));
   if(res)
      {
         Print("空头开仓成功--品种对:",ExpertSymbol()," 成交价格:",Trade.ResultPrice());
         last_open_short_price=latest_price.bid;
         short_pos_id.Add(Trade.ResultOrder());
         double tp_price=latest_price.bid-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         Print("short modify tp:",tp_price," latest_price:", latest_price.ask, " tp_points:", tp_points);
         for(int i=0;i<short_pos_id.Total();i++)
            {
             int counter=0;
             bool modify_success=false;
             while(counter<50&&!modify_success)
               {
                modify_success=Trade.PositionModify(short_pos_id.At(i),0,tp_price);
                counter++;
                Sleep(500);
               }
             Print("modify TP Result:",modify_success, " counter num:", counter);
            }
      }
    else
      {
       Print("空头开仓失败--品种对:",ExpertSymbol()," 失败代码:",Trade.ResultRetcode());
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
bool CGridBaseOperate::BuildLongPositionWithCostTP(int tp_points,double open_lots)
  {
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,latest_price.ask,0,0,ExpertSymbol()+":long(cost_price)-"+string(pos_state.num_buy+1));
   if(res)
     {
      last_open_long_price=latest_price.ask;
      long_pos_id.Add(Trade.ResultOrder());
      CalCostPrice();
      double tp_price=cost_long_price+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      for(int i=0;i<long_pos_id.Total();i++) Trade.PositionModify(long_pos_id.At(i),0,tp_price);
     }
   return res;
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
bool CGridBaseOperate::BuildShortPositionWithCostTP(int tp_points,double open_lots)
  {
   bool res=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,latest_price.bid,0,0,ExpertSymbol()+":short(cost_price)-"+string(pos_state.num_sell+1));
   if(res)
      {
      last_open_short_price=latest_price.bid;
      short_pos_id.Add(Trade.ResultOrder());
      CalCostPrice();
      double tp_price=cost_short_price-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      for(int i=0;i<short_pos_id.Total();i++) Trade.PositionModify(short_pos_id.At(i),0,tp_price);
      }
    return res;
  }
//+------------------------------------------------------------------+
//|              平多头仓位                                          |
//+------------------------------------------------------------------+
void CGridBaseOperate::CloseLongPosition(void)
  {
   for(int i=0;i<long_pos_id.Total();i++) Trade.PositionClose(long_pos_id.At(i));
      {
       long_pos_id.Clear();
       long_pos_level.Clear();
      }
  }
//+------------------------------------------------------------------+
//|             平空头仓位                                           |
//+------------------------------------------------------------------+
void CGridBaseOperate::CloseShortPosition(void)
  {
   for(int i=0;i<short_pos_id.Total();i++) Trade.PositionClose(short_pos_id.At(i));
    {
     short_pos_id.Clear();
     short_pos_level.Clear();
    }
  }
//+------------------------------------------------------------------+
//|            根据不同的方式计算对应手数                            |
//+------------------------------------------------------------------+
double CGridBaseOperate::CalLotsDefault(int num_pos)
  {
   double pos_lots=0.01;
   double alpha,beta;
   switch(lots_type)
     {
      case ENUM_GRID_LOTS_EXP :
         pos_lots=NormalizeDouble(base_lots*0.7*exp(0.4*num_pos),2);
         break;
      case ENUM_GRID_LOTS_EXP15:
         pos_lots=NormalizeDouble(base_lots*0.7197*exp(0.3289*num_pos),2);
         break;
      case ENUM_GRID_LOTS_EXP20:
         pos_lots=NormalizeDouble(base_lots*0.7848*exp(0.2424*num_pos),2);
         break;
      case ENUM_GRID_LOTS_FIBONACCI:
         pos_lots=NormalizeDouble(base_lots*(1/sqrt(5)*(MathPow((1+sqrt(5))/2,num_pos)-MathPow((1-sqrt(5))/2,num_pos))),2);
         break;
      case ENUM_GRID_LOTS_GEMINATION:
         pos_lots=NormalizeDouble(base_lots*MathPow(2,num_pos),2);
         break;
      case ENUM_GRID_LOTS_EXP_NUM:
         beta=MathLog(100)/(num_pos_max-1);
         alpha=1/MathExp(beta);
         pos_lots=NormalizeDouble(base_lots*alpha*exp(beta*num_pos),2);
         break;
      case ENUM_GRID_LOTS_FBS:
         pos_lots=NormalizeDouble(base_lots*0.76*exp(0.2628*num_pos),2);
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
bool CGridBaseOperate::IsEmptyPosition(void)
   {
    if(pos_state.num_buy+pos_state.num_sell==0) return true;
    return false;
   }
void CGridBaseOperate::ClosePartialLongPosition(const long &pos_id[])
   {
    for(int i=0;i<ArraySize(pos_id);i++)
      {
       Trade.PositionClose(long_pos_id.At(pos_id[i]));
      }
    for(int i=ArraySize(pos_id)-1;i>=0;i--)
      {
       long_pos_id.Delete(pos_id[i]);
       long_pos_level.Delete(pos_id[i]);
      }
   }
void CGridBaseOperate::ClosePartialShortPosition(const long &pos_id[])
   {
    for(int i=0;i<ArraySize(pos_id);i++)
      {
       Trade.PositionClose(short_pos_id.At(pos_id[i]));
      }
     for(int i=ArraySize(pos_id)-1;i>=0;i--)
      {
       short_pos_id.Delete(pos_id[i]);
       short_pos_level.Delete(pos_id[i]);       
      }
   }
double CGridBaseOperate::GetPartialLongPositionProfitsPerLots(const long &pos_id[])
   {
    double sum_lots=0,sum_profits=0;
    for(int i=0;i<ArraySize(pos_id);i++)
      {
       PositionSelectByTicket(long_pos_id.At(pos_id[i]));
       sum_lots+=PositionGetDouble(POSITION_VOLUME);
       sum_profits+=PositionGetDouble(POSITION_PROFIT);
      }
    if(sum_lots>0) return sum_profits/sum_lots;
    else return 0;
   }
double CGridBaseOperate::GetPartialShortPositionProfitsPerLots(const long &pos_id[])
   {
    double sum_lots=0,sum_profits=0;
    for(int i=0;i<ArraySize(pos_id);i++)
      {
       PositionSelectByTicket(short_pos_id.At(pos_id[i]));
       sum_lots+=PositionGetDouble(POSITION_VOLUME);
       sum_profits+=PositionGetDouble(POSITION_PROFIT);
      }
    if(sum_lots>0) return sum_profits/sum_lots;
    else return 0;
   }
double CGridBaseOperate::GetPartialLongPositionProfits(const long &pos_id[])
   {
    double sum_lots=0,sum_profits=0;
    for(int i=0;i<ArraySize(pos_id);i++)
      {
       PositionSelectByTicket(long_pos_id.At(pos_id[i]));
       sum_lots+=PositionGetDouble(POSITION_VOLUME);
       sum_profits+=PositionGetDouble(POSITION_PROFIT);
      }
    if(sum_lots>0) return sum_profits;
    else return 0;
   }
double CGridBaseOperate::GetPartialShortPositionProfits(const long &pos_id[])
   {
    double sum_lots=0,sum_profits=0;
    for(int i=0;i<ArraySize(pos_id);i++)
      {
       PositionSelectByTicket(short_pos_id.At(pos_id[i]));
       sum_lots+=PositionGetDouble(POSITION_VOLUME);
       sum_profits+=PositionGetDouble(POSITION_PROFIT);
      }
    if(sum_lots>0) return sum_profits;
    else return 0;
   }
double CGridBaseOperate::GetTotalPositionProfitsPerLots(void)
   {
    double sum_lots=0,sum_profits=0;
    for(int i=0;i<long_pos_id.Total();i++)
      {
       PositionSelectByTicket(long_pos_id.At(i));
       sum_lots+=PositionGetDouble(POSITION_VOLUME);
       sum_profits+=PositionGetDouble(POSITION_PROFIT);
      }
    for(int i=0;i<short_pos_id.Total();i++)
      {
       PositionSelectByTicket(short_pos_id.At(i));
       sum_lots+=PositionGetDouble(POSITION_VOLUME);
       sum_profits+=PositionGetDouble(POSITION_PROFIT);
      }
    if(sum_lots>0) return sum_profits/sum_lots;
    else return 0;
   }
double CGridBaseOperate::GetAllLongPositionProfitsPerLots(void)
   {
    double sum_lots=0,sum_profits=0;
    for(int i=0;i<long_pos_id.Total();i++)
      {
       PositionSelectByTicket(long_pos_id.At(i));
       sum_lots+=PositionGetDouble(POSITION_VOLUME);
       sum_profits+=PositionGetDouble(POSITION_PROFIT);
      }
    if(sum_lots>0) return sum_profits/sum_lots;
    else return 0;
   }
double CGridBaseOperate::GetAllShortPositionProfitsPerLots(void)
   {
    double sum_lots=0,sum_profits=0;
    for(int i=0;i<short_pos_id.Total();i++)
      {
       PositionSelectByTicket(short_pos_id.At(i));
       sum_lots+=PositionGetDouble(POSITION_VOLUME);
       sum_profits+=PositionGetDouble(POSITION_PROFIT);
      }
    if(sum_lots>0) return sum_profits/sum_lots;
    else return 0;
   }
void CGridBaseOperate::BuildLongPosition(double build_lots)
   {
    if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,build_lots,latest_price.ask,0,0,"czj"))
      {
       long_pos_id.Add(Trade.ResultOrder());
       if(long_pos_level.Total()==0) long_pos_level.Add(1);
       else long_pos_level.Add(long_pos_level.At(long_pos_level.Total()-1)+1);
       
      }
   }
void CGridBaseOperate::BuildShortPosition(double build_lots)
   {
    if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,build_lots,latest_price.bid,0,0,"czj")) 
      {
       short_pos_id.Add(Trade.ResultOrder());
       if(short_pos_level.Total()==0) short_pos_level.Add(1);
       else short_pos_level.Add(short_pos_level.At(short_pos_level.Total()-1)+1);
      }
   }
double CGridBaseOperate::DistanceAtLastLongPositionPrice(void)
   {
    PositionSelectByTicket(long_pos_id.At(long_pos_id.Total()-1));
    return(PositionGetDouble(POSITION_PRICE_OPEN)-latest_price.ask)*MathPow(10,Digits());
    
   }
double CGridBaseOperate::DistanceAtLastShortPositionPrice(void)
   {
    PositionSelectByTicket(short_pos_id.At(short_pos_id.Total()-1));
    return(latest_price.bid-PositionGetDouble(POSITION_PRICE_OPEN))*MathPow(10,Digits());
   }
double CGridBaseOperate::GetLongPositionLotsAt(int index)
   {
    PositionSelectByTicket(long_pos_id.At(index));
    return PositionGetDouble(POSITION_VOLUME);
   }
double CGridBaseOperate::GetShortPositionLotsAt(int index)
   {
    PositionSelectByTicket(short_pos_id.At(index));
    return PositionGetDouble(POSITION_VOLUME);
   }
//+------------------------------------------------------------------+
