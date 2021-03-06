//+------------------------------------------------------------------+
//|                                      S_EA_TriangularArbWhile.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs
#include <strategy_czj\special\TriangularArb.mqh>

input int Inp_open_points=50;// 开仓点
input int Inp_close_points=80;   // 反向平仓点
input int Inp_win_points=80;  // 止盈平仓点
input double Inp_lots=0.1; // 手数
input bool  Inp_Need_Standard=true; // 手数是否需要调整
input string Inp_symbol_selected="1,1,1,1,1,1,1";//EUR,GBP,AUD,NZD,CAD,CHF,JPY
input ulong Inp_Magic=3180503;

string str_selected[];
bool symbol_is_selected[7];
int num=StringSplit(Inp_symbol_selected,StringGetCharacter(",",0),str_selected);

CTriangularArb arb=new CTriangularArb();
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   for(int i=0;i<7;i++)
      symbol_is_selected[i]=int(str_selected[i])==1?true:false;
      
   arb.SetParameter(Inp_open_points,Inp_close_points,Inp_win_points,Inp_lots,Inp_Need_Standard);
   arb.SetMagic(Inp_Magic);
   arb.SelectSymbolSet(symbol_is_selected);
   while(!IsStopped())
     {
      arb.ArbCalculation();
     }
  }
//+------------------------------------------------------------------+
