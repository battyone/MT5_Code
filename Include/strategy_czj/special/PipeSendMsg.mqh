//+------------------------------------------------------------------+
//|                                                  PipeSendMsg.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <CNamedPipes.mqh>

class CPipeSendMsg
  {
private:
   CNamedPipe        PipeManager;   // 命名管道处理器
   bool              pipe_connected;   // 管道是否连接标识
   string            msg;  // 发送的消息内容
public:
                     CPipeSendMsg(void);
                    ~CPipeSendMsg(void);
  };
