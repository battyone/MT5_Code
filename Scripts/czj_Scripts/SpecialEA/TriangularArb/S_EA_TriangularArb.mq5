//+------------------------------------------------------------------+
//|                                            S_EA_TrangularArb.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\TradeCustom.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>

//input double lots_base=0.02;
//input int    open_delta_points=30;
//input int    close_delta_points=5;
//input int    win_points=5;
//input ulong magic_num=20180510;

double arr_lots_base[4]={0.1,0.2,0.3,0.01};
int arr_open[4]={20,25,35,50};
int arr_close[4]={20,20,35,50};
int arr_win[4]={20,25,35,50};
ulong arr_magic[4]={1,2,3,31805100};

int select_i = 3;
double lots_base=arr_lots_base[select_i];
int    open_delta_points=arr_open[select_i];
int    close_delta_points=arr_close[select_i];
int    win_points=arr_win[select_i];
ulong magic_num=arr_magic[select_i];
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
enum TypeCurrency
  {
   ENUM_TYPE_CURRENCY_XUSD_XUSD,
   ENUM_TYPE_CURRENCY_XUSD_USDX,
   ENUM_TYPE_CURRENCY_USDX_USDX
  };

string symbol_usd[7]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
string symbol_cross[21]=
  {
   "EURGBP","EURAUD","EURNZD","EURCAD","EURCHF","EURJPY",
   "GBPAUD","GBPNZD","GBPCAD","GBPCHF","GBPJPY",
   "AUDNZD","AUDCAD","AUDCHF","AUDJPY",
   "NZDCAD","NZDCHF","NZDJPY",
   "CADCHF","CADJPY",
   "CHFJPY"
  };
TypeCurrency type_cross[21]=
  {
   ENUM_TYPE_CURRENCY_XUSD_XUSD,ENUM_TYPE_CURRENCY_XUSD_XUSD,ENUM_TYPE_CURRENCY_XUSD_XUSD,ENUM_TYPE_CURRENCY_XUSD_USDX,ENUM_TYPE_CURRENCY_XUSD_USDX,ENUM_TYPE_CURRENCY_XUSD_USDX,
   ENUM_TYPE_CURRENCY_XUSD_XUSD,ENUM_TYPE_CURRENCY_XUSD_XUSD,ENUM_TYPE_CURRENCY_XUSD_USDX,ENUM_TYPE_CURRENCY_XUSD_USDX,ENUM_TYPE_CURRENCY_XUSD_USDX,
   ENUM_TYPE_CURRENCY_XUSD_XUSD,ENUM_TYPE_CURRENCY_XUSD_USDX,ENUM_TYPE_CURRENCY_XUSD_USDX,ENUM_TYPE_CURRENCY_XUSD_USDX,
   ENUM_TYPE_CURRENCY_XUSD_USDX,ENUM_TYPE_CURRENCY_XUSD_USDX,ENUM_TYPE_CURRENCY_XUSD_USDX,
   ENUM_TYPE_CURRENCY_USDX_USDX,ENUM_TYPE_CURRENCY_USDX_USDX,
   ENUM_TYPE_CURRENCY_USDX_USDX
  };
