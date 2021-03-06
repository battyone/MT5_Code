//+------------------------------------------------------------------+
//|                                                PipeCrossPlat.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Files\FilePipe.mqh>
#include <Trade\Trade.mqh>
#include <strategy_czj\common\strategy_common.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypeOperator
  {
   ENUM_OPERATOR_OPEN_LONG=1,
   ENUM_OPERATOR_OPEN_SHORT=2,
   ENUM_OPERATOR_CLOSE_SHORT=3,
   ENUM_OPERATOR_CLOSE_LONG=4,
   ENUM_OPERATOR_NULL=0
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypeOperatorRes
  {
   ENUM_OPERATOR_RES_OPEN_LONG_FAILED=1,
   ENUM_OPERATOR_RES_OPEN_SHORT_FAILED=2,
   ENUM_OPERATOR_RES_CLOSE_LONG_FAILED=3,
   ENUM_OPERATOR_RES_CLOSE_SHORT_FAILED=4,
   ENUM_OPERATOR_RES_SUCCESS=0
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPipeCrossPlat
  {
private:
   CFilePipe         PipeManager;   // 命名管道处理器
   CTrade            ExtTrade;   // 交易处理器
   bool              pipe_connected;   // 管道是否连接标识
   int               num_symbol; // 套利品种数
   string            symbols[];  // 外汇品种名称
   double            points[];   // 外汇品种最小点
   MqlTick           ticks[]; // 外汇tick报价
   int               ea_operators[];   //ea操作标识
   int               operator_res[];   //ea操作结果标识
   int               operator_exception[];   //ea异常处理标识
   double            base_lots;  //基本手数
   ulong             pos_id[];   // 记录上次操作的仓位id
private:
   void              SendTickData();   // 发送tick数据
   void              ReadOperator();   // 读取EA操作指示
   void              EaOperator();  // EA操作
   void              SendOperatorResult();   // 发送EA操作结果
   void              ReadExceptionHandle();  // 读取异常操作处理
   void              ExceptionHandle();   // 异常处理
   void              OpenLong(int index); // 开多
   void              OpenShort(int index);   // 开空
   void              ClosePosition(int index,TypeOperatorRes reason); // 平仓
   void              NoOperate(int index);   // 不进行开平仓操作
public:
                     CPipeCrossPlat(void);
                    ~CPipeCrossPlat(void){};
   bool              ConnectedToServer(string pipe_name); // 同服务器管道建立连接
   void              SetMagic(ulong ea_magic=60001){ExtTrade.SetExpertMagicNumber(ea_magic);};  // 设置magic
   void              SetLots(double lots){base_lots=lots;}; // 设置手数
   void              Run();   // 进行管道读写及EA操作
   bool              PipeConnected(void){return pipe_connected;};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPipeCrossPlat::CPipeCrossPlat(void)
  {
   num_symbol=7;
   ArrayCopy(symbols,SYMBOLS_7);
   ArrayResize(points,num_symbol);
   ArrayResize(ticks,num_symbol);
   ArrayResize(ea_operators,num_symbol);
   ArrayResize(operator_res,num_symbol);
   ArrayResize(operator_exception,num_symbol);
   ArrayResize(pos_id,num_symbol);
   for(int i=0;i<num_symbol;i++)
     {
      points[i]=SymbolInfoDouble(symbols[i],SYMBOL_POINT);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPipeCrossPlat::ConnectedToServer(string pipe_name)
  {
   if(PipeManager.Open("\\\\REN\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeManager.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("管道连接成功:",pipe_name);
      return pipe_connected=true;
     }
   if(PipeManager.Open("\\\\.\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeManager.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      Print("管道连接成功:",pipe_name);
      return pipe_connected=true;
     }
   Print("管道连接失败！");
   return pipe_connected=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPipeCrossPlat::Run()
  {
   while(!IsStopped() && pipe_connected)
     {
      SendTickData();   // 发送tick数据至管道
      ReadOperator();
      EaOperator();
      SendOperatorResult();
      //ReadExceptionHandle();
      //ExceptionHandle();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPipeCrossPlat::SendTickData(void)
  {
   for(int i=0;i<num_symbol;i++)
     {
      if(SymbolInfoTick(symbols[i],ticks[i]))
        {
         PipeManager.WriteInteger((int)(ticks[i].ask/points[i]));
         PipeManager.WriteInteger((int)(ticks[i].bid/points[i]));
        }
      else
        {
         PipeManager.WriteInteger(-1);
         PipeManager.WriteInteger(-1);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPipeCrossPlat::ReadOperator(void)
  {
   for(int i=0;i<num_symbol;i++)
     {
      if(!PipeManager.ReadInteger(ea_operators[i]))
        {
         pipe_connected=false;
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPipeCrossPlat::EaOperator(void)
  {
   for(int i=0;i<num_symbol;i++)
     {
      switch(ea_operators[i])
        {
         case ENUM_OPERATOR_OPEN_LONG:
            OpenLong(i);
            break;
         case ENUM_OPERATOR_OPEN_SHORT:
            OpenShort(i);
            break;
         case ENUM_OPERATOR_CLOSE_SHORT:
            ClosePosition(i,ENUM_OPERATOR_RES_CLOSE_SHORT_FAILED);
            break;
         case ENUM_OPERATOR_CLOSE_LONG:
            ClosePosition(i,ENUM_OPERATOR_RES_CLOSE_LONG_FAILED);
            break;
         case ENUM_OPERATOR_NULL:
            default:
            NoOperate(i);
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CPipeCrossPlat::OpenLong(int index)// 开多；
  {
   if(ExtTrade.PositionOpen(symbols[index],ORDER_TYPE_BUY,base_lots,ticks[index].ask,0,0,"buy-"+string(ticks[index].ask)))
     {
      Print("Long 开仓成功:",symbols[index],"ask:",ticks[index].ask,"result-price:",ExtTrade.ResultPrice());
      operator_res[index]=ENUM_OPERATOR_RES_SUCCESS;
      pos_id[index]=ExtTrade.ResultOrder();
     }
   else
     {
      Print("Long 开仓失败:",symbols[index]," Result Retcode:",ExtTrade.ResultRetcode());
      operator_res[index]=ENUM_OPERATOR_RES_OPEN_LONG_FAILED;
      pos_id[index]=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CPipeCrossPlat::OpenShort(int index)
  {
   if(ExtTrade.PositionOpen(symbols[index],ORDER_TYPE_SELL,base_lots,ticks[index].bid,0,0,"sell-"+string(ticks[index].bid)))
     {
      Print("Short 开仓成功:",symbols[index],ticks[index].bid,"result-price:",ExtTrade.ResultPrice());
      operator_res[index]=ENUM_OPERATOR_RES_SUCCESS;
      pos_id[index]=ExtTrade.ResultOrder();
     }
   else
     {
      Print("Short 开仓失败:",symbols[index]," Result Retcode:",ExtTrade.ResultRetcode());
      operator_res[index]=ENUM_OPERATOR_RES_OPEN_SHORT_FAILED;
      pos_id[index]=0;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CPipeCrossPlat::ClosePosition(int index,TypeOperatorRes reason)
  {
   if(ExtTrade.PositionClose(pos_id[index],"close"))
     {
      Print("平仓成功",symbols[index]);
      operator_res[index]=ENUM_OPERATOR_RES_SUCCESS;
      pos_id[index]=0;
     }
   else
     {
      Print("平仓失败", symbols[index], " ", EnumToString(reason));
      operator_res[index]=reason;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CPipeCrossPlat::NoOperate(int index)
  {
   operator_res[index]=ENUM_OPERATOR_RES_SUCCESS;//没有操作默认发送成功操作的指示
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CPipeCrossPlat::SendOperatorResult(void)
  {
   for(int i=0;i<num_symbol;i++)
     {
      PipeManager.WriteInteger(operator_res[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPipeCrossPlat::ReadExceptionHandle(void)
  {
   for(int i=0;i<num_symbol;i++)
     {
      PipeManager.ReadInteger(operator_exception[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CPipeCrossPlat::ExceptionHandle(void)
  {
   for(int i=0;i<num_symbol;i++)
     {
      if(operator_exception[i]==0) continue;
      else
        {
         while(!ExtTrade.PositionClose(pos_id[i]))
           {
            Sleep(250);
           }
        }
     }
  }
//+------------------------------------------------------------------+
