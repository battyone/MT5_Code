//+------------------------------------------------------------------+
//|                                           ShortHighLowPoints.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "短期高低点识别"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 4
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_width1 2
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_width2 2
#property indicator_type3 DRAW_ARROW
#property indicator_color3 clrYellow
#property indicator_width3 2
#property indicator_type4 DRAW_ARROW
#property indicator_color4 clrOrangeRed
#property indicator_width4 2

double HighPrice[];
double LowPrice[];
double PLine[];
double ALine[];
double Signal[];

datetime last_time=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,HighPrice,INDICATOR_DATA);
   SetIndexBuffer(1,LowPrice,INDICATOR_DATA);
   SetIndexBuffer(2,PLine,INDICATOR_DATA);
   SetIndexBuffer(3,ALine,INDICATOR_DATA);
   SetIndexBuffer(4,Signal,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0,PLOT_ARROW,221);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"短期高点");
   PlotIndexSetInteger(1,PLOT_ARROW,222);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(1,PLOT_LABEL,"短期低点");
   PlotIndexSetInteger(2,PLOT_ARROW,116);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(2,PLOT_LABEL,"孕线");
   PlotIndexSetInteger(3,PLOT_ARROW,116);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(3,PLOT_LABEL,"包线");

   ArraySetAsSeries(HighPrice,true);
   ArraySetAsSeries(LowPrice,true);
   ArraySetAsSeries(Signal,true);
   ArraySetAsSeries(PLine,true);
   ArraySetAsSeries(ALine,true);

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
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   
   int num_bar_check=3;
   if(rates_total<num_bar_check) return 0;

   if(last_time==time[0]) return rates_total; // 没有产生新BAR，不进行指标计算
   last_time=time[0];
   
   int num_handle;
   if(prev_calculated<num_bar_check) num_handle=rates_total-num_bar_check;
   else num_handle=rates_total-prev_calculated;
   
   for(int i=num_handle+1;i>1;i--)
     {
      HighPrice[i]=EMPTY_VALUE;
      LowPrice[i]=EMPTY_VALUE;
      PLine[i]=EMPTY_VALUE;
      ALine[i]=EMPTY_VALUE;
      Signal[i]=0;
                                                                      
      if(high[i]>high[i+1] && high[i]>high[i-1] && low[i]>low[i+1]) // 价格突破给定范围内的最高价
        {
         HighPrice[i]=high[i];
         Signal[i]=1;
        }
      else if(low[i]<low[i+1] && low[i]<low[i-1] && high[i]<high[i+1]) // 价格突破给定范围内的最低价
        {
         LowPrice[i]=low[i];
         Signal[i]=-1;
        }
      else if(high[i]>high[i+1] && low[i]<low[i+1])
             {
              //ALine[i]=high[i];
             }
      else if(high[i]<high[i+1] && low[i]>low[i+1])
             {
              //PLine[i]=low[i];
             }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }