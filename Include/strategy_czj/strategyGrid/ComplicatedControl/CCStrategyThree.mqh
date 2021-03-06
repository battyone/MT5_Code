//+------------------------------------------------------------------+
//|                                              CCStrategyThree.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "多品种组合网格策略：网格根据仓位风险进行弹性控制，设置多种平仓方式"
#include "CCOpenCloseLogic.mqh"

enum SymbolRiskType
  {
   ENUM_RISK_DOUBLE_RISK,
   ENUM_RISK_DOUBLE_HEDGE,
   ENUM_RISK_SINGLE_RISK,
   ENUM_RISK_SINGLE_HEDGE
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCStrategyThree:public CCOpenCloseLogic
  {
private:
   int gap_hedge2_less3;
   int gap_hedge2_less5;
   int gap_hedge2;
   int gap_hedge1_less3;
   int gap_hedge1_less5;
   int gap_hedge1;
   int gap_risk1_less3;
   int gap_risk1_less5;
   int gap_risk1;
   int gap_risk2_less3;
   int gap_risk2_less5;
   int gap_risk2;
protected:
   virtual void      CheckPositionClose(); // 平仓判断
   virtual void      CheckPositionOpen(const MarketEvent &event); // 开仓判断  
   void              ElasticGridOpen();
   bool              NeedBigGapLongPositionAt(int index);
   bool              NeedBigGapShortPositionAt(int index);
   int               CalLongGapByRisk(int index);
   int               CalShortGapByRisk(int index);
   SymbolRiskType    CalSymbolRiskType(int index, ENUM_POSITION_TYPE p_type);
public:
                     CCStrategyThree(void);
                    ~CCStrategyThree(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCStrategyThree::CCStrategyThree(void)
  {
   AddBarOpenEvent(ExpertSymbol(),PERIOD_M1);
   for(int i=0;i<28;i++)
     {
      AddBarOpenEvent(SYMBOLS_28[i],PERIOD_H1);
     }
   //gap_hedge2_less3=150;
   //gap_hedge2_less5=200;
   //gap_hedge2=250;
   //gap_hedge1_less3=300;
   //gap_hedge1_less5=500;
   //gap_hedge1=800;
   //gap_risk1_less3=400;
   //gap_risk1_less5=600;
   //gap_risk1=1000;
   //gap_risk2_less3=600;
   //gap_risk2_less5=1500;
   //gap_risk2=5000;
   
   gap_hedge2_less3=300;
   gap_hedge2_less5=400;
   gap_hedge2=500;
   gap_hedge1_less3=500;
   gap_hedge1_less5=700;
   gap_hedge1=900;
   gap_risk1_less3=600;
   gap_risk1_less5=900;
   gap_risk1=1200;
   gap_risk2_less3=800;
   gap_risk2_less5=1600;
   gap_risk2=4500;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyThree::CheckPositionOpen(const MarketEvent &event)
  {
   switch(event.period)
     {
      case PERIOD_M1:
         RefreshRiskInfor();
         ElasticGridOpen();
         break;
      case PERIOD_H1:
         RefreshRiskInfor();
         PrintRiskInfor();
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyThree::CheckPositionClose(void)
  {
   RefreshRiskInfor();
   CheckAllPositionClose(500,100);
   RefreshRiskInfor();
   for(int i=0;i<28;i++)
     {
      PartialClosePosition(i,200.0,200.0,POSITION_TYPE_BUY,"PartClose");
      PartialClosePosition(i,200.0,200.0,POSITION_TYPE_SELL,"PartClose");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyThree::ElasticGridOpen(void)
  {
//for(int i=0;i<28;i++)
//  {
//   if(NeedBigGapLongPositionAt(i)) NormGridOpenLongAt(i,1500,"BigAdd");
//   else NormGridOpenLongAt(i,150,"NormAdd");
//   if(NeedBigGapShortPositionAt(i)) NormGridOpenShortAt(i,1500,"BigAdd");
//   else NormGridOpenShortAt(i,150,"NormAdd");
//  }
   for(int i=0;i<28;i++)
     {
      int gap_long=CalLongGapByRisk(i);
      int gap_short=CalShortGapByRisk(i);
      NormGridOpenLongAt(i,gap_long,string(gap_long));
      NormGridOpenShortAt(i,gap_short,string(gap_short));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCStrategyThree::NeedBigGapLongPositionAt(int index)
  {
   if(pos_risk_state.LongPosTotalAt(index)>10) return true;
   if(pos_risk_state.GetSymbolLeftCurrencyRisk(index)>0.2&&pos_risk_state.GetSymbolRightCurrencyRisk(index)<-0.2) return true;
   if(pos_risk_state.GetSymbolLeftCurrencyRisk(index)>1||pos_risk_state.GetSymbolRightCurrencyRisk(index)<-1) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCStrategyThree::NeedBigGapShortPositionAt(int index)
  {
   if(pos_risk_state.ShortPosTotalAt(index)>10) return true;
   if(pos_risk_state.GetSymbolLeftCurrencyRisk(index)<-0.1&&pos_risk_state.GetSymbolRightCurrencyRisk(index)>0.1) return true;
   if(pos_risk_state.GetSymbolLeftCurrencyRisk(index)<-1||pos_risk_state.GetSymbolRightCurrencyRisk(index)>1) return true;
   return false;
  }
SymbolRiskType CCStrategyThree::CalSymbolRiskType(int index,ENUM_POSITION_TYPE p_type)
   {
      double left_c_risk=pos_risk_state.GetSymbolLeftCurrencyRisk(index);
      double right_c_risk=pos_risk_state.GetSymbolRightCurrencyRisk(index);
      if(p_type==POSITION_TYPE_BUY)
        {
         if(left_c_risk<0 && right_c_risk>0) return ENUM_RISK_DOUBLE_HEDGE;   // 双向对冲
         if(left_c_risk<0 && right_c_risk<0)  // 两币种空头风险
            {
             if(MathAbs(right_c_risk)>MathAbs(left_c_risk)) return ENUM_RISK_SINGLE_RISK;
             else return ENUM_RISK_SINGLE_HEDGE;
            }
          if(left_c_risk>0 && right_c_risk>0) // 两币种多头风险
            {
             if(MathAbs(left_c_risk)>MathAbs(right_c_risk)) return ENUM_RISK_SINGLE_RISK;
             else return ENUM_RISK_SINGLE_HEDGE;
            }
          return ENUM_RISK_DOUBLE_RISK;  // 双向加剧
        }
      else
        {
         if(left_c_risk>0 && right_c_risk<0) return ENUM_RISK_DOUBLE_HEDGE;   // 双向对冲
         if(left_c_risk<0 && right_c_risk<0)  // 两币种空头风险
            {
             if(MathAbs(right_c_risk)<MathAbs(left_c_risk)) return ENUM_RISK_SINGLE_RISK;
             else return ENUM_RISK_SINGLE_HEDGE;
            }
          if(left_c_risk>0 && right_c_risk>0) // 两币种多头风险
            {
             if(MathAbs(left_c_risk)<MathAbs(right_c_risk)) return ENUM_RISK_SINGLE_RISK;
             else return ENUM_RISK_SINGLE_HEDGE;
            }
          return ENUM_RISK_DOUBLE_RISK;  // 双向加剧
        }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CCStrategyThree::CalLongGapByRisk(int index)
  {
   SymbolRiskType srt=CalSymbolRiskType(index,POSITION_TYPE_BUY);
   switch(srt)
      {
       case ENUM_RISK_DOUBLE_HEDGE :
         if(pos_risk_state.LongPosTotalAt(index)<3) return gap_hedge2_less3;
         if(pos_risk_state.LongPosTotalAt(index)<5) return gap_hedge2_less5;
         else return gap_hedge2;
         break;
       case ENUM_RISK_DOUBLE_RISK:
         if(pos_risk_state.LongPosTotalAt(index)<3) return gap_risk2_less3;
         if(pos_risk_state.LongPosTotalAt(index)<5) return gap_risk2_less5;
         else return gap_risk2;           
         break;
       case ENUM_RISK_SINGLE_HEDGE:
         if(pos_risk_state.LongPosTotalAt(index)<3) return gap_hedge1_less3;
         if(pos_risk_state.LongPosTotalAt(index)<5) return gap_hedge1_less5;
         else return gap_hedge1;          
          break;
       case ENUM_RISK_SINGLE_RISK:
         if(pos_risk_state.LongPosTotalAt(index)<3) return gap_risk1_less3;
         if(pos_risk_state.LongPosTotalAt(index)<5) return gap_risk1_less5;
         else return gap_risk1;          
          break;
       default:
         if(pos_risk_state.LongPosTotalAt(index)<3) return gap_risk1_less3;
         if(pos_risk_state.LongPosTotalAt(index)<5) return gap_risk1_less5;
         else return gap_risk1;    
      }  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CCStrategyThree::CalShortGapByRisk(int index)
  {
   SymbolRiskType srt=CalSymbolRiskType(index,POSITION_TYPE_SELL);   
   switch(srt)
      {
       case ENUM_RISK_DOUBLE_HEDGE :
         if(pos_risk_state.ShortPosTotalAt(index)<3) return gap_hedge2_less3;
         if(pos_risk_state.ShortPosTotalAt(index)<5) return gap_hedge2_less5;
         else return gap_hedge2;
         break;
       case ENUM_RISK_DOUBLE_RISK:
         if(pos_risk_state.ShortPosTotalAt(index)<3) return gap_risk2_less3;
         if(pos_risk_state.ShortPosTotalAt(index)<5) return gap_risk2_less5;
         else return gap_risk2;           
         break;
       case ENUM_RISK_SINGLE_HEDGE:
         if(pos_risk_state.ShortPosTotalAt(index)<3) return gap_hedge1_less3;
         if(pos_risk_state.ShortPosTotalAt(index)<5) return gap_hedge1_less5;
         else return gap_hedge1;          
          break;
       case ENUM_RISK_SINGLE_RISK:
         if(pos_risk_state.ShortPosTotalAt(index)<3) return gap_risk1_less3;
         if(pos_risk_state.ShortPosTotalAt(index)<5) return gap_risk1_less5;
         else return gap_risk1;          
          break;
       default:
         if(pos_risk_state.ShortPosTotalAt(index)<3) return gap_risk1_less3;
         if(pos_risk_state.ShortPosTotalAt(index)<5) return gap_risk1_less5;
         else return gap_risk1;    
      }   
  }
//+------------------------------------------------------------------+
