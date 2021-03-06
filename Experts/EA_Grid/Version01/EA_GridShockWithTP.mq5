//+------------------------------------------------------------------+
//|                                           EA_GridShockWithTP.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "震荡网格策略--带设置止盈线出场"
#property description "参数设置1--手数序列:基础手数,序列类型,指数仓位控制数"
#property description "参数设置2--网格参数:网格间距,止盈点位,止盈方式"
#include <strategy_czj\strategyGrid\Strategies\GridShockStrategyWithTP.mqh>
#include <Strategy\StrategiesList.mqh>

input double Inp_base_lots=0.01; // 基础手数
input GridLotsCalType Inp_lots_type=ENUM_GRID_LOTS_EXP;  // 手数类型
input int Inp_exp_num=12;  // 设置指数类型手数控制的仓位数
input int Inp_grid_gap=300; // 网格间距
input int Inp_grid_tp=600; // 止盈点位
input GridWinType Inp_win_type=ENUM_GRID_WIN_LAST;    // 设置止盈线的方式
input uint Inp_magic=20181204;  // Magic

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridShockStrategyWithTP *s=new CGridShockStrategyWithTP();
   s.ExpertName("CGridShockStrategyWithTP");
   s.ExpertMagic(Inp_magic);
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.SetLotsParameter(Inp_base_lots,Inp_lots_type,Inp_exp_num);
   s.SetGridParameters(Inp_grid_gap,Inp_grid_tp,Inp_win_type);
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
