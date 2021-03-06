//+------------------------------------------------------------------+
//|                                          GridSimpleDynamicTP.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "GridSimple.mqh"
//+------------------------------------------------------------------+
//| 在CGridSimple的基础上，添加动态止盈，根据多空的仓位情况，        |
//| 仓位轻的止盈点设置更加激进些                                     |
//+------------------------------------------------------------------+
class CGridSimpleDynamicTP:public CGridSimple
  {
private:
   double            tp_ratio;
   int               num_unbalance;
public:
                     CGridSimpleDynamicTP(void);
                    ~CGridSimpleDynamicTP(void){};
   void              SetDynamicParameter(double tp_ratio_=3/2,int num_unbalance_=5);
protected:
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridSimpleDynamicTP::CGridSimpleDynamicTP(void)
  {
   tp_ratio=3/2;
   num_unbalance=5;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimpleDynamicTP::SetDynamicParameter(double tp_ratio_=1.000000,int num_unbalance_=5)
  {
   tp_ratio=tp_ratio_;
   num_unbalance=num_unbalance_;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimpleDynamicTP::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      grid_operator.RefreshPositionState();
      grid_operator.RefreshTickPrice();
      int num_buy_to_sell=grid_operator.pos_state.num_buy-grid_operator.pos_state.num_sell;
      switch(win_out_type)
        {
         case ENUM_GRID_WIN_COST :
            if(grid_operator.pos_state.num_buy==0) grid_operator.BuildLongPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_sell==0) grid_operator.BuildShortPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_buy>0 && grid_operator.DistanceAtLastBuyPrice()>points_add)
              {
               if(num_buy_to_sell<-num_unbalance) grid_operator.BuildLongPositionWithCostTP((int)(points_win*tp_ratio));
               else grid_operator.BuildLongPositionWithCostTP(points_win);
              }
            if(grid_operator.pos_state.num_sell>0 && grid_operator.DistanceAtLastSellPrice()>points_add)
              {
               if(num_buy_to_sell>num_unbalance) grid_operator.BuildShortPositionWithCostTP((int)(points_win*tp_ratio));
               else  grid_operator.BuildShortPositionWithCostTP(points_win);
              }
            break;
         case ENUM_GRID_WIN_LAST:
            if(grid_operator.pos_state.num_buy==0) grid_operator.BuildLongPositionWithTP(points_win);
            if(grid_operator.pos_state.num_sell==0) grid_operator.BuildShortPositionWithTP(points_win);
            if(grid_operator.pos_state.num_buy>0 && grid_operator.DistanceAtLastBuyPrice()>points_add)
              {
               if(num_buy_to_sell<-num_unbalance) grid_operator.BuildLongPositionWithTP((int)(points_win*tp_ratio));
               else grid_operator.BuildLongPositionWithTP(points_win);
              }
            if(grid_operator.pos_state.num_sell>0 && grid_operator.DistanceAtLastSellPrice()>points_add)
              {
               if(num_buy_to_sell>num_unbalance) grid_operator.BuildShortPositionWithTP((int)(points_win*tp_ratio));
               else grid_operator.BuildShortPositionWithTP(points_win);
              }
            break;
         default:
            break;
        }
     }
  }
//+------------------------------------------------------------------+
