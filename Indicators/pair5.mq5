//+------------------------------------------------------------------+
//|                                                         pair.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "pair2"

#include <Math\Alglib\alglib.mqh>

double   pair2[];
struct close_d
{
   double   c[];
};

input string   to_split = "EURUSD,XAUUSD,USDJPY,GBPUSD";    //设定全部品种对
input bool     flag_mode = false;      //是否用设定的参数进行计算
input string   to_data = "1,1,1,1,1";  //设定品种对对应的参数，数量比品种对多一个，最后一位为残差
input int      data_l = 1000;    //回归计算样本的长度
input int      data_shift = 0;   //回归计算样本的偏移度
string   symbol[];
datetime m_last_time[];
double   can[];
double   point[];
int      ln = 4;
double   tt1 = 0;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- 从字符串中获取品种对数据
   string result[];
   string sep = ",";
   ushort u_sep; 
   u_sep = StringGetCharacter(sep,0); 
   int k = StringSplit(to_split, u_sep, result);
   PrintFormat("Strings obtained: %d. Used separator '%s' with the code %d", k, sep, u_sep); 
   ln = k;
   
   ArrayResize(symbol, ln + 1);
   ArrayResize(point, ln + 1);
   ArrayResize(can, ln);            
  
   if(k > 0) 
   { 
      //--- 将所有品种对调整到与图表中的品种对相同的量级
      for(int i=0; i < k; i++) 
      { 
         PrintFormat("result[%d]=\"%s\"",i,result[i]); 
         symbol[i] = result[i];
         point[i] = SymbolInfoDouble(symbol[i], SYMBOL_POINT);
         if(symbol[i] == "XAUUSD")  point[i] = 0.01;
      } 
   }   
   //--- 对黄金进行单独调整
   symbol[ln] = Symbol();
   point[ln] = SymbolInfoDouble(symbol[ln], SYMBOL_POINT); 
   if(symbol[ln] == "XAUUSD")  point[ln] = 0.01;  
   Print(symbol[ln]);
   
   for(int i = 0; i < ln; i++)
   {
      point[i] = point[ln] / point[i];
      Print(point[i]);
   }
   
   //--- 从字符串中获取参数数据，并将参数设为指定值
   if(flag_mode == true)
   {
      string result2[];
      int k2 = StringSplit(to_data, u_sep, result2);
      PrintFormat("Strings obtained: %d. Used separator '%s' with the code %d", k2, sep, u_sep);
      
      for(int i = 0; i < ln; i++)
      {
         can[i] = StringToDouble(result2[i]);
         Print(result2[i]);
         Print(can[i]);
      }
      
      tt1 = StringToDouble(result2[ln]);     
   }
   
   //--- indicator buffers mapping
   SetIndexBuffer(0, pair2, INDICATOR_DATA);

   //--- indicator buffers mapping
	bool synchronized=false;
      //--- 循环计数器
   int attempts=0;
      // 进行5次尝试等候同步进行
   while(attempts<5)
   {
      if(SeriesInfoInteger(symbol[ln], Period(), SERIES_SYNCHRONIZED))
      {
         //--- 同步化完成，退出
         synchronized=true;
         break;
      }
      //--- 增加计数器
      attempts++;
      //--- 等候10毫秒直至嵌套反复
      Sleep(10);
   }
   //--- 同步化后退出循环
   if(synchronized)
   {
      
      Print("The first date in the terminal history for the symbol-period at the moment = ",
            (datetime)SeriesInfoInteger(symbol[ln], 0, SERIES_FIRSTDATE));
      Print("The first date in the history for the symbol on the server = ",
            (datetime)SeriesInfoInteger(symbol[ln], 0, SERIES_SERVER_FIRSTDATE));
   }
      //--- 不发生数据同步
   else
   {
      Print("Failed to get number of bars for ",symbol[ln]);
      //如果这这里同步不了的话，那么就继续让程序跑，获不到bar的情况下，他会再做一次同步
      //return(INIT_FAILED);
   }   
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
   //--- prev_calculated ==0 有三种情况，初次计算，出现错误需要重新计算，人工刷新导致重新计算
   if(prev_calculated == 0)
   {
      int data_n = data_l + data_shift + data_l / 5;
      int start = rates_total - data_l - data_shift - data_l / 10;
      int datalen[];
      int offset[];
      close_d close_p[];
      
      //--- 初始化各个数组
      ArrayResize(datalen, ln + 1);
      ArrayResize(m_last_time, ln + 1);
      ArrayInitialize(pair2, 0);            
      ArrayResize(close_p, ln);
      ArrayResize(offset, ln + 1);
      ArrayInitialize(offset, 0);      
      
      for(int i = 0; i < ln; i++)
      {
         ArrayResize(close_p[i].c, data_n);
         ArrayInitialize(close_p[i].c, 0);         
      }
      
      //--- 获取图表中品种对的数据
      MqlRates nextrates[];
      datalen[ln] = CopyRates(symbol[ln], Period(), time[start], time[rates_total - 1], nextrates);
      Print(datalen[ln]);
      if(datalen[ln] < 0)
      {
         Print(datalen[ln]);
         SeriesInfoInteger(symbol[ln], Period(), SERIES_SYNCHRONIZED);
         return prev_calculated;   
      }
      
      //--- 同步不同品种对的时间序列       
      for(int i = 0; i < datalen[ln] - 1; i++)
      {
         for(int j = 0; j < ln; j++)
         {
            //--- 获取第j个品种对的数据
            MqlRates temp[];
            datalen[j] = CopyRates(symbol[j], Period(), time[start], time[rates_total - 1], temp);
            if(datalen[j] < 0)
            {
               Print(datalen[j]);
               SeriesInfoInteger(symbol[j], Period(), SERIES_SYNCHRONIZED);
               return prev_calculated;   
            }
            
            //--- 若大于基准品种对的时间就减1偏移度，若小于就加1偏移度            
            while(1 && !IsStopped())
            {
               if(temp[i + offset[j]].time == nextrates[i].time)
               {
                  break;               
               }
               else if(temp[i + offset[j]].time > nextrates[i].time)
               {
                  if(i + offset[j] == 0)  break;
                  offset[j]--;
                  if(temp[i + offset[j]].time == nextrates[i].time)
                  {
                     break;
                  }
                  else if(temp[i + offset[j]].time < nextrates[i].time)
                  {
                     break;
                  }
                  else if(temp[i + offset[j]].time > nextrates[i].time)
                  {
                     if(i + offset[j] == 0)  break;
                     offset[j]--;
                  }               
               }
               else if(temp[i + offset[j]].time < nextrates[i].time)
               {
                  if(i + offset[j] > datalen[j] - 1)   break;
                  offset[j]++;
                  if(temp[i + offset[j]].time == nextrates[i].time)
                  {
                     break;
                  }
                  else if(temp[i + offset[j]].time < nextrates[i].time)
                  {
                     if(i + offset[j] > datalen[j] - 1)   break;                  
                     offset[j]++;
                  }
                  else if(temp[i + offset[j]].time > nextrates[i].time)
                  {
                     offset[j]--;
                     break;
                  }                               
               }
            }
            //--- 存储配对好的数据，并归一到同一数量级
            close_p[j].c[i] = temp[i + offset[j]].close * point[j];
            m_last_time[j] = temp[datalen[j] - 2].time;                                 
         }    
      }
      
      //--- 若没有自定义参数就通过回归来计算参数
      if(flag_mode == false)
      {
         //--- 线性回归
         //--- 独立变量个数
         int nvars = ln - 1;
         //--- 样品成交量
         int npoints = data_l;
         //--- 创建线性回归参数的矩阵
         CMatrixDouble xy(npoints, nvars + 1);
         for(int i = 0; i < npoints; i++)
         {
            for(int j = 0; j < nvars; j++)
            {
               xy[i].Set(j, close_p[j + 1].c[datalen[ln] - i - data_shift - 2]);
            }
            xy[i].Set(nvars, close_p[0].c[datalen[ln] - i - data_shift - 2]);
         }
         //---  检测计算结果 (成功, 不成功)的变量
         int info;
         //--- 存储计算数据所必需的类对象
         CLinearModelShell lm;
         CLRReportShell    ar;
         //--- 存储回归结果的数组
         double lr_coeff[];
         double lr_values[];
         ArrayResize(lr_values, npoints);
         //--- 计算线性回归率
         CAlglib::LRBuild(xy, npoints, nvars, info, lm, ar);
   
         //---接收线性回归率
         CAlglib::LRUnpack(lm, lr_coeff, nvars);
      
         for(int i = 0; i < ln; i++)
         {     
            Print("lr_coeff[",i, "]: ", lr_coeff[i]);
         }
         
         //---得到计算好的参数数据
         for(int i = 0; i < nvars; i++)
         {
            can[i + 1] = -1 * lr_coeff[i];            
         }
         can[0] = 1;
         tt1 = lr_coeff[nvars];
         
         //---通过参数数据计算最终的拟合值
         for(int j = 0; j < data_l + data_shift - 2; j++)
         {
            double temp = 0;
            for(int i = 0; i < ln; i++)
            {
               temp += close_p[i].c[datalen[ln] - j - 2] * can[i];
            }
            pair2[rates_total - j - 1] = temp - tt1;               
         }
      }
      //---通过指定的参数数据直接计算最终的拟合值
      else
      { 
         for(int j = 0; j < data_l + data_shift - 2; j++)
         {
            double temp = 0;
            for(int i = 0; i < ln; i++)
            {
               temp += close_p[i].c[datalen[ln] - j - 2] * can[i];
            }
            pair2[rates_total - j - 1] = temp - tt1;               
         }         
      }
   }
   else
   {
      MqlRates nextrates[];
      int datalen[];
      datetime time_p[];
      //---初始化
      ArrayResize(datalen, ln + 1);
      ArrayResize(time_p, ln + 1);
      
      for(int i = 0; i < ln + 1; i++)
      {
         datalen[i] = CopyRates(symbol[i], Period(), time[rates_total - 10], time[rates_total - 1], nextrates);
         if(datalen[i] < 0)
         {
            SeriesInfoInteger(symbol[i], Period(), SERIES_SYNCHRONIZED);
            return prev_calculated;   
         }
         time_p[i] = nextrates[datalen[i] - 2].time;                  
      }
      
      //---判断是否有新k线出现    
      bool flag = false;
      for(int i = 0; i < ln; i++)
      {
         if(m_last_time[i] != time_p[i])
         {
            flag = true;
            break;
         }        
      }   
      //---通过得到的参数计算最新的拟合值
      if(flag == true)
      {
         double temp = 0;
         for(int i = 0; i < ln; i++)
         {
            MqlRates nextrates2[];
            CopyRates(symbol[i], Period(), time[rates_total - 10], time[rates_total - 1], nextrates2);            
            temp += nextrates2[datalen[i] - 2].close * point[i] * can[i];
         }
         pair2[rates_total - 1] = temp - tt1;
      }      
   }


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//SymbolInfoDouble(SYMBOL_POINT)