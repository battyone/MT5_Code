//+------------------------------------------------------------------+
//|                                           EA_Detector_Pinbar.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyDetectors\DetectorPinBar.mqh>

input string InpPipeName="dpinbar"; // 管道名称

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CDetectorPinBar *s=new CDetectorPinBar();
   s.ExpertName("Pinbar检测");
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.ExpertMagic(111);
   
   s.SetSymbols();
   ENUM_TIMEFRAMES tfs[]={PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1};
   s.SetPeriods(tfs);
   
   s.ConnectPipeServer(InpPipeName);
   s.InitHandles();
   Manager.AddStrategy(s);
   
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
