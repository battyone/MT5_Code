//+------------------------------------------------------------------+
//|                                            GridTrendStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridTrendBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridTrendStrategy:public CStrategy
  {
private:
   CGridTrendBaseOperate grid_operator;
   int               grid_points;
   int               tp_points_per_lots;
   int               tp_total;
   double            base_lots;
   
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              RefreshState();  // 刷新仓位信息
   void              CheckPositionClose();   // 平仓检测
   void              CheckPositionOpen(); // 开仓检测
   double            CalLotsFibonacci(int index){return NormalizeDouble(base_lots*(1/sqrt(5)*(MathPow((1+sqrt(5))/2,index+1)-MathPow((1-sqrt(5))/2,index+1))),2);};  // 给定级别计算手数   
public:
                     CGridTrendStrategy(void){};
                    ~CGridTrendStrategy(void){};
                    void Init(int g_points,int tp_points, double b_lots, int tp_t=100);
  };
void CGridTrendStrategy::Init(int g_points=100,int tp_points=20,double b_lots=0.01, int tp_t=100)
   {
    grid_operator.ExpertSymbol(ExpertSymbol());
    grid_operator.ExpertMagic(ExpertMagic());
    grid_points=g_points;
    base_lots=b_lots;
    tp_points_per_lots=tp_points;
    tp_total=tp_t;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategy::RefreshState(void)
  {
   grid_operator.RefreshTickPrice();
   grid_operator.RefreshPositionState();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategy::CheckPositionClose(void)
  {
   if((grid_operator.pos_state.lots_buy+grid_operator.pos_state.lots_sell)==0) return;
   if(grid_operator.GetProfitsPerLots()>tp_points_per_lots||grid_operator.GetProfitsTotal()>tp_total)
     {
      grid_operator.CloseAllPosition();
      grid_operator.RefreshBasePrice();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategy::CheckPositionOpen(void)
  {
   if(grid_operator.pos_state.num_buy+grid_operator.pos_state.num_sell==0) // 空仓情况
     {
      if(grid_operator.UpWithBasePrice()>grid_points)
        {
         grid_operator.BuildLongPosition(CalLotsFibonacci(grid_operator.GetGridLevel()+1));
        }
      else if(grid_operator.DownWithBasePrice()>grid_points)
        {
         grid_operator.BuildShortPosition(CalLotsFibonacci(grid_operator.GetGridLevel()+1));
        }
     }
   else // 持仓情况
     {
      if(grid_operator.GetLastPositionType()==POSITION_TYPE_BUY)
        {
         if(grid_operator.DownWithBasePrice()>grid_points)
           {
            grid_operator.BuildShortPosition(CalLotsFibonacci(grid_operator.GetGridLevel()+1));
           }
        }
      else
        {
         if(grid_operator.UpWithBasePrice()>grid_points)
           {
            grid_operator.BuildLongPosition(CalLotsFibonacci(grid_operator.GetGridLevel()+1));
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      RefreshState();
      CheckPositionClose();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
