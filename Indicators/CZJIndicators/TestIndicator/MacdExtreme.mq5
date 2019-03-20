//+------------------------------------------------------------------+
//|                                                  MacdExtreme.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "寻找MACD的极值点,根据相邻的点进行判断"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots  1
#property indicator_type1 DRAW_COLOR_ARROW
#property indicator_color1 clrRed,clrYellow

double MaxMin[];
double Color[];
double Signal[];
int h_macd;
double v_macd[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MaxMin,INDICATOR_DATA);
   SetIndexBuffer(1,Color,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,Signal,INDICATOR_CALCULATIONS);
   
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"macd extreme");
   ArraySetAsSeries(MaxMin, true);
   ArraySetAsSeries(Color, true);
   ArraySetAsSeries(Signal, true);
   h_macd=iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE);
   Print("初始化成功，MacdExtreme");
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
// 数据数量确认
   if(rates_total<100) return(0);
   if(BarsCalculated(h_macd)<rates_total)
     {
      Print("MACD指标数量不足");
      return(0);
     }
//    确认拷贝的数量
   int to_copy;
   if(prev_calculated>rates_total||prev_calculated<10) to_copy=rates_total;
   else  to_copy=rates_total-prev_calculated;
   if(to_copy<10) to_copy=10;
   if(CopyBuffer(h_macd,0,0,to_copy,v_macd)<0)
      {
       Print("指标拷贝失败");
       return(0);
      }
   ArraySetAsSeries(v_macd,true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
//   指标计算
   
   for(int i=0;i<to_copy;i++)
     {
      if(i<2||i==to_copy-1) continue;
      if(v_macd[i]>0&&v_macd[i]>v_macd[i-1]&&v_macd[i]>v_macd[i+1])
        {
         MaxMin[i]=high[i];
         Color[i]=0;
        }
      else if(v_macd[i]<0&&v_macd[i]<v_macd[i-1]&&v_macd[i]<v_macd[i+1])
         {
          MaxMin[i]=low[i];
          Color[i]=1;
         }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
