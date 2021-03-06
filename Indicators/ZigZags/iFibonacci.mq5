//+------------------------------------------------------------------+
//|                                                   iFibonacci.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1

#property indicator_label1  "FibonacciRatio"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrYellow,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

////--- plot ZigZag
//#property indicator_label2  "ZigZag"
//#property indicator_type2   DRAW_SECTION
//#property indicator_color2  clrRed
//#property indicator_style2  STYLE_SOLID
//#property indicator_width2  1
////--- plot Direction
//#property indicator_label3  "Direction"
//#property indicator_type3   DRAW_NONE
//#property indicator_style3  STYLE_SOLID
//#property indicator_width3  1
////--- plot LastHighBar
//#property indicator_label4  "LastHighBar"
//#property indicator_type4   DRAW_NONE
//#property indicator_style4  STYLE_SOLID
//#property indicator_width4  1
////--- plot LastLowBar
//#property indicator_label5  "LastLowBar"
//#property indicator_type5   DRAW_NONE
//#property indicator_style5  STYLE_SOLID
//#property indicator_width5  1

#include <RingBuffer\\RiBuffDbl.mqh>

//--- input parameters
input int      period=12;  //ZIGZAG计算极值时的周期
input int      num_zz=6;   //zigzag极值点个数

//--- indicator buffers
double         ZigZagBuffer[];   // zigzag指标
double         DirectionBuffer[];   // zigzag指标值对应的方向(1--极大，0--极小)
double         LastHighBarBuffer[]; //前一个极大值的索引
double         LastLowBarBuffer[];  //前一个极小值的索引
double         FibonacciBuffer[];   //Fibonacci回调比例
double         ColorBuffer[]; //颜色

CRiBuffDbl zz_value;
double max_price;
double min_price;
int direction_fibonacci;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,FibonacciBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ZigZagBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,DirectionBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,LastHighBarBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,LastLowBarBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ColorBuffer,INDICATOR_COLOR_INDEX);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

   zz_value.SetMaxTotal(num_zz);
   Print("Init Successed");
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

   int start; // 

   if(prev_calculated==0)
     {
      //
      DirectionBuffer[0]=0;
      LastHighBarBuffer[0]=0;
      LastLowBarBuffer[0]=0;
      start=1; // расчет со следующих элементов после инициализированных
     }
   else
     { // в процессе работы
      start=prev_calculated-1;
     }

   for(int i=start;i<rates_total;i++)
     {
      // из предыдущего элемента буфера получаем 
      // значение определенного ранее направления
      DirectionBuffer[i]=DirectionBuffer[i-1];

      // вычисление начального бара для функций 
      // ArrayMaximum() и ArrayMinimum() 
      int ps=i-period+1;
      // определение баров максимума и минимума на
      // диапазоне period баров
      int hb=ArrayMaximum(high,ps,period);
      int lb=ArrayMinimum(low,ps,period);

      // если выявлен максимум или минимум
      if(hb==i && lb!=i)
        { // выявлен максимум
         DirectionBuffer[i]=1;
        }
      else if(lb==i && hb!=i)
        { // выявлен минимум
         DirectionBuffer[i]=-1;
        }
      //===
      LastHighBarBuffer[i]=LastHighBarBuffer[i-1];
      LastLowBarBuffer[i]=LastLowBarBuffer[i-1];
      ZigZagBuffer[i]=EMPTY_VALUE;

      switch((int)DirectionBuffer[i])
        {
         case 1://新出现的点是高点
            switch((int)DirectionBuffer[i-1])
              {
               case 1://前一个点也是高点
                  // 当前高点大于前一个高点，前高点置空，记录新高点
                  if(high[i]>high[(int)LastHighBarBuffer[i]])
                    { // новый максимум
                     // старую точку зигзага удаляем
                     ZigZagBuffer[(int)LastHighBarBuffer[i]]=EMPTY_VALUE;
                     // ставим новую точку
                     ZigZagBuffer[i]=high[i];
                     // индекс бара с новой вершиной
                     LastHighBarBuffer[i]=i;
                     if(zz_value.GetTotal()==0)
                       {
                        zz_value.AddValue(high[i]);
                       }

                     else
                       {
                        zz_value.ChangeValue(zz_value.GetTotal()-1,high[i]);
                       }

                    }
                  break;
               case -1:
                  // 前一个点时低点 ， 记录当前高点
                  ZigZagBuffer[i]=high[i];
                  LastHighBarBuffer[i]=i;
                  zz_value.AddValue(high[i]);
                  break;
              }
            break;
         case -1:
            switch((int)DirectionBuffer[i-1])
              {
               case -1:
                  // продолжение движения вниз
                  if(low[i]<low[(int)LastLowBarBuffer[i]])
                    { // новый минимум
                     // старую точку зигзага удаляем                  
                     ZigZagBuffer[(int)LastLowBarBuffer[i]]=EMPTY_VALUE;
                     // ставим новую точку
                     ZigZagBuffer[i]=low[i];
                     // индекс бара с новой вершиной
                     LastLowBarBuffer[i]=i;

                     if(zz_value.GetTotal()==0)
                        zz_value.AddValue(low[i]);
                     else
                        zz_value.ChangeValue(zz_value.GetTotal()-1,low[i]);
                    }
                  break;
               case 1:
                  // начало нового движения вниз     
                  ZigZagBuffer[i]=low[i];
                  LastLowBarBuffer[i]=i;
                  zz_value.AddValue(low[i]);
                  break;
              }
            break;
        }

      if(zz_value.GetTotal()<num_zz)
        {
         FibonacciBuffer[i]=EMPTY_VALUE;
         ColorBuffer[i]=1;
        }
      else
        {
         if(!GetFibonacciMaxMinValue(zz_value))
           {
            FibonacciBuffer[i]=EMPTY_VALUE;
            ColorBuffer[i]=1;
           }
         else
           {
            //Print(max_price, " ", min_price);
            FibonacciBuffer[i]=direction_fibonacci==1?(max_price-close[rates_total-1])/(max_price-min_price):(close[rates_total-1]-min_price)/(max_price-min_price);
            ColorBuffer[i]=0;
           }
        }

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PatternValid(const CRiBuffDbl &zigzags)
  {
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetFibonacciMaxMinValue(CRiBuffDbl &zigzags)
  {
   if(!PatternValid(zigzags)) return false;
   double arr_zz[];
   zigzags.ToArray(arr_zz);
//zigzags.ToArray(arr_zz);
   int max_loc=ArrayMaximum(arr_zz);
   int min_loc=ArrayMinimum(arr_zz);
   max_price=arr_zz[max_loc];
   min_price=arr_zz[min_loc];
   for(int i=0;i<ArraySize(arr_zz);i++)
     {
      Print("i=",i, " ,",arr_zz[i]);
     }

   if(max_loc>min_loc) direction_fibonacci=1;
   else direction_fibonacci=-1;
   return true;
  }
//+------------------------------------------------------------------+
