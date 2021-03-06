//+------------------------------------------------------------------+
//|                                                     socketEA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\SymbolInfo.mqh>
#include <RiskManager\RiskManager.mqh>

input string address = "127.0.0.1";
input int port = 9091;

int socket;
long account=AccountInfoInteger(ACCOUNT_LOGIN);
//+------------------------------------------------------------------+
//|EA初始化                                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   socket=SocketCreate();
   Print("本机账户号：",account);
   Print("等待下一次请求...");
   //EventSetTimer(1);
   EventSetMillisecondTimer(10);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   SocketClose(socket);
  }
//+------------------------------------------------------------------+
//|计时器函数                                                        |
//|每秒向服务器请求一次连接                                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   socket=SocketCreate();
   if(socket!=INVALID_HANDLE)
     {
      if(SocketConnect(socket,address,port,100))
        {
         Print("连接上服务器",address,":",port);
         send_package(socket,string(account));
         string len=HTTPRecv(socket);
         Print("len:",len);
         string received=HTTPRecv(socket, int(len));
         Print("本机账户号：",account,",从服务器接收的信息：",received);
         if(received=="open")
         {
            Print("开仓");
            position_open();
         }
         else if(received=="close")
         {
            Print("平仓");
            position_close();       
         }
         else if(received=="current")
         {
            Print("查询当前持仓");
            position_get_all();             
         }
         else if(received=="info")
         {
            Print("账户信息");
            send_history(socket);
            Print("账户信息发送完毕");
            send_package(socket,"over");
         }
         else if(received=="current2")
         {
            Print("查询指定ID的当前持仓");
            position_get_single(); 
         }
         else
           {
            Print("没有收到消息，关闭socket");
            //send_package(socket,"no data");
           }

         Print("等待下一次请求...");
        }
      SocketClose(socket);
     }
  }
//+------------------------------------------------------------------+
//|接受服务器信息（账户数据）             |
//+------------------------------------------------------------------+
string HTTPRecv(int sock,int l = 4,uint timeout = 100)
{
   char   rsp[]; 
   string result; 
   uint   timeout_check=GetTickCount()+timeout;
   int    len_result = 0;
//--- 读取套接数据，直至套接数据不长过超时且仍然存在 
   do 
     { 
      uint len=SocketIsReadable(sock); 
      if(len && len_result < l) 
        { 
         int rsp_len; 
         rsp_len=SocketRead(socket,rsp,l-len_result,timeout); 
         //--- 分析响应 
         if(rsp_len>0) 
           { 
            result+=CharArrayToString(rsp,0,rsp_len); 
            len_result=StringLen(result);
           } 
        } 
     } 
   while(GetTickCount()<timeout_check && len_result<l && !IsStopped()); 
   return result; 
}
//+------------------------------------------------------------------+
//|封装发送信息,在字符串前面加上其长度，格式化为4位                  |
//+------------------------------------------------------------------+
bool send_package(int sock,string tosend_string)
  {
   char req[];
   int  len=StringToCharArray(tosend_string,req,0,-1,CP_UTF8)-1;
   string temp=IntegerToString(len,4);
   string tosend=temp+tosend_string;
   return socksend(socket,tosend);
  }
//+------------------------------------------------------------------+
//|向服务器传输信息，传输成功返回true，失败返回false                 |
//+------------------------------------------------------------------+
bool socksend(int sock,string request)
  {
   char req[];
   int  len=StringToCharArray(request,req,0,-1,CP_UTF8)-1;
   if(len<0) return(false);
   return(SocketSend(sock,req,len)==len);
  }
