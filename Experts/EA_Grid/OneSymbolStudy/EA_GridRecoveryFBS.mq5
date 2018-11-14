//+------------------------------------------------------------------+
//|                                           EA_GridRecoveryFBS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridRecoveryFBS.mqh>

input string Inp_symbols="EURGBP,EURUSD,GBPUSD";
input string Inp_points_add="40,50,60";
input string Inp_points_win="40,40,40";
input double Inp_base_lots=0.01;
input GridLotsCalType  Inp_lots_type=ENUM_GRID_LOTS_FBS;
input GridWinType Inp_win_type=ENUM_GRID_WIN_COST;
input uint Inp_magic=20181010;
input string Inp_pos_max="15,15,15";   // 手数类型--第n个仓位为1手，参数n的值
input ENUM_ORDER_TYPE_FILLING Inp_order_type=ORDER_FILLING_FOK;//FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)

CStrategyList Manager;

string str_symbols[];
string str_add_points[];
string str_win_points[];
string str_pos_num[];
int num1=StringSplit(Inp_symbols,StringGetCharacter(",",0),str_symbols);
int num2=StringSplit(Inp_points_add,StringGetCharacter(",",0),str_add_points);
int num3=StringSplit(Inp_points_win,StringGetCharacter(",",0),str_win_points);
int num4=StringSplit(Inp_pos_max,StringGetCharacter(",",0),str_pos_num);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---   
    for(int i=0;i<num1;i++)
     {
      CGridRecoveryFBS *strategy=new CGridRecoveryFBS();
      strategy.ExpertName("CGridRecoveryFBS-"+string(i));
      strategy.ExpertMagic(Inp_magic+i);
      strategy.Timeframe(_Period);
      strategy.ExpertSymbol(str_symbols[i]);
      strategy.Init(StringToInteger(str_add_points[i]),StringToInteger(str_win_points[i]),Inp_base_lots,Inp_lots_type,Inp_win_type,StringToInteger(str_pos_num[i]));
      strategy.SetTypeFilling(Inp_order_type);
      strategy.ReInitPositions();
      Manager.AddStrategy(strategy);
     }
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

