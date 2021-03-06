//+------------------------------------------------------------------+
//|                                                 DetectorBase.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Files\FilePipe.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDetectorBase:public CStrategy
  {
protected:
   string            symbols[];  // 监控的品种
   ENUM_TIMEFRAMES   periods[];  // 监控的周期
   int               h_detector[];  // 监控的指标句柄
   double            h_signal[]; // 指标对应的信号
   MqlTick           latest_price;  // tick报价
   string            msg;  // 信息

   int               num_p;   // 周期数
   int               num_s;   // 品种数
   CFilePipe         pipe_manager;  // 管道管理器
   bool              pipe_connected;   // 管道是否连接
public:
                     CDetectorBase(void){};
                    ~CDetectorBase(void){};
   void              SetSymbols(bool for_test=false);  // 设置监控的品种对
   void              SetPeriods(bool for_test=false);  // 设置监控的周期
   void              SetSymbols(string &s_arr[]);  // 设置监控的品种对
   void              SetPeriods(ENUM_TIMEFRAMES &p_arr[]);  // 设置监控的周期
   bool              ConnectPipeServer(string pipe_name);   // 连接管道服务器
protected:
   virtual void      OnEvent(const MarketEvent &event);  // 时间处理
   virtual void      SignalCheckAndOperateAt(int h_index,int s_index,int p_index){};  // 对指定索引进行指标信号的相关的处理 
   virtual void      CheckPositionOpenAt(int h_index,int s_index,int p_index){};  // 对指定索引进行指标信号的开仓操作
   void              SendMsg(string msg_,string mail_title="Detectors");   // 发送消息
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorBase::SetSymbols(bool for_test=false)
  {
   if(for_test)
     {
      ArrayResize(symbols,1);
      num_s=1;
      symbols[0]=ExpertSymbol();
      return;
     }
   ArrayResize(symbols,30);
   symbols[0]="XAUUSD";
   bool is_custom;
   if(SymbolExist("WTI",is_custom)) symbols[1]="WTI";
   else symbols[1]="XTIUSD";
   ArrayCopy(symbols,SYMBOLS_28,2,0);
   num_s=ArraySize(symbols);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorBase::SetSymbols(string &s_arr[])
  {
   ArrayCopy(symbols,s_arr);
   num_s=ArraySize(symbols);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorBase::SetPeriods(bool for_test=false)
  {
   if(for_test)
     {
      num_p=2;
      ArrayResize(periods,num_p);
      periods[0]=Timeframe();
      periods[1]=PERIOD_H4;
      return;
     }
   ENUM_TIMEFRAMES tfs[]={PERIOD_H1,PERIOD_H4,PERIOD_D1};
   ArrayCopy(periods,tfs);
   num_p=ArraySize(periods);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorBase::SetPeriods(ENUM_TIMEFRAMES &p_arr[])
  {
   ArrayCopy(periods,p_arr);
   num_p=ArraySize(periods);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDetectorBase::ConnectPipeServer(string pipe_name)
  {
   Print("连接管道:"+pipe_name);
   pipe_connected=false;
   int counter=0;
   while(!pipe_connected && counter<5)
     {
      counter++;
      if(pipe_manager.Open("\\\\REN\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN|FILE_ANSI)!=INVALID_HANDLE) pipe_connected=true;
      else if(pipe_manager.Open("\\\\.\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN|FILE_ANSI)!=INVALID_HANDLE) pipe_connected=true;
      if(!pipe_connected) Sleep(3000);
      Print("第"+string(counter)+"次连接结果:",pipe_connected);
     }
   return pipe_connected;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorBase::SendMsg(string msg_,string mail_title="Detectors")
  {
   Print(msg_);
   SendMail(mail_title,msg_);
   SendNotification(msg_);
   if(pipe_connected)
     {
      pipe_manager.WriteString(msg_);
      Print("成功发送管道消息");
      Sleep(500); // 给服务器管道读取预留时间，可能后续会有bug
     }
   else Print("管道消息未发送成功！");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorBase::OnEvent(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_BAR_OPEN)
     {
      for(int i=0;i<num_s;i++)
        {
         if(event.symbol!=symbols[i]) continue;
         SymbolInfoTick(symbols[i],latest_price);
         for(int j=0;j<num_p;j++)
           {
            if(event.period==periods[j])
              {
               int index=i*num_p+j;
               SignalCheckAndOperateAt(index,i,j);
               CheckPositionOpenAt(index,i,j);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
