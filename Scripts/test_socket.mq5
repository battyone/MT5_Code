//+------------------------------------------------------------------+
//|                                           scOnTickMarketWatch.mq5|
//|                                             Copyright 2019, IDTU |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, IDTU"
#property version   "1.00"


//socket数据发送函数
bool socksend(int sock,string request) 
{
   char req[];
   int  len=StringToCharArray(request,req)-1;
   if(len<0) return(false);
   return(SocketSend(sock,req,len)==len); 
}

//启动事件函数
void OnStart()
{
   long new_tick_time[];   
   long last_tick_time[];
   ushort po = 0;
   MqlTick new_tick;
   string symbols[];
   
   MqlRates bars[2];
   long new_bar_time[];
   long last_bar_time[30][5];
   ENUM_TIMEFRAMES period[] = {PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1};
   
   //存储发送数据的字符串变量
   string tosend_tick;
   string tosend_bar;
   int socket;
   
   long count = 0; //测试计数器
   
   //获取品种数量和名称
   int total = SymbolsTotal(true);
   ArrayResize(new_tick_time, total);
   ArrayResize(new_bar_time, total);
   ArrayResize(last_tick_time, total);
   ArrayResize(last_bar_time, total);
   ArrayResize(symbols, total);
   for(ushort pos=0; pos<total; pos++)
   {  
      symbols[pos]=SymbolName(pos,true);
      
   }
   
   //初始化时间数组
   ArrayInitialize(last_tick_time, 0);
   ArrayInitialize(last_bar_time, 0);
   
  
   while(!_StopFlag)
   {  
      for(int i=0; i<SymbolsTotal(true); i++)  //遍历每个品种
      {
         for(int j=0; j<ArraySize(period); j++)  //8个不同周期的bar
         {
            CopyRates(symbols[i],period[j],0,2,bars);
            if(bars[1].time > last_bar_time[i][j])
            {
               Print( " New bar on the symbol ", symbols[i], " ", bars[0].time," ",EnumToString(period[j]));
               last_bar_time[i][j] = bars[1].time;
            }
         }
      }
   }
   SocketClose(socket); //关闭套接字   
}
