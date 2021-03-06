//+------------------------------------------------------------------+
//|                                                       EA_PCA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyCombination\strategyCombinationRSI.mqh>

input int Inp_period=200;
input double Inp_rsi_up=70;
input double Inp_rsi_down=30;
input int Inp_win_points=200;
input int Inp_lots=1.0;
input int Inp_pca_index=0;
input double Inp_coef_EURUSD=1;
input double Inp_coef_GBPUSD=1;
input double Inp_coef_AUDUSD=1;
input double Inp_coef_NZDUSD=1;
input double Inp_coef_USDCAD=1;
input double Inp_coef_USDCHF=1;
input double Inp_coef_USDJPY=1;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double coef_choose[7];
   coef_choose[0]=Inp_coef_EURUSD;
   coef_choose[1]=Inp_coef_GBPUSD;
   coef_choose[2]=Inp_coef_AUDUSD;
   coef_choose[3]=Inp_coef_NZDUSD;
   coef_choose[4]=Inp_coef_USDCAD;
   coef_choose[5]=Inp_coef_USDCHF;
   coef_choose[6]=Inp_coef_USDJPY;
 
   CStrategyCombinationRSI *strategy=new CStrategyCombinationRSI();
   strategy.ExpertName("CombineRSI策略");
   strategy.ExpertMagic(51804400);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.InitStrategy(Inp_period,Inp_rsi_up,Inp_rsi_down,coef_choose,Inp_win_points,Inp_lots);
   Manager.AddStrategy(strategy);
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
