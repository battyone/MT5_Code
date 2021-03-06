//+------------------------------------------------------------------+
//|                                         EA_GridShockGradeOut.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "2.00"
#property description "震荡网格策略--分级出场"
#property description "    仓位小于三级,检测所有仓位的每手止盈和总止盈是否满足条件出场"
#property description "    仓位大于等于三级,检测最后几个仓位和最早仓位的每手止盈和总止盈是否满足条件出场"
#property description "参数设置1--手数序列:基础手数,序列类型,指数仓位控制数"
#property description "参数设置2--网格参数:网格间距,每手止盈,总止盈,仓位最大级数，多空方向"

#include <strategy_czj\strategyGrid\Strategies\GridShockStrategyGradeOut.mqh>
#include <Strategy\StrategiesList.mqh>

input double Inp_base_lots=0.01; // 基础手数
input GridLotsCalType Inp_lots_type=ENUM_GRID_LOTS_LINEAR;  // 手数类型
input int Inp_exp_num=12;  // 设置指数类型手数控制的仓位数

input int Inp_grid_gap=150; // 网格间距
input double Inp_grid_tp_per_lots=100; // 每手止盈
input double Inp_grid_tp_total=6;    // 总止盈
input int InpMaxLevel=15;  // 最大级数
input int InpLSMode=0;  // 0-多空，1-多，2-空
input ENUM_MARKET_EVENT_TYPE InpOpenType=MARKET_EVENT_TICK; // 开仓在tick还是bar上

input uint Inp_magic=20181204;  // Magic

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridShockStrategyGradeOut *s=new CGridShockStrategyGradeOut();   // 新建分级出场网格策略
   s.ExpertName("CGridShockStrategyGradeOut");  // 网格策略名称
   s.ExpertMagic(Inp_magic);
   s.ExpertSymbol(_Symbol);  
   s.Timeframe(_Period);    
   s.SetLotsParameter(Inp_base_lots,Inp_lots_type,Inp_exp_num);
   s.SetGridParameter(Inp_grid_gap,Inp_grid_tp_per_lots,Inp_grid_tp_total);
   s.SetMaxLevel(InpMaxLevel);
   s.SetLSMode(InpLSMode);
   s.SetEventOpen(InpOpenType);
   s.ReBuildPositionState();
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

