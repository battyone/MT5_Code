//+------------------------------------------------------------------+
//|                                             GridBaseStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "GridPosition.mqh"
#include <strategy_czj\common\strategy_common.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridBaseStrategyOneSymbol:public CStrategy
  {
protected:
   CGridPositionOneSymbol pos;   // 网格仓位信息
   MqlTick           latest_price;  // 最新的tick报价
   GridLotsCalType   l_type;  // 手数序列类型
   double            base_lots;  // 基准手数
   int               pos_num;
protected:
   virtual void      CheckPositionOpen(const MarketEvent &event){}; // 开仓检测
   virtual void      CheckPositionClose(const MarketEvent &event){};   // 平仓检测
   virtual void      OnEvent(const MarketEvent &event);

   int               DistToLastShortPrice(); // 和当前空头最后一个仓位比，又上升的点数
   int               DistToLastLongPrice(); // 和当前多头最后一个仓位比，又下跌的点数
   double            DeltaHoursToLastLong();
   double            DeltaHoursToLastShort();
   //---平仓操作
   void              CloseLongPosition();
   void              CloseLongPosition(CArrayInt &index_pid);
   void              CloseShortPosition();
   void              CloseShortPosition(CArrayInt &index_pid);
   void              CloseLongPosition(int index);
   void              CloseShortPosition(int index);
   //---开仓操作
   void              OpenLongPosition(string comment="comment");
   void              OpenShortPosition(string comment="comment");
public:
                     CGridBaseStrategyOneSymbol(void);
                    ~CGridBaseStrategyOneSymbol(void){};
   void              SetLotsParameter(double lots_=0.01,GridLotsCalType lots_type_=ENUM_GRID_LOTS_LINEAR,int pos_max=15);   // 设置手数序列相关参数，Pos_max仅在指定为LOS_EXP有效
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridBaseStrategyOneSymbol::CGridBaseStrategyOneSymbol(void)
  {
   SetLotsParameter();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseStrategyOneSymbol::SetLotsParameter(double lots_=0.010000,GridLotsCalType lots_type_=8,int pos_max=15)
  {
   base_lots=lots_;
   l_type=lots_type_;
   pos_num=pos_max;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseStrategyOneSymbol::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      pos.Refresh();
     }
   CheckPositionClose(event);
   CheckPositionOpen(event);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGridBaseStrategyOneSymbol::DistToLastLongPrice(void)
  {
   return (int)((pos.LastLongPrice()-latest_price.ask)*MathPow(10,Digits()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGridBaseStrategyOneSymbol::DistToLastShortPrice(void)
  {
   return (int)((latest_price.bid-pos.LastShortPrice())*MathPow(10,Digits()));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridBaseStrategyOneSymbol::DeltaHoursToLastLong(void)
  {
   Print("DeltaHoursToLastLong:",double(latest_price.time-pos.LastLongTime())/(60*60));
   return double(latest_price.time-pos.LastLongTime())/(60*60);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridBaseStrategyOneSymbol::DeltaHoursToLastShort(void)
  {
   Print("DeltaHoursToLastShort:",double(latest_price.time-pos.LastShortTime())/(60*60));
   return double(latest_price.time-pos.LastShortTime())/(60*60);
  }
void CGridBaseStrategyOneSymbol::CloseLongPosition(int index)
   {
    Trade.PositionClose(pos.LongPosIdAt(index));
    pos.DelLongPosId(index);
   }
void CGridBaseStrategyOneSymbol::CloseShortPosition(int index)
   {
    Trade.PositionClose(pos.ShortPosIdAt(index));
    pos.DelShortPosId(index);
   }
void CGridBaseStrategyOneSymbol::CloseLongPosition(void)
   {
    for(int i=pos.TotalLong()-1;i>=0;i--)
      {
       Trade.PositionClose(pos.LongPosIdAt(i));
       pos.DelLongPosId(i);
      }
   }
void CGridBaseStrategyOneSymbol::CloseShortPosition(void)
   {
    for(int i=pos.TotalShort()-1;i>=0;i--)
      {
       Trade.PositionClose(pos.ShortPosIdAt(i));
       pos.DelShortPosId(i);
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseStrategyOneSymbol::CloseLongPosition(CArrayInt &index_pid)
  {
   for(int i=0;i<index_pid.Total();i++)
     {
      Trade.PositionClose(pos.LongPosIdAt(index_pid.At(i)));
     }
   pos.DelLongPosId(index_pid);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseStrategyOneSymbol::CloseShortPosition(CArrayInt &index_pid)
  {
   for(int i=0;i<index_pid.Total();i++)
     {
      Trade.PositionClose(pos.ShortPosIdAt(index_pid.At(i)));
     }
   pos.DelShortPosId(index_pid);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseStrategyOneSymbol::OpenLongPosition(string comment="comment")
  {
   int level=0;
   double l=0;
   if(pos.TotalLong()==0) level=1;
   else level=pos.LastLongLevel()+1;
   l=CalGridLots(level,base_lots,l_type,pos_num);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l,latest_price.ask,0,0,comment);
   pos.AddLongPosId(Trade.ResultOrder(),level);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridBaseStrategyOneSymbol::OpenShortPosition(string comment="comment")
  {
   int level=0;
   double l=0;
   if(pos.TotalShort()==0) level=1;
   else level=pos.LastShortLevel()+1;
   l=CalGridLots(level,base_lots,l_type,pos_num);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l,latest_price.bid,0,0,comment);
   pos.AddShortPosId(Trade.ResultOrder(),level);
  }
//+------------------------------------------------------------------+
