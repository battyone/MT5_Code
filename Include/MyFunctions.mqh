//+------------------------------------------------------------------+
//|                                                  MyFunctions.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//|                        判断给定位置是否是极大值点                |
//+------------------------------------------------------------------+
bool IsMaxLeftRight(double const &buffer[],int index,int left_num,int right_num)
  {
   int index_left_max=ArrayMaximum(buffer,index+1,left_num);
   int index_right_max=ArrayMaximum(buffer,index-right_num,right_num);
   if(buffer[index]>buffer[index_left_max]&&buffer[index]>buffer[index_right_max]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                           判断给定位置是否是极小值点             |
//+------------------------------------------------------------------+
bool IsMinLeftRight(double const &buffer[],int index,int left_num,int right_num)
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