//+------------------------------------------------------------------+
//|                                             EA_TriangularArb.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\special\TriangularArb.mqh>

input int Inp_open_points=50;// 开仓点
input int Inp_close_points=80;   // 反向平仓点
input int Inp_win_points=80;  // 止盈平仓点
input double Inp_lots=0.1; // 手数
input bool  Inp_Need_Standard=true; // 手数是否需要调整
input string Inp_symbol_selected="1,1,1,1,1,1,1";//EUR,GBP,AUD,NZD,CAD,CHF,JPY
input ulong Inp_Magic=3180501;

string str_selected[];
bool symbol_is_selected[7];
int num=StringSplit(Inp_symbol_selected,StringGetCharacter(",",0),str_selected);

CTriangularArb arb=new CTriangularArb();
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   for(int i=0;i<7;i++)
      symbol_is_selected[i]=int(str_selected[i])==1?true:false;
      
   arb.SetParameter(Inp_open_points,Inp_close_points,Inp_win_points,Inp_lots,Inp_Need_Standard);
   arb.SetMagic(Inp_Magic);
   arb.SelectSymbolSet(symbol_is_selected);
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
   datetime tl=TimeLocal();
   MqlDateTime tl_struct;
   TimeToStruct(tl,tl_struct);
   if(tl_struct.hour*60+tl_struct.min>5*60+50&&tl_struct.hour*60+tl_struct.min<6*60+10) return;  // alpari的品种日切换时间
   if(tl_struct.hour*60+tl_struct.min>4*60+50&&tl_struct.hour*60+tl_struct.min<5*60+10) return;  // aus品种的日切换时间
   arb.ArbCalculation();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnTimer()
  {

  }
//+------------------------------------------------------------------+
