//+------------------------------------------------------------------+
//|                                                 MacdExtreme3.mq5 |
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

input int                InpFastEMA=12;               // Fast EMA period
input int                InpSlowEMA=26;               // Slow EMA period
input int                InpSignalSMA=9;              // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price
input int                InpSearchBarNum=100;
input int                InpExtremeControlNum=2;

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
   SetIndexBuffer(0,UpDown,INDICATOR_DATA);
   SetIndexBuffer(1,Color,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(UpDown,true);
   ArraySetAsSeries(Color,true);
   ArraySetAsSeries(signal,true);

//---- drawing settings
   PlotIndexSetInteger(0,PLOT_ARROW,74);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"MACD Detector");
   handle_macd=iMACD(NULL,0,InpFastEMA,InpSlowEMA,InpSignalSMA,InpAppliedPrice);
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
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);

// copy macd buffer   
   if(CopyBuffer(handle_macd,0,0,InpSearchBarNum,macd_buffer)<=0)
     {
      Print("复制MACD缓冲失败",GetLastError());
      return(0);
     }
   ArraySetAsSeries(macd_buffer,true);
//  寻找macd区域的起点
   int begin=0;
   for(int i=1;i<InpSearchBarNum;i++)
     {
      if(macd_buffer[i]*macd_buffer[0]<0)
        {
         begin=i;
         break;
        }
     }
   if(begin<5) return(rates_total);    //  macd的同一向的bar数太少，不进行识别
   
//   寻找区域内的极值点
   if(macd_buffer[0]>0) // 寻找极大值
     {
      for(int i=0;i<begin;i++)
        {
         UpDown[i]=EMPTY_VALUE;
         bool is_extreme=true;    
         for(int j=1;j<=InpExtremeControlNum;j++)
           {
            if((i+j<begin && macd_buffer[i+j]>macd_buffer[i])||i+j>=begin)
              {
               is_extreme=false;
               break;
              }
            if((i-j>1 && macd_buffer[i-j]>macd_buffer[i])||i-j<=1)
              {
               is_extreme=false;
               break;
              }
           }
         if(is_extreme)
           {
            UpDown[i]=High[i];
            Color[i]=1;
           }
        }
     }
   else if(macd_buffer[0]<0)  // 寻找极小值
     {
      for(int i=0;i<begin;i++)
        {
         UpDown[i]=EMPTY_VALUE;
         bool is_extreme=true;
         for(int j=1;j<=InpExtremeControlNum;j++)
           {
            if((i+j<begin && macd_buffer[i+j]<macd_buffer[i])||i+j>=begin)
              {
               is_extreme=false;
               break;
              }
            if((i-j>1 && macd_buffer[i-j]<macd_buffer[i])||i-j<=1)
              {
               is_extreme=false;
               break;
              }
           }
         if(is_extreme)
           {
            UpDown[i]=Low[i];
            Color[i]=0;
           }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
