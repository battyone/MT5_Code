//+------------------------------------------------------------------+
//|                                                 DetectorMACD.mqh |
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
class CDetectorMACD:public CStrategy
  {
private:
   string            symbols[];
   ENUM_TIMEFRAMES   periods[];
   int               handle_detector[];
   int               handle_macd[];
   double            h_signal[];
   double            h_index[];
   double            h_macd_value[];
   MqlTick           latest_price;
   string            msg;
   int               num_p;
   int               num_s;
   CFilePipe         pipe_manager;
   bool              pipe_connected;
public:
                     CDetectorMACD(void){};
                    ~CDetectorMACD(void){};
   void              SetSymbols();
   void              SetPeriods();
   bool              ConnectPipeServer(string pipe_name);
   void              InitHandles(int ma_fast=12,int ma_slow=26,int sma=9,ENUM_APPLIED_PRICE apply_close=PRICE_CLOSE,int search_bars=100,int extreme_bars=2,double range_price=10,double range_macd=0.0003,bool need_draw=false);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              SendMsg(string msg_);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMACD::SetSymbols(void)
  {
   ArrayResize(symbols,30);
   symbols[0]="XAUUSD";
   bool is_custom;
   if(SymbolExist("WTI",is_custom)) symbols[1]="WTI";
   else symbols[1]="XTIUSD";
   
   ArrayCopy(symbols,SYMBOLS_28,2,0);
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMACD::SetPeriods(void)
  {
   ENUM_TIMEFRAMES tfs[]={PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1};
//ENUM_TIMEFRAMES tfs[]={PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4};
   ArrayCopy(periods,tfs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDetectorMACD::ConnectPipeServer(string pipe_name)
  {
   Print("连接管道:"+pipe_name);
   pipe_connected=false;
   int counter=0;
   while(!pipe_connected && counter<5)
     {
      counter++;
      if(pipe_manager.Open("\\\\REN\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN|FILE_ANSI)!=INVALID_HANDLE) pipe_connected=true;
      else if(pipe_manager.Open("\\\\.\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN|FILE_ANSI)!=INVALID_HANDLE)  pipe_connected=true;
      if(!pipe_connected) Sleep(3000);
      Print("第"+string(counter)+"次连接结果:",pipe_connected);
     }
   return pipe_connected;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMACD::InitHandles(int ma_fast=12,int ma_slow=26,int sma=9,ENUM_APPLIED_PRICE apply_close=PRICE_CLOSE,int search_bars=100,int extreme_bars=2,double range_price=10,double range_macd=0.0003,bool need_draw=false)
  {
   num_s=ArraySize(symbols);
   num_p=ArraySize(periods);
   ArrayResize(handle_detector,num_p*num_s);
   ArrayResize(handle_macd,num_p*num_s);
   for(int i=0;i<num_s;i++)
     {
      for(int j=0;j<num_p;j++)
        {
         int index=i*num_p+j;
         handle_detector[index]=iCustom(symbols[i],periods[j],"CZJIndicators\\Detectors\\MacdDetector2",ma_fast,ma_slow,sma,apply_close,search_bars,extreme_bars,range_price,range_macd,false);
         handle_macd[index]=iMACD(symbols[i],periods[j],12,26,9,PRICE_CLOSE);
         AddBarOpenEvent(symbols[i],periods[j]);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMACD::SendMsg(string msg_)
  {
   Print(msg_);
   SendMail("MACD Detectors",msg_);
   SendNotification(msg_);
   if(pipe_connected)
     {
      pipe_manager.WriteString(msg_);
      Print("成功发送管道消息");
      Sleep(500); // 给服务器管道读取预留时间，可能后续会有bug
     }
   else
     {
      Print("管道消息未发送成功！");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMACD::OnEvent(const MarketEvent &event)
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
               CopyBuffer(handle_detector[index],2,0,1,h_signal);
               CopyBuffer(handle_detector[index],3,0,1,h_index);
               CopyBuffer(handle_detector[index],4,0,100,h_macd_value);
               
               ArraySetAsSeries(h_signal,true);
               ArraySetAsSeries(h_index,true);
               ArraySetAsSeries(h_macd_value,true);
               
               //if(periods[j]==PERIOD_H1) // 用于测试是否准时发送消息
               //  {
               //   msg=symbols[i]+"@"+EnumToString(periods[j])+" Time-"+TimeToString(Time[0]);
               //   SendMsg(msg);
               //  }
               if(h_signal[0]==-1)
                 {
                  msg=symbols[i]+" On "+EnumToString(periods[j])+"MACD to Sell,China Time:"+TimeToString(TimeLocal())+",Current Price:"+NormalizeDouble(latest_price.bid,Digits());
                  SendMsg(msg);
                 }
               else if(h_signal[0]==1)
                 {
                  msg=symbols[i]+" On "+EnumToString(periods[j])+"MACD to Buy,China Time:"+TimeToString(TimeLocal())+",Current Price:"+NormalizeDouble(latest_price.ask,Digits());
                  SendMsg(msg);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDetectorMACDOneSymbol:public CStrategy
  {
private:
   int               handle_detector;
   int               handle_macd;
   double            h_signal[];
   double            h_index[];
   double            h_macd_value[];
   string            msg;
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              SendMsg(string msg_);
public:
                     CDetectorMACDOneSymbol(void){};
                    ~CDetectorMACDOneSymbol(void){};
   void              InitHandle();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMACDOneSymbol::InitHandle(void)
  {
   handle_detector=iCustom(ExpertSymbol(),Timeframe(),"CZJIndicators\\Detectors\\MacdDetector2");
   handle_macd=iMACD(ExpertSymbol(),Timeframe(),12,26,9,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMACDOneSymbol::OnEvent(const MarketEvent &event)
  {
   if(event.type==MARKET_EVENT_BAR_OPEN && event.period==Timeframe() && event.symbol==ExpertSymbol())
     {
      CopyBuffer(handle_detector,2,0,1,h_signal);
      CopyBuffer(handle_detector,3,0,1,h_index);
      CopyBuffer(handle_detector,4,0,100,h_macd_value);
      ArraySetAsSeries(h_signal,true);
      ArraySetAsSeries(h_index,true);
      ArraySetAsSeries(h_macd_value,true);
      if(h_signal[0]==-1)
        {
         msg=ExpertSymbol()+" On "+EnumToString(Timeframe())+" MACD背离 To Sell,Time:"+TimeToString(Time[0])+
             ",Location:"+DoubleToString(h_index[0])+
             ",Price:"+DoubleToString(High[0+2],Digits())+">"+DoubleToString(High[2+(int)h_index[0]],Digits())+
             ",MACD:"+DoubleToString(h_macd_value[0+2],5)+"<"+DoubleToString(h_macd_value[0+2+int(h_index[0])],5);
         SendMsg(msg);
        }
      else if(h_signal[0]==1)
        {
         msg=ExpertSymbol()+" On "+EnumToString(Timeframe())+" MACD背离 To Buy,Time:"+TimeToString(Time[0])+
             ",Location:"+DoubleToString(h_index[0])+
             ",Price:"+DoubleToString(Low[2],Digits())+"<"+DoubleToString(Low[2+(int)h_index[0]],Digits())+
             ",MACD:"+DoubleToString(h_macd_value[2],5)+">"+DoubleToString(h_macd_value[2+(int)h_index[0]],5);
         SendMsg(msg);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDetectorMACDOneSymbol::SendMsg(string msg_)
  {
   Print(msg_);
   SendMail("MACD Detectors",msg_);
   SendNotification(msg_);
  }
//+------------------------------------------------------------------+
