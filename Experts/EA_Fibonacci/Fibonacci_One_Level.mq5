//+------------------------------------------------------------------+
//|                               FibonacciMultiSymbolMultiLevel.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\Fibonacci.mqh>
#include <Strategy\StrategiesList.mqh>

input int period_search_mode=12;   //搜素模式的大周期
input int range_period=4; //模式的最大数据长度
input int range_point=500; //短周期模式的最小点数差

input double open_level1=0.618; //开仓点
input double tp_level1=0.882; //止盈平仓点
input double sl_level1=-1.0; //止损平仓点
input double open_lots1=0.01; //开仓手数
input int Ea_Magic=118062601; // MAGIC

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   FibonacciRatioStrategy *strategy1;
   strategy1=new FibonacciRatioStrategy();
   strategy1.ExpertMagic(Ea_Magic);
   strategy1.Timeframe(_Period);
   strategy1.ExpertSymbol(_Symbol);
   strategy1.ExpertName("Fibonacci Ratio Strategy");
   strategy1.SetPatternParameter(period_search_mode,range_period,range_point);
   strategy1.SetOpenRatio(open_level1);
   strategy1.SetCloseRatio(tp_level1,sl_level1);
   strategy1.SetLots(open_lots1);
   strategy1.SetEventDetect(_Symbol,_Period);
   
   Manager.AddStrategy(strategy1);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
