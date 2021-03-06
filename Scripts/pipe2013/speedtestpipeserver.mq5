//+------------------------------------------------------------------
//|                                          SpeedTestPipeServer.mq5 |
//|                                      Copyright 2010, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------
#property copyright "Copyright 2010, Investeo.pl"
#property link      "http:/Investeo.pl"
#property version   "1.00"

#property script_show_inputs
#include <CNamedPipes.mqh>

input int account=50231716;
bool tickReceived;
uint start,stop;

CNamedPipe pipe;
//+------------------------------------------------------------------
//| Script program start function                                    |
//+------------------------------------------------------------------
void OnStart()
  {
   int i=0;
   if(pipe.Create(account)==true)
      if(pipe.Connect()==true)
         Print("管道已连接");

   do
     {
      tickReceived=pipe.ReadTick();
      if(i==0) start=GetTickCount();
      if(tickReceived==false)
        {
         if(kernel32::GetLastError()==ERROR_BROKEN_PIPE)
           {
            Print("客户端从管道断开 "+pipe.GetPipeName());
            pipe.Disconnect();
            break;
           }
        }
      else i++;
     }
   while(tickReceived==true);
   stop=GetTickCount();

   if(i>0)
     {
      Print(IntegerToString(i)+" 即时价收到.");
      i=0;
     };
   
   pipe.Close();
   Print("服务器: 接收时间 "+IntegerToString(stop-start)+" [ms]");

  }

//+------------------------------------------------------------------
