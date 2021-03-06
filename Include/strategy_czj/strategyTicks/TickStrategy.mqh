//+------------------------------------------------------------------+
//|                                                 TickStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum SymbolRelation
  {
   RELATION_POSITIVE,// 正相关
   RELATION_NEGATIVE // 负相关
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTickStrategy:public CStrategy
  {
protected:
   string            sym_x;
   string            sym_y;
   MqlTick           tick_x[];
   MqlTick           tick_y[];
   SymbolRelation    sr;
   bool              is_buy;
   bool              is_sell;
   int tp_points;
   int               delta_tick_x;
   int               delta_tick_y;
protected:
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CTickStrategy(void);
                    ~CTickStrategy(void){};
   void              SetSymbolX(string s_x="EURUSD"){sym_x=s_x; AddTickEvent(s_x);};
   void              SetSymbolY(string s_y="GBPUSD"){sym_y=s_y; AddTickEvent(s_y);};
   void              SetSymbolRelation(SymbolRelation sym_r){sr=sym_r;};
   void              SetTP(int points_tp=40){tp_points=points_tp;};
   void              RefreshTickMode();
   void              BuyY();
   void              SellY();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTickStrategy::CTickStrategy(void)
  {
   SetSymbolX();
   SetSymbolY();
   SetSymbolRelation(RELATION_POSITIVE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTickStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      RefreshTickMode();
      if(is_buy) BuyY();
      else if(is_sell) SellY();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTickStrategy::BuyY(void)
  {
   double tp=tick_y[9].ask+tp_points*SymbolInfoDouble(sym_y,SYMBOL_POINT);
   double sl=tick_y[9].bid-tp_points*SymbolInfoDouble(sym_y,SYMBOL_POINT);
   Trade.PositionOpen(sym_y,ORDER_TYPE_BUY,0.01,tick_y[9].ask,sl,tp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTickStrategy::SellY(void)
  {
   double tp=tick_y[9].bid-tp_points*SymbolInfoDouble(sym_y,SYMBOL_POINT);
   double sl=tick_y[9].ask+tp_points*SymbolInfoDouble(sym_y,SYMBOL_POINT);
   Trade.PositionOpen(sym_y,ORDER_TYPE_SELL,0.01,tick_y[9].bid,sl,tp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTickStrategy::RefreshTickMode(void)
  {
   int num_x=CopyTicks(sym_x,tick_x,COPY_TICKS_ALL,0,10);
   int num_y=CopyTicks(sym_y,tick_y,COPY_TICKS_ALL,0,10);
   if(num_x<10||num_y<10) return;
   is_buy=false;
   is_sell=false;
   switch(sr)
     {
      case RELATION_NEGATIVE :
         if(tick_x[9].ask-tick_x[8].ask>50*SymbolInfoDouble(sym_x,SYMBOL_POINT))
           {
            if(tick_y[9].ask-tick_y[8].ask>-10*SymbolInfoDouble(sym_y,SYMBOL_POINT))
              {
               is_sell=true;
              }
           }
         else if(tick_x[9].ask-tick_x[8].ask<-50*SymbolInfoDouble(sym_x,SYMBOL_POINT))
           {
            if(tick_y[9].ask-tick_y[8].ask<10*SymbolInfoDouble(sym_y,SYMBOL_POINT))
              {
               is_buy=true;
              }
           }
         break;
      case RELATION_POSITIVE:
         if(tick_x[9].ask-tick_x[8].ask>50*SymbolInfoDouble(sym_x,SYMBOL_POINT))
           {
            if(tick_y[9].ask-tick_y[8].ask<10*SymbolInfoDouble(sym_y,SYMBOL_POINT))
              {
               is_buy=true;
              }
           }
         else if(tick_x[9].ask-tick_x[8].ask<-50*SymbolInfoDouble(sym_x,SYMBOL_POINT))
           {
            if(tick_y[9].ask-tick_y[8].ask>-10*SymbolInfoDouble(sym_y,SYMBOL_POINT))
              {
               is_sell=true;
              }
           }
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
