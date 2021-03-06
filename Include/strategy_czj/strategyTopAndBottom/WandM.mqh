//+------------------------------------------------------------------+
//|                                                        WandM.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>

enum OpenSignal
  {
   OPEN_SIGNAL_BUY=0,
   OPEN_SIGNAL_SELL=1,
   OPEN_SIGNAL_NULL=2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CWM:public CStrategy
  {
private:
   int               handle_zigzag;
   MqlTick           latest_price;
   double            extreme_value[];
   int               num_zigzag;
   double            open_price;
   double            tp_price;
   double            sl_price;
   OpenSignal        signal;
   double            order_lots;
   double e0;
   double e1;
   double e2;
   double e3;
public:
                     CWM(void);
                    ~CWM(void){};
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              GetZigZagValues();  // 取zigzag的非0值
   void              PatternRecognize();  // 模式识别

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CWM::CWM(void)
  {
   handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag");
   num_zigzag=5;
   order_lots=0.01;
   ArrayResize(extreme_value,num_zigzag);
   signal = OPEN_SIGNAL_NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWM::GetZigZagValues(void)
  {
//复制zigzag指标数值--并取得极值点
   double zigzag_value[120];
   int counter=0;
   CopyBuffer(handle_zigzag,0,0,120,zigzag_value);
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
void CWM::PatternRecognize(void)
  {
   if(extreme_value[3]>extreme_value[1]&&extreme_value[1]>extreme_value[2]&&extreme_value[2]>extreme_value[4])
     {
      signal = OPEN_SIGNAL_SELL;
      //open_price = extreme_value[2];
      open_price = (extreme_value[1]+extreme_value[2])/2;
      //tp_price = extreme_value[4];
      //tp_price = extreme_value[4];
      tp_price =  (extreme_value[2]+extreme_value[4])/2;
      //tp_price = extreme_value[3]-0.618*(extreme_value[3]-extreme_value[4]);
      //sl_price = extreme_value[3];
      sl_price = extreme_value[1];
      //sl_price = (extreme_value[1]+extreme_value[3])/2;
      return;
     }
    if(extreme_value[3]<extreme_value[1]&&extreme_value[1]<extreme_value[2]&&extreme_value[2]<extreme_value[4])
      {
       signal = OPEN_SIGNAL_BUY;
       //open_price = extreme_value[2];
       open_price = (extreme_value[1]+extreme_value[2])/2;
       //tp_price = extreme_value[4];
       tp_price =  (extreme_value[2]+extreme_value[4])/2;
       //tp_price = extreme_value[3]+0.618*(extreme_value[4]-extreme_value[3]);
       //sl_price = extreme_value[3];
       sl_price = extreme_value[1];
       //sl_price = (extreme_value[1]+extreme_value[3])/2;
       return;
      }
     signal = OPEN_SIGNAL_NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWM::OnEvent(const MarketEvent &event)
  {
//新BAR形成且空仓需要进行模式识别
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      GetZigZagValues();   // 取zigzag非0值
      PatternRecognize();  // 进行模式识别
     }
//tick事件发生时，对应的处理
   if(e0==extreme_value[1]&&e1==extreme_value[2]&&e2==extreme_value[3]&&e3==extreme_value[4]) return;
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      if(signal==OPEN_SIGNAL_BUY && latest_price.ask>open_price)
        {
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY, order_lots,latest_price.ask,sl_price,tp_price)) return;
         e0=extreme_value[1];
         e1=extreme_value[2];
         e2=extreme_value[3];
         e3=extreme_value[4];
         
        }
      if(signal==OPEN_SIGNAL_SELL && latest_price.bid<open_price)
        {
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL, order_lots,latest_price.bid,sl_price,tp_price)) return;
          e0=extreme_value[1];
         e1=extreme_value[2];
         e2=extreme_value[3];
         e3=extreme_value[4];
         
        }
     }
  }
//+------------------------------------------------------------------+
