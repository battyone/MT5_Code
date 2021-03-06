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


input string symbol_pairs="1,1,1,1"; // XAUJPY,EURCHF,AUDCAD,XAUXAG

input double lots_x=0.01;//品种一手数
input double lots_y=0.01;//品种二手数
input IndicatorType indicator_type=ENUM_INDICATOR_ORIGIN;//计算协整采用的指标
input double p_down=0.05;//套利下界
input double p_up=0.95;//套利上界
input uint ea_magic=888800;//ea标识符

input int num_ts_1=4680;//XAUJPY协整周期
input int num_ts_2=600;//EURCHF协整周期
input int num_ts_3=600;//AUDCAD协整周期
input int num_ts_4=6000;//XAUXAG协整周期

input double take_profits_1=2.0;//XAUJPY获利止盈 
input double take_profits_2=2;//EURCHF获利止盈 
input double take_profits_3=2;//AUDCAD获利止盈 
input double take_profits_4=4.5;//XAUXAG获利止盈 

CStrategyList Manager;
string symbol_xs[]={"XAUUSD","EURUSD","AUDUSD","XAUUSD"};
string symbol_ys[]={"USDJPY","USDCHF","USDCAD","XAGUSD"};
CointergrationCalType coin[]={ENUM_COINTERGRATION_TYPE_MULTIPLY,ENUM_COINTERGRATION_TYPE_MULTIPLY,ENUM_COINTERGRATION_TYPE_MULTIPLY,ENUM_COINTERGARTION_TYPE_DIVIDE};
int num_ts[4];

double take_profits[4];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   num_ts[0]=num_ts_1;
   num_ts[1]=num_ts_2;
   num_ts[2]=num_ts_3;
   num_ts[3]=num_ts_4;
   take_profits[0]=take_profits_1;
   take_profits[1]=take_profits_2;
   take_profits[2]=take_profits_3;
   take_profits[3]=take_profits_4;
   
   string results[];
   StringSplit(symbol_pairs,StringGetCharacter(",",0),results);
   
   for(int i=0;i<4;i++)
     {
      if(results[i]!="1")  continue;
      CArbitrageStrategy *arb =new CArbitrageStrategy();
      arb.ExpertMagic(ea_magic+i);
      arb.ExpertSymbol(symbol_xs[i]);
      arb.Timeframe(_Period);
      arb.ExpertName("Arbitrage"+string(ea_magic+i));
      arb.SetEventDetect(symbol_xs[i],_Period);
      arb.SetEventDetect(symbol_ys[i],_Period);
      arb.SetSymbolsInfor(symbol_xs[i],symbol_ys[i],_Period,num_ts[i],lots_x,lots_y);
      arb.SetCointergrationInfor(coin[i],indicator_type);
      arb.SetOpenCloseParameter(p_down,p_up,take_profits[i]);
      arb.ReInitPositions();
      Manager.AddStrategy(arb);
     }      
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
