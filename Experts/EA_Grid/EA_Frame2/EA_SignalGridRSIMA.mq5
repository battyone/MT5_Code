//+------------------------------------------------------------------+
//|                                           EA_SignalGridRSIMA.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "基于RSI和MA信号的网格策略"

#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridFrame2\SignalRsiMaGridStrategy.mqh>

input double Inp_base_lots=0.01;
input GridLotsCalType Inp_l_type=ENUM_GRID_LOTS_LINEAR;
input int  Inp_num_pos=15;
input int Inp_gap=300;
input int Inp_tp_per=200;
input int Inp_tp_total=200;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CSignalRsiMaGridStrategy *strategy=new CSignalRsiMaGridStrategy();
   strategy.ExpertName("CSignalRsiMaGridStrategy");
   strategy.ExpertMagic(2018090401);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init();
   strategy.SetLotsParameter(Inp_base_lots,Inp_l_type,Inp_num_pos);
   strategy.SetParameters(Inp_gap,Inp_tp_total,Inp_tp_per);
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

