//+------------------------------------------------------------------+
//|                                             HedgeBaseOperate.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHedgeBaseOperate:public CStrategy
  {
private:
   CArrayLong        long_pos_id;   // 多头仓位的id
   CArrayLong        short_pos_id;   // 空头仓位的id
   MqlTick           latest_price;

public:
   PositionInfor     pos_state;
public:
                     CHedgeBaseOperate(void){};
                    ~CHedgeBaseOperate(void){};
   virtual void      RefreshTickPrice();
   void              RefreshPositionState();
   virtual bool      LongCondition(){return false;};
   virtual bool      ShortCondition(){return false;};
   void              OpenLongPosition(double lots);
   void              OpenShortPosition(double lots);
   void              OpenLongPositionWithTpAndSl(double lots,int tp_points,int sl_points);
   void              OpenShortPositionWithTpAndSl(double lots,int tp_points,int sl_points);
   void              CloseLongPosition();
   void              CloseShortPosition();
   void              SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling){Trade.SetTypeFilling(filling);};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::RefreshTickPrice(void)
  {
   SymbolInfoTick(ExpertSymbol(),latest_price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::RefreshPositionState(void)
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
void CHedgeBaseOperate::CloseLongPosition(void)
  {
   for(int i=0;i<long_pos_id.Total();i++) Trade.PositionClose(long_pos_id.At(i));
   long_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::CloseShortPosition(void)
  {
   for(int i=0;i<short_pos_id.Total();i++) Trade.PositionClose(short_pos_id.At(i));
   short_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::OpenLongPosition(double open_lots)
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,latest_price.ask,0,0,ExpertSymbol()+":long hedge");
   long_pos_id.Add(Trade.ResultOrder());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::OpenShortPosition(double open_lots)
  {
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,latest_price.bid,0,0,ExpertSymbol()+":short hedge");
   short_pos_id.Add(Trade.ResultOrder());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::OpenLongPositionWithTpAndSl(double lots,int tp_points,int sl_points)
  {
   double tp_price=latest_price.ask+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   double sl_price=latest_price.ask-sl_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots,latest_price.ask,sl_price,tp_price,ExpertSymbol()+":long hedge with tp-sl");
   long_pos_id.Add(Trade.ResultOrder());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::OpenShortPositionWithTpAndSl(double lots,int tp_points,int sl_points)
  {
   double tp_price=latest_price.bid-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   double sl_price=latest_price.bid+sl_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots,latest_price.bid,sl_price,tp_price,ExpertSymbol()+":short hedge with tp-sl");
   short_pos_id.Add(Trade.ResultOrder());
  }
//+------------------------------------------------------------------+
