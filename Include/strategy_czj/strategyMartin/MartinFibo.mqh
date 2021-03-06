//+------------------------------------------------------------------+
//|                                                    MartinRSI.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "MartinBase.mqh"
enum FiboState
  {
   FIBO_STATE_NULL,
   FIBO_STATE_BUY,
   FIBO_STATE_SELL
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMartinFibo:public CMartinBase
  {
private:
   int               num_pattern_recognize; //模式识别需要的周期
   int               num_pattern_max;//模式允许的最大周期
   int               point_range;//模式允许的最小的趋势长度
   double            open_ratio;   // Fibo回调的开仓比例
   double            tp_ratio;  // Fibo的止盈比例
   double            sl_ratio;  // Fibo的止损比例
   
   double            open_price;   // 开仓价格
   double            tp_price;  // 止盈价格
   double            sl_price;  // 止损价格
   double            max_price;// 模式最大值
   double            min_price; // 模式最小值
   FiboState         fi_state;
protected:
   virtual void      TickEventHandle();
   virtual void      BarEventHandle();
public:
                     CMartinFibo(void);
                    ~CMartinFibo(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMartinFibo::CMartinFibo(void)
  {
   num_pattern_recognize=12;
   num_pattern_max=4;
   point_range=500;
   open_ratio=0.382;
   tp_ratio=0.882;
   sl_ratio=-0.2;
  }
void CMartinFibo::BarEventHandle(void)
   {
    //计算最高最低价及对应的位置
      double high[],low[];
      int max_loc,min_loc;
      ArrayResize(high,num_pattern_recognize);
      ArrayResize(low,num_pattern_recognize);
      CopyHigh(ExpertSymbol(),Timeframe(),0,num_pattern_recognize,high);
      CopyLow(ExpertSymbol(),Timeframe(),0,num_pattern_recognize,low);
      max_loc=ArrayMaximum(high);
      min_loc=ArrayMinimum(low);
      max_price=high[max_loc];
      min_price=low[min_loc];
      if(max_price-min_price>=point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && max_price-min_price<=5*point_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT) && MathAbs(max_loc-min_loc)<=num_pattern_max)
        {
         if(max_loc>min_loc)
           {
            fi_state=FIBO_STATE_BUY;
            open_price=open_ratio*(max_price-min_price)+min_price;
            tp_price=NormalizeDouble(tp_ratio*(max_price-min_price)+min_price,SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
            sl_price=NormalizeDouble(sl_ratio*(max_price-min_price)+min_price,SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
           }
         if(max_loc<min_loc)
           {
            fi_state=FIBO_STATE_SELL;
            open_price=max_price-open_ratio*(max_price-min_price);
            tp_price=NormalizeDouble(max_price-tp_ratio*(max_price-min_price),SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
            sl_price=NormalizeDouble(max_price-sl_ratio*(max_price-min_price),SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS));
           }
        }
      else fi_state=FIBO_STATE_NULL;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMartinFibo::TickEventHandle(void)
  {
   
   
   if(latest_price.bid>open_price&&fi_state==FIBO_STATE_SELL)
     {
      signal=OPEN_SIGNAL_SELL;
     }
   else if(latest_price.ask<open_price&&fi_state==FIBO_STATE_BUY)
     {
      signal=OPEN_SIGNAL_BUY;
     }
   else
     {
      signal=OPEN_SIGNAL_NULL;
     }
     
   if(positions.open_total>0)
     {
      CPosition *pos=ActivePositions.At(0);
      if(pos.Profit()/pos.Volume()>200)
        {
         //pos.CloseAtMarket("TP");
         Trade.PositionClose(pos.ID());
         num_failed=0;
        }
      else if(pos.Profit()/pos.Volume()<-200)
        {
         Trade.PositionClose(pos.ID());
         //pos.CloseAtMarket("SL");
         num_failed++;
        }
     }
  }
//+------------------------------------------------------------------+
