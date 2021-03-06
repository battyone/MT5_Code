//+------------------------------------------------------------------+
//|                                                  EA_ArbTest2.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <Arbitrage\ArbitrageStrategy.mqh>

input string symbol_x="XAUUSD";//品种一
input string symbol_y="USDJPY";//品种二
input int num_ts=600;//协整周期
input double lots_x=0.08;//品种一手数
input double lots_y=0.12;//品种二手数
input CointergrationCalType coin_cal_type=ENUM_COINTERGRATION_TYPE_MULTIPLY;//协整序列计算方法
input IndicatorType indicator_type=ENUM_INDICATOR_ORIGIN;//计算协整采用的指标
input double p_down=0.15;//套利下界
input double p_up=0.8;//套利上界
input double take_profits=20;//获利止盈 
input uint ea_magic=888801;//ea标识符

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   CArbitrageStrategy *arb =new CArbitrageStrategy();
   arb.ExpertMagic(ea_magic);
   arb.ExpertSymbol(symbol_x);
   arb.Timeframe(PERIOD_M1);
   arb.ExpertName("Arbitrage"+string(ea_magic));
   arb.SetEventDetect(symbol_x,PERIOD_M1);
   arb.SetEventDetect(symbol_y,PERIOD_M1);
   arb.SetSymbolsInfor(symbol_x,symbol_y,PERIOD_M1,num_ts,lots_x,lots_y);
   arb.SetCointergrationInfor(coin_cal_type,indicator_type);
   arb.SetOpenCloseParameter(p_down,p_up,take_profits);
   arb.ReInitPositions();
   
   Manager.AddStrategy(arb);
   
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
