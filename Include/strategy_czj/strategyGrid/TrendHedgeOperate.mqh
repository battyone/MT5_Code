//+------------------------------------------------------------------+
//|                                            TrendHedgeOperate.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrendHedgeOperate:public CStrategy
  {
private:
   int               h_ma_long;
   int               h_ma_short;
   double            ma_long[];
   double            ma_short[];

   CArrayLong        long_pos_id;   // 多头仓位的id
   CArrayLong        short_pos_id;   // 空头仓位的id
   MqlTick           latest_price;
public:
   PositionInfor     pos_state;
public:
                     CTrendHedgeOperate(void){};
                    ~CTrendHedgeOperate(void){};
   void              Init();
   void              RefreshTickPrice();   // 刷新最新报价
   void              OpenLongPosition(double open_lots);
   void              CloseLongPosition();
   void              OpenShortPosition(double open_lots);
   void              CloseShortPosition();
   void              RefreshPositionState();
   bool              IsUp(){return ma_long[0]<ma_short[0]?true:false;};
   bool              IsDown(){return ma_long[0]>ma_short[0]?true:false;};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendHedgeOperate::Init(void)
  {
   h_ma_long=iMA(ExpertSymbol(),PERIOD_H1,200,0,MODE_SMA,PRICE_CLOSE);
   h_ma_short=iMA(ExpertSymbol(),PERIOD_H1,24,0,MODE_SMA,PRICE_CLOSE);
   long_pos_id.Clear();
   short_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendHedgeOperate::RefreshTickPrice(void)
  {
   SymbolInfoTick(ExpertSymbol(),latest_price);
   CopyBuffer(h_ma_long,0,0,1,ma_long);
   CopyBuffer(h_ma_short,0,0,1,ma_short);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendHedgeOperate::RefreshPositionState(void)
  {
   long_pos_id.Clear();
   short_pos_id.Clear();
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionGetSymbol(i)!=ExpertSymbol() || PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      ulong ticket=PositionGetTicket(i);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) long_pos_id.Add(ticket);
      else short_pos_id.Add(ticket);
     }
   pos_state.Init();
   for(int i=0;i<long_pos_id.Total();i++)
     {
      PositionSelectByTicket(long_pos_id.At(i));
      pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_buy+=1;
      pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
     }
   for(int i=0;i<short_pos_id.Total();i++)
     {
      PositionSelectByTicket(short_pos_id.At(i));
      pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_sell+=1;
      pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendHedgeOperate::CloseLongPosition(void)
  {
   for(int i=0;i<long_pos_id.Total();i++) Trade.PositionClose(long_pos_id.At(i));
   long_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendHedgeOperate::CloseShortPosition(void)
  {
   for(int i=0;i<short_pos_id.Total();i++) Trade.PositionClose(short_pos_id.At(i));
   short_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendHedgeOperate::OpenLongPosition(double open_lots)
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,latest_price.ask,0,0,ExpertSymbol()+":long hedge*************");
   long_pos_id.Add(Trade.ResultOrder());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTrendHedgeOperate::OpenShortPosition(double open_lots)
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,latest_price.bid,0,0,ExpertSymbol()+":short hedge***************");
   short_pos_id.Add(Trade.ResultOrder());
  }
//+------------------------------------------------------------------+
