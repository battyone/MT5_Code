//+------------------------------------------------------------------+
//|                                              ZigZagLightning.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "ZigZagBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CZigZagLightning:public CZigZag
  {
private:
   int               handle_ma_long;
   int               handle_ma_short;
   double            ma_long[];
   double            ma_short[];
public:
                     CZigZagLightning(void);
                    ~CZigZagLightning(void){};
protected:
   virtual void      PatternRecognize(); // 给出买卖信号，open_price（用于突破的价格）, tp_price, sl_price
  };
CZigZagLightning::CZigZagLightning(void)
   {
   handle_ma_long=iMA(ExpertSymbol(),Timeframe(),200,0,MODE_SMA,PRICE_CLOSE);
   handle_ma_short=iMA(ExpertSymbol(),Timeframe(),24,0,MODE_SMA,PRICE_CLOSE);
   }
//+------------------------------------------------------------------+
void CZigZagLightning::PatternRecognize(void)
   {
    if((extreme_value[1]-extreme_value[0])/(extreme_value[1]-extreme_value[2])<0.618)
      {
       signal = OPEN_SIGNAL_NULL;
       return;
      }
    if(extreme_value[1]>extreme_value[2])
      {
       signal = OPEN_SIGNAL_BUY;
       //open_price = (extreme_value[0]+extreme_value[1])/2;
       open_price = extreme_value[0];
       tp_price = extreme_value[0]+0.5*(extreme_value[1]-extreme_value[2]);
       sl_price = extreme_value[2];
       //Print("Pattern Recognize: BUY SIGNAL", open_price,"/", tp_price, "/",sl_price);
       return;
      }
    if(extreme_value[1]<extreme_value[2])
      {
       signal = OPEN_SIGNAL_SELL;
       //open_price = (extreme_value[0]+extreme_value[1])/2;
       open_price = extreme_value[0];
       tp_price = extreme_value[0]-0.5*(extreme_value[2]-extreme_value[1]);
       sl_price = extreme_value[2];
       //Print("Pattern Recognize: SELL SIGNAL",open_price,"/", tp_price, "/",sl_price);
       return;
      }
     signal = OPEN_SIGNAL_NULL;
   }
