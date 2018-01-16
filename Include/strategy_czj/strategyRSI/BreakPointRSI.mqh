//+------------------------------------------------------------------+
//|                                                BreakPointRSI.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
enum RSI_type
  {
   ENUM_RSI_TYPE_1,// RSI偏离越来越大，且最新的大于rsi_up或小于rsi_down
   ENUM_RSI_TYPE_2,// 最新RSI的偏离大于rsi_up或小于rsi_down且前一个点时拐点(极大值/极小值)
   ENUM_RSI_TYPE_3 //RSI偏离越来越大，且均大于rsi_up或均小于rsi_down
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBreakPointRSIStrategy:public CStrategy
  {
private:
   int               rsi_handle;
   double            rsi_up;
   double            rsi_down;
   double            rsi_buffer[];
   MqlTick           latest_price;
   double            order_lots;
   RSI_type rsi_type;
protected:
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CBreakPointRSIStrategy(void);
                    ~CBreakPointRSIStrategy(void){};
   void              SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame);
   void  InitStrategy(RSI_type type_rsi);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBreakPointRSIStrategy::CBreakPointRSIStrategy(void)
  {

  }
void CBreakPointRSIStrategy::InitStrategy(RSI_type type_rsi)
   {
       rsi_handle=iRSI(ExpertSymbol(),Timeframe(),12,PRICE_CLOSE);
      rsi_up=70;
      rsi_down=30;
      order_lots=0.1;
      rsi_type=type_rsi;
   }
void CBreakPointRSIStrategy::SetEventDetect(string symbol,ENUM_TIMEFRAMES time_frame)
   {
    AddBarOpenEvent(symbol,time_frame);
    AddTickEvent(symbol);
   }
void CBreakPointRSIStrategy::OnEvent(const MarketEvent &event)
   {
    // 品种的tick事件发生时候的处理
    if(event.symbol==ExpertSymbol()&&event.type==MARKET_EVENT_TICK)
      {
       CopyBuffer(rsi_handle,0,0,3,rsi_buffer);
       bool rsi_short=false,rsi_long=false;
      switch(rsi_type)
        {
         case ENUM_RSI_TYPE_1:
           // 最新RSI的偏离大于rsi_up或小于rsi_down,且之前是递增/递减的
           rsi_short=rsi_buffer[0]>rsi_up&&rsi_buffer[0]>rsi_buffer[1]&&rsi_buffer[1]>rsi_buffer[2];
           rsi_long=rsi_buffer[0]<rsi_down&&rsi_buffer[0]<rsi_buffer[1]&&rsi_buffer[1]<rsi_buffer[2];
           break;
         case ENUM_RSI_TYPE_2:
            // 最新RSI的偏离大于rsi_up或小于rsi_down且前一个点时拐点(极大值/极小值)
           rsi_short=rsi_buffer[0]>rsi_up&&rsi_buffer[1]>rsi_buffer[0]&&rsi_buffer[1]>rsi_buffer[2];
           rsi_long=rsi_buffer[0]<rsi_down&&rsi_buffer[1]<rsi_buffer[0]&&rsi_buffer[1]<rsi_buffer[2];
            break;
         case ENUM_RSI_TYPE_3:
             //RSI偏离越来越大，且均大于rsi_up或均小于rsi_down
           rsi_short=rsi_buffer[2]>rsi_up&&rsi_buffer[1]>rsi_buffer[2]&&rsi_buffer[0]>rsi_buffer[1];
           rsi_long=rsi_buffer[2]<rsi_down&&rsi_buffer[1]<rsi_buffer[2]&&rsi_buffer[0]<rsi_buffer[1];
            break;     
         default:
           break;
        }
       SymbolInfoTick(ExpertSymbol(),latest_price);
       for(int i=0;i<ActivePositions.Total();i++)
         {
          CPosition *cpos=ActivePositions.At(i);
          if(cpos.ExpertMagic()!=ExpertMagic())continue;
          if(cpos.Symbol() != ExpertSymbol())continue;
          
          if(cpos.Direction()==POSITION_TYPE_BUY&&rsi_short)
             Trade.PositionClose(cpos.ID());
          if(cpos.Direction()==POSITION_TYPE_SELL&&rsi_long)
             Trade.PositionClose(cpos.ID());
         }
      }
     //---品种的BAR事件发生时候的处理
     if(event.symbol==ExpertSymbol()&&event.period==Timeframe()&&event.type==MARKET_EVENT_BAR_OPEN)
       {
        CopyBuffer(rsi_handle,0,0,3,rsi_buffer);
        bool rsi_short=false,rsi_long=false;
        switch(rsi_type)
        {
         case ENUM_RSI_TYPE_1:
           // 最新RSI的偏离大于rsi_up或小于rsi_down,且之前是递增/递减的
           rsi_short=rsi_buffer[0]>rsi_up&&rsi_buffer[0]>rsi_buffer[1]&&rsi_buffer[1]>rsi_buffer[2];
           rsi_long=rsi_buffer[0]<rsi_down&&rsi_buffer[0]<rsi_buffer[1]&&rsi_buffer[1]<rsi_buffer[2];
           break;
         case ENUM_RSI_TYPE_2:
            // 最新RSI的偏离大于rsi_up或小于rsi_down且前一个点时拐点(极大值/极小值)
           rsi_short=rsi_buffer[0]>rsi_up&&rsi_buffer[1]>rsi_buffer[0]&&rsi_buffer[1]>rsi_buffer[2];
           rsi_long=rsi_buffer[0]<rsi_down&&rsi_buffer[1]<rsi_buffer[0]&&rsi_buffer[1]<rsi_buffer[2];
            break;
         case ENUM_RSI_TYPE_3:
             //RSI偏离越来越大，且均大于rsi_up或均小于rsi_down
           rsi_short=rsi_buffer[2]>rsi_up&&rsi_buffer[1]>rsi_buffer[2]&&rsi_buffer[0]>rsi_buffer[1];
           rsi_long=rsi_buffer[2]<rsi_down&&rsi_buffer[1]<rsi_buffer[2]&&rsi_buffer[0]<rsi_buffer[1];
            break;     
         default:
           break;
        }
        if(positions.open_buy==0&&rsi_long)
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,order_lots,latest_price.ask,0,0,"buy RSI"+(string)rsi_buffer[0]);
        if(positions.open_sell==0&&rsi_short)
          Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,order_lots,latest_price.bid,0,0,"sell RSI"+(string)rsi_buffer[0]);
       }
   }
//+------------------------------------------------------------------+
