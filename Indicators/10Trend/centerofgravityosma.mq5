//+---------------------------------------------------------------------+
//|                                             CenterOfGravityOSMA.mq5 |
//|                         Copyright © 2007, MetaQuotes Software Corp. |
//|                                           http://www.metaquotes.net |
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---- indicator version number
#property version   "1.11"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- fifteen buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- drawing indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the four-colored histogram
#property indicator_color1 clrMagenta,clrViolet,clrGray,clrDodgerBlue,clrAqua
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is 2
#property indicator_width1 2
//---- displaying the indicator label
#property indicator_label1 "CenterOfGravityOSMA"
//+-----------------------------------+
//| Declaration of enumerations       |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input uint Period_=10; // Indicator averaging period
input uint SmoothPeriod1=3; // Signal line smoothing period
input ENUM_MA_METHOD MA_Method_1=MODE_SMA; // Signal line averaging method
input uint SmoothPeriod2=3; // Signal line smoothing period
input ENUM_MA_METHOD MA_Method_2=MODE_SMA; // Signal line averaging method
input Applied_price_ AppliedPrice=PRICE_CLOSE_;// Price constant
//+-----------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double ExtBuffer[];
double ColorExtBuffer[];
//---- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| iPriceSeries function description                                |
//| Описание класса Moving_Average                                   | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of constants
   min_rates_total=int(Period_+1+SmoothPeriod1+SmoothPeriod2+2);
//---- set MAMABuffer dynamic array as indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorExtBuffer,INDICATOR_COLOR_INDEX);
//---- initialization of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Center of Gravity OSMA(",Period_,")");
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determine the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);
//---- declaration of floating point variables  
   double price,sma,lwma,res1,res2,res3,diff;
//---- declaration of integer variables
   int first,bar,clr;
   static int startbar1,startbar2;
//---- initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      first=0; // starting index for calculation of all first loop bars
      startbar1=int(Period_+1);
      startbar2=startbar1+int(SmoothPeriod1);
     }
   else // starting number for calculation of new bars
     {
      first=prev_calculated-1;
     }
//---- Declaration of Moving_Average class variables
   static CMoving_Average MA,LWMA,SIGN,SMOOTH;
//---- main cycle of calculation of the channel center line
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- call of the PriceSeries function to get the Series input price
      price=PriceSeries(AppliedPrice,bar,open,low,high,close);
      //----
      sma=MA.MASeries(0,prev_calculated,rates_total,Period_,MODE_SMA,price,bar,false);
      lwma=LWMA.MASeries(0,prev_calculated,rates_total,Period_,MODE_LWMA,price,bar,false);
      //----
      res1=sma*lwma/_Point;
      res2=SIGN.MASeries(startbar1,prev_calculated,rates_total,SmoothPeriod1,MA_Method_1,res1,bar,false);
      res3=res1-res2;
      ExtBuffer[bar]=SMOOTH.MASeries(startbar2,prev_calculated,rates_total,SmoothPeriod2,MA_Method_2,res3,bar,false);
     }
//---
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      first=min_rates_total;
//---- main loop of the signal line coloring
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      clr=2;
      diff=ExtBuffer[bar]-ExtBuffer[bar-1];
//---
      if(ExtBuffer[bar]>0)
        {
         if(diff>0) clr=4;
         if(diff<0) clr=3;
        }
//---
      if(ExtBuffer[bar]<0)
        {
         if(diff<0) clr=0;
         if(diff>0) clr=1;
        }
//---
      ColorExtBuffer[bar]=clr;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
