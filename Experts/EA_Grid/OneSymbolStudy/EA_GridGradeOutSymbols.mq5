//+------------------------------------------------------------------+
//|                                       EA_GridGradeOutSymbols.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridOneSymbolGradeOut.mqh>

input double Inp_base_lots=0.01; // 基础手数
input string Inp_symbols="USDJPY,EURGBP,AUDNZD,CADCHF"; // 品种
input string Inp_points_add="160,160,160,160"; // 网格大小
input string Inp_tp_per_lots="200,200,200,200"; // 每手止盈
input string Inp_tp_total="2,2,2,2"; // 总盈利
input string Inp_pos_num="15,15,15,15";  // 仓位数控制
input LotsType Inp_lots_type=ENUM_LOTS_LINEAR; // 手数序列类型
CStrategyList Manager;


string str_symbols[];
string str_add_points[];
string str_win_points_per_lots[];
string str_win_points[];
string str_pos_num[];
int num1=StringSplit(Inp_symbols,StringGetCharacter(",",0),str_symbols);
int num2=StringSplit(Inp_points_add,StringGetCharacter(",",0),str_add_points);
int num3=StringSplit(Inp_tp_per_lots,StringGetCharacter(",",0),str_win_points_per_lots);
int num4=StringSplit(Inp_tp_total,StringGetCharacter(",",0),str_win_points);
int num5=StringSplit(Inp_pos_num,StringGetCharacter(",",0),str_pos_num);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   for(int i=0;i<num1;i++)
     {
      CGridOneSymbolGradeOut *strategy=new CGridOneSymbolGradeOut();
      strategy.ExpertName("CGridOneSymbolGradeOut-"+str_symbols[i]);
      strategy.ExpertMagic(2018090401+i);
      strategy.Timeframe(_Period);
      strategy.ExpertSymbol(str_symbols[i]);
      strategy.Init(Inp_base_lots,int(str_pos_num[i]),int(str_add_points[i]),(int)(str_win_points_per_lots[i]),(int)(str_win_points[i]));
      strategy.SetLotsType(Inp_lots_type);
      Manager.AddStrategy(strategy);
     }
   
   
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

