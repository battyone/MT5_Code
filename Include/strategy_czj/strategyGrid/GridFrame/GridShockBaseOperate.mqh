//+------------------------------------------------------------------+
//|                                         GridShockBaseOperate.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridShockBaseOperate:public CGridBaseOperate
  {
protected:
   int               grid_gap_sell;
   int               grid_gap_buy;
public:
                     CGridShockBaseOperate(void){};
                    ~CGridShockBaseOperate(void){};
   void              SetGridGapSell(int sell_gap){grid_gap_sell=sell_gap;};   // 设置卖单的网格gap
   void              SetGridGapBuy(int buy_gap){grid_gap_buy=buy_gap;};   // 设置买单的网格gap
   int               GetGridGapSell(){return grid_gap_sell;}; // 获取卖单网格gap
   int               GetGridGapBuy(){ return grid_gap_buy;}; // 获取买单网格gap
  };
//+------------------------------------------------------------------+
