//+------------------------------------------------------------------+
//|                             DynamicGridShockStrategyGradeOut.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "动态网格分级出场"
#property description "动态--开首仓时根据过去的支撑阻力进行网格大小的设计"
#property description "分级出场--每次检测最后和最早的仓位组合是否满足止盈出场条件"

#include "GridShockStrategyGradeOut.mqh"
#include  <Arrays\ArrayDouble.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDynamicGridShockStrategyGradeOut:public CGridShockStrategyGradeOut
  {
private:
   int               grid_num_buy;
   int               grid_num_sell;
   int               handle_zz;
   double            zz_value[];
   CArrayDouble      extreme_value;
protected:
   double            lots_seq_buy[];   // 手数序列
   double            price_seq_buy[]; // 网格序列
   double            lots_seq_sell[];   // 手数序列
   double            price_seq_sell[]; // 网格序列
protected:
   void              SetBuySeq();   // 设置多单的网格位置
   void              SetSellSeq();  // 设置空单的网格位置
   void              GetZZ();
public:
                     CDynamicGridShockStrategyGradeOut(void);
                    ~CDynamicGridShockStrategyGradeOut(void){};
   virtual void      CheckPositionOpen();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDynamicGridShockStrategyGradeOut::CDynamicGridShockStrategyGradeOut(void)
  {
   handle_zz=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag");
   grid_num_buy=50;
   ArrayResize(lots_seq_buy,grid_num_buy);
   ArrayResize(price_seq_buy,grid_num_buy);
   grid_num_sell=50;
   ArrayResize(lots_seq_sell,grid_num_sell);
   ArrayResize(price_seq_sell,grid_num_sell);
   extreme_value.Sort();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDynamicGridShockStrategyGradeOut::CheckPositionOpen(void)
  {
   if(pos_state.num_buy==0)
     {
      SetBuySeq();
      BuildLongPosition(lots_seq_buy[0]);
     }
   else
     {
      if(latest_price.ask<price_seq_buy[pos_state.num_buy])
        {
         BuildLongPosition(lots_seq_buy[long_pos_level.At(long_pos_level.Total()-1)]);
        }
     }

   if(pos_state.num_sell==0)
     {
      SetSellSeq();
      BuildShortPosition(lots_seq_sell[0]);
     }
   else
     {
      if(latest_price.bid>price_seq_sell[pos_state.num_sell])
        {
         BuildShortPosition(lots_seq_sell[short_pos_level.At(short_pos_level.Total()-1)]);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDynamicGridShockStrategyGradeOut::SetBuySeq(void)
  {
   GetZZ();
   int index=extreme_value.SearchLess(latest_price.ask);
   for(int i=0;i<grid_num_buy;i++)
     {
      lots_seq_buy[i]=CalLotsDefault(i+1);
      if(index==-1)
         {
          price_seq_buy[i]=latest_price.bid-i*300*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         }
      else if(index>0)
             {
               price_seq_buy[i]=extreme_value.At(index);
               index--;
             }
      else
        {
         price_seq_buy[i]=price_seq_buy[i-1]-300*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
        }
      
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDynamicGridShockStrategyGradeOut::SetSellSeq(void)
  {
   GetZZ();
   int index=extreme_value.SearchGreat(latest_price.bid);
   for(int i=0;i<grid_num_sell;i++)
     {
      lots_seq_sell[i]=CalLotsDefault(i+1);
      if(index==-1)
        {
         price_seq_sell[i]=latest_price.ask+i*1000*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
        }
      else if(index<extreme_value.Total())
             {
               price_seq_sell[i]=extreme_value.At(index);
               index++;
             }
      else
         {
          price_seq_sell[i]=price_seq_sell[i-1]+1000*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
         }      
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDynamicGridShockStrategyGradeOut::GetZZ(void)
  {
   extreme_value.Clear();
   ArrayResize(zz_value,4800);

   CopyBuffer(handle_zz,0,0,4800,zz_value);
   for(int i=ArraySize(zz_value)-2;i>=0;i--)
     {
      if(zz_value[i]==0) continue;//过滤为0的值
      extreme_value.InsertSort(zz_value[i]);
     }
   int counter=0;
   while(counter!=extreme_value.Total()-2)
     {
      if(extreme_value.At(counter+1)-extreme_value.At(counter)<150*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
        {
         extreme_value.Delete(counter+1);
        }
      else
        {
         counter++;
        }
     }
  }
//+------------------------------------------------------------------+
