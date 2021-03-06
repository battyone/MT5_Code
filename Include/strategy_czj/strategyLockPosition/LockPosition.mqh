//+------------------------------------------------------------------+
//|                                                 LockPosition.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLockPosition:public CObject
  {
private:
   long              p_id;  // 仓位ID
   ENUM_POSITION_TYPE p_type; // 仓位类型

   bool              is_hedge; // 仓位是否已经对冲
   long              p_id_hedge;  // 对冲仓位ID
   
   bool              main_close;
   bool              hedge_close;
   
public:
                     CLockPosition(void){};
                     CLockPosition(long pos_id);
                    ~CLockPosition(void){};
   void              AddHedgePosition(long pos_id); // 增加对冲仓位
   int               MainPositionWinPoints(); // 主仓位的盈利点数
   int               HedgePositionWinPoints();  // 对冲仓位的盈利点数
   bool              IsHedge();
   long              MainPosID() {return p_id;};
   long              HedgePosID() {return p_id_hedge;};
   void              SetMainClose() {main_close=true;};
   void              SetHedgeClose() {hedge_close=true;};
   bool              IsMainClose() {return main_close;};
   bool              IsHedgeClose() {return hedge_close;};   
   bool              PostionIsClose();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLockPosition::CLockPosition(long pos_id)
  {
   p_id=pos_id;
   PositionSelectByTicket(p_id);
   p_type=PositionGetInteger(POSITION_TYPE);
   is_hedge=false;
   main_close=false;
   hedge_close=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLockPosition::AddHedgePosition(long pos_id)
  {
   p_id_hedge=pos_id;
   is_hedge=true;
  }   
bool CLockPosition::IsHedge(void)
   {
    return is_hedge;
   } 
bool CLockPosition::PostionIsClose(void)
   {
    if(!main_close||(is_hedge&&!hedge_close)) return false;
    return true;
   }  
int CLockPosition::MainPositionWinPoints(void)
   {
    PositionSelectByTicket(p_id);
    double p=(PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_PRICE_CURRENT))/SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_POINT);
    if(p_type==POSITION_TYPE_BUY) return int(-p);
    else return int(p);
   }
int CLockPosition::HedgePositionWinPoints(void)
   {
    PositionSelectByTicket(p_id_hedge);
    double p=(PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_PRICE_CURRENT))/SymbolInfoDouble(PositionGetString(POSITION_SYMBOL),SYMBOL_POINT);
    if(p_type==POSITION_TYPE_BUY) return int(p);
    else return int(-p);
   }        
//+------------------------------------------------------------------+
