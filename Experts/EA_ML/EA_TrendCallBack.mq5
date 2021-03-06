//+------------------------------------------------------------------+
//|                                             EA_TrendCallBack.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRobot\TrendCallBack.mqh>

input int InpMapIndex=0;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string syms[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   for(int i=0;i<7;i++)
     {
      CTrendCallBack *s=new CTrendCallBack();
      s.ExpertMagic(i+10);
      s.ExpertName("趋势回调追踪"+i);
      s.ExpertSymbol(syms[i]);
      s.Timeframe(_Period);
      s.Init();
      s.SetMappingIndex(InpMapIndex);
      Manager.AddStrategy(s);
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
