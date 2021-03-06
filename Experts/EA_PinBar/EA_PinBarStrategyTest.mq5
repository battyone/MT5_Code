//+------------------------------------------------------------------+
//|                                        EA_PinBarStrategyTest.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyPinBar\PinBar.mqh>
#include <Strategy\StrategiesList.mqh>
CStrategyList Manager;

input int Inp_ma_long=200; // 长均线周期
input int Inp_ma_short=24; // 短均线周期
input int Inp_rsi=12;   // RSI周期
input double Inp_lots=0.01;   // 基础手数
input double Inp_tp_conservated=1.618; // 激进止赢线
input double Inp_sl_conservated=2.618; // 激进止损线
input double Inp_tp_radical=0.618;  // 保守止赢线
input double Inp_sl_radical=0.1;  // 保守止损线
input int Inp_EA_Magic=418061901;   // EA MAGIC


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CPinBarStrategy *pinbar= new CPinBarStrategy();
   pinbar.ExpertName("PinBar");
   pinbar.ExpertMagic(Inp_EA_Magic);
   pinbar.Timeframe(_Period);
   pinbar.ExpertSymbol(_Symbol);
   pinbar.SetHandleParameters(Inp_ma_long, Inp_ma_short, Inp_rsi);
   pinbar.SetPositionParameters(Inp_lots,Inp_tp_conservated, Inp_sl_conservated, Inp_tp_radical,Inp_sl_radical);
   Manager.AddStrategy(pinbar);
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
