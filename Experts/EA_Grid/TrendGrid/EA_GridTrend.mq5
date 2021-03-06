//+------------------------------------------------------------------+
//|                                                 EA_GridTrend.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridTrendStrategy.mqh>

input double Inp_base_lots=0.01; // 基础手数
input int Inp_grid=150; // 加仓点数
input int Inp_tp_per_lots=20; // 每手止盈
input int Inp_tp_total=100; // 总盈利

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridTrendStrategy *strategy=new CGridTrendStrategy();
   strategy.ExpertName("CGridTrendStrategy");
   strategy.ExpertMagic(2018090401);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init(Inp_grid,Inp_tp_per_lots,Inp_base_lots,Inp_tp_total);
   Manager.AddStrategy(strategy);
   
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

