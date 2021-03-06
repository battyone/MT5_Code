//+------------------------------------------------------------------+
//|                                               EA_Grid_Simple.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridSimple.mqh>

input int Inp_points_add=300; // 网格加仓点数
input int Inp_points_win=600; // 网格出场止盈点数
input double Inp_base_lots=0.01; // 基础手数
input GridLotsCalType  Inp_lots_type=ENUM_GRID_LOTS_EXP_NUM;// 手数类型
input GridWinType Inp_win_type=ENUM_GRID_WIN_LAST; // 设置止盈点位的方式
input uint Inp_magic=20181010;   // Magic ID
input int Inp_pos_max=10;   // 手数类型--第n个仓位为1手，参数n的值
input ENUM_ORDER_TYPE_FILLING Inp_order_type=ORDER_FILLING_FOK;//FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)


CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridSimple *strategy=new CGridSimple();
   strategy.ExpertName("CGridSimple");
   strategy.ExpertMagic(Inp_magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init(Inp_points_add,Inp_points_win,Inp_base_lots,Inp_lots_type,Inp_win_type,Inp_pos_max);
   strategy.SetTypeFilling(Inp_order_type);  // FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)
   strategy.ReInitPositions();
   Manager.AddStrategy(strategy);
//---
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
