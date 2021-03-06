//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot ZigZag
#property indicator_label1  "ZigZag"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Direction
#property indicator_label2  "Direction"
#property indicator_type2   DRAW_NONE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot LastHighBar
#property indicator_label3  "LastHighBar"
#property indicator_type3   DRAW_NONE
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot LastLowBar
#property indicator_label4  "LastLowBar"
#property indicator_type4   DRAW_NONE
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters
input int      period=12;
//--- indicator buffers
double         ZigZagBuffer[];
double         DirectionBuffer[];
double         LastHighBarBuffer[];
double         LastLowBarBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigZagBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DirectionBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,LastHighBarBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,LastLowBarBuffer,INDICATOR_CALCULATIONS);

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
                const double &_high[],
                const double &_low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int start; // переменная для индекса бара с которого будет выполняться расчет 
   if(prev_calculated==0)
     { // на запуске
      // инициализация начальных элементов буферов
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
      int hb=ArrayMaximum(close,ps,period);
      int lb=ArrayMinimum(close,ps,period);

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

      ZigZagBuffer[(int)LastHighBarBuffer[i]]=close[(int)LastHighBarBuffer[i]];
      ZigZagBuffer[(int)LastLowBarBuffer[i]]=close[(int)LastLowBarBuffer[i]];

      switch((int)DirectionBuffer[i])
        {
         case 1:
            switch((int)DirectionBuffer[i-1])
              {
               case 1:
                  // продолжение движения вверх
                  if(close[i]>close[(int)LastHighBarBuffer[i]])
                    { // новый максимум
                     // старую точку зигзага удаляем
                     ZigZagBuffer[(int)LastHighBarBuffer[i]]=EMPTY_VALUE;
                     // ставим новую точку
                     ZigZagBuffer[i]=close[i];
                     // индекс бара с новой вершиной
                     LastHighBarBuffer[i]=i;
                    }
                  break;
               case -1:
                  // начало нового движения вверх
                  ZigZagBuffer[i]=close[i];
                  LastHighBarBuffer[i]=i;
                  break;
              }
            break;
         case -1:
            switch((int)DirectionBuffer[i-1])
              {
               case -1:
                  // продолжение движения вниз
                  if(close[i]<close[(int)LastLowBarBuffer[i]])
                    { // новый минимум
                     // старую точку зигзага удаляем                  
                     ZigZagBuffer[(int)LastLowBarBuffer[i]]=EMPTY_VALUE;
                     // ставим новую точку
                     ZigZagBuffer[i]=close[i];
                     // индекс бара с новой вершиной
                     LastLowBarBuffer[i]=i;
                    }
                  break;
               case 1:
                  // начало нового движения вниз     
                  ZigZagBuffer[i]=close[i];
                  LastLowBarBuffer[i]=i;
                  break;
              }
            break;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
