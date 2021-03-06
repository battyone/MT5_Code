//+------------------------------------------------------------------+
//|                                                     bar_data.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBarData:public CStrategy
  {
private:
   MqlRates rates[];
protected:
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CBarData(void){};
                    ~CBarData(void){};
  };
void CBarData::OnEvent(const MarketEvent &event)
   {
    if(event.type==MARKET_EVENT_BAR_OPEN)
      {
       CopyRates(ExpertSymbol(),Timeframe(),0,1,rates);
       Print(rates[0].time,rates[0].open);
      }
   }
