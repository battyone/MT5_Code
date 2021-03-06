//+------------------------------------------------------------------
//|                                          SpeedTestPipeClient.mq5 |
//|                                      Copyright 2010, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------
#property copyright "Copyright 2010, Investeo.pl"
#property link      "http:/Investeo.pl"
#property version   "1.00"

#include <CNamedPipes.mqh>
CNamedPipe pipe;
//+------------------------------------------------------------------
//| Script program start function                                    |
//+------------------------------------------------------------------
void OnStart()
  {
   MqlTick outgoing;
   SymbolInfoTick(Symbol(), outgoing);
    
   //while(!pipe.Open(AccountInfoInteger(ACCOUNT_LOGIN)))
   while(!pipe.Open(20231716))
     {
      Print("管道未创建, 5 秒内重试...");
      if(GlobalVariableCheck("gvar1")==true) break;
     }
   Print("发送...");
   uint start=GetTickCount();
   for(int i=0;i<100000;i++)
      Print(pipe.WriteTick(outgoing));
   uint stop=GetTickCount();
   Print("发送时间"+IntegerToString(stop-start)+" [ms]");
   pipe.Close();
  }
//+------------------------------------------------------------------
