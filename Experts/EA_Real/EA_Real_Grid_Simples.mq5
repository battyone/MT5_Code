//+------------------------------------------------------------------+
//|                                         EA_Real_Grid_Simples.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridSimple.mqh>

input string Inp_symbols="AUDCHF,AUDJPY,EURJPY,NZDCAD"; // 品种对
input string Inp_points_add="200,300,400,250"; // 网格大小
input string Inp_points_win="500,750,610,790"; // 出场点数
input string Inp_pos_max="15,10,10,14";   // 参数n的值(第n个仓位为1手)
input string Inp_symbol_available="1,1,1,1";  // 设置品种对是否允许交易

input double Inp_base_lots=0.01;    // 基础手数
input uint Inp_magic=201811100;   // 第一个品种的Magic

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   string str_symbols[];
   string str_add_points[];
   string str_win_points[];
   string str_pos_num[];
   string str_available_sym[];
   
   int num1=StringSplit(Inp_symbols,StringGetCharacter(",",0),str_symbols);
   int num2=StringSplit(Inp_points_add,StringGetCharacter(",",0),str_add_points);
   int num3=StringSplit(Inp_points_win,StringGetCharacter(",",0),str_win_points);
   int num4=StringSplit(Inp_pos_max,StringGetCharacter(",",0),str_pos_num);
   int num5=StringSplit(Inp_symbol_available,StringGetCharacter(",",0),str_available_sym);
//---
   Print("策略进行初始化操作...");
   for(int i=0;i<num1;i++)
     {
      if(StringToInteger(str_available_sym[i])==0)  // 判断品种对是否允许交易
        {
         Print("品种对禁止交易:",str_symbols[i]);
         continue;
        }
      CGridSimple *strategy=new CGridSimple();
      strategy.ExpertName("CGridSimple-"+str_symbols[i]);
      strategy.ExpertMagic(Inp_magic+i);
      strategy.Timeframe(_Period);
      strategy.ExpertSymbol(str_symbols[i]);
      // 策略参数初始化
      Print("品种对:",str_symbols[i]," 网格大小",str_add_points[i]," 出场点数",str_win_points[i]," 仓位数",str_pos_num[i]);
      strategy.Init(StringToInteger(str_add_points[i]),StringToInteger(str_win_points[i]),Inp_base_lots,ENUM_GRID_LOTS_EXP_NUM,ENUM_GRID_WIN_LAST,StringToInteger(str_pos_num[i]));
      strategy.SetTypeFilling(ORDER_FILLING_FOK);
      strategy.ReInitPositions();   // 重新获取仓位信息至CStrategy ActivePosition
      //strategy.ReBuildPositionState(); // 重新获取仓位信息至grid_operate pos_state和last_open_price; ---已经包含在Init中了
      Manager.AddStrategy(strategy);
     }
    Print("策略初始化成功...");
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
