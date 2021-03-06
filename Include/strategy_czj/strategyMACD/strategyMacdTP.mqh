//+------------------------------------------------------------------+
//|                                               strategyMacdTP.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "strategyMACDBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStrategyMacdTP:public CMACDBase
  {
private:
   int               tp;
   int               sl;
   double            tp_price;
   double            sl_price;
   bool              need_filter;
   
public:
                     CStrategyMacdTP(void){};
                    ~CStrategyMacdTP(void){};
   void              SetParametersTP(int tp_points=500,int sl_points=500,bool need_f=true);
protected:
   virtual void      CheckPositionOpen();
   void      OpenMode1();
   void      OpenMode2();
   virtual void      CheckPositionClose(){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CStrategyMacdTP::SetParametersTP(int tp_points=500,int sl_points=500,bool need_f=true)
  {
   tp=tp_points;
   sl=sl_points;
   need_filter=need_f;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CStrategyMacdTP::CheckPositionOpen(void)
  {
   if(need_filter) OpenMode2();
   else OpenMode1();
  }
  
void CStrategyMacdTP::OpenMode1(void)
   {
    CopyBuffer(h_macd_detector,2,0,1,value_signal);
   if(value_signal[0]==1)
     {
      Print("Buy");
      tp_price=latest_price.ask+tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      sl_price=latest_price.ask-sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,base_lots,latest_price.ask,sl_price,tp_price);
     }
   else if(value_signal[0]==-1)
     {
      Print("Sell");
      tp_price=latest_price.bid-tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      sl_price=latest_price.bid+sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,base_lots,latest_price.bid,sl_price,tp_price);
     }
   }
void CStrategyMacdTP::OpenMode2(void)
  {
   double price1[];
   double price2[];
   CopyBuffer(h_macd_detector,2,0,1,value_signal);
   CopyBuffer(h_macd_detector,5,0,1,price1);
   CopyBuffer(h_macd_detector,6,0,1,price2);
   if(MathAbs(price1[0]-price2[0])/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)<400) return;
   
   if(value_signal[0]==1)
     {
      tp_price=latest_price.ask+tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      sl_price=latest_price.ask-sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,base_lots,latest_price.ask,sl_price,tp_price);
     }
   else if(value_signal[0]==-1)
     {
      tp_price=latest_price.bid-tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      sl_price=latest_price.bid+sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,base_lots,latest_price.bid,sl_price,tp_price);
     }
  }
//+------------------------------------------------------------------+
