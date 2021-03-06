//+------------------------------------------------------------------+
//|                                                MacdDetector2.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "MACD价格背离形态检测器"
#property description "--MACD指标的四个参数"
#property description "--背离形态只在给定搜寻范围内进行"
#property description "--MACD的极值点判断通过给定范围内的数量进行判断(临近极值点的判断的右侧只需要一个点即可，其他根据参数控制)"
#property description "--设置价格落差和MACD落差来过滤不明显的背离形态"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrBlue,clrRed
#property indicator_width1  2

input int                InpFastEMA=12;               // Fast EMA period
input int                InpSlowEMA=26;               // Slow EMA period
input int                InpSignalSMA=9;              // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price
input int                InpSearchBarNum=100;   // 搜寻背离形态的bar数
input int                InpExtremeControlNum=2;   // 确认极值的bar数
input double             InpDeltaPrice=10;  // 背离形态价格的落差
input double             InpDeltaMacd=0.0002;   // 背离形态macd的落差
input bool               InpNeedDrawLine=true;  // 是否绘制形态识别辅助线

                                                // Indicator buffers
double HighLow[]; // 确定背离形态成立时的收盘价，不成立时为空值
double Color[];   // 背离做空-颜色取clrBlue, 背离做多-颜色取clrRed
double Signal[];  // 存储背离形态对应的操作方向：0不操作，-1做空，1做多
double LastExtremIndex[];  //  上一个极值点位置相对当前极值点的位置信息
double MacdValue[];  // macd的值

double Price1[];  // 背离起点的价格
double Price2[];  // 背离终点的价格

int handle_macd;
double macd_buffer[];
datetime last_time=0;
string msg;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicator buffers mapping  
   SetIndexBuffer(0,HighLow,INDICATOR_DATA);
   SetIndexBuffer(1,Color,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,Signal,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,LastExtremIndex,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,MacdValue,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,Price1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,Price2,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(HighLow,true);
   ArraySetAsSeries(Color,true);
   ArraySetAsSeries(Signal,true);
   ArraySetAsSeries(LastExtremIndex,true);
   ArraySetAsSeries(MacdValue,true);
   ArraySetAsSeries(Price1,true);
   ArraySetAsSeries(Price2,true);

//---- drawing settings
   PlotIndexSetInteger(0,PLOT_ARROW,108);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"MACD Detector");

   handle_macd=iMACD(NULL,_Period,InpFastEMA,InpSlowEMA,InpSignalSMA,InpAppliedPrice);
   //Print("Init");
   //SendNotification("Init");
   ObjectsDeleteAll(0);
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
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   if(rates_total<InpSearchBarNum) return 0; // 图表数据太少，不进行指标计算

   if(last_time==time[0]) return rates_total; // 没有产生新BAR，不进行指标计算
   last_time=time[0];

   int num_handle;
   if(prev_calculated<InpSearchBarNum) num_handle=rates_total-InpSearchBarNum;
   else num_handle=rates_total-prev_calculated;

