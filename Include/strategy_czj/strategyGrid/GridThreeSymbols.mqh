//+------------------------------------------------------------------+
//|                                             GridThreeSymbols.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
#include "TrendHedgeOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridThreeSymbols:public CStrategy
  {
private:
   string            symbols[3];
   CGridBaseOperate  child_strategy[3];
   int               grid_add_points[3];
   int               grid_tp_points[3];
   int               grid_pos_num[3];

protected:
   void              RefreshTickPrice();
   void              RefreshPositionState();
   void              CheckPositionOpen();
public:
                     CGridThreeSymbols(void){};
                    ~CGridThreeSymbols(void){};
   void              SetThreeSymbols(string symbol_cross,string symbol_x,string symbol_y);
   void              SetThreeGrids(int grid_cross,int grid_x,int grid_y);
   void              SetThreePosNums(int pnum_cross,int pnum_x,int pnum_y);
   void              SetThreeTPs(int tp_cross,int tp_x,int tp_y);
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::SetThreeSymbols(string symbol_cross,string symbol_x,string symbol_y)
  {
   symbols[0]=symbol_cross;
   symbols[1]=symbol_x;
   symbols[2]=symbol_y;
   for(int i=0;i<3;i++)
     {
      child_strategy[i].ExpertMagic(i+ExpertMagic());
      child_strategy[i].ExpertSymbol(symbols[i]);
      child_strategy[i].Init();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::SetThreePosNums(int pnum_cross,int pnum_x,int pnum_y)
  {
   grid_pos_num[0]=pnum_cross;
   grid_pos_num[1]=pnum_x;
   grid_pos_num[2]=pnum_y;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::SetThreeGrids(int grid_cross,int grid_x,int grid_y)
  {
   grid_add_points[0]=grid_cross;
   grid_add_points[1]=grid_x;
   grid_add_points[2]=grid_y;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::SetThreeTPs(int tp_cross,int tp_x,int tp_y)
  {
   grid_tp_points[0]=tp_cross;
   grid_tp_points[1]=tp_x;
   grid_tp_points[2]=tp_y;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::RefreshTickPrice(void)
  {
   for(int i=0;i<3;i++)
     {
      CGridBaseOperate *s=&child_strategy[i];
      s.RefreshTickPrice();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::RefreshPositionState(void)
  {
   for(int i=0;i<3;i++)
     {
      CGridBaseOperate *s=&child_strategy[i];
      s.RefreshPositionState();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshTickPrice();
      RefreshPositionState();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridThreeSymbols::CheckPositionOpen(void)
  {
//   交叉币种的开仓
   if(child_strategy[0].pos_state.num_buy==0)
     {
      child_strategy[0].BuildLongPositionWithTP(grid_tp_points[0]);
     }
   else if(child_strategy[0].DistanceAtLastBuyPrice()>grid_add_points[0])
     {
      child_strategy[0].BuildLongPositionWithTP(grid_tp_points[0]);
     }
   if(child_strategy[0].pos_state.num_sell==0)
     {
      child_strategy[0].BuildShortPositionWithTP(grid_tp_points[0]);
     }
   else if(child_strategy[0].DistanceAtLastSellPrice()>grid_add_points[0])
     {
      child_strategy[0].BuildShortPositionWithTP(grid_tp_points[0]);
     }
     
   int long_minus_short=child_strategy[0].pos_state.num_buy-child_strategy[0].pos_state.num_sell;

   if(long_minus_short < 0 && child_strategy[1].pos_state.num_buy>0 && child_strategy[1].DistanceAtLastBuyPrice()>grid_add_points[1]) child_strategy[1].BuildLongPositionWithTP(grid_tp_points[1]);
   if(long_minus_short > 0 &&child_strategy[1].pos_state.num_sell>0 && child_strategy[1].DistanceAtLastSellPrice()>grid_add_points[1]) child_strategy[1].BuildShortPositionWithTP(grid_tp_points[1]);
   if(long_minus_short > 0 &&child_strategy[2].pos_state.num_buy>0 && child_strategy[2].DistanceAtLastBuyPrice()>grid_add_points[2]) child_strategy[2].BuildLongPositionWithTP(grid_tp_points[2]);
   if(long_minus_short < 0 &&child_strategy[2].pos_state.num_sell>0 && child_strategy[2].DistanceAtLastSellPrice()>grid_add_points[2]) child_strategy[2].BuildShortPositionWithTP(grid_tp_points[2]);
//      直盘x OR Y的开仓

   if(long_minus_short<-4)
     {
      if(child_strategy[1].pos_state.num_buy==0)
        {
         child_strategy[1].BuildLongPositionWithTP(grid_tp_points[1]);
        }
      
      if(child_strategy[2].pos_state.num_sell==0)
        {
         child_strategy[2].BuildShortPositionWithTP(grid_tp_points[2]);
        }
      
     }
   else if(long_minus_short>4)
     {
      if(child_strategy[1].pos_state.num_sell==0)
        {
         child_strategy[1].BuildShortPositionWithTP(grid_tp_points[1]);
        }
      
      if(child_strategy[2].pos_state.num_buy==0)
        {
         child_strategy[2].BuildLongPositionWithTP(grid_tp_points[2]);
        }
     }
  }
//+------------------------------------------------------------------+
