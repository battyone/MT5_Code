//+------------------------------------------------------------------+
//|                                                 ABCDDetector.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property description "AB=CD形态检测"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_width1 2
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_width2 2
#include <MyFunctions.mqh>

input int InpBarCtrlNumBig=20;
input int InpBarCtrlNumSmall=5;
input int InpMaxSearchBarNum=20;

double BuyPrice[];
double SellPrice[];
double Signal[];

datetime last_time=0;
double l1;
double l2;
double l3;
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
   PlotIndexSetString(0,PLOT_LABEL,"AB=CD检测--Buy");
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(1,PLOT_LABEL,"AB=CD检测--Sell");

   ArraySetAsSeries(BuyPrice,true);
   ArraySetAsSeries(SellPrice,true);
   ArraySetAsSeries(Signal,true);
   
   ObjectsDeleteAll(0);
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

   int num_bar_check=InpMaxSearchBarNum*4+4;
   if(rates_total<num_bar_check) return 0;

   if(last_time==time[0]) return rates_total; // 没有产生新BAR，不进行指标计算
   last_time=time[0];

   int num_handle;
   if(prev_calculated<num_bar_check) num_handle=rates_total-num_bar_check;
   else num_handle=rates_total-prev_calculated;

   for(int i=num_handle-1;i>=0;i--)
     {
      BuyPrice[i]=EMPTY_VALUE;
      SellPrice[i]=EMPTY_VALUE;
      Signal[i]=0;
      // 寻找下跌形态的AB=CD的对应的位置
      if(IsMaxLeftRight(high,i+1,InpBarCtrlNumBig,1)) // D为极大值
        {
         for(int j=i+1;j<i+InpMaxSearchBarNum;j++)
           {
            if(IsMinLeftRight(low,j,InpBarCtrlNumSmall,InpBarCtrlNumBig)) // C为极小值
              {
               for(int k=j+1;k<j+InpMaxSearchBarNum;k++)
                 {
                  if(IsMaxLeftRight(high,k,InpBarCtrlNumBig,InpBarCtrlNumSmall)) // B为极大值
                    {
                     for(int l=k+1;l<k+InpMaxSearchBarNum;l++)
                       {
                        if(IsMinLeftRight(low,l,InpBarCtrlNumSmall,InpBarCtrlNumBig)) // A为极小值
                          {
                           l1=high[i+1]-low[j];
                           l2=high[k]-low[j];
                           l3=high[k]-low[l];
                           if(MathAbs(l1-l2)/SymbolInfoDouble(NULL,SYMBOL_POINT)<15&&high[i+1]>high[k]&&low[j]>low[l])
                             {
                              SellPrice[i]=open[i];
                              Signal[i]=-1;
                              string msg1="AB:"+DoubleToString(low[l],Digits())+"/"+DoubleToString(high[k],Digits())+"/"+DoubleToString(MathAbs(l1-l2),Digits());
                              string msg2="BC:"+DoubleToString(high[k],Digits())+"/"+DoubleToString(low[j],Digits());
                              string msg3="CD:"+DoubleToString(low[j],Digits())+"/"+DoubleToString(high[i+1],Digits());;
                              TrendCreate(0,msg1,0,time[l],low[l],time[k],high[k],clrRed);
                              TrendCreate(0,msg2,0,time[k],high[k],time[j],low[j],clrRed);
                              TrendCreate(0,msg3,0,time[j],low[j],time[i+1],high[i+1],clrRed);
                             }
                            break;
                          }
                       }
                    }
                 }
              }
           }
        }
      else if(IsMinLeftRight(low,i+1,InpBarCtrlNumBig,1)) // D为极小值
        {
         for(int j=i+1;j<i+InpMaxSearchBarNum;j++)
           {
            if(IsMaxLeftRight(high,j,InpBarCtrlNumSmall,InpBarCtrlNumBig)) // C为极大值
              {
               for(int k=j+1;k<j+InpMaxSearchBarNum;k++)
                 {
                  if(IsMinLeftRight(low,k,InpBarCtrlNumBig,InpBarCtrlNumSmall)) // B为极小值
                    {
                     for(int l=k+1;l<k+InpMaxSearchBarNum;l++)
                       {
                        if(IsMaxLeftRight(high,l,InpBarCtrlNumSmall,InpBarCtrlNumBig)) // A为极大值
                          {
                           l1=high[i+1]-low[j];
                           l2=high[k]-low[j];
                           l3=high[k]-low[l];
                           if(MathAbs(l1-l2)/SymbolInfoDouble(NULL,SYMBOL_POINT)<100&&high[i+1]>high[k]&&low[j]<low[l])
                             {
                              //BuyPrice[i]=open[i];
                              //Signal[i]=1;
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
      else continue;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