//Print("copy buffer num:",num_handle);
   CopyBuffer(handle_macd,0,0,num_handle+InpSearchBarNum,macd_buffer);
   ArraySetAsSeries(macd_buffer,true);

   for(int i=num_handle+1;i>1;i--)
     {
      HighLow[i-2]=EMPTY_VALUE;
      Signal[i-2]=0;
      LastExtremIndex[i-2]=EMPTY_VALUE;
      MacdValue[i-2]=macd_buffer[i-2];
      Price1[i-2]=0;
      Price2[i-2]=0;
      if(macd_buffer[i-1]>0) // MACD的值为正的情况：寻找macd下降，价格上升的形态
        {
         if(!IsMaxLeftRight(macd_buffer,i,InpExtremeControlNum,1)) continue;  // i位置不是临近极大值点，直接跳过
         for(int j=InpExtremeControlNum;j<InpSearchBarNum-InpExtremeControlNum;j++)
           {
            if(macd_buffer[i+j]<0) break; // 搜寻的位置到达由正到负时，停止寻找第二极大值点
            if(IsMaxLeftRight(macd_buffer,i+j,InpExtremeControlNum,InpExtremeControlNum)) // i+j位置是上一个极大值点
              {
               //if(macd_buffer[i]<macd_buffer[i+j] && High[i]>High[i+j])
               if(macd_buffer[i]+InpDeltaMacd<macd_buffer[i+j] && High[i]>High[i+j]+InpDeltaPrice*Point()) // 价格和macd背离
                 {
                  // i和i+j位置对应的macd和价格背离形态成立(在i-1位置上bar形成时才能确认),i-1位置bar的指标数值设为close[i-1]
                  HighLow[i-2]=Open[i-2];
                  Signal[i-2]=-1;
                  Color[i-2]=1;
                  LastExtremIndex[i-2]=j;
                  Price1[i-2]=High[i+j];
                  Price2[i-2]=High[i];
                  
                  msg=_Symbol+" On "+EnumToString(_Period)+" MACD背离 To Sell,Time:"+TimeToString(time[i-1])+
                      ",Location:"+IntegerToString(j)+
                      ",Price:"+DoubleToString(High[i],Digits())+">"+DoubleToString(High[i+j],Digits())+
                      ",MACD:"+DoubleToString(macd_buffer[i],5)+"<"+DoubleToString(macd_buffer[i+j],5);
                  if(InpNeedDrawLine)
                    {
                     TrendCreate(0,msg,0,time[i+j],High[i+j],time[i],High[i],clrRed);
                     VLineCreate(0,"Vline1 "+msg,0,time[i+j],clrRed);
                     VLineCreate(0,"Vline2 "+msg,0,time[i],clrRed);
                    }
                    
                  if(i-1==1) // 当前最新监测的背离形态才进行提醒
                    {
                     Print(msg);
                     Alert(msg);
                     SendNotification(msg);
                     SendMail("MACD Detector",msg);
                    }
                 }
               break;   // 找到上一个极值点后，不再进行极值点的查找(即使当前找到的点并不是背离形态)
              }
           }
        }
      else if(macd_buffer[i-1]<0) // macd为负的情况:寻找macd上升，价格下降的形态
        {
         if(!IsMinLeftRight(macd_buffer,i,InpExtremeControlNum,1)) continue;  // i位置不是临近极小值点，直接跳过
         for(int j=InpExtremeControlNum;j<InpSearchBarNum-InpExtremeControlNum;j++)
           {
            if(macd_buffer[i+j]>0) break; // 搜寻的位置到达由负到正时，停止寻找第二极大值点
            if(IsMinLeftRight(macd_buffer,i+j,InpExtremeControlNum,InpExtremeControlNum)) // i+j位置是上一个极小值点
              {
               if(macd_buffer[i]>macd_buffer[i+j]+InpDeltaMacd && Low[i]+InpDeltaPrice*Point()<Low[i+j]) // macd和价格背离
                 {
                  // i和i+j位置对应的macd和价格背离形态成立(在i-1位置上bar形成时才能确认),i-1位置bar的指标数值设为close[i-1]
                  HighLow[i-2]=Open[i-2];
                  Signal[i-2]=1;
                  Color[i-2]=0;
                  LastExtremIndex[i-2]=j;
                  Price1[i-2]=Low[i+j];
                  Price2[i-2]=Low[i];
                  msg=_Symbol+" On "+EnumToString(_Period)+" MACD背离 To Buy,Time:"+TimeToString(time[i-1])+
                      ",Location:"+IntegerToString(j)+
                      ",Price:"+DoubleToString(Low[i],Digits())+"<"+DoubleToString(Low[i+j],Digits())+
                      ",MACD:"+DoubleToString(macd_buffer[i],5)+">"+DoubleToString(macd_buffer[i+j],5);
                  if(InpNeedDrawLine)
                    {
                     TrendCreate(0,msg,0,time[i+j],Low[i+j],time[i],Low[i],clrBlue);
                     VLineCreate(0,"Vline1 "+msg,0,time[i+j],clrBlue);
                     VLineCreate(0,"Vline2 "+msg,0,time[i],clrBlue);
                    }

                  
                  if(i-1==1) // 当前最新监测的背离形态才进行提醒
                    {
                     Print(msg);
                     Alert(msg);
                     SendNotification(msg);
                     SendMail("MACD Detector",msg);
                    }
                 }
               break; // 找到上一个极值点后，不再进行极值点的查找(即使当前找到的点并不是背离形态)
              }
           }
        }
     }
   return(rates_total);
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
//| 通过已给的坐标创建趋势线                                            | 
//+------------------------------------------------------------------+ 
bool TrendCreate(const long            chart_ID=0,        // 图表 ID 
                 const string          name="TrendLine",  // 线的名称 
                 const int             sub_window=0,      // 子窗口指数 
                 datetime              time1=0,           // 第一个点的时间 
                 double                price1=0,          // 第一个点的价格 
                 datetime              time2=0,           // 第二个点的时间 
                 double                price2=0,          // 第二个点的价格 
                 const color           clr=clrRed,        // 线的颜色 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // 线的风格 
                 const int             width=1,           // 线的宽度 
                 const bool            back=false,        // 在背景中 
                 const bool            selection=false,// 突出移动 
                 const bool            ray_left=false,    // 线延续向左 
                 const bool            ray_right=false,   // 线延续向右 
                 const bool            hidden=true,       // 隐藏在对象列表 
                 const long            z_order=0)         // 鼠标单击优先 
  {
//--- 若未设置则设置定位点的坐标 
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- 重置错误的值 
   ResetLastError();
//--- 通过已给的坐标创建趋势线 
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- 设置线的颜色 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- 设置线的显示风格 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- 设置线的宽度 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- 显示前景 (false) 或背景 (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- 启用 (true) 或禁用 (false) 通过鼠标移动线的模式 
//--- 当使用ObjectCreate函数创建图形对象时，对象不能 
//--- 默认下突出并移动。在这个方法中，默认选择参数 
//--- true 可以突出移动对象 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- 启用 (true) 或禁用 (false) 延续向左显示线的模式 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- 启用 (true) 或禁用 (false) 延续向右显示线的模式 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- 在对象列表隐藏(true) 或显示 (false) 图形对象名称 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- 设置在图表中优先接收鼠标点击事件 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- 成功执行 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| 检查趋势线定位点的值和为空点设置                                      | 
//| 默认的值                                                           | 
//+------------------------------------------------------------------+ 
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
  {
//--- 如果第一点的时间没有设置，它将位于当前柱 
   if(!time1)
      time1=TimeCurrent();
//--- 如果第一点的价格没有设置，则它将用卖价值 
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- 如果第二点的时间没有设置，它则位于第二点左侧的9个柱 
   if(!time2)
     {
      //--- 接收最近10柱开盘时间的数组 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- 在第一点左侧9柱设置第二点 
      time2=temp[0];
     }
//--- 如果第二点的价格没有设置，则它与第一点的价格相等 
   if(!price2)
      price2=price1;
  }
//+------------------------------------------------------------------+ 
//| 创建垂直线                                                        | 
//+------------------------------------------------------------------+ 
bool VLineCreate(const long            chart_ID=0,        // 图表 ID 
                 const string          name="VLine",      // 线的名称 
                 const int             sub_window=0,      // 子窗口指数 
                 datetime              time=0,            // 线的时间 
                 const color           clr=clrRed,        // 线的颜色 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // 线的风格 
                 const int             width=1,           // 线的宽度 
                 const bool            back=false,        // 在背景中 
                 const bool            selection=false,// 突出移动 
                 const bool            ray=true,          // 线延续下降 
                 const bool            hidden=true,       // 隐藏在对象列表 
                 const long            z_order=0)         // 鼠标单击优先 
  {
//--- 如果没有线的时间，通过收盘柱来绘制它 
   if(!time)
      time=TimeCurrent();
//--- 重置错误的值 
   ResetLastError();
//--- 创建垂直线 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- 设置线的颜色 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- 设置线的显示风格 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- 设置线的宽度 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- 显示前景 (false) 或背景 (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- 启用 (true) 或禁用 (false) 通过鼠标移动线的模式 
//--- 当使用ObjectCreate函数创建图形对象时，对象不能 
//--- 默认下突出并移动。在这个方法中，默认选择参数 
//--- true 可以突出移动对象 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- 启用 (true) 或禁用 (false) the mode of displaying the line in the chart subwindows 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
//--- 在对象列表隐藏(true) 或显示 (false) 图形对象名称 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- 设置在图表中优先接收鼠标点击事件 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- 成功执行 
   return(true);
  }

//+------------------------------------------------------------------+
