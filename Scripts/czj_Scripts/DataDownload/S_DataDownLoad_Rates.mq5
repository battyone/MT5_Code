//+------------------------------------------------------------------+
//|                                         S_DataDownLoad_Rates.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs
#include <strategy_czj\common\strategy_common.mqh>
input datetime d_begin=D'2010.01.01';
input datetime d_end=D'2018.10.30';
input ENUM_TIMEFRAMES time_frame=PERIOD_M1;
input string Inp_sym="EURUSD";   // 设置下载数据对应的品种，0代表28个外汇

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   if(StringToInteger(Inp_sym)==0)
     {
      for(int i=0;i<28;i++)
        {
         DownLoadRates(SYMBOLS_28[i],time_frame,d_begin,d_end);
        }
     }
   else DownLoadRates(Inp_sym,time_frame,d_begin,d_end);
   
   
  }
void DownLoadRates(string symbol, ENUM_TIMEFRAMES tf,datetime d_b, datetime d_e)
   {
    MqlRates rates[];
    CopyRates(symbol,tf,d_b,d_e,rates);
    string file_name=symbol+"_"+EnumToString(tf)+".csv";
    int file_handle=FileOpen(file_name,FILE_READ|FILE_WRITE|FILE_CSV);
     FileWrite(file_handle,"time","open","high","low","close","real_volume","tick_volume","spread");
    for(int i=0;i<ArraySize(rates);i++)
      {
       FileWrite(file_handle,rates[i].time,rates[i].open,rates[i].high,rates[i].low,rates[i].close,rates[i].real_volume,rates[i].tick_volume,rates[i].spread);
      }
    FileClose(file_handle);
   }
//+------------------------------------------------------------------+
