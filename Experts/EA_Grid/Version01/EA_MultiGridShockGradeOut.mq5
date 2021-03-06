//+------------------------------------------------------------------+
//|                                    EA_MultiGridShockGradeOut.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "震荡网格--多网格对冲"
#property description "根据多空的不均衡度，开启对冲网格以降低不均衡度"
#property description "仓位重的方向优先进行出场检测"
#property description "参数设置1--手数序列:基础手数,序列类型,指数仓位控制数"
#property description "参数设置2--网格参数:网格间距,每手止盈,总止盈"

#include <strategy_czj\strategyGrid\Strategies\MultiGridShockStrategyGradeOut.mqh>
#include <Strategy\StrategiesList.mqh>

input double Inp_base_lots=0.01; // 基础手数
input GridLotsCalType Inp_lots_type=ENUM_GRID_LOTS_LINEAR;  // 手数类型
input int Inp_exp_num=12;  // 设置指数类型手数控制的仓位数

input int Inp_grid_gap=150; // 网格间距
input double Inp_grid_tp_per_lots=600; // 每手止盈
input double Inp_grid_tp_total=6;    // 总止盈

input uint Inp_magic=20181204;  // Magic
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CMultiGridShockStrategyGradeOut *s=new CMultiGridShockStrategyGradeOut();
   s.ExpertName("CMultiGridShockStrategyGradeOut");
   s.ExpertMagic(Inp_magic);
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.SetLotsParameter(Inp_base_lots,Inp_lots_type,Inp_exp_num);
   s.SetGridParameter(Inp_grid_gap,Inp_grid_tp_per_lots,Inp_grid_tp_total);
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

