//+------------------------------------------------------------------+
//|                                              FibonacciZigZag.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OpenSignal
  {
   OPEN_SIGNAL_BUY=0,
   OPEN_SIGNAL_SELL=1,
   OPEN_SIGNAL_NULL=2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFibonacciZigZag:public CStrategy
  {
private:
   int               num_zigzag;   //用于计算的zigzag非0的个数
   double            fibo_open;    // fibo的回调入场的比例
   double            fibo_tp;    // fibo的止盈比例
   double            fibo_sl;    // fibo的止损比例
   double            order_lots; // 手数

   int               handle_zigzag;   // zigzag句柄
   double            extreme_value[];  // 存放非0的zigzag数值
   OpenSignal        signal;  // 模式对应的买卖信号
   double            open_price; // 开仓的触发价格
   double            tp_price;  // 止盈价格
   double            sl_price;  // 止损价格
   MqlTick           latest_price; // 最新的tick报价
   double            max_price;
   double            min_price;
   double            pre_max_price;
   double            pre_min_price;

public:
                     CFibonacciZigZag(void);
                     CFibonacciZigZag(double ratio_open, double ratio_tp, double ratio_sl, double open_lots);
                    ~CFibonacciZigZag(void){};
protected:
   virtual void      OnEvent(const MarketEvent &event);
private:
   void              GetZigZagValues();  // 取zigzag的非0值
   void              PatternRecognize();  // 模式识别
   void              CalPriceLevel();  // 计算对应的价格水平：开仓，tp,sl
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFibonacciZigZag::CFibonacciZigZag(void)
  {
   num_zigzag=3;
   fibo_open=0.618;
   fibo_tp=0.882;
   fibo_sl=0;
   order_lots=0.01;
   ArrayResize(extreme_value,num_zigzag);
   handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag",60,5,3);
  }
CFibonacciZigZag::CFibonacciZigZag(double ratio_open,double ratio_tp,double ratio_sl,double open_lots)
   {
   num_zigzag=3;
   fibo_open=ratio_open;
   fibo_tp=ratio_tp;
   fibo_sl=ratio_sl;
   order_lots=open_lots;
   ArrayResize(extreme_value,num_zigzag);
   handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag");
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciZigZag::GetZigZagValues(void)
  {
//复制zigzag指标数值--并取得极值点
   double zigzag_value[1200];
   int counter=0;
   CopyBuffer(handle_zigzag,0,0,1200,zigzag_value);
   for(int i=ArraySize(zigzag_value)-2;i>=0;i--)
     {
      if(zigzag_value[i]==0) continue;//过滤为0的值
      if(counter==num_zigzag) break;//极值数量达到给定的值不再取值
      counter++;
      extreme_value[counter-1]=zigzag_value[i];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CFibonacciZigZag::PatternRecognize(void)
  {
   //if(extreme_value[0]-extreme_value[1]>0)
   //  {
   //   signal=OPEN_SIGNAL_BUY;
   //   open_price=extreme_value[1]+(extreme_value[0]-extreme_value[1])*fibo_open;
   //   tp_price = extreme_value[1] + (extreme_value[0]-extreme_value[1])*fibo_tp;
   //   sl_price = extreme_value[1] + (extreme_value[0]-extreme_value[1])*fibo_sl;
   //   return;
   //  }
   //if(extreme_value[1]-extreme_value[0]>0)
   //  {
   //   signal=OPEN_SIGNAL_SELL;
   //   open_price=extreme_value[1]-(extreme_value[1]-extreme_value[0])*fibo_open;
   //   tp_price = extreme_value[1] - (extreme_value[1]-extreme_value[0])*fibo_tp;
   //   sl_price = extreme_value[1] - (extreme_value[1]-extreme_value[0])*fibo_sl;
   //   return;
   //  }
   //signal=OPEN_SIGNAL_NULL;
   int imax = ArrayMaximum(extreme_value);
   int imin = ArrayMinimum(extreme_value);
   max_price = extreme_value[imax];
   min_price = extreme_value[imin];
   if(imax<imin)
     {
      signal=OPEN_SIGNAL_BUY;
      open_price=min_price+(max_price-min_price)*fibo_open;
      tp_price =min_price + (max_price-min_price)*fibo_tp;
      sl_price = min_price + (max_price-min_price)*fibo_sl;
      return;
     }
   if(imin<imax)
     {
      signal=OPEN_SIGNAL_SELL;
      open_price=max_price-(max_price-min_price)*fibo_open;
      tp_price = max_price - (max_price-min_price)*fibo_tp;
      sl_price = max_price - (max_price-min_price)*fibo_sl;
      return;
     }
   signal=OPEN_SIGNAL_NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciZigZag::OnEvent(const MarketEvent &event)
  {
//新BAR形成且空仓需要进行模式识别
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      GetZigZagValues();   // 取zigzag非0值
      PatternRecognize();  // 进行模式识别
     }
//tick事件发生时，对应的处理
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      if(max_price==pre_max_price&&min_price==pre_min_price) return;
      if(signal==OPEN_SIGNAL_BUY && latest_price.ask<open_price)
        {
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY, order_lots,latest_price.ask,sl_price,tp_price)) return;
         pre_max_price = max_price;
         pre_min_price = min_price;
        }
      if(signal==OPEN_SIGNAL_SELL && latest_price.bid>open_price)
        {
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL, order_lots,latest_price.bid,sl_price,tp_price)) return;
         pre_max_price = max_price;
         pre_min_price = min_price;
        }
     }
  }
//+------------------------------------------------------------------+
