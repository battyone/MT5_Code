//+------------------------------------------------------------------+
//|                                      SymbolsCharaterAnalysis.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs 
#include <Math\Alglib\alglib.mqh>
#include <strategy_czj\common\strategy_common.mqh>
input string Inp_Symbols="EURUSD";

CAlglib alg_op;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   ENUM_TIMEFRAMES period_arr[]={PERIOD_MN1,PERIOD_W1,PERIOD_D1,PERIOD_H4,PERIOD_H1,PERIOD_M15,PERIOD_M5,PERIOD_M1};
   
   string path_file="statics.csv";
   int handle_file=FileOpen(path_file,FILE_WRITE|FILE_CSV);
   if(handle_file!=INVALID_HANDLE)
     {
      FileWrite(handle_file,
                "symbol",
                "period",
                "max",
                "min",
                "mean",
                "sigma"
                );
     for(int i=0;i<28;i++)
     {
      for(int j=0;j<ArraySize(period_arr);j++)
        {
          double range_max,range_min,range_mean,range_var;
          CalStatics(SYMBOLS_28[i],period_arr[j],range_max,range_min,range_mean,range_var);
          FileWrite(handle_file,
                    SYMBOLS_28[i],
                    EnumToString(period_arr[j]),
                    NormalizeDouble(range_max,0),
                    NormalizeDouble(range_min,0),
                    NormalizeDouble(range_mean,0),
                    NormalizeDouble(MathSqrt(range_var),0)
                    );
          Print("symbol:",SYMBOLS_28[i],",Period:",EnumToString(period_arr[j]),",max:",NormalizeDouble(range_max,0),",min:",NormalizeDouble(range_min,0),",mean:",NormalizeDouble(range_mean,0),",sigma:",NormalizeDouble(MathSqrt(range_var),0));
        }
     }
      FileClose(handle_file);
      Print("Write data OK!");
     }
   else
      Print("打开文件错误",GetLastError());
  }
//+------------------------------------------------------------------+

void CalStatics(string s, ENUM_TIMEFRAMES tf, double &max_range, double &min_range, double &mean_range, double &var_range)
   {
    MqlRates rates[];
    double range[];
    max_range=DBL_MIN;
    min_range=DBL_MAX;
    double d=SymbolInfoDouble(s,SYMBOL_POINT);
    datetime d1=D'2016.01.01';
    datetime d2=D'2018.01.01';
    CopyRates(s,tf,d1,d2,rates);
    int size=ArraySize(rates);
    ArrayResize(range,size);
    for(int i=0;i<size;i++)
      {
       range[i]=(rates[i].high-rates[i].low)/d;
       if(max_range<range[i]) max_range=range[i];
       if(min_range>range[i]) min_range=range[i];
      }
    double sk,kur;
    alg_op.SampleMoments(range,mean_range,var_range,sk,kur);
   }