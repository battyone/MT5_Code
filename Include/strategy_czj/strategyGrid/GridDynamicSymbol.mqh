//+------------------------------------------------------------------+
//|                                            GridDynamicSymbol.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ChooseSymbolType
  {
   ENUM_CHOOSE_SYMBOL_FIX,    // 选择固定的品种
   ENUM_CHOOSE_SYMBOL_RAND,   // 随机选择品种
   ENUM_CHOOSE_SYMBOL_ALG  // 算法选择品种
  };
enum GridOutType
  {
   ENUM_GRID_OUT_TIMEER,   // 时间原因出场
   ENUM_GRID_OUT_SUM_PROFITS, // 总获利原因出场
   ENUM_GRID_OUT_CURRENT_LOSS // 单次损失原因出场
  };
struct CloseSymbols7
  {
   double close[];
  };
string SYMBOLS_7[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridDynamicSymbols:public CStrategy
  {
private:
   ChooseSymbolType  symbol_choose_type;
   CGridBaseOperate  grid_operator[28];
   int               current_grid_index;
   CloseSymbols7     s_close[8];
   double            pattern_value[28];
   
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              RefreshState();  // 刷新仓位信息
   void              GridDestroyOperate();   // 进行网格消网操作
   void              GridBuildOperate(); // 进行网格建仓操作  
   void              SymbolGridSelect();  // 选择进行网格操作的品种
   int               SymbolSelectByAlg(); // 根据算法选择最适合网格操作的品种
   double            CalLots(int num,int num_total,double base_lots); // 计算手数
   void              GetPatternOnBar();
public:
                     CGridDynamicSymbols(void);
                    ~CGridDynamicSymbols(void){};
  };
CGridDynamicSymbols::CGridDynamicSymbols(void)
   {
      MathSrand(GetTickCount());
      symbol_choose_type=ENUM_CHOOSE_SYMBOL_ALG;
      for(int i=0;i<28;i++)
        {
         grid_operator[i].ExpertMagic(ExpertMagic()+i);
         grid_operator[i].ExpertSymbol(SYMBOLS_28[i]);
         pattern_value[i]=0;
        }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridDynamicSymbols::RefreshState(void)
  {
   for(int i=0;i<28;i++)
     {
      grid_operator[i].RefreshTickPrice();  // 刷新tick报价
      grid_operator[i].RefreshPositionState(); // 刷新仓位信息
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridDynamicSymbols::SymbolGridSelect(void)
  {
   switch(symbol_choose_type)
     {
      case ENUM_CHOOSE_SYMBOL_RAND :
         current_grid_index=MathRand()%28;
         Print("$$$$$:", current_grid_index);
         break;
      case ENUM_CHOOSE_SYMBOL_ALG:
         current_grid_index=SymbolSelectByAlg();
         break;
      case ENUM_CHOOSE_SYMBOL_FIX:
         current_grid_index=0;
         break;
      default:
         current_grid_index=0;
         break;
     }
  }
int CGridDynamicSymbols::SymbolSelectByAlg(void)
   {
    int min_index=ArrayMinimum(pattern_value);
    if(pattern_value[min_index]<-1) return min_index;
    else return -1;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridDynamicSymbols::CalLots(int num,int num_total,double base_lots)
  {
   double beta=MathLog(100)/(num_total-1);
   double alpha=1/MathExp(beta);
   return NormalizeDouble(base_lots*alpha*exp(beta*num),2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridDynamicSymbols::GridBuildOperate(void)
  {
   if(current_grid_index==-1) return;
   if(grid_operator[current_grid_index].IsEmptyPosition())
     {
      SymbolGridSelect();
      if(current_grid_index==-1) return;
      RefreshState();
      grid_operator[current_grid_index].BuildShortPositionWithCostTP(200,0.01);
      grid_operator[current_grid_index].BuildLongPositionWithCostTP(200,0.01);
     }
   else
     {
      if(grid_operator[current_grid_index].pos_state.num_buy==0)
        {
         grid_operator[current_grid_index].BuildLongPositionWithCostTP(200,0.01);
        }
      else if(grid_operator[current_grid_index].DistanceAtLastBuyPrice()>250)
        {
         double c_lots=CalLots(grid_operator[current_grid_index].pos_state.num_buy+1,15,0.01);
         grid_operator[current_grid_index].BuildLongPositionWithCostTP(100,c_lots);
        }
      if(grid_operator[current_grid_index].pos_state.num_sell==0)
        {
         grid_operator[current_grid_index].BuildShortPositionWithCostTP(200,0.01);
        }
      else if(grid_operator[current_grid_index].DistanceAtLastSellPrice()>250)
        {
         double c_lots=CalLots(grid_operator[current_grid_index].pos_state.num_sell+1,15,0.01);
         grid_operator[current_grid_index].BuildShortPositionWithCostTP(100,c_lots);
        }
     }
  }
void CGridDynamicSymbols::GridDestroyOperate(void)
   {
    if(!grid_operator[current_grid_index].IsEmptyPosition()&&grid_operator[current_grid_index].pos_state.profits_buy+grid_operator[current_grid_index].pos_state.profits_sell<-100)
      {
       grid_operator[current_grid_index].CloseLongPosition();
       grid_operator[current_grid_index].CloseShortPosition();
      }
   }
void CGridDynamicSymbols::GetPatternOnBar(void)
   {
    for(int i=0;i<7;i++)
      {
       if(i<4) CopyClose(SYMBOLS_7[i],PERIOD_H1,1,2,s_close[i].close);
       else CopyClose(SYMBOLS_7[i],PERIOD_H1,1,2,s_close[i+1].close);       
      }
    for(int i=0;i<6;i++)
      {
       if(i==4) continue;
       for(int j=i+1;j<7;j++)
         {
          if(j==4) continue;
          int index=i*(15-i)/2+MathAbs(j-i)-1;
          if(j<4 || i>4)
            {
              if(((s_close[i].close[1]-s_close[i].close[0]))*(s_close[j].close[1]-s_close[j].close[0])<0) pattern_value[index]+=1;
              else pattern_value[index]-=0.1;
            }
          else
            {
             if(((s_close[i].close[1]-s_close[i].close[0]))*(s_close[j].close[1]-s_close[j].close[0])>0) pattern_value[index]+=1;
             else pattern_value[index]-=0.1;
            }
         }
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridDynamicSymbols::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshState();
      GridDestroyOperate();
     }
     
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      RefreshState();
      GridBuildOperate();
     }
  }
//+------------------------------------------------------------------+
