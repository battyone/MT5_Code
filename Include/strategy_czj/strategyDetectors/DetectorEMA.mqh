//+------------------------------------------------------------------+
//|                                                  DetectorEMA.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "DetectorBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDetectorEMA:public CDetectorBase
  {
protected:
   int               h_w_long[];
   int               h_w_short[];
   int               h_ema_close[];
   int               h_ema_high[];
   int               h_ema_low[];
   double            buffer_w_long[];
   double            buffer_w_short[];
   double            buffer_ema_close[];
   double            buffer_ema_high[];
   double            buffer_ema_low[];
public:
                     CDetectorEMA(void){};
                    ~CDetectorEMA(void){};
   void              InitHandles(int ema_close_period=50,int ema_high_period=150,int ema_low_period=150,int w_long_period=100,int w_short_period=10);
protected:
   virtual void      SignalCheckAndOperateAt(int h_index,int s_index,int p_index);  // 对指定索引进行指标信号的相关的处理                        
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorEMA::InitHandles(int ema_close_period=50,int ema_high_period=150,int ema_low_period=150,int w_long_period=100,int w_short_period=10)
  {
   ArrayResize(h_ema_close,num_p*num_s);
   ArrayResize(h_ema_high,num_p*num_s);
   ArrayResize(h_ema_low,num_p*num_s);
   ArrayResize(h_w_long,num_p*num_s);
   ArrayResize(h_w_short,num_p*num_s);
   
   for(int i=0;i<num_s;i++)
     {
      for(int j=0;j<num_p;j++)
        {
         int index=i*num_p+j;
         h_ema_close[index]=iMA(symbols[i],periods[j],ema_close_period,0,MODE_EMA,PRICE_CLOSE);
         h_ema_high[index]=iMA(symbols[i],periods[j],ema_high_period,0,MODE_EMA,PRICE_HIGH);
         h_ema_low[index]=iMA(symbols[i],periods[j],ema_low_period,0,MODE_EMA,PRICE_LOW);
         h_w_long[index]=iWPR(symbols[i],periods[j],w_long_period);
         h_w_short[index]=iWPR(symbols[i],periods[j],w_short_period);
         AddBarOpenEvent(symbols[i],periods[j]);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorEMA::SignalCheckAndOperateAt(int h_index,int s_index,int p_index)
  {
   CopyBuffer(h_w_long[h_index],0,0,10,buffer_w_long);
   CopyBuffer(h_w_short[h_index],0,0,10,buffer_w_short);
   CopyBuffer(h_ema_close[h_index],0,0,10,buffer_ema_close);
   CopyBuffer(h_ema_high[h_index],0,0,10,buffer_ema_high);
   CopyBuffer(h_ema_low[h_index],0,0,10,buffer_ema_low);
   if(buffer_ema_close[9]>buffer_ema_high[9] && buffer_w_long[9]>-20 && buffer_w_short[9]<-80)
     {
      msg=symbols[s_index]+" On "+EnumToString(periods[p_index])+" EMA3+William to buy,China Time:"+TimeToString(TimeLocal())+" Current Price:"+DoubleToString(latest_price.bid,Digits());
      SendMsg(msg);
     }
   else if(buffer_ema_close[9]<buffer_ema_low[9] && buffer_w_long[9]<-80 && buffer_w_short[9]>-20)
     {
      msg=symbols[s_index]+" On "+EnumToString(periods[p_index])+" EMA3+William to sell,China Time:"+TimeToString(TimeLocal())+" Current Price:"+DoubleToString(latest_price.ask,Digits());
      SendMsg(msg);
     }
  }
//+------------------------------------------------------------------+
