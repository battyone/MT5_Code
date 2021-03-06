//+------------------------------------------------------------------+
//|                                               MABreakPoints2.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "均线拐点检测2"
#property description "    当前价格高于过去固定bar数的最高价--拐点买"
#property description "    当前价格低于过去固定bar数的最低价--拐点卖"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_width1 2
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_width2 2

input int InpLastBarNum=24;

double BuyPrice[];
double SellPrice[];
double Signal[];

datetime last_time=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BuyPrice,INDICATOR_DATA);
   SetIndexBuffer(1,SellPrice,INDICATOR_DATA);
   SetIndexBuffer(2,Signal,INDICATOR_CALCULATIONS);
   
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"拐点检测2--Buy");
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(1,PLOT_LABEL,"拐点检测2--Sell");
   
   ArraySetAsSeries(BuyPrice,true);
   ArraySetAsSeries(SellPrice,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   
   int num_bar_check=InpLastBarNum+1;
   if(rates_total<num_bar_check) return 0;
   
   if(last_time==time[0]) return rates_total; // 没有产生新BAR，不进行指标计算
   last_time=time[0]; 
   
   int num_handle;
   if(prev_calculated<num_bar_check) num_handle=rates_total-num_bar_check;
   else num_handle=rates_total-prev_calculated;
   
   for(int i=num_handle;i>=0;i--)
     {
      BuyPrice[i]=EMPTY_VALUE;
      SellPrice[i]=EMPTY_VALUE;
      int imax=ArrayMaximum(high,i+2,InpLastBarNum);
      int imin=ArrayMinimum(low,i+2,InpLastBarNum);
      if(high[i+1]>=high[imax])
        {
         BuyPrice[i]=open[i];
        }
      else if(low[i+1]<=low[imin])
         {
          SellPrice[i]=open[i];
         }
      
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
