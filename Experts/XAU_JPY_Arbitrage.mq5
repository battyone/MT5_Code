//+------------------------------------------------------------------+
//|                                                 XAU_JPY_Arib.mq5 |
//|                                                      Daixiaorong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Daixiaorong"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <Strategy\Samples\N_Arbitrage.mqh>

input double theta_times=4;
input int    windows=4325;
input bool   is_fix_lot=true;
input double m_fix_lot=1.00;
double Lots[]={1.00,1.00,1.00,2.00,3.00,4.00,5.00,0.8,1.10,1.15,1.56,2.18,2.35,3.05,4.27,4.27,4.27,4.27,4.27,4.27};
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CArbitrage *m_arbi=new CArbitrage();
   m_arbi.ExpertMagic(20170829);
   m_arbi.Timeframe(Period());
   m_arbi.ExpertSymbol(Symbol());
   m_arbi.ExpertName("XAUUSD_USDJPY_Arbitrage");
   m_arbi.SetSymbolPair("XAUUSD", PERIOD_M1,"USDJPY", PERIOD_M1);
   m_arbi.Window(windows);
   if(is_fix_lot)
     {
      m_arbi.FixLot(m_fix_lot);
     }
   else
     {
      m_arbi.LevelLot(Lots);
     }
   m_arbi.SetTakeProfitParams(19,50);
   m_arbi.InThetaTimes(theta_times);
   if(!Manager.AddStrategy(m_arbi))
      delete m_arbi;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
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
