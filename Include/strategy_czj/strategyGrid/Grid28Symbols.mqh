//+------------------------------------------------------------------+
//|                                                Grid28Symbols.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"  
#include "GridBaseOperate.mqh"
#include <Math\Alglib\matrix.mqh>

string CURRENCIES[]={"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGrid28Symbols:public CStrategy
  {
private:
   CMatrixDouble     symbol_lots; // 上三角存储多单手数，下三角存储空单手数
   double            currency_risk[8];   // 存储每个币种的风险(多单手数-空单手数)
   CGridBaseOperate  symbol_strategy[28]; // 单个品种的策略
   int               grid_buy[28];
   int               grid_sell[28];
   bool              close_operate;

protected:
   void              RefreshPositionState();  // 刷新仓位信息
   void              AdjustGrid();
   void              CheckPositionClose();
   void              CheckPositionOpen();

public:
                     CGrid28Symbols(void){};
                    ~CGrid28Symbols(void){};
   void              Init();
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGrid28Symbols::Init(void)
  {
   for(int i=0;i<28;i++)
     {
      symbol_strategy[i].ExpertSymbol(SYMBOLS_28[i]);
      symbol_strategy[i].ExpertMagic(ExpertMagic()+i);
      symbol_strategy[i].Init();
     }
   symbol_lots.Resize(8,8);
   close_operate=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGrid28Symbols::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshPositionState();
      CheckPositionClose();
      if(close_operate) RefreshPositionState();
      //RefreshPositionState();
      AdjustGrid();
      CheckPositionOpen();
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGrid28Symbols::RefreshPositionState(void)
  {
// 刷新子策略的仓位信息
   for(int i=0;i<28;i++) symbol_strategy[i].RefreshPositionState();
// 各个品种对的买卖手数矩阵赋值
   for(int i=0;i<8;i++)
     {
      for(int j=0;j<8;j++)
        {
         if(i>=j) continue;
         if(i<j)
           {
            int index=i*(15-i)/2+MathAbs(j-i)-1;
            symbol_lots[i].Set(j,symbol_strategy[index].pos_state.lots_buy);
            symbol_lots[j].Set(i,symbol_strategy[index].pos_state.lots_sell);
           }
        }
     }
// 计算每种货币的多空风险(多头手数-空头手数)
   for(int i=0;i<8;i++)
     {
      currency_risk[i]=0;
      for(int j=0;j<8;j++)
        {
         if(i==j) continue;
         currency_risk[i]+=symbol_lots[i][j];
         currency_risk[i]-=symbol_lots[j][i];
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGrid28Symbols::AdjustGrid(void)
  {
   for(int i=0;i<7;i++)
     {
      for(int j=i+1;j<8;j++)
        {
         int index=i*(15-i)/2+MathAbs(j-i)-1;
         if(currency_risk[i]<-0.2)
           {
            if(currency_risk[j]<-0.2) // x空头风险,y空头风险 x-y无风险
              {
               grid_buy[index]=300;
               grid_sell[index]=300;
              }
            else if(currency_risk[j]>0.2) // x空头风险,y多头风险 x-y空头大风险
              {
               grid_buy[index]=100;
               grid_sell[index]=300;
              }
            else   // x空头风险,y无风险 x-y空头风险
              {
               grid_buy[index]=100;
               grid_sell[index]=300;
              }
           }
         else if(currency_risk[i]>0.2)
           {
            if(currency_risk[j]<-0.2) // x多头风险,y空头风险 x-y多头大风险
              {
               grid_buy[index]=300;
               grid_sell[index]=100;
              }
            else if(currency_risk[j]>0.2) // x多头风险,y多头风险 x-y无风险
              {
               grid_buy[index]=300;
               grid_sell[index]=300;
              }
            else   // x多头风险,y无风险 x-y多头风险
              {
               grid_buy[index]=300;
               grid_sell[index]=100;
              }
           }
         else
           {
            if(currency_risk[j]<-0.2) // x无风险,y空头风险 x-y多头风险
              {
               grid_buy[index]=300;
               grid_sell[index]=100;
              }
            else if(currency_risk[j]>0.2) // x无风险,y多头风险 x-y空头风险
              {
               grid_buy[index]=100;
               grid_sell[index]=300;
              }
            else   // x无风险,y无风险 x-y多头风险
              {
               grid_buy[index]=300;
               grid_sell[index]=300;
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGrid28Symbols::CheckPositionClose(void)
  {
   close_operate=false;
   for(int i=0;i<28;i++)
     {
      CGridBaseOperate *s_grid=&symbol_strategy[i];
      if(s_grid.pos_state.num_buy>0)
        {
         bool buy_win_little=s_grid.pos_state.profits_buy/s_grid.pos_state.lots_buy>100||s_grid.pos_state.profits_buy>50;
         bool buy_win_much=s_grid.pos_state.profits_buy/s_grid.pos_state.lots_buy>150||s_grid.pos_state.profits_buy>500;
         if(s_grid.pos_state.num_buy>=s_grid.pos_state.num_sell+5 && buy_win_little)
            {
             s_grid.CloseLongPosition();
             close_operate=true;
            }
         if(s_grid.pos_state.num_buy<s_grid.pos_state.num_sell+5 && buy_win_much)
            {
             s_grid.CloseLongPosition();
             close_operate=true;
            }
        }
      if(s_grid.pos_state.num_sell>0)
        {
         bool sell_win_little=s_grid.pos_state.profits_sell/s_grid.pos_state.lots_sell>100||s_grid.pos_state.profits_sell>50;
         bool sell_win_much=s_grid.pos_state.profits_sell/s_grid.pos_state.lots_sell>150||s_grid.pos_state.profits_sell>500;
         if(sell_win_little && s_grid.pos_state.num_sell>=s_grid.pos_state.num_buy+5)
            {
             s_grid.CloseShortPosition();
             close_operate=true;
            }
         else if(s_grid.pos_state.num_sell<s_grid.pos_state.num_buy-5 && sell_win_much)
            {
             s_grid.CloseShortPosition();
             close_operate=true;
            }
        }
      
      //bool close_long0=s_grid.pos_state.num_buy>0 && ;
      //bool close_long1=s_grid.pos_state.num_buy>s_grid.pos_state.num_sell && (s_grid.pos_state.profits_buy/s_grid.pos_state.lots_buy>100||s_grid.pos_state.profits_buy>50);
      //bool close_long2=s_grid.pos_state.num_buy>0 && s_grid.pos_state.num_buy<s_grid.pos_state.num_sell && (s_grid.pos_state.profits_buy/s_grid.pos_state.lots_buy>100||s_grid.pos_state.profits_buy>50);
      //if(close_long0)
      //  {
      //   Print(s_grid.ExpertSymbol(),"进行多头网格策略平仓");
      //   s_grid.CloseLongPosition();
      //   close_operate=true;
      //  }
      //bool close_short0=s_grid.pos_state.num_sell>0 && (s_grid.pos_state.profits_sell/s_grid.pos_state.lots_sell>100||s_grid.pos_state.profits_sell>50);
      //bool close_short1=s_grid.pos_state.num_sell>s_grid.pos_state.num_buy && (s_grid.pos_state.profits_sell/s_grid.pos_state.lots_sell>100||s_grid.pos_state.profits_sell>50);
      //bool close_short2=s_grid.pos_state.num_sell>0 && s_grid.pos_state.num_sell<s_grid.pos_state.num_buy && (s_grid.pos_state.profits_sell/s_grid.pos_state.lots_sell>100||s_grid.pos_state.profits_sell>50);
      //if(close_short0)
      //  {
      //   Print(s_grid.ExpertSymbol(),"进行空头网格策略平仓");
      //   s_grid.CloseShortPosition();
      //   close_operate=true;
      //  }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGrid28Symbols::CheckPositionOpen(void)
  {
   for(int i=0;i<28;i++)
     {
      CGridBaseOperate *s=&symbol_strategy[i];
      if(s.pos_state.num_buy==0) s.BuildLongPositionDefault();
      if(s.pos_state.num_sell==0) s.BuildShortPositionDefault();
      if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>grid_buy[i]) s.BuildLongPositionDefault();
      if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>grid_sell[i]) s.BuildShortPositionDefault();
      //if(s.pos_state.num_buy==0) s.BuildLongPositionWithTP(500);
      //if(s.pos_state.num_sell==0) s.BuildShortPositionWithTP(500);
      //if(s.pos_state.num_buy>0 && s.DistanceAtLastBuyPrice()>grid_buy[i]) s.BuildLongPositionWithTP(500);
      //if(s.pos_state.num_sell>0 && s.DistanceAtLastSellPrice()>grid_sell[i]) s.BuildShortPositionWithTP(500);
     }
  }
//+------------------------------------------------------------------+
