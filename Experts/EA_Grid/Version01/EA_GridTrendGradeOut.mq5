//+------------------------------------------------------------------+
//|                                         EA_GridTrendGradeOut.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "趋势网格策略"
#property description "趋势网格--设定上下趋势突破边界"
#property description "当价格运动的方向突破的边界与上次突破的边界相反时，进行该方向的趋势单"
#property description "检测多空最近的两个仓位的盈利情况，如果满足止盈条件就全部平仓"
#property description "参数设置1--手数序列:基础手数,序列类型,指数仓位控制数"
#property description "参数设置2--网格参数:边界宽度,每手止盈,总止盈"
#include <strategy_czj\strategyGrid\Strategies\GridTrendStrategyGradeOut.mqh>
#include <Strategy\StrategiesList.mqh>

input double Inp_base_lots=0.1; // 基础手数
input GridLotsCalType Inp_lots_type=ENUM_GRID_LOTS_LINEAR;  // 手数类型
input int Inp_exp_num=12;  // 设置指数类型手数控制的仓位数

input int Inp_grid_gap=100; // 网格间距
input double Inp_grid_tp_per_lots=100; // 每手止盈
input double Inp_grid_tp_total=20;    // 总止盈

input uint Inp_magic=20181204;  // Magic

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridTrendStrategyGradeOut *s=new CGridTrendStrategyGradeOut();
   s.ExpertName("CGridTrendStrategyGradeOut");
   s.ExpertMagic(Inp_magic);
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.SetLotsParameter(Inp_base_lots,Inp_lots_type,Inp_exp_num);
   s.SetGridParameters(Inp_grid_gap,Inp_grid_tp_per_lots,Inp_grid_tp_total);
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
