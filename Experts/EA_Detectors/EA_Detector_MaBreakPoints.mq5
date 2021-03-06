//+------------------------------------------------------------------+
//|                                    EA_Detector_MaBreakPoints.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyDetectors\DetectorMaBreakPoints.mqh>

input string InpPipeName="dmabreakpoints"; // 管道名称
input int InpLastBarNum=24;      // 判断价格突破的bar数
input int InpMAPeriod=24;  // 均线bar数
input int InpExtremeLeftBarNum=5;   // 均线极值点判断左边的bar数
input int InpExtremeRightBarNum=1;   // 均线极值点判断右的bar数
input int InpDistExtreme=2;   // 极值点距离当前点的位置距离要求(扣除了right bar数)

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CDetectorMaBreakPoints *s=new CDetectorMaBreakPoints();
   s.ExpertName("均线拐点监控");
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.ExpertMagic(111);
   
   s.SetSymbols();
   ENUM_TIMEFRAMES tfs[]={PERIOD_H1,PERIOD_H4,PERIOD_D1};
   s.SetPeriods(tfs);
   
   s.ConnectPipeServer(InpPipeName);
   s.InitHandles(InpLastBarNum,InpMAPeriod,InpExtremeLeftBarNum,InpExtremeRightBarNum,InpDistExtreme);
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
