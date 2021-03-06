//+------------------------------------------------------------------+
//|                                              IndCandleDevour.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "蜡烛吞没形态检测器"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 1
#property indicator_type1 DRAW_COLOR_ARROW
#property indicator_color1 clrLime, clrRed
#property indicator_width1 2
input int  DisplayDistance=5; // DisplayDistance - the higher it is the the distance from faces to candles.

double UpDown[];
double Color[];
double support_position[];
double resistence_position[];
double signal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,UpDown,INDICATOR_DATA);
   SetIndexBuffer(1,Color,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,support_position,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,resistence_position,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,signal,INDICATOR_CALCULATIONS);


   PlotIndexSetInteger(0,PLOT_ARROW,74);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//PlotIndexSetString(0,PLOT_LABEL,"CandleDevour");
//PlotIndexSetString(3,PLOT_LABEL,"Support");
//PlotIndexSetString(4,PLOT_LABEL,"Resistence");

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
   int limit;
   if(prev_calculated<1) limit=1;
   else limit = prev_calculated-1;
   
   for(int i=limit;i<rates_total;i++)
        {
         if(i<10) UpDown[i]=EMPTY_VALUE;
         else
           {
            // bullish
            if(close[i-1]<open[i-1] && close[i]>high[i-1] && open[i]<close[i-1])
              {
               int iloc_max= ArrayMaximum(high,i-10,10);
               int iloc_min= ArrayMinimum(low,i-10,10);
               if(iloc_max<iloc_min)
                 {
                  UpDown[i]= high[i]+DisplayDistance * _Point;
                  Color[i] = 1;
                  resistence_position[i]=high[iloc_max];
                  support_position[i]=low[iloc_min];
                  signal[i]=1;
                  //PlotIndexSetString(0,PLOT_LABEL,"res/"+resistence_position[i]+" sup/"+support_position[i]);
                 }
              }
            // bearish
            if(close[i-1]>open[i-1] && close[i]<low[i-1] && open[i]>close[i-1])
              {
               int iloc_max=ArrayMaximum(high,i-10,10);
               int iloc_min=ArrayMinimum(low,i-10,10);
               if(iloc_max>iloc_min)
                 {
                  UpDown[i]=low[i]-DisplayDistance*_Point;
                  Color[i]=0;
                  resistence_position[i]=high[iloc_max];
                  support_position[i]=low[iloc_min];
                  signal[i]=-1;
                 }
              }
           }

        }
//--- return value of prev_calculated for next call

   return(rates_total);
  }

//+------------------------------------------------------------------+
