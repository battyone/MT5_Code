//+------------------------------------------------------------------+
//|                                               MABreakPoints1.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "均线拐点信号--根据均线的极大值/极小值确定"
#property description "    根据拐点左边一定数量的bar和右边一定数量的bar来确定拐点"
#property description "    确定拐点时，需要右边的一定数量的bar确定"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1 DRAW_ARROW
#property indicator_width1 2
#property indicator_color1 clrBlue
#property indicator_type2 DRAW_ARROW
#property indicator_width2 2
#property indicator_color2 clrRed

input int InpMaPeriod=24;
input int InpLeftBarNum=5;
input int InpRightBarNum=2;

double BuyPrice[];
double SellPrice[];
double Signal[]; 

int h_ma;
datetime last_time=0;
double ma_buffer[];

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
   PlotIndexSetString(0,PLOT_LABEL,"均线拐点检测器");
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(1,PLOT_LABEL,"均线拐点检测器");
   
   ArraySetAsSeries(BuyPrice,true);
   ArraySetAsSeries(SellPrice,true);
   ArraySetAsSeries(Signal,true);
   h_ma=iMA(NULL,NULL,InpMaPeriod,0,MODE_EMA,PRICE_CLOSE);
   
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
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   int num_bar_check=InpLeftBarNum+InpRightBarNum+1;
   if(rates_total<num_bar_check) return 0;
  
   if(last_time==time[0]) return rates_total; // 没有产生新BAR，不进行指标计算
   last_time=time[0];   
   
   int num_handle;   // 需要处理bar的数量
   if(prev_calculated<num_bar_check) num_handle=rates_total-num_bar_check;
   else num_handle=rates_total-prev_calculated;
   
   CopyBuffer(h_ma,0,0,num_handle+num_bar_check,ma_buffer); 
   ArraySetAsSeries(ma_buffer,true);
   
   for(int i=num_handle+1;i>0;i--)
     {
      //Price[i]=open[i];
      BuyPrice[i]=EMPTY_VALUE;
      SellPrice[i]=EMPTY_VALUE;
      if(IsMaxLeftRight(ma_buffer,i+InpRightBarNum,InpLeftBarNum,InpRightBarNum))
        {
         SellPrice[i]=open[i];
        }
      else if(IsMinLeftRight(ma_buffer,i+InpRightBarNum,InpLeftBarNum,InpRightBarNum))
             {
              BuyPrice[i]=open[i];
             }
     }
   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
bool IsMaxLeftRight(double &buffer[],int index,int left_num,int right_num)
  {
   int index_left_max=ArrayMaximum(buffer,index+1,left_num);
   int index_right_max=ArrayMaximum(buffer,index-right_num,right_num);
   if(buffer[index]>buffer[index_left_max]&&buffer[index]>buffer[index_right_max]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                           判断给定位置是否是极小值点             |
//+------------------------------------------------------------------+
bool IsMinLeftRight(double &buffer[],int index,int left_num,int right_num)
  {
   int index_left_min=ArrayMinimum(buffer,index+1,left_num);
   int index_right_min=ArrayMinimum(buffer,index-right_num,right_num);
   if(buffer[index]<buffer[index_left_min]&&buffer[index]<buffer[index_right_min]) return true;
   return false;
  }
//+------------------------------------------------------------------+
