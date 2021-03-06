//+------------------------------------------------------------------+
//|                                                   ZigZagBase.mqh |
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
class CZigZag:public CStrategy
  {
protected:
   int               handle_zigzag;
   int               num_zigzag;
   double            extreme_value[];
   double            pre_extreme_value[];
   double            open_price;
   double            tp_price;
   double            sl_price;
   OpenSignal        signal;
   MqlTick           latest_price;
   double            order_lots;
   string comment;

public:
                     CZigZag(void);
                    ~CZigZag(void){};
private:
   void              GetZigZagValues();  // 取zigzag的非0值
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      BarEventHandle(){};
   virtual void      TickEventHandle(){};
   virtual void      PatternRecognize(){}; // 给出买卖信号，open_price（用于突破的价格）, tp_price, sl_price
   virtual bool      IsUsedMode();
   virtual void      PositionOpenEventHandle();
   virtual bool      BuyCondition();
   virtual bool      SellCondition();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CZigZag::CZigZag(void)
  {
   handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag");
   num_zigzag=10;
   signal=OPEN_SIGNAL_NULL;
   ArrayResize(extreme_value,num_zigzag);
   ArrayResize(pre_extreme_value,num_zigzag);
   order_lots=0.01;
   comment="";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZigZag::GetZigZagValues(void)
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
void CZigZag::PositionOpenEventHandle(void)
  {
   ArrayCopy(pre_extreme_value,extreme_value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CZigZag::IsUsedMode(void)
  {
   for(int i=0;i<num_zigzag;i++)
     {
      if(extreme_value[i]!=pre_extreme_value[i]) return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CZigZag::BuyCondition(void)
  {
   if(signal==OPEN_SIGNAL_BUY && latest_price.ask>open_price&&latest_price.ask>sl_price&&latest_price.ask<tp_price) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CZigZag::SellCondition(void)
  {
   if(signal==OPEN_SIGNAL_SELL && latest_price.bid<open_price&&latest_price.bid<sl_price&&latest_price.bid>tp_price) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZigZag::OnEvent(const MarketEvent &event)
  {
//新BAR形成且空仓需要进行模式识别
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      //Print("Bar Event");
      BarEventHandle();
      GetZigZagValues();   // 取zigzag非0值
      PatternRecognize();  // 进行模式识别
     }
//tick事件发生时，对应的处理
   if(IsUsedMode()) return;   // 已经使用过当前模式开仓的不再开仓
   if(event.type==MARKET_EVENT_TICK && event.symbol==ExpertSymbol())
     {
      TickEventHandle();
      SymbolInfoTick(ExpertSymbol(),latest_price);
      if(BuyCondition())
        {
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY, order_lots,latest_price.ask,sl_price,tp_price,comment)) return;
         PositionOpenEventHandle();
        }
      if(SellCondition())
        {
         if(!Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL, order_lots,latest_price.bid,sl_price,tp_price,comment)) return;
         PositionOpenEventHandle();
        }
     }
  }
//+------------------------------------------------------------------+
