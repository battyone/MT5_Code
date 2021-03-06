//+------------------------------------------------------------------+
//|                                           PositionOpenLogic2.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "ComplicatedControlStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CComplicatedControl::CheckBestSymbolOpen(void)
  {
   RefreshRiskInfor();
   if(pos_risk_state.GetSymbolOpenNum()==0) // 初始化仓位
     {
      NormGridOpenLongAt(0);
      NormGridOpenLongAt(13);
      NormGridOpenLongAt(22);
      NormGridOpenLongAt(27);
      NormGridOpenShortAt(0);
      NormGridOpenShortAt(13);
      NormGridOpenShortAt(22);
      NormGridOpenShortAt(27);
     }
   else
     {
      //for(int i=0;i<28;i++)
      //  {
      //   if(pos_risk_state.IsSymbolOpen(i))
      //     {
      //      NormGridOpenLongAt(i);
      //      NormGridOpenShortAt(i);
      //     }
      //  }
      //CheckHedgeGridPositionOpen();
      //CheckRebuildSymbolOpen();
      
      if(pos_risk_state.GetCurrencyDeltaRiskMax()<0.2)
        {
         for(int i=0;i<28;i++)
           {
            if(pos_risk_state.IsSymbolOpen(i))
              {
               NormGridOpenLongAt(i);
               NormGridOpenShortAt(i);
              }
           }
        }
      else
        {
         CheckHedgeGridPositionOpen();
         CheckRebuildSymbolOpen();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CComplicatedControl::OpenHedgeSymbol(int c_long,int c_short)
  {
   if(c_long==c_short) return false;
   int index;
   if(c_long<c_short)
     {
      index=c_long*(15-c_long)/2+c_short-c_long-1;
      return HedgeGridOpenLongAt(index);
     }
   else if(c_long>c_short)
     {
      index=c_short*(15-c_short)/2+c_long-c_short-1;
      return HedgeGridOpenShortAt(index);
     }
   return false;
  }
//+------------------------------------------------------------------+
//|         对冲网格开仓                                   |
//+------------------------------------------------------------------+
CComplicatedControl::CheckHedgeGridPositionOpen(void)
  {
   int i_left=0;
   int i_right=7;
   while(i_left<i_right)
     {
      if(MathAbs(pos_risk_state.GetIndexCurrencyRiskSortAt(i_left)>MathAbs(pos_risk_state.GetIndexCurrencyRiskSortAt(i_left))))
        {
         for(int i_move=i_right;i_move>i_left;i_move--)
           {
            OpenHedgeSymbol(pos_risk_state.GetIndexCurrencyRiskSortAt(i_left),pos_risk_state.GetIndexCurrencyRiskSortAt(i_move));
           }
         i_left++;
        }
      else
        {
         for(int i_move=i_left;i_move<i_right;i_move++)
           {
            OpenHedgeSymbol(pos_risk_state.GetIndexCurrencyRiskSortAt(i_move),pos_risk_state.GetIndexCurrencyRiskSortAt(i_right));
           }
         i_right--;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckRebuildSymbolOpen(void)
  {
   for(int i=0;i<28;i++)
     {
      switch(pos_risk_state.GetRiskTypeSTC(i))
        {
         case ENUM_RISKSTC_DOUBLE_RISK :
            RebuildSymbolPosition(i);
            break;
         default:
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::RebuildSymbolPosition(int index)
  {
   //if(pos_risk_state.GetSymbolDeltaRiskAt(index)>0 && pos_risk_state.GetSymbolShortProfitsAt(index)>0 && DistanceLatestPriceToLastSellPrice(index)<-300)
   //  {
   //   CloseShortPositionAt(index,"CloseForOpen");
   //   OpenFirstShortPositionSymbolAt(index,5);
   //   return;
   //  }
   //if(pos_risk_state.GetSymbolDeltaRiskAt(index)<0 && pos_risk_state.GetSymbolLongProfitsAt(index)>0 && DistanceLatestPriceToLastBuyPrice(index)<-300)
   //  {
   //   CloseLongPositionAt(index,"CloseForOpen");
   //   OpenFirstLongPositionSymbolAt(index,5);
   //  }
     if(pos_risk_state.GetSymbolDeltaRiskAt(index)>0 && pos_risk_state.GetSymbolAllShortFirstLongProfitsAt(index)>100)
       {
        
       }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::OpenFirstLongPositionSymbolAt(int index,int level)
  {
   double l=0.01*level;
   Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,"CLF-NEW");
   long_pos_id[index].Add(Trade.ResultOrder());
   long_pos_level[index].Add(level);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::OpenFirstShortPositionSymbolAt(int index,int level)
  {
   double l=0.01*level;
   Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"CLF-NEW");
   short_pos_id[index].Add(Trade.ResultOrder());
   short_pos_level[index].Add(level);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckSignalGridPositionOpen(void)
  {
//for(int i=0;i<28;i++)
//  {
//   if(sym_risk[i][0]>sym_risk[i][1]+0.1)
//     {
//      SignalGridOpenLongAt(i);
//     }
//   if(sym_risk[i][1]>sym_risk[i][0]+0.1)
//     {
//      SignalGridOpenShortAt(i);
//     }
//  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CComplicatedControl::NormGridOpenLongAt(int index,double grid_gap=150)
  {
   if(long_pos_id[index].Total()==0)
     {
      double l=0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,"Open-Norm");
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(1);
      return true;
     }
   else if(DistanceLatestPriceToLastBuyPrice(index)>grid_gap)
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,"Open-Norm");
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1)+1);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CComplicatedControl::NormGridOpenShortAt(int index,double grid_gap=150)
  {
   if(short_pos_id[index].Total()==0)
     {
      double l=0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Open-Norm");
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(1);
      return true;
     }
   else if(DistanceLatestPriceToLastSellPrice(index)>grid_gap)
     {
      double l=(short_pos_level[index].At(short_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Open-Norm");
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(short_pos_level[index].At(short_pos_level[index].Total()-1)+1);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CComplicatedControl::HedgeGridOpenLongAt(int index)
  {
   if(long_pos_id[index].Total()==0)
     {
      //int begin_level=MathMax(short_pos_level[index].At(short_pos_level[index].Total()-1)-4,1);
      int begin_level=1;
      double l=0.01*begin_level;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,"Open-Hedge");
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(begin_level);
      return true;
     }
   else if(DistanceLatestPriceToLastBuyPrice(index)>150)
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,"Open-Hedge");
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1)+1);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CComplicatedControl::HedgeGridOpenShortAt(int index)
  {
   if(short_pos_id[index].Total()==0)
     {
      //int begin_level=MathMax(long_pos_level[index].At(long_pos_level[index].Total()-1)-4,1);
      int begin_level=1;

      double l=0.01*begin_level;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Open-Hedge");
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(begin_level);
      return true;
     }
   else if(DistanceLatestPriceToLastSellPrice(index)>150)
     {
      double l=(short_pos_level[index].At(short_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Open-Hedge");
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(short_pos_level[index].At(short_pos_level[index].Total()-1)+1);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::SignalGridOpenLongAt(int index)
  {
   if(DistanceLatestPriceToLastBuyPrice(index)>300 && value_rsi[index].ind_value[1]<30)
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1)+1)*0.01*2;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,"Open-Signal");
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1)+1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::SignalGridOpenShortAt(int index)
  {
   if(DistanceLatestPriceToLastSellPrice(index)>300 && value_rsi[index].ind_value[1]>70)
     {
      double l=(short_pos_level[index].At(short_pos_level[index].Total()-1)+1)*0.01*2;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Open-Signal");
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(short_pos_level[index].At(short_pos_level[index].Total()-1)+1);
     }
  }
//+------------------------------------------------------------------+
