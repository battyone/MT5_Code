//+------------------------------------------------------------------+
//|                                                       PinBar.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "C opyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPinBarStrategy:public CStrategy
  {
protected:
   int               handle_pinbar; // pinbar指标句柄
   int               handle_ma_long;   // 长均线指标句柄
   int               handle_ma_short;  // 短均线指标句柄
   int               handle_rsi; // RSI指标句柄
   double            base_lots;  // 基本手数
   double            tp_conservated;
   double            sl_conservated;
   double            tp_radical;
   double            sl_radical;
   double            fibo_radical;

   
   double            open_lots;  // 开仓手数
   double            open_price; // 开仓价格
   double            tp_price;   // 止盈价格
   double            sl_price;   // 止损价格
   double            signal[3];// 开仓信号：-1 卖； 0 不操作； 1 买
   double            point_range[3];   // 趋势长度
   double            ma_long[3]; // 长均线值
   double            ma_short[3];   // 短均线值
   double            rsi[3];  // RSI值
   double            open[3]; 
   double            close[3];
   double            high[3];
   double            low[3];

   bool              is_new_bar; // 是否是未处理过(开仓)的bar
   MqlTick           latest_price;  // 最近的tick报价
public:
                     CPinBarStrategy(void);
                    ~CPinBarStrategy(void){};
                    void SetHandleParameters(int period_ma_long=200, int period_ma_short=24, int perid_rsi=12);
                    void SetPositionParameters(double lots_base=0.01, double fibo_tp_conservated=1.618, double fibo_sl_conservated=2.618, double fibo_tp_radical=0.618, double fibo_sl_radical=1.618);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CalPrices(); // 计算signal,open_price, tp_price, sl_price
private:
   void              CalPriceMode1();
   void              CalPriceMode2();
   void              CalPriceMode3();
   void              CalPriceMode4();
   void              CalPriceMode5();
   void              CalPriceMode6();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPinBarStrategy::CPinBarStrategy(void)
  {
   //handle_pinbar=iCustom(ExpertSymbol(),Timeframe(),"PinbarDetector");
   //handle_ma_long=iMA(ExpertSymbol(),Timeframe(),200,0,MODE_SMA,PRICE_CLOSE);
   //handle_ma_short=iMA(ExpertSymbol(),Timeframe(),24,0,MODE_SMA,PRICE_CLOSE);
   //handle_rsi=iRSI(ExpertSymbol(),Timeframe(),12,PRICE_CLOSE);
   //base_lots=0.01;
  }
CPinBarStrategy::SetHandleParameters(int period_ma_long,int period_ma_short,int perid_rsi)
   {
    handle_pinbar=iCustom(ExpertSymbol(),Timeframe(),"PinbarDetector");
   handle_ma_long=iMA(ExpertSymbol(),Timeframe(),period_ma_long,0,MODE_SMA,PRICE_CLOSE);
   handle_ma_short=iMA(ExpertSymbol(),Timeframe(),period_ma_short,0,MODE_SMA,PRICE_CLOSE);
   handle_rsi=iRSI(ExpertSymbol(),Timeframe(),perid_rsi,PRICE_CLOSE);
   }
CPinBarStrategy::SetPositionParameters(double lots_base=0.010000,double fibo_tp_conservated=1.618000,double fibo_sl_conservated=2.618000,double fibo_tp_radical=0.618000,double fibo_sl_radical=1.618000)
   {
    base_lots=lots_base;
    tp_conservated=fibo_tp_conservated;
    tp_radical=fibo_tp_radical;
    sl_conservated=fibo_sl_conservated;
    sl_radical=fibo_sl_radical;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPinBarStrategy::OnEvent(const MarketEvent &event)
  {
// 品种的tick事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CalPrices();
      if(signal[1]==1 && is_new_bar && latest_price.ask>open_price)//buy
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,latest_price.ask,sl_price,tp_price,ExpertNameFull());
         is_new_bar=false;
        }
      else if(signal[1]==-1 && is_new_bar && latest_price.bid<open_price)//sell
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,latest_price.bid,sl_price,tp_price,ExpertNameFull());
         is_new_bar=false;
        }
     }