CTradeCustom ExtTrade;
MqlTick price_usd[7],price_cross[21];
double long_chance[21],short_chance[21];
double cross_points[21];
int position_long[21],position_short[21];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ThreePosId:public CObject
  {
public:
   ulong             pos_id[3];
   double            lots;
   double            GetProfits();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ThreePosId::GetProfits(void)
  {
   double profits=0;
   for(int i=0;i<3;i++)
     {
      PositionSelectByTicket(pos_id[i]);
      profits+=PositionGetDouble(POSITION_PROFIT);
     }
   return profits;
  }

CArrayObj long_position[21];
CArrayObj short_position[21];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   Print("Parameter Information:");
   Print("EA magic:",magic_num);
   Print("Open:",open_delta_points," Close:",close_delta_points," Win:",win_points," Lots:",lots_base);
   PositionReInit();
   ExtTrade.SetExpertMagicNumber(magic_num);

   for(int i=0;i<21;i++)
     {
      cross_points[i]=SymbolInfoDouble(symbol_cross[i],SYMBOL_POINT);
     }

   while(!IsStopped())
     {
      //   获取直盘货币对tick报价
      for(int i=0;i<7;i++)
        {
         if(!SymbolInfoTick(symbol_usd[i],price_usd[i])) return;
        }
      //     获取交叉盘货币对tick报价
      for(int i=0;i<21;i++)
        {
         if(!SymbolInfoTick(symbol_cross[i],price_cross[i])) return;
        }
      //   遍历品种对进行套利分析
      for(int i=0;i<6;i++)
        {
         for(int j=i+1;j<7;j++)
           {
            int index=21-(7-i)*(6-i)/2+(j-i)-1;
            ArbChanceFind(price_usd[i],price_usd[j],price_cross[index],type_cross[index],long_chance[index],short_chance[index]);
            CheckPositionClose(index);
            if(OpenLongCondition(index))
              {
               Print(symbol_usd[i]," ",symbol_usd[j]," ",symbol_cross[index]," ",EnumToString(type_cross[index]));
               Print("Index:",index," Long:",int(long_chance[index]/cross_points[index]));
               ThreePosId *pos_new=new ThreePosId();
               OpenLongPosition(index,i,j,lots_base,pos_new);
               long_position[index].Add(pos_new);
              }
            if(OpenShortCondition(index))
              {
               Print(symbol_usd[i]," ",symbol_usd[j]," ",symbol_cross[index]," ",EnumToString(type_cross[index]));
               Print("Index:",index," Short:",int(short_chance[index]/cross_points[index]));
               ThreePosId *pos_new=new ThreePosId();
               OpenShortPosition(index,i,j,lots_base,pos_new);
               short_position[index].Add(pos_new);
              }
           }
        }
     }
    Print("remove on going");
    

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArbChanceFind(const MqlTick &tick_x,const MqlTick &tick_y,const MqlTick &tick_xy,TypeCurrency cross_type,double &delta_long,double &delta_short)
  {
   switch(cross_type)
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD:
         delta_long=tick_x.bid/tick_y.ask-tick_xy.ask;
         delta_short=tick_xy.bid-tick_x.ask/tick_y.bid;
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         delta_long=tick_y.bid/tick_x.ask-tick_xy.ask;
         delta_short=tick_xy.bid-tick_y.ask/tick_x.bid;
         break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         delta_long=tick_x.bid*tick_y.bid-tick_xy.ask;
         delta_short=tick_xy.bid-tick_x.ask*tick_y.ask;
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OpenLongCondition(int cross_index)
  {
   if(long_position[cross_index].Total()>0) return false;
   if(long_chance[cross_index]/cross_points[cross_index]>open_delta_points) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OpenShortCondition(int cross_index)
  {
   if(short_position[cross_index].Total()>0) return false;
   if(short_chance[cross_index]/cross_points[cross_index]>open_delta_points) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenLongPosition(int cross_index,int x_index,int y_index,double open_lots,ThreePosId &pos)
  {
   switch(type_cross[cross_index])
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD:
         if(!ExtTrade.PositionOpen(symbol_cross[cross_index],ORDER_TYPE_BUY,open_lots,price_cross[cross_index].ask,0,0))
            {
             Print("Open symbol "+symbol_cross[cross_index]+" failed! ", ExtTrade.ResultRetcode());
             return;
            }
         pos.pos_id[0]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[x_index],ORDER_TYPE_SELL,open_lots,price_usd[x_index].bid,0,0))
            {
             Print("Open symbol "+symbol_usd[x_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[1]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[y_index],ORDER_TYPE_BUY,open_lots,price_usd[y_index].ask,0,0))
            {
             Print("Open symbol "+symbol_usd[y_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             ExtTrade.PositionClose(pos.pos_id[1],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[2]=ExtTrade.ResultOrder();
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         if(!ExtTrade.PositionOpen(symbol_cross[cross_index],ORDER_TYPE_BUY,open_lots,price_cross[cross_index].ask,0,0))
            {
             Print("Open symbol "+symbol_cross[cross_index]+" failed! ", ExtTrade.ResultRetcode());
             return;  
            }
         pos.pos_id[0]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[x_index],ORDER_TYPE_BUY,open_lots,price_usd[x_index].ask,0,0))
            {
             Print("Open symbol "+symbol_usd[x_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[1]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[y_index],ORDER_TYPE_SELL,open_lots,price_usd[y_index].bid,0,0))
            {
             Print("Open symbol "+symbol_usd[y_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             ExtTrade.PositionClose(pos.pos_id[1],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[2]=ExtTrade.ResultOrder();
         break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         if(!ExtTrade.PositionOpen(symbol_cross[cross_index],ORDER_TYPE_BUY,open_lots,price_cross[cross_index].ask,0,0))
            {
             Print("Open symbol "+symbol_cross[cross_index]+" failed! ", ExtTrade.ResultRetcode());
             return; 
            }
         pos.pos_id[0]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[x_index],ORDER_TYPE_SELL,open_lots,price_usd[x_index].bid,0,0))
            {
             Print("Open symbol "+symbol_usd[x_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[1]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[y_index],ORDER_TYPE_SELL,open_lots,price_usd[y_index].bid,0,0))
            {
             Print("Open symbol "+symbol_usd[y_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             ExtTrade.PositionClose(pos.pos_id[1],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[2]=ExtTrade.ResultOrder();
         break;
      default:
         break;
     }
   pos.lots=open_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenShortPosition(int cross_index,int x_index,int y_index,double open_lots,ThreePosId &pos)
  {
   switch(type_cross[cross_index])
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD:
         if(!ExtTrade.PositionOpen(symbol_cross[cross_index],ORDER_TYPE_SELL,open_lots,price_cross[cross_index].bid,0,0))
            {
             Print("Open symbol "+symbol_cross[cross_index]+" failed! ", ExtTrade.ResultRetcode());
             return;
            }
         pos.pos_id[0]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[x_index],ORDER_TYPE_BUY,open_lots,price_usd[x_index].ask,0,0))
            {
             Print("Open symbol "+symbol_usd[x_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[1]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[y_index],ORDER_TYPE_SELL,open_lots,price_usd[y_index].bid,0,0))
            {
             Print("Open symbol "+symbol_usd[y_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             ExtTrade.PositionClose(pos.pos_id[1],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[2]=ExtTrade.ResultOrder();
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         if(!ExtTrade.PositionOpen(symbol_cross[cross_index],ORDER_TYPE_SELL,open_lots,price_cross[cross_index].bid,0,0))
            {
             Print("Open symbol "+symbol_cross[cross_index]+" failed! ", ExtTrade.ResultRetcode());
             return;
            }
         pos.pos_id[0]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[x_index],ORDER_TYPE_SELL,open_lots,price_usd[x_index].bid,0,0))
            {
             Print("Open symbol "+symbol_usd[x_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[1]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[y_index],ORDER_TYPE_BUY,open_lots,price_usd[y_index].ask,0,0))
            {
             Print("Open symbol "+symbol_usd[y_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             ExtTrade.PositionClose(pos.pos_id[1],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[2]=ExtTrade.ResultOrder();
         break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         if(!ExtTrade.PositionOpen(symbol_cross[cross_index],ORDER_TYPE_SELL,open_lots,price_cross[cross_index].bid,0,0))
            {
             Print("Open symbol "+symbol_cross[cross_index]+" failed! ", ExtTrade.ResultRetcode());
             return;
            }
         pos.pos_id[0]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[x_index],ORDER_TYPE_BUY,open_lots,price_usd[x_index].ask,0,0))
            {
             Print("Open symbol "+symbol_usd[x_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[1]=ExtTrade.ResultOrder();
         if(!ExtTrade.PositionOpen(symbol_usd[y_index],ORDER_TYPE_BUY,open_lots,price_usd[y_index].ask,0,0))
            {
             Print("Open symbol "+symbol_usd[y_index]+" failed! ", ExtTrade.ResultRetcode());
             ExtTrade.PositionClose(pos.pos_id[0],-1,"强平部分开仓");
             ExtTrade.PositionClose(pos.pos_id[1],-1,"强平部分开仓");
             return;
            }
         pos.pos_id[2]=ExtTrade.ResultOrder();
         break;
      default:
         break;
     }
   pos.lots=open_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckPositionClose(int cross_index)
  {
   
   int total_long=long_position[cross_index].Total();
   int total_short=short_position[cross_index].Total();
//    检查多头仓位
   for(int i=total_long-1;i>=0;i--)
     {
      ThreePosId *long_pos=long_position[cross_index].At(i);
      if(long_pos.GetProfits()/long_pos.lots>win_points)
        {
         PositionClose(long_pos,"TP "+string(win_points));
         long_position[cross_index].Delete(i);
        }
      else if(short_chance[cross_index]/cross_points[cross_index]>close_delta_points)
        {
         PositionClose(long_pos,"Reverse "+string(close_delta_points));
         long_position[cross_index].Delete(i);
        }
     }
//    检查多头仓位
   for(int i=total_short-1;i>=0;i--)
     {
      ThreePosId *short_pos=short_position[cross_index].At(i);
      if(short_pos.GetProfits()/short_pos.lots>win_points)
        {
         PositionClose(short_pos,"TP "+string(win_points));
         short_position[cross_index].Delete(i);
        }
      else if(long_chance[cross_index]/cross_points[cross_index]>close_delta_points)
        {
         PositionClose(short_pos,"Reverse "+string(close_delta_points));
         short_position[cross_index].Delete(i);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionClose(ThreePosId &pos,string close_reason="")
  {
   ExtTrade.PositionClose(pos.pos_id[0],-1,close_reason);
   ExtTrade.PositionClose(pos.pos_id[1],-1,close_reason);
   ExtTrade.PositionClose(pos.pos_id[2],-1,close_reason);
  }
//+------------------------------------------------------------------+
//|        重载策略时重新计算已存在的仓位              |
//+------------------------------------------------------------------+
void PositionReInit()
  {
   CArrayLong *pos_id_used=new CArrayLong();// 用于记录已经配对的position id
   int total=PositionsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=PositionGetTicket(i);
      PositionSelectByTicket(ticket);
      ulong magic_id=PositionGetInteger(POSITION_MAGIC);
      if(magic_id!=magic_num) continue;   // 非当前策略magic id的仓位不进行处理

      string cross_symbol=PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE cross_type=PositionGetInteger(POSITION_TYPE);
      double cross_lots=PositionGetDouble(POSITION_VOLUME);
      int cross_open_time=PositionGetInteger(POSITION_TIME);
      //      判断是否是交叉货币
      bool is_cross_symbol=false;
      int cross_index=0;
      for(int j=0;j<21;j++)
        {
         if(symbol_cross[j]==cross_symbol)
           {
            is_cross_symbol=true;
            cross_index=j;
            break;
           }
        }
      //    以交叉货币对作为匹配基准进行匹配
      if(is_cross_symbol)
        {
         string symbol_x,symbol_y;
         bool x_is_xxxusd,y_is_xxxusd;
         cross_to_usd(cross_symbol,symbol_x,symbol_y,x_is_xxxusd,y_is_xxxusd);
         bool find_x=false,find_y=false,direct_x=false,direct_y=false;
         ulong ticket_x,ticket_y;
         if(cross_type==POSITION_TYPE_BUY)
           {
            ThreePosId *pos=new ThreePosId();
            pos.pos_id[0]=ticket;
            for(int k=0;k<PositionsTotal();k++)
              {
               ticket_x=PositionGetTicket(k);
               if(!(pos_id_used.Search(ticket_x)==-1)) continue;
               PositionSelectByTicket(ticket_x);
               find_x=(PositionGetString(POSITION_SYMBOL)==symbol_x) && (PositionGetDouble(POSITION_VOLUME)==cross_lots) && (MathAbs(int(PositionGetInteger(POSITION_TIME)-cross_open_time))<5);
               direct_x=((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) && x_is_xxxusd) || ((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) && !x_is_xxxusd);
               if(find_x && direct_x) break;
              }
            for(int k=0;k<PositionsTotal();k++)
              {
               ticket_y=PositionGetTicket(k);
               if(!(pos_id_used.Search(ticket_y)==-1)) continue;
               PositionSelectByTicket(ticket_y);
               find_y=(PositionGetString(POSITION_SYMBOL)==symbol_y) && (PositionGetDouble(POSITION_VOLUME)==cross_lots) && (MathAbs(int(PositionGetInteger(POSITION_TIME)-cross_open_time))<5);
               direct_y=((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) && y_is_xxxusd) || ((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) && !y_is_xxxusd);
               if(find_y && direct_y) break;
              }
            if(find_x && direct_x && find_y && direct_y)
              {
               pos.pos_id[1]=ticket_x;
               pos.pos_id[2]=ticket_y;
               pos.lots=cross_lots;
               long_position[cross_index].Add(pos);
               pos_id_used.Add(ticket_x);
               pos_id_used.Add(ticket_y);
              }
           }
         else
           {
            ThreePosId *pos=new ThreePosId();
            pos.pos_id[0]=ticket;
            for(int k=0;k<PositionsTotal();k++)
              {
               ticket_x=PositionGetTicket(k);
               if(!(pos_id_used.Search(ticket_x)==-1)) continue;
               PositionSelectByTicket(ticket_x);
               find_x=(PositionGetString(POSITION_SYMBOL)==symbol_x) && (PositionGetDouble(POSITION_VOLUME)==cross_lots) && (MathAbs(int(PositionGetInteger(POSITION_TIME)-cross_open_time))<5);
               direct_x=((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) && x_is_xxxusd) || ((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) && !x_is_xxxusd);
               if(find_x && direct_x) break;
              }
            for(int k=0;k<PositionsTotal();k++)
              {
               ticket_y=PositionGetTicket(k);
               if(!(pos_id_used.Search(ticket_y)==-1)) continue;
               PositionSelectByTicket(ticket_y);
               find_y=(PositionGetString(POSITION_SYMBOL)==symbol_y) && (PositionGetDouble(POSITION_VOLUME)==cross_lots) && (MathAbs(int(PositionGetInteger(POSITION_TIME)-cross_open_time))<5);
               direct_y=((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) && y_is_xxxusd) || ((PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) && !y_is_xxxusd);
               if(find_y && direct_y) break;
              }
            if(find_x && direct_x && find_y && direct_y)
              {
               pos.pos_id[1]=ticket_x;
               pos.pos_id[2]=ticket_y;
               pos.lots=cross_lots;
               short_position[cross_index].Add(pos);
               pos_id_used.Add(ticket_x);
               pos_id_used.Add(ticket_y);
              }
           }
        }
     }
   for(int i=0;i<21;i++)
     {
      if(long_position[i].Total()>0)
        {
         for(int j=0;j<long_position[i].Total();j++)
           {
            string xy,x,y;
            ThreePosId*pos_reinit=long_position[i].At(j);
            PositionSelectByTicket(pos_reinit.pos_id[0]);
            xy=PositionGetString(POSITION_SYMBOL);
            PositionSelectByTicket(pos_reinit.pos_id[1]);
            x=PositionGetString(POSITION_SYMBOL);
            PositionSelectByTicket(pos_reinit.pos_id[2]);
            y=PositionGetString(POSITION_SYMBOL);
            Print("ReInit Long Position: symbol_xy-",xy," symbol_x-",x," symbol_y-",y);
           }
        }
      if(short_position[i].Total()>0)
        {
         for(int j=0;j<short_position[i].Total();j++)
           {
            string xy,x,y;
            ThreePosId*pos_reinit=short_position[i].At(j);
            PositionSelectByTicket(pos_reinit.pos_id[0]);
            xy=PositionGetString(POSITION_SYMBOL);
            PositionSelectByTicket(pos_reinit.pos_id[1]);
            x=PositionGetString(POSITION_SYMBOL);
            PositionSelectByTicket(pos_reinit.pos_id[2]);
            y=PositionGetString(POSITION_SYMBOL);
            Print("ReInit Short Position: symbol_xy-",xy,"symbol_x-",x,"symbol_y-",y);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cross_to_usd(string cross_s,string &x_s,string &y_s,bool &x_is_xusd,bool &y_is_xusd)
  {
   string left=StringSubstr(cross_s,0,3);
   string right=StringSubstr(cross_s,3,3);
   if(left=="EUR" || left=="GBP" || left=="AUD" || left=="NZD")
     {
      x_s=left+"USD";
      x_is_xusd=true;
     }
   else
     {
      x_s="USD"+left;
      x_is_xusd=false;
     }

   if(right=="EUR" || right=="GBP" || right=="AUD" || right=="NZD")
     {
      y_s=right+"USD";
      y_is_xusd=true;
     }

   else
     {
      y_s="USD"+right;
      y_is_xusd=false;
     }
  }
//+------------------------------------------------------------------+
