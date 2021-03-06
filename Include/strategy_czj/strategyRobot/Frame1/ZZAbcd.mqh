//+------------------------------------------------------------------+
//|                                                       ZZAbcd.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "ZZBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CZZAbcd:public CZZBase
  {
private:
   double            z1;
   double            z2;
   double            z3;
   double            z4;
   double            last_buy_price;
   double            last_sell_price;
public:
                     CZZAbcd(void){};
                    ~CZZAbcd(void){};
protected:
   virtual void      CheckPositionOpen();
   void              CheckZZ();
   void              CheckOpen();
   bool              IsBuyMode();
   bool              IsSellMode();
   bool              AbEqualCd();
   bool              IsSuitablePrice();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CZZAbcd::CheckPositionOpen(void)
  {
   z1=value_zz.At(value_zz.Total()-1);
   z2=value_zz.At(value_zz.Total()-2);
   z3=value_zz.At(value_zz.Total()-3);
   z4=value_zz.At(value_zz.Total()-4);
   z1=latest_price.ask;
   CheckOpen();
  }
void CZZAbcd::CheckOpen(void)
   {
     if(positions.open_buy==0 || (latest_price.time-last_buy_time>4*60*60)) // 开多单的基本条件
     //if(positions.open_buy==0) // 开多单的基本条件
     {
      if(IsBuyMode())
        {
         tp_price=latest_price.ask+points_tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         sl_price=latest_price.bid-points_sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01,latest_price.ask,sl_price,tp_price);
         last_buy_time=latest_price.time;
         last_buy_price=latest_price.ask;
        }
     }
   if(positions.open_sell==0 || (latest_price.time-last_sell_time>4*60*60)) // 开空单的基本条件
   //if(positions.open_sell==0)  
     {
      if(IsSellMode())
        {
         tp_price=latest_price.bid-points_tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         sl_price=latest_price.ask+points_sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01,latest_price.bid,sl_price,tp_price);
         last_sell_time=latest_price.time;
         last_sell_price=latest_price.bid;
        }
     }
   }     
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CZZAbcd::IsBuyMode(void)
  {
   if(!AbEqualCd()) return false;
   if(!IsSuitablePrice()) return false;
   if(z2>z1) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CZZAbcd::IsSellMode(void)
  {
   if(!AbEqualCd()) return false;
   if(!IsSuitablePrice()) return false;
   if(z2<z1) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CZZAbcd::AbEqualCd(void)
  {
   double len_ab=MathAbs(z4-z3);
   double len_cd=MathAbs(z2-z1);
   double len_bc=MathAbs(z3-z2);
   if(len_ab==0||len_bc==0||len_cd==0) return false;
   if(len_ab<500*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) return false;
   if(MathAbs(len_ab-len_cd)<SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)*100&&len_bc/len_ab<0.4) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CZZAbcd::IsSuitablePrice(void)
  {
   if(MathAbs(latest_price.ask-z1)/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)<100) return true;
   return false;
  }
//+------------------------------------------------------------------+
