//+------------------------------------------------------------------+
//|                                                           AD.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property description "Accumulation/Distribution"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  LightSeaGreen
#property indicator_label1  "A/D"
//--- 输入参数
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volume type
//---- 缓存
double ExtADbuffer[];
//+------------------------------------------------------------------+
//| 自定义指标初始化函数                                                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- 指标位数
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- 指标简称
   IndicatorSetString(INDICATOR_SHORTNAME,"A/D");
//---- 索引缓存
   SetIndexBuffer(0,ExtADbuffer);
//--- 设置绘图开始的索引
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,1);
//---- 初始化结束
  }
//+------------------------------------------------------------------+
//| 离散指标                                                                         |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- 检查柱形的数量
   if(rates_total<2)
      return(0); //退出，返回零
//--- 获取当前位置
   int pos=prev_calculated-1;
   if(pos<0) pos=0;
//--- 用适当的交易量进行计算
   if(InpVolumeType==VOLUME_TICK)
      Calculate(rates_total,pos,High,Low,Close,TickVolume);
   else
      Calculate(rates_total,pos,High,Low,Close,Volume);
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| 用选中的交易量进行计算                                                   |
//+------------------------------------------------------------------+
void Calculate(const int rates_total,const int pos,
               const double &High[],
               const double &Low[],
               const double &Close[],
               const long &Volume[])
  {
   double hi,lo,cl;
//--- 主循环
   for(int i=pos;i<rates_total && !IsStopped();i++)
     {
      //--- 从数组中获取数据
      hi=High[i];
      lo=Low[i];
      cl=Close[i];
      //--- 计算新的AD值
      double sum=(cl-lo)-(hi-cl);
      if(hi==lo) sum=0.0;
      else       sum=(sum/(hi-lo))*Volume[i];
      if(i>0) sum+=ExtADbuffer[i-1];
      ExtADbuffer[i]=sum;
     }
//----
  }
//+------------------------------------------------------------------+
