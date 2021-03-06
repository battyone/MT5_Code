//+------------------------------------------------------------------+
//|                                               MABreakPoints3.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"

#property description "均线拐点检测3"
#property description "    当前价格高于过去固定bar数的最高价,上一个极值点为极小值点--拐点买"
#property description "    当前价格低于过去固定bar数的最低价，上一个极值点为极大值点--拐点卖"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_width1 2
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_width2 2

input int InpLastBarNum=24;      // 判断价格突破的bar数
input int InpMAPeriod=24;  // 均线bar数
input int InpExtremeLeftBarNum=5;   // 均线极值点判断左边的bar数
input int InpExtremeRightBarNum=1;   // 均线极值点判断右的bar数
input int InpDistExtreme=2;   // 极值点距离当前点的位置距离要求(扣除了right bar数)

double BuyPrice[];
double SellPrice[];
double Signal[];

datetime last_time=0;
int h_ma;
double buffer_ma[];
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
   PlotIndexSetString(0,PLOT_LABEL,"拐点检测3--Buy");
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(1,PLOT_LABEL,"拐点检测3--Sell");

   ArraySetAsSeries(BuyPrice,true);
   ArraySetAsSeries(SellPrice,true);
   ArraySetAsSeries(Signal,true);

   h_ma=iMA(NULL,NULL,InpMAPeriod,0,MODE_EMA,PRICE_CLOSE);
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

   CopyBuffer(h_ma,0,0,num_handle+num_bar_check,buffer_ma);
   ArraySetAsSeries(buffer_ma,true);

   for(int i=num_handle-1;i>=0;i--)
     {
      BuyPrice[i]=EMPTY_VALUE;
      SellPrice[i]=EMPTY_VALUE;
      Signal[i]=0;
      int imax=ArrayMaximum(high,i+2,InpLastBarNum);
      int imin=ArrayMinimum(low,i+2,InpLastBarNum);
      int index=FindLastMaExtremeIndex(buffer_ma,i+1+InpExtremeRightBarNum,InpLastBarNum-InpExtremeLeftBarNum);
      if(MathAbs(index)>InpDistExtreme+InpExtremeRightBarNum) continue; // 极值点离现在突破点的位置太远，不认为当前位置为拐点
                                                                        //if(MathAbs(buffer_ma[MathAbs(index)]-buffer_ma[MathAbs(index)+InpExtremeLeftBarNum])/InpExtremeLeftBarNum<5*SymbolInfoDouble(NULL,SYMBOL_POINT)) continue;
      if(high[i+1]>=high[imax] && index<0 && low[i+1]>low[i+2]) // 价格突破给定范围内的最高价
        {
         BuyPrice[i]=open[i];
         Signal[i]=1;
        }
      else if(low[i+1]<=low[imin] && index>0 && high[i+1]<high[i+2]) // 价格突破给定范围内的最低价
        {
         SellPrice[i]=open[i];
         Signal[i]=-1;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FindLastMaExtremeIndex(double &buffer[],int begin,int num)
  {
   for(int i=begin;i<begin+num;i++)
     {
      if(IsMaxLeftRight(buffer,i,InpExtremeLeftBarNum,InpExtremeRightBarNum)) return 1*(i-begin+InpExtremeRightBarNum);
      if(IsMinLeftRight(buffer,i,InpExtremeLeftBarNum,InpExtremeRightBarNum)) return -1*(i-begin+InpExtremeRightBarNum);
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                        判断给定位置是否是极大值点                |
//+------------------------------------------------------------------+
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
