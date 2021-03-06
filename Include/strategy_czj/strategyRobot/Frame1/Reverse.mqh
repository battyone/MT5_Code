//+------------------------------------------------------------------+
//|                                                      Reverse.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"

#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\czj_function.mqh>
#include "MaFilter.mqh"
#include "PriceFilter.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CReverseStrategy:public CStrategy
  {
protected:
   int               points_tp;
   int               points_sl;
   int               search_bar;
   int               adj_bar;
   int               sep_time;

   MqlTick           latest_price;
   double            max_price;
   double            min_price;
   double            high_price[];
   double            low_price[];
   int               max_index;
   int               min_index;
   datetime          last_buy_time;
   datetime          last_sell_time;
   double            tp_price;
   double            sl_price;
   string            comment;

   CMaFilter         filter;
   bool              use_ma_filter;

   CPriceFilter      filter_price;
   bool              use_price_filter;

public:
                     CReverseStrategy(void){};
                    ~CReverseStrategy(void){};
   void              Init();  // 初始化操作
   void              SetParameters(int tp_points,int sl_points,int bar_search,int bar_adj,int time_sep); // 设置基本参数
   //--- MaFilter相关操作函数   
   void              SetMaFilterMapping(int &mapping[]) {filter.SetCodeMap(mapping);}; // 设置MaFilter的mapping关系
   void              SetMaFilterMode(bool mode=true) {use_ma_filter=mode;};   // 设置MaFilter是否启用
   void              InitMaFilter();
   //--- PriceFilter相关操作
   void              SetPriceFilterMapping(int &mapping[]) {filter_price.SetCodeMap(mapping);}
   void              SetPriceFilterMode(bool mode=true) {use_price_filter=mode;};
   void              InitPriceFilter();
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              FindMaxMinPrice();
   void              CheckPositionOpen();
   void              LongPositionOpenCheck();
   void              ShortPositionOpenCheck();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseStrategy::Init(void)
  {
//CopyHigh(ExpertSymbol(),Timeframe(),1,search_bar,high_price);
//CopyLow(ExpertSymbol(),Timeframe(),1,search_bar,low_price);
//max_index=ArrayMaximum(high_price);
//min_index=ArrayMinimum(low_price);
//max_price=high_price[max_index];
//min_price=low_price[min_index];
   FindMaxMinPrice();
   use_ma_filter=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseStrategy::InitMaFilter(void)
  {
   filter.SetFilterParameter(ExpertSymbol(),PERIOD_H1,24,200);
   filter.CopyMaValue();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseStrategy::InitPriceFilter(void)
  {
   filter_price.SetFilterParameter(ExpertSymbol(),PERIOD_H1,24,4);
   filter_price.CopyPrice();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseStrategy::SetParameters(int tp_points,int sl_points,int bar_search,int bar_adj,int time_sep)
  {
   points_tp=tp_points;
   points_sl=sl_points;
   search_bar=bar_search;
   adj_bar=bar_adj;
   sep_time=time_sep;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseStrategy::FindMaxMinPrice(void)
  {
   CopyHigh(ExpertSymbol(),Timeframe(),1,search_bar,high_price);
   CopyLow(ExpertSymbol(),Timeframe(),1,search_bar,low_price);
   bool find_max=false,find_min=false;
   max_price=DBL_MAX;
   min_price=DBL_MIN;
   for(int i=search_bar-adj_bar;i>adj_bar;i--)
     {
      if(!find_max && IsMaxLeftRight(high_price,i,adj_bar,adj_bar))
        {
         max_index=i;
         max_price=high_price[max_index];
         find_max=true;
        }
      if(!find_min && IsMinLeftRight(low_price,i,adj_bar,adj_bar))
        {
         min_index=i;
         min_price=low_price[min_index];
         find_min=true;
        }
      if(find_max && find_min) break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionOpen();
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      //CopyHigh(ExpertSymbol(),Timeframe(),1,search_bar,high_price);
      //CopyLow(ExpertSymbol(),Timeframe(),1,search_bar,low_price);
      //max_index=ArrayMaximum(high_price);
      //min_index=ArrayMinimum(low_price);
      //max_price=high_price[max_index];
      //min_price=low_price[min_index];
      FindMaxMinPrice();
      if(use_ma_filter) filter.CopyMaValue();
      if(use_price_filter) filter_price.CopyPrice();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseStrategy::CheckPositionOpen(void)
  {
   //if(max_price-min_price<100*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) return;
//if(latest_price.ask-latest_price.bid>20*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) return;
   //if(max_index==min_index) return;

   LongPositionOpenCheck();
   ShortPositionOpenCheck();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseStrategy::LongPositionOpenCheck(void)
  {
   if(use_ma_filter && filter.MappingCode(latest_price)!=1) return;  // 启用MaFilter的情况下，当前映射关系不成立
   if(use_price_filter && filter_price.MappingCode(latest_price)!=1) return;  // 启用MaFilter的情况下，当前映射关系不成立

   if(positions.open_buy>0&&latest_price.time-last_buy_time<60*60*sep_time) return;
   //if(positions.open_buy>=3) return;
   if(latest_price.ask<min_price)
     {
      tp_price=latest_price.ask+points_tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      sl_price=latest_price.bid-points_sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      comment="MinIndex:"+IntegerToString(min_index)+"MP:"+DoubleToString(min_price,5);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01,latest_price.ask,sl_price,tp_price,comment);
      last_buy_time=latest_price.time;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseStrategy::ShortPositionOpenCheck(void)
  {
   if(use_ma_filter && filter.MappingCode(latest_price)!=2) return; // 启用MaFilter的情况下，当前映射关系不成立
   if(use_price_filter && filter_price.MappingCode(latest_price)!=2) return;  // 启用MaFilter的情况下，当前映射关系不成立
   //if(positions.open_sell>=3) return;
   if(positions.open_sell>0&&latest_price.time-last_sell_time<60*60*sep_time) return;
   if(latest_price.bid>max_price)
     {
      tp_price=latest_price.bid-points_tp*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      sl_price=latest_price.ask+points_sl*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      comment="MaxIndex:"+IntegerToString(max_index)+"MP:"+DoubleToString(max_price,5);
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01,latest_price.bid,sl_price,tp_price,comment);
      last_sell_time=latest_price.time;
     }
  }
//+------------------------------------------------------------------+
