//+------------------------------------------------------------------+
//|                                                TriangularArb.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
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
bool selected[7]={true,true,false,false,false,false,false};
CTrade trade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TriangularPosition
  {
   ulong             id;
   ulong             pos_id_xy;
   ulong             pos_id_x;
   ulong             pos_id_y;
   double            CalProfits();
   void              ClosePosition(string comment);
   void              InitPosition(ulong xy_p_id,ulong x_p_id,ulong y_p_id,ulong combine_id);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TriangularPosition::InitPosition(ulong xy_p_id,ulong x_p_id,ulong y_p_id,ulong combine_id)
  {
   pos_id_xy=xy_p_id;
   pos_id_x=x_p_id;
   pos_id_y=y_p_id;
   id=combine_id;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TriangularPosition::CalProfits(void)
  {
   double profits=0;
   PositionSelectByTicket(pos_id_xy);
   profits+=PositionGetDouble(POSITION_PROFIT);
   PositionSelectByTicket(pos_id_x);
   profits+=PositionGetDouble(POSITION_PROFIT);
   PositionSelectByTicket(pos_id_y);
   profits+=PositionGetDouble(POSITION_PROFIT);
   return profits;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TriangularPosition::ClosePosition(string comment)
  {
   trade.PositionClose(pos_id_xy,comment);
   trade.PositionClose(pos_id_x,comment);
   trade.PositionClose(pos_id_y,comment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTriangularArb
  {
private:
   int               arb_open;   // 开仓需要满足的套利点位
   int               arb_close;  // 平仓需要满足的套利点位
   int               arb_win;    // 平仓需要满足的盈利点位
   double            base_lots;  // 基本手数
   bool              lots_need_standard;  // 手数是否需要调整
   bool              symbol_selected[7]; // 筛选的品种

   int               arb_pos_id;    // 套利组合仓位编号
   MqlTick           tick_usd[7];   // 记录直盘货币对的tick数据
   MqlTick           tick_cross[21];   // 记录交叉盘货币对的tick数据
   double            deal_price_usd[7];   // 记录直盘货币对成交的价格
   double            deal_price_cross[21]; // // 记录交叉盘货币对成交的价格
   double            tick_usd_value[7];   // 记录直盘货币对波动一个点的价值
   double            tick_cross_value[21];   // 记录交叉盘货币对波动一个点的价值
   double            tick_cross_size[21]; // 记录交叉盘货币对的tick size
   double            arb_long[21];  // 存储如果做多(做多交叉盘，做空直盘组合)的点差
   double            arb_short[21]; // 存储如果做空(做空交叉盘，做多直盘组合)的点差
   bool              long_position_exist[21];   // 记录是否已有多头仓位
   bool              short_position_exist[21];  // 记录是否已有空头仓位  
   TriangularPosition pos_long_triangular[21];  //  三角套利多头仓位
   TriangularPosition pos_short_triangular[21];  // 三角套利空头仓位
   double            lots_xy;   // 交叉货币对的手数
   double            lots_x;    // 直盘x的手数
   double            lots_y;    // 直盘y的手数

public:
                     CTriangularArb(void);
                    ~CTriangularArb(void){};
   void              SelectSymbolSet(bool &b_selected[]){ArrayCopy(symbol_selected,b_selected);};
   void              SetParameter(int open_point,int close_point,int win_point,double open_lots,bool need_standard_lots=true);
   void              SetMagic(ulong magic){trade.SetExpertMagicNumber(magic);};
   void              ArbCalculation(void);   // 计算套机机会
private:
   bool              RefreshTick(int index_x,int index_y,int index_xy);      // 刷新tick数据
   void              CalArbPoints(int index_x,int index_y,int index_xy);      // 计算套利点位
   void              PositionCloseCheckByReverse(int cross_index);   // 平仓检测--反向偏移达到
   void              PositionCloseCheckByTP(int cross_index);   // 平仓检测--止盈
   void              PositionOpenCheck(int index_x,int index_y,int index_xy);    // 开仓检测
   void              OpenLongPosition(int index_x,int index_y,int index_xy, string comment="");  // 开多头
   void              OpenShortPosition(int index_x,int index_y,int index_xy, string comment=""); // 开空头
   void              CalLots(int index_x,int index_y,int index_xy);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::CTriangularArb(void)
  {
   arb_open=50;
   arb_close=100;
   arb_win=50;
   base_lots=0.1;
   lots_need_standard=false;
   trade.SetExpertMagicNumber(3180501);
   for(int i=0;i<21;i++)
     {
      tick_cross_size[i]=SymbolInfoDouble(symbol_cross[i],SYMBOL_TRADE_TICK_SIZE);
     }
   ArrayCopy(symbol_selected,selected);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::SetParameter(int open_point,int close_point,int win_point,double open_lots,bool need_standard_lots=true)
  {
   arb_open=open_point;
   arb_close=close_point;
   arb_win=win_point;
   base_lots=open_lots;
   lots_need_standard=need_standard_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTriangularArb::RefreshTick(int index_x,int index_y,int index_xy)
  {
   bool b1=SymbolInfoTick(symbol_usd[index_x],tick_usd[index_x]);
   bool b2=SymbolInfoTick(symbol_usd[index_y],tick_usd[index_y]);
   bool b3=SymbolInfoTick(symbol_cross[index_xy],tick_cross[index_xy]);
   tick_usd_value[index_x]=SymbolInfoDouble(symbol_usd[index_x],SYMBOL_TRADE_TICK_VALUE);
   tick_usd_value[index_y]=SymbolInfoDouble(symbol_usd[index_y],SYMBOL_TRADE_TICK_VALUE);
   tick_cross_value[index_xy]=SymbolInfoDouble(symbol_cross[index_xy],SYMBOL_TRADE_TICK_VALUE);
   return b1&&b2&&b3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::CalArbPoints(int index_x,int index_y,int index_xy)
  {
   switch(type_cross[index_xy])
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD:
         arb_long[index_xy]=tick_usd[index_x].bid/tick_usd[index_y].ask-tick_cross[index_xy].ask;
         arb_short[index_xy]=tick_cross[index_xy].bid-tick_usd[index_x].ask/tick_usd[index_y].bid;
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         arb_long[index_xy]=tick_usd[index_y].bid/tick_usd[index_x].ask-tick_cross[index_xy].ask;
         arb_short[index_xy]=tick_cross[index_xy].bid-tick_usd[index_y].ask/tick_usd[index_x].bid;
         break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         arb_long[index_xy]=tick_usd[index_x].bid*tick_usd[index_y].bid-tick_cross[index_xy].ask;
         arb_short[index_xy]=tick_cross[index_xy].bid-tick_usd[index_x].ask*tick_usd[index_y].ask;
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::ArbCalculation(void)
  {
   for(int i=0;i<6;i++)
     {
      for(int j=i+1;j<7;j++)
        {
         int index=21-(7-i)*(6-i)/2+(j-i)-1;
         if(!symbol_selected[i] || !symbol_selected[j]) continue;
         PositionCloseCheckByTP(index);
         if(!RefreshTick(i,j,index)) continue; 
         CalArbPoints(i,j,index);
         PositionCloseCheckByReverse(index);
         PositionOpenCheck(i,j,index);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::PositionCloseCheckByTP(int cross_index)
  {
   if(pos_long_triangular[cross_index].CalProfits()/base_lots>arb_win)
     {
      Print("多头止盈平仓");
      pos_long_triangular[cross_index].ClosePosition("P-id(close long by tp):"+string(pos_long_triangular[cross_index].id));
      long_position_exist[cross_index]=false;
     }
   if(pos_short_triangular[cross_index].CalProfits()/base_lots>arb_win)
     {
      Print("空头止盈平仓");
      pos_short_triangular[cross_index].ClosePosition("P-id(close short by tp):"+string(pos_short_triangular[cross_index].id));
      short_position_exist[cross_index]=false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::PositionCloseCheckByReverse(int cross_index)
  {
   if(long_position_exist[cross_index] && arb_short[cross_index]>arb_close*tick_cross_size[cross_index])
     {
      Print("多头逆向平仓");
      pos_long_triangular[cross_index].ClosePosition("P-id(close long by reverse):"+string(pos_long_triangular[cross_index].id));
      long_position_exist[cross_index]=false;
     }
   if(short_position_exist[cross_index] && arb_long[cross_index]>arb_close*tick_cross_size[cross_index])
     {
      Print("空头逆向平仓");
      pos_short_triangular[cross_index].ClosePosition("P-id(close short by reverse):"+string(pos_short_triangular[cross_index].id));
      short_position_exist[cross_index]=false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::PositionOpenCheck(int index_x,int index_y,int index_xy)
  {
   if(!long_position_exist[index_xy] && arb_long[index_xy]>arb_open*tick_cross_size[index_xy])
     {
      OpenLongPosition(index_x,index_y,index_xy,"P-id(open long):"+string(arb_pos_id));
     }
   if(!short_position_exist[index_xy] && arb_short[index_xy]>arb_open*tick_cross_size[index_xy])
     {
      OpenShortPosition(index_x,index_y,index_xy,"P-id(open short):"+string(arb_pos_id));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::OpenLongPosition(int index_x,int index_y,int index_xy,string comment)
  {
   ulong pos_3ids[3];
   CalLots(index_x,index_y,index_xy);
   switch(type_cross[index_xy])
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD:
         if(!trade.PositionOpen(symbol_cross[index_xy],ORDER_TYPE_BUY,lots_xy,tick_cross[index_xy].ask,0,0,comment))
           {
            Print("Open symbol "+symbol_cross[index_xy]+" failed! ",trade.ResultRetcode());
            return;
           }
         deal_price_cross[index_xy]=trade.ResultPrice();
         pos_3ids[0]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_x],ORDER_TYPE_SELL,lots_x,tick_usd[index_x].bid,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_x]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            return;
           }
         deal_price_usd[index_x]=trade.ResultPrice();
         pos_3ids[1]=trade.ResultOrder();
         
         if(!trade.PositionOpen(symbol_usd[index_y],ORDER_TYPE_BUY,lots_y,tick_usd[index_y].ask,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_y]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            trade.PositionClose(pos_3ids[1],"强平部分开仓");
            return;
           }
         deal_price_usd[index_y]=trade.ResultPrice();
         pos_3ids[2]=trade.ResultOrder();
         Print("***Long Open Condition:XUSD-XUSD",tick_cross[index_xy].ask," ",tick_usd[index_x].bid, " ",tick_usd[index_y].ask);
         Print("***Long Open Result:XUSD-XUSD",deal_price_cross[index_xy]," ", deal_price_usd[index_x]," ", deal_price_usd[index_y]);
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         if(!trade.PositionOpen(symbol_cross[index_xy],ORDER_TYPE_BUY,lots_xy,tick_cross[index_xy].ask,0,0,comment))
           {
            Print("Open symbol "+symbol_cross[index_xy]+" failed! ",trade.ResultRetcode());
            return;
           }
         deal_price_cross[index_xy]=trade.ResultPrice();
         pos_3ids[0]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_x],ORDER_TYPE_BUY,lots_x,tick_usd[index_x].ask,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_x]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            return;
           }
         deal_price_usd[index_x]=trade.ResultPrice();
         pos_3ids[1]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_y],ORDER_TYPE_SELL,lots_y,tick_usd[index_y].bid,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_y]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            trade.PositionClose(pos_3ids[1],"强平部分开仓");
            return;
           }
         deal_price_usd[index_y]=trade.ResultPrice();
         pos_3ids[2]=trade.ResultOrder();
         Print("***Long Open Condition:USDX-USDX",tick_cross[index_xy].ask," ",tick_usd[index_x].ask, " ",tick_usd[index_y].bid);
         Print("***Long Open Result:USDX-USDX",deal_price_cross[index_xy]," ", deal_price_usd[index_x]," ", deal_price_usd[index_y]);
         break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         if(!trade.PositionOpen(symbol_cross[index_xy],ORDER_TYPE_BUY,lots_xy,tick_cross[index_xy].ask,0,0,comment))
           {
            Print("Open symbol "+symbol_cross[index_xy]+" failed! ",trade.ResultRetcode());
            return;
           }
         deal_price_cross[index_xy]=trade.ResultPrice();
         pos_3ids[0]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_x],ORDER_TYPE_SELL,lots_x,tick_usd[index_x].bid,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_x]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            return;
           }
         deal_price_usd[index_x]=trade.ResultPrice();
         pos_3ids[1]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_y],ORDER_TYPE_SELL,lots_y,tick_usd[index_y].bid,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_y]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            trade.PositionClose(pos_3ids[1],"强平部分开仓");
            return;
           }
         deal_price_usd[index_y]=trade.ResultPrice();
         pos_3ids[2]=trade.ResultOrder();
         Print("***Long Open Condition:XUSD-USDX",tick_cross[index_xy].ask," ",tick_usd[index_x].bid, " ",tick_usd[index_y].bid);
         Print("***Long Open Result:XUSD-USDX",deal_price_cross[index_xy]," ", deal_price_usd[index_x]," ", deal_price_usd[index_y]);
         break;
      default:
         break;
     }
   pos_long_triangular[index_xy].InitPosition(pos_3ids[0],pos_3ids[1],pos_3ids[2],arb_pos_id);
   long_position_exist[index_xy]=true;
   arb_pos_id++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::OpenShortPosition(int index_x,int index_y,int index_xy,string comment)
  {
   ulong pos_3ids[3];
   CalLots(index_x,index_y,index_xy);
   switch(type_cross[index_xy])
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD:
         if(!trade.PositionOpen(symbol_cross[index_xy],ORDER_TYPE_SELL,lots_xy,tick_cross[index_xy].bid,0,0,comment))
           {
            Print("Open symbol "+symbol_cross[index_xy]+" failed! ",trade.ResultRetcode());
            return;
           }
         deal_price_cross[index_xy]=trade.ResultPrice();
         pos_3ids[0]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_x],ORDER_TYPE_BUY,lots_x,tick_usd[index_x].ask,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_x]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            return;
           }
         deal_price_usd[index_x]=trade.ResultPrice();
         pos_3ids[1]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_y],ORDER_TYPE_SELL,lots_y,tick_usd[index_y].bid,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_y]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            trade.PositionClose(pos_3ids[1],"强平部分开仓");
            return;
           }
         deal_price_usd[index_y]=trade.ResultPrice();
         pos_3ids[2]=trade.ResultOrder();
         Print("***Short Open Condition:XUSD-XUSD",tick_cross[index_xy].bid," ",tick_usd[index_x].ask, " ",tick_usd[index_y].bid);
         Print("***Short Open Result:XUSD-XUSD",deal_price_cross[index_xy]," ", deal_price_usd[index_x]," ", deal_price_usd[index_y]);
         break;
      
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         if(!trade.PositionOpen(symbol_cross[index_xy],ORDER_TYPE_SELL,lots_xy,tick_cross[index_xy].bid,0,0,comment))
           {
            Print("Open symbol "+symbol_cross[index_xy]+" failed! ",trade.ResultRetcode());
            return;
           }
         deal_price_cross[index_xy]=trade.ResultPrice();
         pos_3ids[0]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_x],ORDER_TYPE_SELL,lots_x,tick_usd[index_x].bid,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_x]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            return;
           }
         deal_price_usd[index_x]=trade.ResultPrice();
         pos_3ids[1]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_y],ORDER_TYPE_BUY,lots_y,tick_usd[index_y].ask,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_y]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            trade.PositionClose(pos_3ids[1],"强平部分开仓");
            return;
           }
         deal_price_usd[index_y]=trade.ResultPrice();
         pos_3ids[2]=trade.ResultOrder();
         Print("***Short Open Condition:USDX-USDX",tick_cross[index_xy].bid," ",tick_usd[index_x].bid, " ",tick_usd[index_y].ask);
         Print("***Short Open Result:USDX-USDX",deal_price_cross[index_xy]," ", deal_price_usd[index_x]," ", deal_price_usd[index_y]);
         break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         if(!trade.PositionOpen(symbol_cross[index_xy],ORDER_TYPE_SELL,lots_xy,tick_cross[index_xy].bid,0,0,comment))
           {
            Print("Open symbol "+symbol_cross[index_xy]+" failed! ",trade.ResultRetcode());
            return;
           }
         deal_price_cross[index_xy]=trade.ResultPrice();
         pos_3ids[0]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_x],ORDER_TYPE_BUY,lots_x,tick_usd[index_x].ask,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_x]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            return;
           }
         deal_price_usd[index_x]=trade.ResultPrice();
         pos_3ids[1]=trade.ResultOrder();
         if(!trade.PositionOpen(symbol_usd[index_y],ORDER_TYPE_BUY,lots_y,tick_usd[index_y].ask,0,0,comment))
           {
            Print("Open symbol "+symbol_usd[index_y]+" failed! ",trade.ResultRetcode());
            trade.PositionClose(pos_3ids[0],"强平部分开仓");
            trade.PositionClose(pos_3ids[1],"强平部分开仓");
            return;
           }
         deal_price_usd[index_y]=trade.ResultPrice();
         pos_3ids[2]=trade.ResultOrder();
         Print("***Short Open Condition:XUSD-USDX",tick_cross[index_xy].bid," ",tick_usd[index_x].ask, " ",tick_usd[index_y].ask);
         Print("***Short Open Result:XUSD-USDX",deal_price_cross[index_xy]," ", deal_price_usd[index_x]," ", deal_price_usd[index_y]);
         break;
      default:
         break;
     }
   pos_short_triangular[index_xy].InitPosition(pos_3ids[0],pos_3ids[1],pos_3ids[2],arb_pos_id);
   short_position_exist[index_xy]=true;
   arb_pos_id++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTriangularArb::CalLots(int index_x,int index_y,int index_xy)
  {
   if(lots_need_standard)
     {
      lots_xy= NormalizeDouble(base_lots/tick_cross_value[index_xy],2);
      lots_x = NormalizeDouble(base_lots/tick_usd_value[index_x],2);
      lots_y = NormalizeDouble(base_lots/tick_usd_value[index_y],2);
     }
   else
     {
      lots_xy=base_lots;
      lots_x = base_lots;
      lots_y = base_lots;
     }
  }
//+------------------------------------------------------------------+
