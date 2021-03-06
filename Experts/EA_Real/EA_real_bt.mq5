//+------------------------------------------------------------------+
//|                              FibonacciOneLevelIndexParameter.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "用于回测和实盘中相应的策略组合的结果"
#property description "策略组合1：Fibonacci-5号参数在GBPUSD,AUDUSD,USDCAD,USDCHF的组合,手数0.05"
#property description "策略组合2：Fibonacci-3号参数在EURUSD,GBPUSD,AUDUSD,NZDUSD,USDCAD,USDCHF,USDJPY的组合,手数0.01"

#include <strategy_czj\Fibonacci.mqh>
#include <Strategy\StrategiesList.mqh>
#include <FibonacciParameters.mqh>

string symbols[7]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   // Fibonacci-5号策略
   FibonacciRatioStrategy *strategy5[7];
   bool bool_5[7];
   ArrayInitialize(bool_5,true);
   bool_5[0]=false;
   bool_5[3]=false;
   bool_5[6]=false;
   for(int j=0;j<7;j++)
     {
      strategy5[j]=new FibonacciRatioStrategy();
      strategy5[j].ExpertMagic(911807100+j);
      strategy5[j].Timeframe(_Period);
      strategy5[j].ExpertSymbol(symbols[j]);
      strategy5[j].ExpertName("Fibo-5:"+string(j));
      strategy5[j].SetPatternParameter(FP_bar_search[5],FP_bar_max[5],FP_range_min[5]);
      strategy5[j].SetOpenRatio(FP_open[5]);
      strategy5[j].SetCloseRatio(FP_tp[5],FP_sl[5]);
      strategy5[j].SetLots(0.05);
      strategy5[j].SetEventDetect(symbols[j],_Period);
      strategy5[j].ReInitPositions();
      if(bool_5[j])
        {
         Manager.AddStrategy(strategy5[j]);
        }
     }
   // Fibonacci-3号策略
   FibonacciRatioStrategy *strategy3[7];
   bool bool_3[7];
   ArrayInitialize(bool_3,true);
   for(int j=0;j<7;j++)
     {
      strategy3[j]=new FibonacciRatioStrategy();
      strategy3[j].ExpertMagic(911807200+j);
      strategy3[j].Timeframe(_Period);
      strategy3[j].ExpertSymbol(symbols[j]);
      strategy3[j].ExpertName("Fibo-3:"+string(j));
      strategy3[j].SetPatternParameter(FP_bar_search[3],FP_bar_max[3],FP_range_min[3]);
      strategy3[j].SetOpenRatio(FP_open[3]);
      strategy3[j].SetCloseRatio(FP_tp[3],FP_sl[3]);
      strategy3[j].SetLots(0.01);
      strategy3[j].SetEventDetect(symbols[j],_Period);
      strategy3[j].ReInitPositions();
      if(bool_3[j])
        {
         Manager.AddStrategy(strategy3[j]);
        }
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
