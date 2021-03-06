//+------------------------------------------------------------------+
//|                                             EA_Detector_Test.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Files\FilePipe.mqh>

input string InpPipeName="test"; // 管道名称
input string InpTimeSeconds=60;

CFilePipe         pipe_manager;  // 管道管理器
bool pipe_connected;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(InpTimeSeconds);
   
   Print("连接管道:"+InpPipeName);
   pipe_connected=false;
   int counter=0;
   while(!pipe_connected && counter<5)
     {
      counter++;
      if(pipe_manager.Open("\\\\REN\\pipe\\"+InpPipeName,FILE_READ|FILE_WRITE|FILE_BIN|FILE_ANSI)!=INVALID_HANDLE) pipe_connected=true;
      else if(pipe_manager.Open("\\\\.\\pipe\\"+InpPipeName,FILE_READ|FILE_WRITE|FILE_BIN|FILE_ANSI)!=INVALID_HANDLE) pipe_connected=true;
      if(!pipe_connected) Sleep(3000);
      Print("第"+string(counter)+"次连接结果:",pipe_connected);
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
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   string msg_="This is a test msg from OnTime";
   Print(msg_);
   if(pipe_connected)
     {
      if(pipe_manager.WriteString(msg_))
         {
          Print("成功发送管道消息");
         }
      
     }
   else Print("管道消息未发送成功！");
  }
//+------------------------------------------------------------------+