//---品种的BAR事件发生时候的处理
   if(event.symbol==ExpertSymbol() && event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      is_new_bar=true;
      CopyBuffer(handle_pinbar,2,0,3,signal);
      CopyBuffer(handle_pinbar,3,0,3,point_range);
      CopyBuffer(handle_ma_long,0,0,3,ma_long);
      CopyBuffer(handle_ma_short,0,0,3,ma_short);
      CopyBuffer(handle_rsi,0,0,3,rsi);
      CopyOpen(_Symbol,_Period,0,3,open);
      CopyHigh(_Symbol,_Period,0,3,high);
      CopyLow(_Symbol,_Period,0,3,low);
      CopyClose(_Symbol,_Period,0,3,close);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPinBarStrategy::CalPrices(void)
  {
//CalPriceMode1();
//CalPriceMode2();
  //CalPriceMode3();
   //CalPriceMode4();
   //CalPriceMode5();//ok
   CalPriceMode6();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPinBarStrategy::CalPriceMode1(void)
  {
   if(signal[1]==1.0) // buy
     {
      open_price=high[1];
      sl_price=low[1];
      tp_price=open[0];
     }
   else if(signal[1]==-1.0)// sell
     {
      open_price=low[1];
      sl_price=high[1];
      tp_price=open[0];
     }
    open_lots=0.01;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPinBarStrategy::CalPriceMode2(void)
  {
   if(signal[1]==1.0) // buy
     {
      open_price=high[1];
      sl_price=open_price-2000*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      tp_price=open_price+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
     }
   else if(signal[1]==-1.0)// sell
     {
      open_price=low[1];
      sl_price=open_price+2000*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      tp_price=open_price-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
     }
   open_lots=0.01;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CPinBarStrategy::CalPriceMode3(void)
  {
   if(signal[1]==1.0) // buy
     {
      
      open_price=high[1];
      sl_price=open_price-1.618*point_range[1];
      tp_price=open_price+0.618*point_range[1];
     }
   else if(signal[1]==-1.0)// sell
     {
      
      open_price=low[1];
      sl_price=open_price+1.618*point_range[1];
      tp_price=open_price-0.618*point_range[1];
     }
    open_lots=0.01;
  }
void  CPinBarStrategy::CalPriceMode4(void)
  {
   if(signal[1]==1.0) // buy
     {
      open_price=high[1];
      sl_price=low[1]-0.2*point_range[1];
      tp_price=low[1]+1.618*point_range[1];
     }
   else if(signal[1]==-1.0)// sell
     {
      open_price=low[1];
      sl_price=high[1]+0.2*point_range[1];
      tp_price=high[1]-1.618*point_range[1];
     }
    open_lots=0.01;
  }
void CPinBarStrategy::CalPriceMode5(void)
   {
    if(signal[1]==1.0) // buy
     {
      open_price=high[1];
      if(ma_short[1]>ma_long[1])
        {
         sl_price=low[1]-sl_conservated*point_range[1];
         tp_price=low[1]+tp_conservated*point_range[1];
         open_lots=2*base_lots;
        }
      else
        {
         sl_price=low[1]-sl_radical*point_range[1];
         tp_price=low[1]+tp_radical*point_range[1];
         open_lots=base_lots;
        }
      
     }
   else if(signal[1]==-1.0)// sell
     {
      open_price=low[1];
      if(ma_short[1]<ma_long[1])
        {
         sl_price=high[1]+sl_conservated*point_range[1];
         tp_price=high[1]-tp_conservated*point_range[1];
         open_lots=2*base_lots;
        }
      else
        {
         sl_price=high[1]+sl_radical*point_range[1];
         tp_price=high[1]-tp_radical*point_range[1];
         open_lots=base_lots;
        }
      
     }
   }
void CPinBarStrategy::CalPriceMode6(void)
   {
    double score=1;
    if(signal[1]==1.0) // buy
     {
      open_price=high[1];
      if(rsi[1]<=30) score++;
      if(ma_short[1]>ma_long[1])
        {
         sl_price=low[1]-sl_conservated*point_range[1];
         tp_price=low[1]+tp_conservated*point_range[1];
         //tp_price=MathMin(low[1]+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT),low[1]+tp_conservated*point_range[1]);
         score++;
        }
      else
        {
         sl_price=low[1]-sl_radical*point_range[1];
         tp_price=low[1]+tp_radical*point_range[1];
         //tp_price=MathMin(low[1]+tp_radical*point_range[1],low[1]+500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT));
        }
     }
   else if(signal[1]==-1.0)// sell
     {
      open_price=low[1];
      if(rsi[1]>=70) score++;
      if(ma_short[1]<ma_long[1])
        {
         sl_price=high[1]+sl_conservated*point_range[1];
         tp_price=high[1]-tp_conservated*point_range[1];
         //tp_price=MathMax(high[1]-tp_conservated*point_range[1],high[1]-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT));
         score++;
        }
      else
        {
         sl_price=high[1]+sl_radical*point_range[1];
         //tp_price=MathMax(high[1]-tp_radical*point_range[1],high[1]-500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT));
         tp_price=high[1]-tp_radical*point_range[1];
        }
     }
    open_lots=score*base_lots;
   }
//+------------------------------------------------------------------+
