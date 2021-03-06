//+------------------------------------------------------------------+
//|                                                EA_PinBarTest.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>

int handle;
CTrade trade;
bool has_buy;
bool has_sell;
ulong pos_id_buy, pos_id_sell;
struct pos_state
  {
   int buy_num;
   int sell_num;
   void Refresh();
  };
pos_state::Refresh(void)
   {
    buy_num=0;
    sell_num=0;
    for(int i=0;i<PositionsTotal();i++)
      {
       ulong ticket=PositionGetTicket(i);
       PositionSelectByTicket(ticket);
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) buy_num++;
       else sell_num++;
      }
   }
pos_state pos;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   handle = iCustom(_Symbol,_Period,"PinbarDetector");
   has_buy=false;
   has_sell=false;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double color_arr[];
   
   pos.Refresh();
   double open[],close[],high[],low[];
   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);
   CopyBuffer(handle,1,1,1,color_arr);
   CopyOpen(_Symbol,_Period,0,3,open);
    CopyHigh(_Symbol,_Period,0,3,high);
    CopyLow(_Symbol,_Period,0,3,low);
    CopyClose(_Symbol,_Period,0,3,close);
    double open_price,tp_price,sl_price;
    bool is_new_bar=false;
   //if(color_arr[0]==0.0&&!has_buy)
   //  {
   //   if(has_sell)
   //     {
   //      Print("平仓操作");
   //      if(!trade.PositionClose(pos_id_sell,"close sell"))
   //         Print("平仓失败：",pos_id_sell," ", trade.ResultRetcode(), " ", trade.ResultRetcodeDescription());
   //      has_sell=false;
   //     }
   //   trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,0.01,0,0,0,"BUY");
   //   pos_id_buy=trade.ResultOrder();
   //   has_buy=true;
   //   return; 
   //  }
   //if(color_arr[0]==0.0&&pos.buy_num==0)
   //   {
   //    open_price=high[1];
   //    tp_price=high[0];
   //    sl_price=low[1];
   //    //Print(open_price, "/",tp_price,"/",sl_price);
   //    if(tick.ask>open_price)
   //      {
   //       trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,0.01,tick.ask,sl_price,tp_price,"buy");
   //      }
   //    return;
   //    } 
    if(color_arr[0]==1.0&&pos.sell_num==0)
      {
       open_price=low[1];
       tp_price=low[0];
       sl_price=high[1];
       if(tick.bid<open_price&&tick.bid>)
         {
           trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,0.01,tick.bid,sl_price,tp_price,"sell");
         }
      
       //if(has_buy)
       //  {
       //  Print("平仓操作");
       //   if(!trade.PositionClose(pos_id_buy,"close buy"))
       //     Print("平仓失败：",pos_id_buy," ", trade.ResultRetcode(), " ", trade.ResultRetcodeDescription());
       //   has_buy=false;
       //  }
       //trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,0.01,0,0,0,"SELL");
       //pos_id_sell=trade.ResultOrder();
       //has_sell=true;
      }
   
  }
//+------------------------------------------------------------------+
