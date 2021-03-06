//+------------------------------------------------------------------+
//|                                      FibonacciZigZagDoubleMA.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <strategy_czj\strategyZigZag\ZigZagBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFibonacciZigZagDoubleMA:public CZigZag
  {
private:
   double            fibo_open;
   double            fibo_tp;
   double            fibo_sl;
   int               handle_ma_long;
   int               handle_ma_short;
   double            ma_long[];
   double            ma_short[];

   double            max_price;
   double            min_price;
   double            pre_max_price;
   double            pre_min_price;
public:
                     CFibonacciZigZagDoubleMA(void);
                    ~CFibonacciZigZagDoubleMA(void){};
protected:
   virtual void      PatternRecognize(); // 给出买卖信号，open_price（用于突破的价格）, tp_price, sl_price
   virtual void      BarEventHandle();
   virtual bool      IsUsedMode();
   virtual void      PositionOpenEventHandle();
   virtual bool      BuyCondition();
   virtual bool      SellCondition();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFibonacciZigZagDoubleMA::CFibonacciZigZagDoubleMA(void)
  {
   handle_ma_long=iMA(ExpertSymbol(),Timeframe(),200,0,MODE_SMA,PRICE_CLOSE);
   handle_ma_short=iMA(ExpertSymbol(),Timeframe(),24,0,MODE_SMA,PRICE_CLOSE);
   fibo_open=0.618;
   fibo_tp=1.0;
   fibo_sl=-0.618;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciZigZagDoubleMA::BarEventHandle(void)
  {
   CopyBuffer(handle_ma_long,0,0,1,ma_long);
   CopyBuffer(handle_ma_short,0,0,1,ma_short);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciZigZagDoubleMA::PositionOpenEventHandle(void)
  {
   pre_max_price=max_price;
   pre_min_price= min_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFibonacciZigZagDoubleMA::IsUsedMode(void)
  {
   if(pre_max_price==max_price&&pre_min_price==min_price) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciZigZagDoubleMA::PatternRecognize(void)
  {
   int imax = ArrayMaximum(extreme_value,0,2);
   int imin = ArrayMinimum(extreme_value,0,2);
   max_price = extreme_value[imax];
   min_price = extreme_value[imin];
   signal=OPEN_SIGNAL_NULL;
   if(ma_short[0]>ma_long[0])//短均线位于长均线上方
     {
      if(imax<imin)
        {
         signal=OPEN_SIGNAL_BUY;
         open_price=min_price+(max_price-min_price)*0.5;
         tp_price =min_price + (max_price-min_price)*0.882;
         sl_price = min_price + (max_price-min_price)*(-0.618);
         return;
        }
       if(imax>imin)
         {
          signal=OPEN_SIGNAL_SELL;
          open_price=max_price-(max_price-min_price)*0.382;
          tp_price = max_price - (max_price-min_price)*0.5;
          sl_price = max_price - (max_price-min_price)*(-0.618);
          return;
         }
     }
   if(ma_short[0]<ma_long[0])// 短均线位于长均线下方
     {
      if(imin<imax)
        {
         signal=OPEN_SIGNAL_SELL;
         open_price=max_price-(max_price-min_price)*0.5;
         tp_price = max_price - (max_price-min_price)*0.882;
         sl_price = max_price - (max_price-min_price)*(-0.618);
         return;
        }
      if(imin>imax)
         {
          signal=OPEN_SIGNAL_BUY;
         open_price=min_price+(max_price-min_price)*0.382;
         tp_price =min_price + (max_price-min_price)*0.5;
         sl_price = min_price + (max_price-min_price)*(-0.618);
         return;
         }
     }
  }
bool CFibonacciZigZagDoubleMA::BuyCondition(void)
   {
    if(signal==OPEN_SIGNAL_BUY&&latest_price.ask<open_price) return true;
    return false;
   }
bool CFibonacciZigZagDoubleMA::SellCondition(void)
   {
    if(signal==OPEN_SIGNAL_SELL&&latest_price.bid>open_price) return true;
    return false;
   
   }
//+------------------------------------------------------------------+
