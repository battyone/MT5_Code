//+------------------------------------------------------------------+
//|                                              PatternDetector.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#include <Pattern/Pattern.mqh>
//+----------------------------------------------+
//|  Parameters of drawing the bullish indicator      |
//+----------------------------------------------+
//---- Drawing the indicator as a label
#property indicator_type1   DRAW_ARROW
//---- Indicator line width
#property indicator_width1  1
//---- bullish indicator label display
#property indicator_label1  "Pattern signal"
//+----------------------------------------------+
//| Indicator input parameters     |
//+----------------------------------------------+
input TYPE_PATTERN      PatternType=1;                // Pattern type
input color             LabelColor=clrCrimson;
input double            LongCoef=1.3;
input double            ShortCoef=0.5;
input double            DojiCoef=0.04;
input double            MaribozuCoef=0.01;
input double            SpinCoef=1;
input double            HummerCoef1=0.1;
input double            HummerCoef2=2;
input int               TrendPeriod=5;
//---
CPattern Pat;
double Signal[];
//---- Declare integer variables for the data calculation start
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialize variables of data calculation start
   min_rates_total=TrendPeriod+2;
//---- Define the accuracy of indicator values to be displayed
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- Set SignUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,Signal,INDICATOR_DATA);
//---- Shift indicator 1 drawing start
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Set indexing of elements in buffers as in timeseries   
   ArraySetAsSeries(Signal,true);
//---- Set indicator values which will not be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- Indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,LabelColor);
//----
   Pat.Long_coef(LongCoef);
   Pat.Short_coef(ShortCoef);
   Pat.Doji_coef(DojiCoef);
   Pat.Maribozu_coef(MaribozuCoef);
   Pat.Spin_coef(SpinCoef);
   Pat.Hummer_coef1(HummerCoef1);
   Pat.Hummer_coef2(HummerCoef2);
   Pat.TrendPeriod(TrendPeriod);
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
//---- Check if there are enough bars for calculation
   if(rates_total<min_rates_total)
      return(0);
//---- Declare local variables 
   int limit,bar;
//---- Set indexing of elements in arrays as in timeseries  
   ArraySetAsSeries(low,true);
//---- Calculate the 'first' starting number for the bars recalculation cycle
   if(prev_calculated>rates_total || prev_calculated<=0)       // Check for the first indicator start
      limit=rates_total-min_rates_total;                       // Starting index for calculating all bars
   else
      limit=rates_total-prev_calculated;                       // Starting index for calculating new bars
//---- Main indicator calculation loop
   for(bar=limit; bar>0; bar--)
     {
      Signal[bar]=0.0;
      if(Pat.PatternType(_Symbol,_Period,PatternType,bar))
         Signal[bar]=low[bar]-200*_Point;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
