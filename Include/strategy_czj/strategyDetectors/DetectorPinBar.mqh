//+------------------------------------------------------------------+
//|                                               DetectorPinBar.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "DetectorBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDetectorPinBar:public CDetectorBase
  {
public:
                     CDetectorPinBar(void){};
                    ~CDetectorPinBar(void){};
   void              InitHandles();
protected:
   virtual void      SignalCheckAndOperateAt(int h_index,int s_index,int p_index);  // 对指定索引进行指标信号的相关的处理                   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorPinBar::InitHandles()
  {
   ArrayResize(h_detector,num_p*num_s);
   for(int i=0;i<num_s;i++)
     {
      for(int j=0;j<num_p;j++)
        {
         int index=i*num_p+j;
         h_detector[index]=iCustom(symbols[i],periods[j],"CZJIndicators\\Detectors\\PinbarDetector");
         AddBarOpenEvent(symbols[i],periods[j]);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorPinBar::SignalCheckAndOperateAt(int h_index,int s_index,int p_index)
  {
   CopyBuffer(h_detector[h_index],2,0,2,h_signal);
   if(h_signal[0]==-1)
     {
      msg=symbols[s_index]+" on "+EnumToString(periods[p_index])+" PinBar to Sell,China Time:"+TimeToString(TimeLocal())+",Current Price:"+DoubleToString(latest_price.bid,Digits());
      SendMsg(msg);
     }
   else if(h_signal[0]==1)
     {
      msg=symbols[s_index]+" on "+EnumToString(periods[p_index])+" PinBar to Buy,China Time:"+TimeToString(TimeLocal())+",Current Price:"+DoubleToString(latest_price.ask,Digits());
      SendMsg(msg);
     }
  }  
//+------------------------------------------------------------------+
