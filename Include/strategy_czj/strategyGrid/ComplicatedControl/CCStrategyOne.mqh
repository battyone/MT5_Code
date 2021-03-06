//+------------------------------------------------------------------+
//|                                                CCStrategyOne.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "CCOpenCloseLogic.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCStrategyOne:public CCOpenCloseLogic
  {
protected:
   virtual void      CheckPositionClose(); // 平仓判断
   virtual void      CheckPositionOpen(const MarketEvent &event); // 开仓判断
   int               GetOptAddLongSymbolIndex();
   int               GetOptAddShortSymbolIndex();
   virtual void      CheckRiskGridPositionOpen();
public:
                     CCStrategyOne(void);
                    ~CCStrategyOne(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCStrategyOne::CCStrategyOne(void)
  {
   AddBarOpenEvent(ExpertSymbol(),PERIOD_M1);
//AddBarOpenEvent(ExpertSymbol(),PERIOD_H1);
   for(int i=0;i<28;i++)
     {
      AddBarOpenEvent(SYMBOLS_28[i],PERIOD_H1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyOne::CheckPositionOpen(const MarketEvent &event)
  {
   switch(event.period)
     {
      case PERIOD_M1:
         RefreshRiskInfor();
         //CheckOpenAfterClose();
         CheckNormGridPositionOpen();
         break;
      case PERIOD_H1:
         RefreshRiskInfor();
         CheckRiskGridPositionOpen();
         PrintRiskInfor();
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyOne::CheckPositionClose(void)
  {
   RefreshRiskInfor();
   CheckAllPositionClose(500,100);
   RefreshRiskInfor();
   for(int i=0;i<28;i++)
     {
      CheckOneSymbolPositionClose(i,200,100);
     }
   RefreshRiskInfor();
   CheckRiskSymbolsPartialPositionClose(200,100);
   RefreshRiskInfor();
   CheckWorstSymbolPartialPositionClose(200,100);
   RefreshRiskInfor();
   CheckOneSymbolCombinePositionClose();
   RefreshRiskInfor();
   CheckSmallPositionTP();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CCStrategyOne::GetOptAddLongSymbolIndex(void)
  {
   int opt_index=0;
   for(int i=0;i<28;i++)
     {
      if(DistanceLatestPriceToLastBuyPrice(i)>DistanceLatestPriceToLastBuyPrice(opt_index)) opt_index=i;
     }
   return opt_index;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CCStrategyOne::GetOptAddShortSymbolIndex(void)
  {
   int opt_index=0;
   for(int i=0;i<28;i++)
     {
      if(DistanceLatestPriceToLastSellPrice(i)>DistanceLatestPriceToLastSellPrice(opt_index)) opt_index=i;
     }
   return opt_index;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyOne::CheckRiskGridPositionOpen(void)
  {
   NormGridOpenLongAt(GetOptAddLongSymbolIndex(),150,"RiskOpen");
   NormGridOpenShortAt(GetOptAddShortSymbolIndex(),150,"RiskOpen");
  }
//+------------------------------------------------------------------+
