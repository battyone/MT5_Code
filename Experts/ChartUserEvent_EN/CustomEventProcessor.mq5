//+------------------------------------------------------------------+
//|                                         CustomEventProcessor.mq5 |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include "CEventProcessor.mqh"


//---
CEventProcessor gEventProc(InpMagic);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   gExpertName=MQLInfoString(MQL_PROGRAM_NAME);
//--- start event processor
   if(gEventProc.Start())
     {
      //--- to log?
      if(InpIsLogging)
         PrintFormat("Expert <<%s>> successfully started.",gExpertName);
      return INIT_SUCCEEDED;
     }
//--- to log?
   if(InpIsLogging)
      PrintFormat("Expert <<%s>> has failed to start.",gExpertName);
//---
   return INIT_FAILED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   gEventProc.Finish();
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   //--- data structure
   SEventData data;
   data.lparam=lparam;
   data.dparam=dparam;
   data.sparam=sparam;
   //--- event processing
   gEventProc.ProcessEvent((ushort)id,data);
  }
//+------------------------------------------------------------------+
//| Expert new tick handling function                                |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   gEventProc.Main();
  }
//+------------------------------------------------------------------+
