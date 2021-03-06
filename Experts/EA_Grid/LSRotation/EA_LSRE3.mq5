//+------------------------------------------------------------------+
//|                                                     EA_LSRE3.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyGrid\LongShortRotation\LSRE3.mqh>
#include <Strategy\StrategiesList.mqh>
//
input double Inp_base_lots=0.01; // 基础手数
input int Inp_rotation_pos_num=5;   // 开启轮转的仓位数
input int Inp_max_pos_num=20; // 最大的持仓数
input int Inp_gap_small=150;  // 小网格
input int Inp_gap_big=1500;   // 大网格
input double Inp_tp_total=500;   // 总盈利
input double Inp_tp_per_lots=200;   // 每手盈利

input uint Inp_magic=20181204;  // Magic
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CLSRE3 *s=new CLSRE3();
   s.ExpertName("CLSRE3");
   s.ExpertMagic(Inp_magic);
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.SetParameters(Inp_rotation_pos_num,Inp_max_pos_num,Inp_gap_small,Inp_gap_big,Inp_base_lots,Inp_tp_total,Inp_tp_per_lots);
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

