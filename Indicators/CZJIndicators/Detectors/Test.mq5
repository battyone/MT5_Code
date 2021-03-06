//+------------------------------------------------------------------+
//|                                                 Test.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrLime, clrRed
#property indicator_width1  2 

// Indicator buffers
double UpDown[];
double Color[];
double signal[];//信号 1：buy;-1:sell;0:no
int handle_macd;
double macd_buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicator buffers mapping  
//---- indicator buffers mapping  
   SetIndexBuffer(0,UpDown,INDICATOR_DATA);
   SetIndexBuffer(1,Color,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(UpDown,true);
   ArraySetAsSeries(Color,true);
   ArraySetAsSeries(signal,true);
//---- drawing settings
   PlotIndexSetInteger(0,PLOT_ARROW,74);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"Pinbar");
   handle_macd=iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tickvolume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(Open, true);
   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);
   ArraySetAsSeries(Close, true);
   ArraySetAsSeries(macd_buffer, true);
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
//--- get SlowSMA buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(handle_macd,0,0,to_copy,macd_buffer)<=0)
     {
      Print("复制MACD失败",GetLastError());
      return(0);
     }
//---
   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;
//--- calculate MACD
   for(int i=limit+1;i<rates_total-1 && !IsStopped();i++)
      {
       if(macd_buffer[i]>0&&macd_buffer[i]>macd_buffer[i-1]&&macd_buffer[i]>macd_buffer[i+1])
           {
            UpDown[i]=High[i];
            Color[i]=1;
           }
       if(macd_buffer[i]<0&&macd_buffer[i]<macd_buffer[i-1]&&macd_buffer[i]<macd_buffer[i+1])
           {
            UpDown[i]=Low[i];
            Color[i]=0;
           }
      }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindExtremeMacd(int to_copy,const double &high[],const double &low[])
  {
   CopyBuffer(handle_macd,0,0,to_copy,macd_buffer);
   ArraySetAsSeries(macd_buffer,true);
   for(int i=1;i<to_copy;i++)
     {
      UpDown[i]=EMPTY_VALUE;
      if(macd_buffer[i]>0)
        {
         if(macd_buffer[i]>macd_buffer[i-1] && macd_buffer[i]>macd_buffer[i+1])
           {
            UpDown[i]=high[i];
            Color[i]=1;
           }
        }
      else if(macd_buffer[i]<0)
        {
         if(macd_buffer[i]<macd_buffer[i-1] && macd_buffer[i]<macd_buffer[i+1])
           {
            UpDown[i]=low[i];
            Color[i]=0;
           }
        }
     }
  }
//+------------------------------------------------------------------+
