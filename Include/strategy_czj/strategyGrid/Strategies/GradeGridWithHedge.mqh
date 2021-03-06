//+------------------------------------------------------------------+
//|                                           GradeGridWithHedge.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "分级出场的网格策略搭配对冲策略"
#include <strategy_czj\strategyGrid\Strategies\GridShockStrategyGradeOut.mqh>
#include <strategy_czj\strategyGrid\HedgeFrame\HedgeOperateByRSI.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGradeGridWithHedge:public CStrategy
  {
public:
   CGridShockStrategyGradeOut ggrid_operate;
   CHedgeOperateByRSI rsi_operate;
public:
                     CGradeGridWithHedge(void){};
                    ~CGradeGridWithHedge(void){};
   void              Init();
protected:
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGradeGridWithHedge::Init(void)
  {
   ggrid_operate.ExpertSymbol(ExpertSymbol());
   ggrid_operate.ExpertMagic(ExpertMagic()+1);
   rsi_operate.ExpertSymbol(ExpertSymbol());
   rsi_operate.ExpertMagic(ExpertMagic()+2);
   AddBarOpenEvent(ExpertSymbol(),PERIOD_M5);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGradeGridWithHedge::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      ggrid_operate.RefreshTickPrice();
      ggrid_operate.RefreshPositionState();
      ggrid_operate.CheckPositionClose();
      ggrid_operate.CheckPositionOpen();
      
      rsi_operate.RefreshPositionState();
      if(rsi_operate.pos_state.GetProfitsLongPerLots()>500&&ggrid_operate.pos_state.GetLotsBuyToSell()>-0.1) rsi_operate.CloseLongPosition();
      if(rsi_operate.pos_state.GetProfitsShortPerLots()>500&&ggrid_operate.pos_state.GetLotsBuyToSell()<0.1) rsi_operate.CloseShortPosition();
      
     }
    if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN && event.period==PERIOD_M5)
      {
       ggrid_operate.RefreshPositionState();
       rsi_operate.RefreshIndValues();
       if(ggrid_operate.pos_state.GetLotsBuyToSell()>0.1)
        {
         if(rsi_operate.IsDownSignal()&&rsi_operate.pos_state.GetLotsBuyToSell()+ggrid_operate.pos_state.GetLotsBuyToSell()>0.05)
           {
            rsi_operate.BuildShortPositionToHedgeLongRisk(0.01);
           }
        }
      else if(ggrid_operate.pos_state.GetLotsBuyToSell()<-0.1)
        {
         if(rsi_operate.IsUpSignal()&&rsi_operate.pos_state.GetLotsBuyToSell()+ggrid_operate.pos_state.GetLotsBuyToSell()<-0.05)
           {
            rsi_operate.BuildLongPositionToHedgeShortRisk(0.01);
           }
        }
      }
  }
//+------------------------------------------------------------------+
