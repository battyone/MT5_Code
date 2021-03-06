//+------------------------------------------------------------------+
//|                                   LSRotationElasticStrategy2.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
#include "LSRotationElasticStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLSRE2:public CLSRotationElasticStrategy
  {
public:
                     CLSRE2(void){};
                    ~CLSRE2(void){};
protected:
   virtual void      CheckPositionOpen();    // 开仓检测
   void              FirstGridAddCheck(ENUM_POSITION_TYPE p_type,int gap);
   void              AllGridAddCheck(ENUM_POSITION_TYPE p_type,int gap);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRE2::CheckPositionOpen(void)
  {
//  设置第一个网格为多头
   if(pr.Total()==0)
     {
      OpenNewLongGridPosition(1,"NewLong");
      OpenNewShortGridPosition(1,"NewLong");
      return;
     }
//   加仓判断和操作   
   if(pr.GetBuyLots()>pr.GetSellLots()+0.1) // 多头风险
     {
      FirstGridAddCheck(POSITION_TYPE_BUY,gap_big);
      AllGridAddCheck(POSITION_TYPE_SELL,gap_small);
     }
   else if(pr.GetBuyLots()<pr.GetSellLots()-0.1)
     {
      FirstGridAddCheck(POSITION_TYPE_SELL,gap_big);
      AllGridAddCheck(POSITION_TYPE_BUY,gap_small);
     }
   else
     {
      AllGridAddCheck(POSITION_TYPE_BUY,gap_small);
      AllGridAddCheck(POSITION_TYPE_SELL,gap_small);
     }
//新网格开仓判断    
   CGridPosition *gp=pr.grid_pos.At(pr.Total()-1);
   if(gp.GetPosType()==POSITION_TYPE_BUY)
     {
      if(pr.GetBuyLots()>pr.GetSellLots()+0.1)
        {
         OpenNewShortGridPosition(1,"NewShort");
        }
     }
   else
     {
      if(pr.GetBuyLots()<pr.GetSellLots()-0.1)
        {
         OpenNewLongGridPosition(1,"NewLong");
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRE2::FirstGridAddCheck(ENUM_POSITION_TYPE p_type,int gap)
  {
//   对已有网格进行加仓操作
   for(int i=0;i<pr.Total();i++)
     {
      CGridPosition *gp=pr.grid_pos.At(i);
      if(gp.GetPosType()!=p_type) continue;
      if(gp.GetPosType()==POSITION_TYPE_BUY)
        {
         if((gp.LastPrice()-latest_price.ask)/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>gap) AddLongPosition(i,gp.LastLevel()+1,"FA-BIG");
         break;
        }
      else
        {
         if((latest_price.bid-gp.LastPrice())/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>gap) AddShortPosition(i,gp.LastLevel()+1,"FA-BIG");
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRE2::AllGridAddCheck(ENUM_POSITION_TYPE p_type,int gap)
  {
//   对已有网格进行加仓操作
   for(int i=0;i<pr.Total();i++)
     {
      CGridPosition *gp=pr.grid_pos.At(i);
      if(gp.GetPosType()!=p_type) continue;
      if(gp.GetPosType()==POSITION_TYPE_BUY)
        {
         if((gp.LastPrice()-latest_price.ask)/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>gap) AddLongPosition(i,gp.LastLevel()+1,"AA-S");
        }
      else
        {
         if((latest_price.bid-gp.LastPrice())/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>gap) AddShortPosition(i,gp.LastLevel()+1,"AA-S");
        }
     }
  }
//+------------------------------------------------------------------+
