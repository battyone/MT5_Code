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
input string Inp_Symbols_enable="1,1,1,1,1,1,1";// EURUSD,GBPUSD,AUDUSD,NZDUSD,USDCAD,USDCHF,USDJPY
string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   string symbol_enable[];
   StringSplit(Inp_Symbols_enable,StringGetCharacter(",",0),symbol_enable); 
   FibonacciRatioStrategy *strategy1[7];
   for(int i=0;i<7;i++)
     {
      strategy1[i]=new FibonacciRatioStrategy();
      strategy1[i].ExpertMagic(Ea_Magic+i);
      strategy1[i].Timeframe(_Period);
      strategy1[i].ExpertSymbol(symbols[i]);
      strategy1[i].ExpertName("Fibonacci一级仓位多品种组合");
      strategy1[i].SetPatternParameter(period_search_mode,range_period,range_point);
      strategy1[i].SetOpenRatio(open_level1);
      strategy1[i].SetCloseRatio(tp_level1,sl_level1);
      strategy1[i].SetLots(open_lots1);
      strategy1[i].SetEventDetect(symbols[i],_Period);
      if(StringToInteger(symbol_enable[i]))
              {
               Manager.AddStrategy(strategy1[i]);
              }
      
     }
   
   
   

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
