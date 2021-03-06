//+------------------------------------------------------------------+
//|                                         GridTrendBaseOperate.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "趋势突破网格策略"
#include "GridBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridTrendBaseOperate:public CGridBaseOperate
  {
protected:
   ENUM_POSITION_TYPE last_pos_type;
public:
                     CGridTrendBaseOperate(void){};
                    ~CGridTrendBaseOperate(void){};

   bool              BuildLongPosition();   // 多头建仓
   bool              BuildShortPosition();  // 空头建仓
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridTrendBaseOperate::BuildLongPosition()
  {
   double l=CalLotsDefault(pos_state.GetTotalNum()+1,base_lots);
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l,latest_price.ask,0,0,"TrendGrid-Long"+IntegerToString(pos_state.GetTotalNum()+1)))
     {
      last_pos_type=POSITION_TYPE_BUY;
      long_pos_id.Add(Trade.ResultOrder());
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridTrendBaseOperate::BuildShortPosition()
  {
   double l=CalLotsDefault(pos_state.GetTotalNum()+1,base_lots);
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l,latest_price.bid,0,0,"TrendGrid-Short"+IntegerToString(pos_state.GetTotalNum()+1)))
     {
      last_pos_type=POSITION_TYPE_SELL;
      short_pos_id.Add(Trade.ResultOrder());
      return true;
     }
    return false;
  }
//+------------------------------------------------------------------+
