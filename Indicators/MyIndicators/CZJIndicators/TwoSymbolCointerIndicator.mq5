//+------------------------------------------------------------------+
//|                                      TwoSymbolCointergration.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  1
#include <Math\Stat\Math.mqh>
#include <RingBuffer\RiSMA.mqh>
#include <RingBuffer\RiMaxMin.mqh>
#include <RingBuffer\RiGauss.mqh>
#include <Math\Stat\Normal.mqh>
#include <strategy_czj\strategyTwoArbitrage\common.mqh>

input string Inp_Major_Symbol="XAUUSD";
input string Inp_Minor_Symbol="USDJPY";
input CointergrationCalType Inp_Cal_Type=ENUM_COINTERGRATION_TYPE_MULTIPLY;
input int Inp_Ind_Cal_period=1440;
input IndicatorCalType Inp_Indicator_Type=ENUM_INDICATOR_TYPE_BIAS;
input bool Inp_Use_Prob=false;
input int Inp_Prob_Cal_period=4320;

double price_combine_indicator_prob[];
double price_combine_indicator[];
double price_combine[];
double price_major_symbol[];
double price_minor_symbol[];

CRiSMA ring_sma;
CRiMaxMin ring_maxmin;
CRiGaussProperty ring_gauss;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping   
   if(Inp_Use_Prob)
     {
      SetIndexBuffer(0,price_combine_indicator_prob,INDICATOR_DATA);
      IndicatorSetString(INDICATOR_SHORTNAME,EnumToString(Inp_Indicator_Type)+"-Prob");
      SetIndexBuffer(4,price_combine_indicator,INDICATOR_CALCULATIONS);
      IndicatorSetInteger(INDICATOR_LEVELS,4);
      IndicatorSetDouble(INDICATOR_MAXIMUM,1.01);
      IndicatorSetDouble(INDICATOR_MINIMUM,-0.01);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0.95);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,0.05);
     }
   else
     {
      SetIndexBuffer(0,price_combine_indicator,INDICATOR_DATA);
      IndicatorSetString(INDICATOR_SHORTNAME,EnumToString(Inp_Indicator_Type));
      SetIndexBuffer(4,price_combine_indicator_prob,INDICATOR_CALCULATIONS);
     }
   SetIndexBuffer(1,price_combine,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,price_major_symbol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,price_minor_symbol,INDICATOR_CALCULATIONS);

   ring_sma.SetMaxTotal(Inp_Ind_Cal_period);
   ring_maxmin.SetMaxTotal(Inp_Ind_Cal_period);
   ring_gauss.SetMaxTotal(Inp_Prob_Cal_period);
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
   double price_major[],price_minor[];
   MqlTick tick_major,tick_minor;
   int error_code;
// 第一次计算   
   if(prev_calculated==0)
     {
      for(int i=0;i<rates_total;i++)
        {
         while(CopyClose(Inp_Major_Symbol,_Period,time[i],1,price_major)==-1)
            Sleep(500);
         while(CopyClose(Inp_Minor_Symbol,_Period,time[i],1,price_minor)==-1)
            Sleep(500);
         price_major_symbol[i]=price_major[0];
         price_minor_symbol[i]=price_minor[0];
         price_combine[i]=CalCointergration(price_major_symbol[i],price_minor_symbol[i]);

         ring_sma.AddValue(price_combine[i]);
         ring_maxmin.AddValue(price_combine[i]);
         if(i<Inp_Ind_Cal_period) price_combine_indicator[i]=EMPTY_VALUE;
         else  price_combine_indicator[i]=CalIndicator(i);
         if(Inp_Use_Prob)
           {
            ring_gauss.AddValue(price_combine_indicator[i]);
            if(i<Inp_Ind_Cal_period+Inp_Prob_Cal_period)
              {
               price_combine_indicator_prob[i]=0;
              }
            else
               //price_combine_indicator_prob[i]=ring_gauss.Mean();
               price_combine_indicator_prob[i]=MathCumulativeDistributionNormal(ring_gauss.GetValue(Inp_Prob_Cal_period-1),ring_gauss.Mean(),sqrt(ring_gauss.StdDev()),error_code);
           }   
        }
     }
