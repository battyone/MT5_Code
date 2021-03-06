//+------------------------------------------------------------------+
//|                                           BaseFilterStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "BaseStrategy.mqh"
#include "ComplicateFilter.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBaseFilterStrategy:public CBaseStrategy
  {
public:
   CComplicateFilter filter;
public:
                     CBaseFilterStrategy(void){};
                    ~CBaseFilterStrategy(void){};
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      PatternCalOnTick(){};  // tick事件上的模式计算
   virtual void      PatternCalOnBar(){};   // bar事件上的模式计算
   virtual void      CheckLongPositionOpenOnTick(){};
   virtual void      CheckShortPositionOpenOnTick(){};
   virtual void      CheckLongPositionOpenOnBar(){};
   virtual void      CheckShortPositionOpenOnBar(){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseFilterStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_tick); // 刷新品种的tick报价
      PatternCalOnTick();
      filter.RefreshTickClassifyState();  // 对模式过滤器中的tick触发的分类器进行类别更新
      SetOrderComment(filter.CurrentIndexArrToStr());
      switch(filter.GenerateMappingRelation())
        {
         case MAPPING_LONG_OPERATE : // 只允许做多
            CheckLongPositionOpenOnTick();
            break;
         case MAPPING_SHORT_OPERATE: // 只允许做空
            CheckShortPositionOpenOnTick();
            break;
         case MAPPING_NO_OPERATE:   // 禁止操作
            break;
         case MAPPING_NULL:   // 不进行指定操作，过滤器失效
            CheckLongPositionOpenOnTick();
            CheckShortPositionOpenOnTick();
            break;
         default:
            break;
        }
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      PatternCalOnBar();
      filter.RefreshBarClassifyState(); // 对模式过滤器中的bar触发的分类器进行类别更新
      SetOrderComment(filter.CurrentIndexArrToStr());
      switch(filter.GenerateMappingRelation())
        {
         case MAPPING_LONG_OPERATE : // 只允许做多
            CheckLongPositionOpenOnBar();
            break;
         case MAPPING_SHORT_OPERATE: // 只允许做空
            CheckShortPositionOpenOnBar();
            break;
         case MAPPING_NO_OPERATE:   // 禁止操作
            break;
         case MAPPING_NULL:   // 不进行指定操作，过滤器失效
            CheckLongPositionOpenOnBar();
            CheckShortPositionOpenOnBar();
            break;
         default:
            break;
        }      
     }
  }
//+------------------------------------------------------------------+
