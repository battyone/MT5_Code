//+------------------------------------------------------------------+
//|                                                     PipeTest.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Files\FilePipe.mqh>
#include <Trade\Trade.mqh>

enum MonitorEventType
  {
   ENUM_MONITOR_EVENT_SEND_TICK=1,// 请求发送tick事件
   ENUM_MONITOR_EVENT_OPEN_POSITION=2,// 请求开仓事件
   ENUM_MONITOR_EVENT_CLOSE_POSITION=3 // 请求平仓事件
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPipeTest
  {
private:
   CFilePipe         PipeManager;   // 命名管道处理器
   MonitorEventType  m_event; // 记录监听到的事件
    
public:
   
   ulong             pos_id[];   // 记录上次操作的仓位id
   int               event;
   int               symbol_index;
   MqlTick           tick;
   ENUM_ORDER_TYPE   order;
   CTrade            trade;
   long p_id;
   int opt_res;
public:
                     CPipeTest(void){};
                    ~CPipeTest(void){};
   bool              ConnectedToServer(string pipe_name); // 同服务器管道建立连接
   void              EventHandle(); // 监听事件并进行对应处理
private:
   bool              SendTick(); 
   bool              OpenPosition();
   bool              ClosePosition();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPipeTest::ConnectedToServer(string pipe_name)
  {
   if(PipeManager.Open("\\\\REN\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeManager.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("管道连接成功:",pipe_name);
      return true;
     }
   if(PipeManager.Open("\\\\.\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeManager.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("管道连接成功:",pipe_name);
      return true;
     }
   Print("管道连接失败！");
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPipeTest::EventHandle(void)
  {
   PipeManager.ReadInteger(m_event);
   switch(m_event)
     {
      case  1:
         Print("Get Tick event");
         if(!PipeManager.ReadInteger(symbol_index))
           {
            Print("接受品种index失败");
           }
         Print("接收品种index",symbol_index);
         SymbolInfoTick(_Symbol,tick);
         
         if(!PipeManager.WriteStruct(tick))
           {
            Print("发送tick失败");
           }
         Print("Total size", sizeof(tick));  
         Print("成功发送tick(time):",tick.time,"/size:",sizeof(tick.time));
         Print("成功发送tick(ask/bid):",tick.ask,"/",tick.bid,"/size:",sizeof(tick.ask),"/size:",sizeof(tick.bid));
         Print("成功发送tick(last/volume):",tick.last,"/",tick.volume,"/size:",sizeof(tick.last),"/size:",sizeof(tick.volume));
         Print("成功发送tick(msc):",tick.time_msc,"/size:",sizeof(tick.time_msc));
         Print("成功发送tick(flags):",tick.flags,"/size:",sizeof(tick.flags));
         break;
      case 2:
         Print("Open Position event");
         if(!PipeManager.ReadInteger(symbol_index))
           {
            Print("接受品种index失败");
           }
         if(!PipeManager.ReadInteger(order))
           {
            Print("接受订单类型失败");
           }
         trade.PositionOpen(_Symbol,order,0.01,0,0,0,"test");
         if(!PipeManager.WriteLong(trade.ResultOrder()))
           {
            Print("发送仓位id失败");
           }
         Print("成功下单并发送仓位id:",trade.ResultOrder());
         break;
      case 3:
         Print("Close Position event");
         if(!PipeManager.ReadLong(p_id))
           {
            Print("读取仓位号失败");
           }
         Print("将进行平仓操作，仓位为:",p_id);
         
         if(!trade.PositionClose(p_id))
            {
             Print("平仓失败:",trade.ResultRetcode());
             opt_res=4;
            }
         else
           {
            Print("平仓成功:",trade.ResultRetcode());
             opt_res=2;
           }
         if(!PipeManager.WriteInteger(opt_res))
           {
            Print("发送平仓结果失败");
            return;
           }
         Print("发送平仓结果成功:",opt_res);
         break;
      default:
         Print("未识别的事件");
         break;
     }
  }
//+------------------------------------------------------------------+
