//+------------------------------------------------------------------+
//|                                         PositionCloseLogical.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "平仓逻辑：针对28个品种对的当前仓位状态进行不同的逻辑设计"
#property description "    --case 1:所有品种所有仓位一起满足止盈的平仓方式"
#property description "    --case 2:单一品种多空仓位满足止盈且不增加最大币种风险的平仓方式"
#property description "    --case 3:检测最差品种对的分级出场"
#property description "          1.x为max(lot_buy-lots_sell)币种，y为min(lot_buy-lots_sell)币种,xy LongPosition 分级出场check"
#property description "          2.x为max(lot_buy-lots_sell)币种，y为min(lot_buy-lots_sell)币种,yx ShortPosition 分级出场check"
#property description "          3.x为max(lot_buy)币种，max(lots_sell)币种,xy LongPosition 分级出场check"
#property description "          4.x为max(lot_buy)币种，max(lots_sell)币种,yx ShortPosition 分级出场check"
#property description "          5:对风险最大方向的货币，其他货币同他进行匹配分级出场"
#property description "          6:同5，每次选取最大的风险币种方向，然后遍历其他比他小的币种进行匹配分级出场。。。待开发"
#property description "    --case 4:检测多空货币对的风险风向的分级出场"
#property description "          1.x为(lot_buy-lots_sell)>0.1币种，y为(lot_buy-lots_sell)<-0.1币种,xy LongPosition 分级出场check"
#property description "          1.x为(lot_buy-lots_sell)>0.1币种，y为(lot_buy-lots_sell)<-0.1币种,yx ShortPosition 分级出场check"


#include "ComplicatedControlStrategy.mqh"
//+------------------------------------------------------------------+
//|          case1同时检测所有仓位所有品种是否满足止盈条件                |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckAllPositionClose(void)
  {
   if(pos_risk_state.GetTotalProfits()>500) 
      {
       Print("平仓操作:CASE-1 所有仓位大于500");
       for(int i=0;i<28;i++) ClosePositionOnOneSymbolAt(i,"CloseAll");
      }
  }
//+------------------------------------------------------------------+
//|              case2逐个检测单一品种所有仓位是否满足止盈条件            |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckOneSymbolPositionClose(void)
  {
   for(int i=0;i<28;i++)
     {
      if(pos_risk_state.GetSymbolProfitsAt(i)>100 && pos_risk_state.GetMaxRiskChangeAfterCloseSymbolAt(i)<0) // 该品种对的所有仓位盈利大于固定值,且平仓不增加两个货币的最大风险
        {
         Print("平仓操作:CASE-2 单个品种所有仓位大于100，且不增加仓位风险--",SYMBOLS_28[i]);
         ClosePositionOnOneSymbolAt(i,"CloseOneSymbol");
        }
     }
  }
//+------------------------------------------------------------------+
//|      case3检测风险最大的两个币种对应风险是否满足分级出场止盈条件 |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckWorstSymbolPartialPositionClose(void)
  {
//--- 针对手数差异最大的币种，组成的品种对应风险方向进行分级出场条件判断；
   PartialClosePosition(pos_risk_state.GetIndexCurrencyDeltaMax(),pos_risk_state.GetIndexCurrencyDeltaMin(),200,200,"PartialClose");
//--- 多头手数最多的x, 空头手数最多的y，组成的品种对应的方向做分级出场判断；
   PartialClosePosition(pos_risk_state.GetIndexCurrencyLongMax(),pos_risk_state.GetIndexCurrencyShortMax(),200,200,"PartialClose");
//---
  }
//+------------------------------------------------------------------+
//|       case 4:检测多空货币对的风险方向的分级出场                  |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckRiskSymbolsPartialPositionClose(void)
  {
   CArrayLong arr_long_index;
   CArrayLong arr_short_index;
//    设定货币多空阈值：用于后续确定可以进行品种分级出场的货币
   for(int i=0;i<8;i++)
     {
      if(pos_risk_state.GetCurrencyDeltaRiskAt(i)>0.1) arr_long_index.Add(i);
      if(pos_risk_state.GetCurrencyDeltaRiskAt(i)<-0.1) arr_short_index.Add(i);
     }
//---
   for(int i=0;i<arr_long_index.Total();i++)
     {
      for(int j=0;j<arr_short_index.Total();j++)
        {
         PartialClosePosition(arr_long_index.At(i),arr_short_index.At(j),200,200,"CASE4");
        }
     }
   delete &arr_long_index;
   delete &arr_short_index;
  }
void CComplicatedControl::CheckOneSymbolCombinePositionClose(void)
   {

   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::PartialClosePosition(int index_c_long,int index_c_short,double profits_total_,double profits_per_lots_,string comment="")
  {
   if(index_c_long==index_c_short) return;
   int index;
   if(index_c_long<index_c_short)
     {
      index=index_c_long*(15-index_c_long)/2+index_c_short-index_c_long-1;
      PartialClosePosition(index,profits_total_,profits_per_lots_,POSITION_TYPE_BUY,comment);
     }
   else
     {
      index=index_c_short*(15-index_c_short)/2+index_c_long-index_c_short-1;
      PartialClosePosition(index,profits_total_,profits_per_lots_,POSITION_TYPE_SELL,comment);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::PartialClosePosition(int index,double profits_total_,double profits_per_lots_,ENUM_POSITION_TYPE p_type,string comment="")
  {
   CArrayLong *p_id;
   CArrayLong *p_level;
   string close_flag;
   if(p_type==POSITION_TYPE_BUY)
     {
      p_id=&long_pos_id[index];
      p_level=&long_pos_level[index];
     }
   else
     {
      p_id=&short_pos_id[index];
      p_level=&short_pos_level[index];
     }
   if(p_id.Total()==0) return;
   
//    获取需要进行分级出场的仓位情况的统计信息
   double sum_l=0,sum_p=0,temp_p;
   CArrayLong *arr_index=new CArrayLong();
   for(int i=0;i<p_id.Total();i++)
     {
      PositionSelectByTicket(p_id.At(i));
      temp_p=PositionGetDouble(POSITION_PROFIT);
      if(i==0 || temp_p>0)
        {
         sum_l+=PositionGetDouble(POSITION_VOLUME);
         sum_p+=temp_p;
         arr_index.Add(i);
        }
     }
// 判断是否满足分级出场条件，进行操作
   if(sum_p>profits_total_ || sum_p/sum_l>profits_per_lots_)
     {
      for(int i=0;i<arr_index.Total();i++)
        {
         Trade.PositionClose(p_id.At(arr_index.At(i)),comment);
        }
      for(int i=arr_index.Total()-1;i>=0;i--)
        {
         p_id.Delete(arr_index.At(i));
         p_level.Delete(arr_index.At(i));
        }
     }
   delete arr_index;
   delete p_id;
   delete p_level;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckSmallPositionTP(void)
  {
   for(int i=0;i<28;i++)
     {
      if(DistanceLatestPriceToLastBuyPrice(i)<-150*6 && pos_risk_state.GetSymbolDeltaRiskAt(i)<0 && pos_risk_state.GetSymbolLongProfitsAt(i)>0)
        {
         CloseLongPositionAt(i,"SmallLongPosTP");
        }
      if(DistanceLatestPriceToLastSellPrice(i)<-150*6 && pos_risk_state.GetSymbolDeltaRiskAt(i)>0 && pos_risk_state.GetSymbolShortProfitsAt(i)>0)
        {
         CloseShortPositionAt(i,"SmallShortPosTP");
        }
     }
  }
//+------------------------------------------------------------------+