//+------------------------------------------------------------------+
//|开仓                                                              |
//+------------------------------------------------------------------+
void position_open()
{
   string data_len = HTTPRecv(socket);
   string data = HTTPRecv(socket, int(data_len));
   Print("data:", data);
   string sep=";";
   ushort u_sep;
   string result[];
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(data,u_sep,result);
   string symbol = result[0];
   double lot = (double)result[1];
   ulong MA_MAGIC = ulong(result[2]);
   string type = result[3];
   ENUM_ORDER_TYPE signal = WRONG_VALUE;
   if(type == "BUY")  signal = ORDER_TYPE_BUY;
   else if(type == "SELL")  signal = ORDER_TYPE_SELL;
   string comment = result[4];
   MqlTradeRequest   m_request;         // request data
   MqlTradeResult    m_result;          // result data
   ZeroMemory(m_request);
   ZeroMemory(m_result);
   PositionOpen(m_request, m_result, symbol, signal, lot,
                      SymbolInfoDouble(symbol,signal==ORDER_TYPE_SELL ? SYMBOL_BID:SYMBOL_ASK),
                      0,0,MA_MAGIC,comment,10);
   ulong Order_Id = m_result.order;
   Print("Order_Id:",Order_Id);
   if(Order_Id > 0)
     {
      uint time_out = GetTickCount() + 1000;
      while(!PositionSelectByTicket(Order_Id) && GetTickCount() < time_out  && !IsStopped())
        {
         Sleep(1);
        }
      string tosend = "";
      tosend += (string)PositionGetInteger(POSITION_TICKET) + ",";
      tosend += (string)PositionGetInteger(POSITION_TIME) + ",";
      tosend += (string)PositionGetInteger(POSITION_TIME_MSC) + ",";
      tosend += (string)PositionGetInteger(POSITION_TIME_UPDATE) + ",";
      tosend += (string)PositionGetInteger(POSITION_TIME_UPDATE_MSC) + ",";
      tosend += (string)PositionGetInteger(POSITION_TYPE) + ",";
      tosend += (string)PositionGetInteger(POSITION_MAGIC) + ",";
      tosend += (string)PositionGetInteger(POSITION_IDENTIFIER) + ",";
      tosend += (string)PositionGetInteger(POSITION_REASON) + ",";
      
      tosend += (string)PositionGetDouble(POSITION_VOLUME) + ",";
      tosend += (string)PositionGetDouble(POSITION_PRICE_OPEN) + ",";
      tosend += (string)PositionGetDouble(POSITION_SL) + ",";
      tosend += (string)PositionGetDouble(POSITION_TP) + ",";
      tosend += (string)PositionGetDouble(POSITION_PRICE_CURRENT) + ",";
      tosend += (string)PositionGetDouble(POSITION_SWAP) + ",";
      tosend += (string)PositionGetDouble(POSITION_PROFIT) + ",";
      
      tosend += PositionGetString(POSITION_SYMBOL) + ",";
      string temp = PositionGetString(POSITION_COMMENT);
      StringReplace(temp,",",";");
      tosend += temp + ",";
      tosend += PositionGetString(POSITION_EXTERNAL_ID);
      
      send_package(socket,tosend); 
      Print("tosend:", tosend);      
     }
   else
     {
      string tosend = "0,0,0,0,0,0,0,0,0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,,,";
      send_package(socket,tosend); 
      Print("tosend:", tosend); 
     }
}
//+------------------------------------------------------------------+
//|平仓                                                              |
//+------------------------------------------------------------------+
void position_close()
{
   string data_len = HTTPRecv(socket);
   string data = HTTPRecv(socket, int(data_len));
   Print("data:", data);
   string sep=";";
   ushort u_sep;
   string result[];
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(data,u_sep,result);

   ulong MA_MAGIC = ulong(result[0]);
   ulong ticket = ulong(result[1]);
   string comment = result[2];

   MqlTradeRequest   m_request;         // request data
   MqlTradeResult    m_result;          // result data
   ZeroMemory(m_request);
   ZeroMemory(m_result);
   PositionClose(m_request, m_result, ticket, MA_MAGIC, comment, 10);
   string Order_Id = string(m_result.order);
   send_package(socket,Order_Id); 
}
//+------------------------------------------------------------------+
//|部分平仓                                                              |
//+------------------------------------------------------------------+
void position_close_partial()
{
   string data_len = HTTPRecv(socket);
   string data = HTTPRecv(socket, int(data_len));
   Print("data:", data);
   string sep=";";
   ushort u_sep;
   string result[];
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(data,u_sep,result);

   double lot = (double)result[0];
   ulong MA_MAGIC = ulong(result[1]);
   ulong ticket = ulong(result[2]);
   string comment = result[3];

   MqlTradeRequest   m_request;         // request data
   MqlTradeResult    m_result;          // result data
   ZeroMemory(m_request);
   ZeroMemory(m_result);
   PositionClosePartial(m_request, m_result, ticket, lot, MA_MAGIC, comment, 10);
   string Order_Id = string(m_result.order);
   send_package(socket,Order_Id); 
}
//+------------------------------------------------------------------+
//|获取当前持仓信息                                                  |
//+------------------------------------------------------------------+
void position_get_all()
{
   string tosend = "\n";
   for(int i=0;i<PositionsTotal();i++)
     {
        ulong ticket=PositionGetTicket(i);
        PositionSelectByTicket(ticket);
        tosend += (string)PositionGetInteger(POSITION_TICKET) + ",";
        tosend += (string)PositionGetInteger(POSITION_TIME) + ",";
        tosend += (string)PositionGetInteger(POSITION_TIME_MSC) + ",";
        tosend += (string)PositionGetInteger(POSITION_TIME_UPDATE) + ",";
        tosend += (string)PositionGetInteger(POSITION_TIME_UPDATE_MSC) + ",";
        tosend += (string)PositionGetInteger(POSITION_TYPE) + ",";
        tosend += (string)PositionGetInteger(POSITION_MAGIC) + ",";
        tosend += (string)PositionGetInteger(POSITION_IDENTIFIER) + ",";
        tosend += (string)PositionGetInteger(POSITION_REASON) + ",";
        
        tosend += (string)PositionGetDouble(POSITION_VOLUME) + ",";
        tosend += (string)PositionGetDouble(POSITION_PRICE_OPEN) + ",";
        tosend += (string)PositionGetDouble(POSITION_SL) + ",";
        tosend += (string)PositionGetDouble(POSITION_TP) + ",";
        tosend += (string)PositionGetDouble(POSITION_PRICE_CURRENT) + ",";
        tosend += (string)PositionGetDouble(POSITION_SWAP) + ",";
        tosend += (string)PositionGetDouble(POSITION_PROFIT) + ",";
        
        tosend += PositionGetString(POSITION_SYMBOL) + ",";
        string temp = PositionGetString(POSITION_COMMENT);
        StringReplace(temp,",",";");
        tosend += temp + ",";
        tosend += PositionGetString(POSITION_EXTERNAL_ID) + "\n";
     }
   send_package(socket,tosend); 
}
//+------------------------------------------------------------------+
//|获取指定position的持仓信息                                                  |
//+------------------------------------------------------------------+
void position_get_single()
{
   string tosend = "";
   // 接收持仓ID
   string data_len = HTTPRecv(socket);
   string data = HTTPRecv(socket, int(data_len));
   Print("data:", data);
   
   ulong position_id = ulong(data);
   PositionSelectByTicket(position_id);
   tosend += (string)PositionGetInteger(POSITION_TICKET) + ",";
   tosend += (string)PositionGetInteger(POSITION_TIME) + ",";
   tosend += (string)PositionGetInteger(POSITION_TIME_MSC) + ",";
   tosend += (string)PositionGetInteger(POSITION_TIME_UPDATE) + ",";
   tosend += (string)PositionGetInteger(POSITION_TIME_UPDATE_MSC) + ",";
   tosend += (string)PositionGetInteger(POSITION_TYPE) + ",";
   tosend += (string)PositionGetInteger(POSITION_MAGIC) + ",";
   tosend += (string)PositionGetInteger(POSITION_IDENTIFIER) + ",";
   tosend += (string)PositionGetInteger(POSITION_REASON) + ",";
   
   tosend += (string)PositionGetDouble(POSITION_VOLUME) + ",";
   tosend += (string)PositionGetDouble(POSITION_PRICE_OPEN) + ",";
   tosend += (string)PositionGetDouble(POSITION_SL) + ",";
   tosend += (string)PositionGetDouble(POSITION_TP) + ",";
   tosend += (string)PositionGetDouble(POSITION_PRICE_CURRENT) + ",";
   tosend += (string)PositionGetDouble(POSITION_SWAP) + ",";
   tosend += (string)PositionGetDouble(POSITION_PROFIT) + ",";
   
   tosend += PositionGetString(POSITION_SYMBOL) + ",";
   string temp = PositionGetString(POSITION_COMMENT);
   StringReplace(temp,",",";");
   tosend += temp + ",";
   tosend += PositionGetString(POSITION_EXTERNAL_ID);
        
   send_package(socket,tosend); 
}
//+------------------------------------------------------------------+
//|发送账户信息                                                      |
//+------------------------------------------------------------------+
void send_history(int sock)
  {
//获取账户信息
   CRiskManager *rm=new CRiskManager();
   rm.RefreshInfor();

   bool flag=false;
   int num=0;

//获取全部的历史交易记录
   for(int i=0; i<rm.deals.Total(); i++)
     {
      string tosend;
      CDealInfor *deal=rm.deals.At(i);
      tosend += (string)deal.deal_time + ",";
      tosend += (string)deal.deal_ticket + ",";
      tosend += (string)deal.order_id + ",";
      tosend += (string)deal.symbol + ",";
      tosend += (string)deal.deal_type + ",";
      tosend += (string)deal.deal_entry + ",";
      tosend += (string)deal.deal_volume + ",";
      tosend += (string)deal.deal_price + ",";
      tosend += (string)deal.deal_commission + ",";
      tosend += (string)deal.deal_swap + ",";
      tosend += (string)deal.deal_profit + ",";
      tosend += (string)deal.deal_magic_id + ",";
      tosend += (string)deal.deal_position_id + ",";
      tosend += (string)deal.order_sl + ",";
      tosend += (string)deal.order_tp + ",";
      string temp = (string)deal.deal_comment;
      StringReplace(temp,",",";");
      tosend += temp + "\n";

      if(send_package(sock,tosend)==false)
        {
         flag=true;
         num++;
        }
     }

//获取强平的交易记录
   for(int i=0; i<rm.deals_force.Total(); i++)
     {
      string tosend;
      CDealInfor *deal=rm.deals_force.At(i);
      tosend += (string)deal.deal_time + ",";
      tosend += (string)deal.deal_ticket + ",";
      tosend += (string)deal.order_id + ",";
      tosend += (string)deal.symbol + ",";
      tosend += (string)deal.deal_type + ",";
      tosend += (string)deal.deal_entry + ",";
      tosend += (string)deal.deal_volume + ",";
      tosend += (string)deal.deal_price + ",";
      tosend += (string)deal.deal_commission + ",";
      tosend += (string)deal.deal_swap + ",";
      tosend += (string)deal.deal_profit + ",";
      tosend += (string)deal.deal_magic_id + ",";
      tosend += (string)deal.deal_position_id + ",";
      tosend += (string)deal.order_sl + ",";
      tosend += (string)deal.order_tp + ",";
      string temp = (string)deal.deal_comment;
      StringReplace(temp,",",";");
      tosend += temp + "\n";

      if(send_package(sock,tosend)==false)
        {
         flag=true;
         num++;
        }
     }

   if(flag==true)
     {
      int n=rm.deals.Total()+rm.deals_force.Total();
      Print("总共有",n,"行信息，","其中有",num,"行信息发送失败!");
     }

   delete rm;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Open position                                                    |
//+------------------------------------------------------------------+
bool PositionOpen(MqlTradeRequest &m_request, MqlTradeResult &m_result,const string symbol,const ENUM_ORDER_TYPE order_type,const double volume,
                          const double price,const double sl,const double tp,const ulong m_magic,const string comment, const ulong deviation)
  {
//--- check
   if(order_type!=ORDER_TYPE_BUY && order_type!=ORDER_TYPE_SELL)
     {
      m_result.retcode=TRADE_RETCODE_INVALID;
      m_result.comment="Invalid order type";
      Print("Invalid order type");
      return(false);
     }
//--- setting request
   m_request.action   =TRADE_ACTION_DEAL;
   m_request.symbol   =symbol;
   m_request.magic    =m_magic;
   m_request.volume   =volume;
   m_request.type     =order_type;
   m_request.price    =price;
   m_request.sl       =sl;
   m_request.tp       =tp;
   m_request.deviation=deviation;
//--- check order type
   if(!OrderTypeCheck(symbol, m_request, m_result))
     {
      Print("Invalid OrderTypeCheck");
      return(false);
     }
//--- check filling
   if(!FillingCheck(symbol, m_request, m_result))
     {
      Print("Invalid FillingCheck");
      return(false);
     }
   m_request.comment=comment;
//--- action and return the result
   return(OrderSend(m_request,m_result));
  }
//+------------------------------------------------------------------+
//| Close specified opened position                                  |
//+------------------------------------------------------------------+
bool PositionClose(MqlTradeRequest &m_request, MqlTradeResult &m_result, const ulong ticket, const ulong m_magic, const string comment, const ulong deviation)
  {
//--- check position existence
   if(!PositionSelectByTicket(ticket))
      return(false);
   string symbol=PositionGetString(POSITION_SYMBOL);
//--- check filling
   if(!FillingCheck(symbol, m_request, m_result))
      return(false);
//--- check
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
     {
      //--- prepare request for close BUY position
      m_request.type =ORDER_TYPE_SELL;
      m_request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
     }
   else
     {
      //--- prepare request for close SELL position
      m_request.type =ORDER_TYPE_BUY;
      m_request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
     }
//--- setting request
   m_request.action   =TRADE_ACTION_DEAL;
   m_request.position =ticket;
   m_request.symbol   =symbol;
   m_request.volume   =PositionGetDouble(POSITION_VOLUME);
   m_request.magic    =m_magic;
   m_request.deviation=deviation;
   m_request.comment  =comment;
//--- close position
   return(OrderSend(m_request,m_result));
  }
//+------------------------------------------------------------------+
//| Partial close specified opened position (for hedging mode only)  |
//+------------------------------------------------------------------+
bool PositionClosePartial(MqlTradeRequest &m_request, MqlTradeResult &m_result, const ulong ticket, const double volume, const ulong m_magic, const string comment, const ulong deviation)
  {
//--- for hedging mode only
   //if(!IsHedging())
   //   return(false);
//--- check position existence
   if(!PositionSelectByTicket(ticket))
      return(false);
   string symbol=PositionGetString(POSITION_SYMBOL);
//--- check filling
   if(!FillingCheck(symbol, m_request, m_result))
      return(false);
//--- check
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
     {
      //--- prepare request for close BUY position
      m_request.type =ORDER_TYPE_SELL;
      m_request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
     }
   else
     {
      //--- prepare request for close SELL position
      m_request.type =ORDER_TYPE_BUY;
      m_request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
     }
//--- check volume
   double position_volume=PositionGetDouble(POSITION_VOLUME);
   if(position_volume>volume)
      position_volume=volume;
//--- setting request
   m_request.action   =TRADE_ACTION_DEAL;
   m_request.position =ticket;
   m_request.symbol   =symbol;
   m_request.volume   =position_volume;
   m_request.magic    =m_magic;
   m_request.deviation=deviation;
   m_request.comment  =comment;
//--- close position
   return(OrderSend(m_request,m_result));
  }
//+------------------------------------------------------------------+
//| Checks order                                                     |
//+------------------------------------------------------------------+
bool OrderTypeCheck(const string symbol, MqlTradeRequest &m_request, MqlTradeResult &m_result)
  {
   bool res=false;
//--- check symbol
   CSymbolInfo sym;
   if(!sym.Name((symbol==NULL)?Symbol():symbol))
      return(false);
//--- get flags of allowed trade orders
   int flags=sym.OrderMode();
//--- depending on the type of order in request
   switch(m_request.type)
     {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_SELL:
         //--- check possibility of execution
         res=((flags&SYMBOL_ORDER_MARKET)!=0);
         break;
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_SELL_LIMIT:
         //--- check possibility of execution
         res=((flags&SYMBOL_ORDER_LIMIT)!=0);
         break;
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_SELL_STOP:
         //--- check possibility of execution
         res=((flags&SYMBOL_ORDER_STOP)!=0);
         break;
      case ORDER_TYPE_BUY_STOP_LIMIT:
      case ORDER_TYPE_SELL_STOP_LIMIT:
         //--- check possibility of execution
         res=((flags&SYMBOL_ORDER_STOP_LIMIT)!=0);
         break;
      default:
         break;
     }
   if(res)
     {
      //--- trading order is valid
      //--- check if we need and able to set protective orders
      if(m_request.sl!=0.0 || m_request.tp!=0.0)
        {
         if((flags&SYMBOL_ORDER_SL)==0)
            m_request.sl=0.0;
         if((flags&SYMBOL_ORDER_TP)==0)
            m_request.tp=0.0;
        }
     }
   else
     {
      //--- trading order is not valid
      //--- set error
      m_result.retcode=TRADE_RETCODE_INVALID_ORDER;
      Print(__FUNCTION__+": Invalid order type");
     }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Checks and corrects type of filling policy                       |
//+------------------------------------------------------------------+
bool FillingCheck(const string symbol, MqlTradeRequest &m_request, MqlTradeResult &m_result)
  {
//--- get execution mode of orders by symbol
   ENUM_SYMBOL_TRADE_EXECUTION exec=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(symbol,SYMBOL_TRADE_EXEMODE);
//--- check execution mode
   if(exec==SYMBOL_TRADE_EXECUTION_REQUEST || exec==SYMBOL_TRADE_EXECUTION_INSTANT)
     {
      //--- neccessary filling type will be placed automatically
      return(true);
     }
//--- get possible filling policy types by symbol
   uint filling=(uint)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
   ENUM_ORDER_TYPE_FILLING m_type_filling = ORDER_FILLING_FOK;
//--- check execution mode again
   if(exec==SYMBOL_TRADE_EXECUTION_MARKET)
     {
      //--- for the MARKET execution mode
      //--- analyze order
      if(m_request.action!=TRADE_ACTION_PENDING)
        {
         //--- in case of instant execution order
         //--- if the required filling policy is supported, add it to the request
         if((filling&SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK)
           {
            m_type_filling=ORDER_FILLING_FOK;
            m_request.type_filling=m_type_filling;
            return(true);
           }
         if((filling&SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC)
           {
            m_type_filling=ORDER_FILLING_IOC;
            m_request.type_filling=m_type_filling;
            return(true);
           }
         //--- wrong filling policy, set error code
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
        }
      return(true);
     }
//--- EXCHANGE execution mode
   switch(m_type_filling)
     {
      case ORDER_FILLING_FOK:
         //--- analyze order
         if(m_request.action==TRADE_ACTION_PENDING)
           {
            //--- in case of pending order
            //--- add the expiration mode to the request
            if(!ExpirationCheck(symbol, m_request))
               m_request.type_time=ORDER_TIME_DAY;
            //--- stop order?
            if(m_request.type==ORDER_TYPE_BUY_STOP || m_request.type==ORDER_TYPE_SELL_STOP ||
               m_request.type==ORDER_TYPE_BUY_LIMIT || m_request.type==ORDER_TYPE_SELL_LIMIT)
              {
               //--- in case of stop order
               //--- add the corresponding filling policy to the request
               m_request.type_filling=ORDER_FILLING_RETURN;
               return(true);
              }
           }
         //--- in case of limit order or instant execution order
         //--- if the required filling policy is supported, add it to the request
         if((filling&SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         //--- wrong filling policy, set error code
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
      case ORDER_FILLING_IOC:
         //--- analyze order
         if(m_request.action==TRADE_ACTION_PENDING)
           {
            //--- in case of pending order
            //--- add the expiration mode to the request
            if(!ExpirationCheck(symbol, m_request))
               m_request.type_time=ORDER_TIME_DAY;
            //--- stop order?
            if(m_request.type==ORDER_TYPE_BUY_STOP || m_request.type==ORDER_TYPE_SELL_STOP ||
               m_request.type==ORDER_TYPE_BUY_LIMIT || m_request.type==ORDER_TYPE_SELL_LIMIT)
              {
               //--- in case of stop order
               //--- add the corresponding filling policy to the request
               m_request.type_filling=ORDER_FILLING_RETURN;
               return(true);
              }
           }
         //--- in case of limit order or instant execution order
         //--- if the required filling policy is supported, add it to the request
         if((filling&SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         //--- wrong filling policy, set error code
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
      case ORDER_FILLING_RETURN:
         //--- add filling policy to the request
         m_request.type_filling=m_type_filling;
         return(true);
     }
//--- unknown execution mode, set error code
   m_result.retcode=TRADE_RETCODE_ERROR;
   return(false);
  }
//+------------------------------------------------------------------+
//| Check expiration type of pending order                           |
//+------------------------------------------------------------------+
bool ExpirationCheck(const string symbol, MqlTradeRequest &m_request)
  {
   CSymbolInfo sym;
//--- check symbol
   if(!sym.Name((symbol==NULL)?Symbol():symbol))
      return(false);
//--- get flags
   int flags=sym.TradeTimeFlags();
//--- check type
   switch(m_request.type_time)
     {
      case ORDER_TIME_GTC:
         if((flags&SYMBOL_EXPIRATION_GTC)!=0)
         return(true);
         break;
      case ORDER_TIME_DAY:
         if((flags&SYMBOL_EXPIRATION_DAY)!=0)
         return(true);
         break;
      case ORDER_TIME_SPECIFIED:
         if((flags&SYMBOL_EXPIRATION_SPECIFIED)!=0)
         return(true);
         break;
      case ORDER_TIME_SPECIFIED_DAY:
         if((flags&SYMBOL_EXPIRATION_SPECIFIED_DAY)!=0)
         return(true);
         break;
      default:
         Print(__FUNCTION__+": Unknown expiration type");
         break;
     }
//--- failed
   return(false);
  }