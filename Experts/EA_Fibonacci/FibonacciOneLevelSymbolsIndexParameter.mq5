//+------------------------------------------------------------------+
//|                              FibonacciOneLevelIndexParameter.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Fibonacci 回调入场趋势策略"
#property description "采用多个策略组合:多个品种，1个仓位"
#property description "参数集根据预定义，直接指定parameter_index(0~23)"

#include <strategy_czj\Fibonacci.mqh>
#include <Strategy\StrategiesList.mqh>
#include <FibonacciParameters.mqh>

input string Inp_Symbols="0,1,1,0,1,1,0"; // EURUSD,GBPUSD,AUDUSD,NZDUSD,USDCAD,USDCHF,USDJPY
input int parameter_index=5;// 参数组合对应的索引值
input double open_lots1=0.01; //开仓手数
//input string Inp_parameter_index_combine="0,3,5";// 参数集组合对应的索引值
//input string Inp_open_lots="0.01,0.01,0.01"; // 参数集对应的开仓手数
input int Ea_Magic=91180700; // 起始MAGIC


string symbols[7]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
string symbol_selected[];


 int period_search_mode=FP_bar_search[parameter_index];   //搜素模式的大周期
 int range_period=FP_bar_max[parameter_index]; //模式的最大数据长度
 int range_point=FP_range_min[parameter_index]; //短周期模式的最小点数差
 double open_level1=FP_open[parameter_index]; //开仓点
 double tp_level1=FP_tp[parameter_index]; //止盈平仓点
 double sl_level1=FP_sl[parameter_index]; //止损平仓点

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int num_symbols=StringSplit(Inp_Symbols,StringGetCharacter(",",0),symbol_selected);

   FibonacciRatioStrategy *strategy[];
   ArrayResize(strategy,num_symbols);

   for(int j=0;j<num_symbols;j++)
     {
         strategy[j]=new FibonacciRatioStrategy();
         strategy[j].ExpertMagic(Ea_Magic+j);
         strategy[j].Timeframe(_Period);
         strategy[j].ExpertSymbol(symbols[j]);
         strategy[j].ExpertName("Fibonacci Ratio Strategy"+string(j));
         strategy[j].SetPatternParameter(period_search_mode,range_period,range_point);
         strategy[j].SetOpenRatio(open_level1);
         strategy[j].SetCloseRatio(tp_level1,sl_level1);
         strategy[j].SetLots(open_lots1);
         strategy[j].SetEventDetect(symbols[j],_Period);
         strategy[j].ReInitPositions();
         if(StringToInteger(symbol_selected[j]))
           {
            Manager.AddStrategy(strategy[j]);
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
