//+------------------------------------------------------------------+
//|                              FibonacciOneLevelIndexParameter.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Fibonacci 回调入场趋势策略"
#property description "采用多个策略组合:多个品种，多个仓位"
#property description "参数集根据预定义，直接指定parameter_index(0~23)"

#include <strategy_czj\Fibonacci.mqh>
#include <Strategy\StrategiesList.mqh>
#include <FibonacciParameters.mqh>

input string Inp_Symbols="1,1,1,1,1,1,1"; // EURUSD,GBPUSD,AUDUSD,NZDUSD,USDCAD,USDCHF,USDJPY
input string Inp_parameter_index_combine="0,3,5";// 参数集组合对应的索引值
input string Inp_open_lots="0.01,0.01,0.01"; // 参数集对应的开仓手数
input int Ea_Magic=118062601; // 起始MAGIC

int arr_parameter_index[];
double arr_lots_combine[];
string symbols[7]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
string symbol_selected[];

int period_search_mode;   //搜素模式的大周期
int range_period; //模式的最大数据长度
int range_point; //短周期模式的最小点数差
double open_level1; //开仓点
double tp_level1; //止盈平仓点
double sl_level1; //止损平仓点

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string result1[];
   string result2[];

   int num_parameter=StringSplit(Inp_parameter_index_combine,StringGetCharacter(",",0),result1);
   StringSplit(Inp_open_lots,StringGetCharacter(",",0),result2);
   int num_symbols=StringSplit(Inp_Symbols,StringGetCharacter(",",0),symbol_selected);
   ArrayResize(arr_parameter_index,num_parameter);
   ArrayResize(arr_lots_combine,num_parameter);
   for(int i=0;i<num_parameter;i++)
     {
      arr_parameter_index[i]=StringToInteger(result1[i]);
      arr_lots_combine[i]=StringToDouble(result2[i]);
     }

   FibonacciRatioStrategy *strategy[];
   int num_strategy=num_symbols*num_parameter;
   ArrayResize(strategy,num_strategy);

   for(int j=0;j<num_symbols;j++)
     {
      for(int i=0;i<num_parameter;i++)
        {
         period_search_mode=FP_bar_search[arr_parameter_index[i]];   //搜素模式的大周期
         range_period=FP_bar_max[arr_parameter_index[i]]; //模式的最大数据长度
         range_point=FP_range_min[arr_parameter_index[i]]; //短周期模式的最小点数差
         open_level1=FP_open[arr_parameter_index[i]]; //开仓点
         tp_level1=FP_tp[arr_parameter_index[i]]; //止盈平仓点
         sl_level1=FP_sl[arr_parameter_index[i]]; //止损平仓点

         strategy[num_parameter*j+i]=new FibonacciRatioStrategy();
         strategy[num_parameter*j+i].ExpertMagic(Ea_Magic+num_parameter*j+i);
         strategy[num_parameter*j+i].Timeframe(_Period);
         strategy[num_parameter*j+i].ExpertSymbol(symbols[j]);
         strategy[num_parameter*j+i].ExpertName("Fibonacci Ratio Strategy"+string(num_parameter*j+i));
         strategy[num_parameter*j+i].SetPatternParameter(period_search_mode,range_period,range_point);
         strategy[num_parameter*j+i].SetOpenRatio(open_level1);
         strategy[num_parameter*j+i].SetCloseRatio(tp_level1,sl_level1);
         strategy[num_parameter*j+i].SetLots(arr_lots_combine[i]);
         strategy[num_parameter*j+i].SetEventDetect(symbols[j],_Period);
         if(StringToInteger(symbol_selected[j]))
           {
            Manager.AddStrategy(strategy[num_parameter*j+i]);
           }
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