//     后续更新
   bool calc=false;
   for(int i=prev_calculated;i<rates_total;i++)
     {
      while(CopyClose(Inp_Major_Symbol,_Period,time[i],1,price_major)==-1)
         Sleep(500);
      while(CopyClose(Inp_Minor_Symbol,_Period,time[i],1,price_minor)==-1)
         Sleep(500);
      price_major_symbol[i]=price_major[0];
      price_minor_symbol[i]=price_minor[0];
      price_combine[i]=CalCointergration(price_major_symbol[i],price_minor_symbol[i]);

      ring_sma.AddValue(price_combine[i]);
      ring_maxmin.AddValue(price_combine[i]);
      price_combine_indicator[i]=CalIndicator(i);
      if(Inp_Use_Prob)
        {
         ring_gauss.AddValue(price_combine_indicator[i]);
         price_combine_indicator_prob[i]=MathCumulativeDistributionNormal(ring_gauss.GetValue(Inp_Prob_Cal_period-1),ring_gauss.Mean(),sqrt(ring_gauss.StdDev()),error_code);
         //price_combine_indicator_prob[i]=ring_gauss.Mean();
        }
      calc=true;
     }
// 更改最后一根柱线的价格指标（RingMaxMin的change value计算有问题不进行最后一个数据的变化更新）
   if(!calc&&!(Inp_Indicator_Type==ENUM_INDICATOR_TYPE_WILLIAM||Inp_Indicator_Type==ENUM_INDICATOR_TYPE_MAX||Inp_Indicator_Type==ENUM_INDICATOR_TYPE_MIN))
     {
      SymbolInfoTick(Inp_Major_Symbol,tick_major);
      SymbolInfoTick(Inp_Minor_Symbol,tick_minor);
      price_combine[rates_total-1]=CalCointergration((tick_major.ask+tick_major.bid)/2,(tick_minor.ask+tick_minor.bid)/2);
      ring_sma.ChangeValue(Inp_Ind_Cal_period-1,price_combine[rates_total-1]);
      ring_maxmin.ChangeValue(Inp_Ind_Cal_period-1,price_combine[rates_total-1]);
      price_combine_indicator[rates_total-1]=CalIndicator(rates_total-1);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double CalCointergration(double x,double y)
  {
   double res;
   switch(Inp_Cal_Type)
     {
      case ENUM_COINTERGRATION_TYPE_PLUS: res=x+y; break;
      case ENUM_COINTERGRATION_TYPE_MULTIPLY: res=x*y; break;
      case ENUM_COINTERGRATION_TYPE_MINUS: res=x-y; break;
      case ENUM_COINTERGRATION_TYPE_DIVIDE:res=x/y; break;
      case ENUM_COINTERGRATION_TYPE_LOG_DIFF: res=log(x)/log(y);break;
      case ENUM_COINTERGRATION_TYPE_MEAN: res=(x+y)/2;break;
      default:Print("Cointergration type not defined! Use plus method instead!");res=x+y; break;
     }
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalIndicator(int index)
  {
   double res;
   switch(Inp_Indicator_Type)
     {
      case ENUM_INDICATOR_TYPE_ORIGIN :
         res=price_combine[index];
         break;
      case ENUM_INDICATOR_TYPE_SMA :
         res=ring_sma.SMA();
         break;
      case ENUM_INDICATOR_TYPE_BIAS :
         res=(ring_sma.GetValue(ring_sma.GetMaxTotal()-1)-ring_sma.SMA())/ring_sma.SMA()*100;
         break;
      case ENUM_INDICATOR_TYPE_WILLIAM:
         res=100-(ring_maxmin.MaxValue()-ring_maxmin.GetValue(Inp_Ind_Cal_period-1))/(ring_maxmin.MaxValue()-ring_maxmin.MinValue())*100;
         break;
      case ENUM_INDICATOR_TYPE_MAX:
         res=ring_maxmin.MaxValue();
         break;
      case ENUM_INDICATOR_TYPE_MIN:
         res=ring_maxmin.MinValue();
         break;
      default:
         res=0;
         break;
     }
   return res;
  }
//+------------------------------------------------------------------+
