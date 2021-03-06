//+------------------------------------------------------------------+
//|                                         MultiSymbolArbitrage.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"

#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Math\Alglib\matrix.mqh>
#include <Math\Alglib\alglib.mqh>
#include <RingBuffer\RiBuffDbl.mqh>
#include <Math\czj\math_tools.mqh>
#include "ArbPosition.mqh"
#include <Arrays\ArrayDouble.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMultiSymbolArbitrage:public CStrategy
  {
private:
   string            symbols[]; // 品种组合
   double            coef[]; // 品种对组合系数

   MqlTick           latest_price[]; // 最新报价
   int               num_sym;
   int               num_ts;

   CArbPosition      pos;
   CArrayDouble      ts;

public:
                     CMultiSymbolArbitrage(void);
                    ~CMultiSymbolArbitrage(void);
   virtual void      OnEvent(const MarketEvent &event);
protected:
   void              CheckPositionOpen();
   void              CheckPositionClose();
   void              CloseLongPosition();
   void              CloseShortPosition();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMultiSymbolArbitrage::CMultiSymbolArbitrage(void)
  {
   string s_default[]={"EURUSD","USDCHF"};
   double c_default[]={1,1};
   num_sym=2;
   num_ts=240;   // H1,10天
   ArrayCopy(symbols,s_default);
   ArrayCopy(coef,c_default);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiSymbolArbitrage::OnEvent(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_TICK)
     {
      for(int i=0;i<num_sym;i++) SymbolInfoTick(symbols[i],latest_price[i]);
      CheckPositionClose();
      CheckPositionOpen();
     }
   if(event.type==MARKET_EVENT_BAR_OPEN)
     {
      Print("BAR OPEN EVENT");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiSymbolArbitrage::CheckPositionClose(void)
  {
   if(pos.GetLongProfits()>100) CloseLongPosition();
   if(pos.GetShortProfits()>100) CloseShortPosition();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiSymbolArbitrage::CheckPositionOpen(void)
  {

  }
//+------------------------------------------------------------------+
