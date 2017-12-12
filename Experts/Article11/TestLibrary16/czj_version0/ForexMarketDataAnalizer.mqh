//+------------------------------------------------------------------+
//|                                      ForexMarketDataAnalizer.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "ForexMarketDataManager.mqh"

class CForexMarketDataAnalyzier
   {
    private:
      CForexMarketDataManager dm;
    public:
      void SetDataManager(CForexMarketDataManager &dm);
      
   };