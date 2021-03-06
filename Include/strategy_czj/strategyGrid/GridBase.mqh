//+------------------------------------------------------------------+
//|                                                     GridBase.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridBase:public CStrategy
  {
protected:
   double            base_lots;
   int               grid_points;
   int               tp_per_lots;
   int               tp_points;
   double            lots_current_buy;
   double            lots_current_sell;
   CArrayLong        long_pos_id;
   CArrayLong        short_pos_id;
   double            last_open_long_price;
   double            last_open_short_price;
   MqlTick           latest_price;
   PositionInfor     pos_state;

protected:
   virtual bool      BuildLongPositionCondition();
   virtual bool      BuildShortPositionCondition();
   virtual bool      AddLongPositionCondition();
   virtual bool      AddShortPositionCondition();
   virtual bool      CloseLongPositionCondition();
   virtual bool      CloseShortPositionCondition();

   virtual void      BuildLongPosition();
   virtual void      BuildShortPosition();
   virtual void      AddLongPosition();
   virtual void      AddShortPosition();
   virtual void      CloseLongPosition();
   virtual void      CloseShortPosition();

   double            CalLotsDefault(int num_pos); // 默认方法计算第n个仓位时候的下单手数
   void              RefreshPositionState();   // 刷新仓位信息
   void              RefreshPositionState2();   //
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CGridBase(void);
                    ~CGridBase(void){};
  };
CGridBase::CGridBase(void)
   {
    base_lots=0.01;
    grid_points=50;
    tp_per_lots=100;
    tp_points=200;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridBase::BuildLongPositionCondition(void)
  {
   if(long_pos_id.Total()==0) return true; // 空仓就可以开仓
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridBase::BuildShortPositionCondition(void)
  {
   if(short_pos_id.Total()==0) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridBase::AddLongPositionCondition(void)
  {
   if(long_pos_id.Total()!=0&&last_open_long_price-latest_price.ask>grid_points/MathPow(10,Digits())) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridBase::AddShortPositionCondition(void)
  {
   if(short_pos_id.Total()!=0&&latest_price.bid-last_open_short_price>grid_points/MathPow(10,Digits())) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridBase::CloseLongPositionCondition(void)
  {
   //if(pos_state.lots_buy>0&&pos_state.profits_buy/pos_state.lots_buy>tp_per_lots) return true;
   //return false;
   if(pos_state.num_sell==0&&pos_state.num_buy==1&&pos_state.profits_buy/pos_state.lots_buy>tp_per_lots) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridBase::CloseShortPositionCondition(void)
  {
   //if(pos_state.lots_sell>0&&pos_state.profits_sell/pos_state.lots_sell>tp_per_lots) return true;
   //return false;
   if(pos_state.num_buy==0&&pos_state.num_sell==1&&pos_state.profits_sell/pos_state.lots_sell>tp_per_lots) return true;
   return false;
  }
void CGridBase::RefreshPositionState(void)
   {
    long_pos_id.Clear();
    short_pos_id.Clear();
    for(int i=0;i<PositionsTotal();i++)
      {
       if(PositionGetSymbol(i)!=ExpertSymbol() && PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
       ulong ticket = PositionGetTicket(i);
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) long_pos_id.Add(ticket);
       else short_pos_id.Add(ticket);
      }
     RefreshPositionState2();
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBase::RefreshPositionState2(void)
  {
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
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBase::BuildLongPosition(void)
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,"first-build long");
   last_open_long_price=latest_price.ask;
   long_pos_id.Add(Trade.ResultOrder());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBase::BuildShortPosition(void)
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.bid,0,0,"first-build short");
   last_open_short_price=latest_price.bid;
   short_pos_id.Add(Trade.ResultOrder());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBase::AddLongPosition(void)
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,"Add long-"+string(long_pos_id.Total()));
   last_open_long_price=latest_price.ask;
   long_pos_id.Add(Trade.ResultOrder());
   for(int i=0;i<long_pos_id.Total();i++)
     {
      Trade.PositionModify(long_pos_id.At(i),0,last_open_long_price+tp_points/MathPow(10,Digits()));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBase::AddShortPosition(void)
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.ask,0,0,"Add short-"+string(short_pos_id.Total()));
   last_open_short_price=latest_price.bid;
   short_pos_id.Add(Trade.ResultOrder());
   for(int i=0;i<short_pos_id.Total();i++)
     {
      Trade.PositionModify(short_pos_id.At(i),0,last_open_short_price-tp_points/MathPow(10,Digits()));
     }
  }
void CGridBase::CloseLongPosition(void)
   {
    for(int i=0;i<long_pos_id.Total();i++)
      {
       Trade.PositionClose(long_pos_id.At(i));
      }
     long_pos_id.Clear();
   }
void CGridBase::CloseShortPosition(void)
   {
    for(int i=0;i<short_pos_id.Total();i++)
      {
       Trade.PositionClose(short_pos_id.At(i));
      }
     short_pos_id.Clear();
   }
void CGridBase::OnEvent(const MarketEvent &event)
   {
    if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
      {
       SymbolInfoTick(ExpertSymbol(),latest_price);
       RefreshPositionState();
       if(CloseLongPositionCondition()) CloseLongPosition();
       if(CloseShortPositionCondition()) CloseShortPosition();
       RefreshPositionState();
       lots_current_buy=CalLotsDefault(pos_state.num_buy+1);
       lots_current_sell=CalLotsDefault(pos_state.num_sell+1);
       if(BuildLongPositionCondition()) BuildLongPosition();
       if(BuildShortPositionCondition()) BuildShortPosition();
       if(AddLongPositionCondition()) AddLongPosition();
       if(AddShortPositionCondition()) AddShortPosition();
      }
   }
double CGridBase::CalLotsDefault(int num_pos)
   {
    return NormalizeDouble(0.007*exp(0.4*num_pos),2);
    //return base_lots*num_pos;
   }
//+------------------------------------------------------------------+
