//+------------------------------------------------------------------+
//|                                              GridSimpleHedge.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
#include "HedgeBaseOperate.mqh"
//+------------------------------------------------------------------+
//|          在网格基础上引入仓位对冲策略                            |
//+------------------------------------------------------------------+
class CGridSimpleHedge:public CStrategy
  {
private:
   CGridBaseOperate  grid_operator; // 网格操作器
   CHedgeBaseOperate hedge_operator;   // 对冲操作器
   int               points_win; // 止盈点位
   int               points_add;    // 加仓点
   GridWinType       win_out_type;  // 止盈出场类型
   bool              hedge_valid;   // 是否开启对冲模式
   double            hedge_lots_unbalance;   // 对冲策略开启阈值
   
public:
                     CGridSimpleHedge(void){};
                    ~CGridSimpleHedge(void){};
   void              Init(int add_points,int win_points,double l_base,GridLotsCalType l_type,GridWinType w_type,int max_pos); // 设置网格策略的参数
   void              SetHedgeParameter(double unbalance_lots=0.2){ hedge_lots_unbalance=unbalance_lots;}; // 设置对冲策略的参数
   void              SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling=ORDER_FILLING_FOK);   // 设置订单执行方式
   void              SetHedgeValid(bool is_hedge_valid=true){hedge_valid=is_hedge_valid;} // 设置对冲模式是否开启
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              HedgeOperate();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimpleHedge::Init(int add_points,int win_points,double l_base,GridLotsCalType l_type,GridWinType w_type,int max_pos)
  {
   grid_operator.ExpertMagic(ExpertMagic());
   grid_operator.ExpertSymbol(ExpertSymbol());
   grid_operator.Init(l_base,l_type,max_pos);
   grid_operator.ReBuildPositionState();
   points_add=add_points;
   points_win=win_points;
   win_out_type=w_type;

   hedge_operator.ExpertMagic(ExpertMagic()+1);
  }
void CGridSimpleHedge::SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling=0)
   {
    grid_operator.SetTypeFilling(filling);
    hedge_operator.SetTypeFilling(filling);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimpleHedge::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      grid_operator.RefreshTickPrice();
      grid_operator.RefreshPositionState();
      switch(win_out_type)
        {
         case ENUM_GRID_WIN_COST :
            if(grid_operator.pos_state.num_buy==0) grid_operator.BuildLongPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_sell==0) grid_operator.BuildShortPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_buy>0 && grid_operator.DistanceAtLastBuyPrice()>points_add) grid_operator.BuildLongPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_sell>0 && grid_operator.DistanceAtLastSellPrice()>points_add) grid_operator.BuildShortPositionWithCostTP(points_win);
            break;
         case ENUM_GRID_WIN_LAST:
            if(grid_operator.pos_state.num_buy==0) grid_operator.BuildLongPositionWithTP(points_win);
            if(grid_operator.pos_state.num_sell==0) grid_operator.BuildShortPositionWithTP(points_win);
            if(grid_operator.pos_state.num_buy>0 && grid_operator.DistanceAtLastBuyPrice()>points_add) grid_operator.BuildLongPositionWithTP(points_win);
            if(grid_operator.pos_state.num_sell>0 && grid_operator.DistanceAtLastSellPrice()>points_add) grid_operator.BuildShortPositionWithTP(points_win);
            break;
         default:
            break;
        }
       if(hedge_valid) HedgeOperate();       
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimpleHedge::HedgeOperate(void)
  {
   hedge_operator.RefreshPositionState();
   double lots_balance=grid_operator.pos_state.lots_buy-grid_operator.pos_state.lots_sell;
   if(MathAbs(lots_balance)<hedge_lots_unbalance) return;
   hedge_operator.RefreshTickPrice();
   if(lots_balance>hedge_lots_unbalance && hedge_operator.pos_state.num_sell==0) hedge_operator.OpenShortPositionWithTpAndSl(NormalizeDouble(lots_balance/4,2),points_add,points_win);
   if(lots_balance<-hedge_lots_unbalance && hedge_operator.pos_state.num_buy==0) hedge_operator.OpenLongPositionWithTpAndSl(NormalizeDouble(-lots_balance/4,2),points_add,points_win);
  }
//+------------------------------------------------------------------+
