//+------------------------------------------------------------------+
//|                                    LSRotationElasticStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "PositionRotation.mqh"
#include "LSRotationStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLSRotationElasticStrategy:public CLSRotationStrategy
  {
protected:
   int               n_lock;  // 网格开仓上限
   int               n_new;   // 当前网格达到该值，开启轮转网格
   int               gap_small;  // 小网格
   int               gap_big; // 大网格
   double            base_lots;
   double            tp_total;
   double            tp_per_lots;

protected:
   virtual void      CheckPositionClose();   // 平仓检测
   virtual void      CheckPositionOpen(); // 开仓检测
   int               CalGapByLevel(int level);  // 根据等级计算gap
   int               CalFirstLevelByRisk();  // 根据风险计算第一个仓位的大小

public:
                     CLSRotationElasticStrategy(void);
                    ~CLSRotationElasticStrategy(void){};
   void              SetParameters(int new_n=5,int lock_n=20,int gap_l=150,int gap_b=1500,double b_lots=0.01,double tp_t=500,double tp_p=200);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLSRotationElasticStrategy::CLSRotationElasticStrategy(void)
  {
   SetParameters();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationElasticStrategy::SetParameters(int new_n=5,int lock_n=20,int gap_l=150,int gap_b=1500,double b_lots=0.010000,double tp_t=500.000000,double tp_p=200.000000)
  {
   n_new=new_n;
   n_lock=lock_n;
   gap_small=gap_l;
   gap_big=gap_b;
   base_lots=b_lots;
   tp_total=tp_t;
   tp_per_lots=tp_p;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationElasticStrategy::CheckPositionClose(void)
  {
   for(int i=0;i<pr.Total();i++)
     {
      PartialClosePosition(i,tp_total,tp_per_lots);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLSRotationElasticStrategy::CheckPositionOpen(void)
  {
//   对已存在的网格进行加仓判断
   int long_add=0;
   int short_add=0;
   for(int i=pr.Total()-1;i>=0;i--)
     {
      CGridPosition *gp=pr.grid_pos.At(i);
      if(gp.Total()>=n_lock) break; // 网格达到开仓上限停止开仓

      switch(gp.GetPosType())
        {
         case POSITION_TYPE_BUY :
            if(long_add>0&&pr.GetBuyLots()>pr.GetSellLots()) return;
            if((gp.LastPrice()-latest_price.ask)/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>CalGapByLevel(gp.Total()+1))
              {
               AddLongPosition(i,gp.LastLevel()+1,"A"+IntegerToString(gp.LastLevel()+1)+" G"+IntegerToString(CalGapByLevel(gp.Total()+1)));
               long_add++;
              }
            break;
         case POSITION_TYPE_SELL:
            if(short_add>0&&pr.GetBuyLots()<pr.GetSellLots()) return;
            if((latest_price.bid-gp.LastPrice())/SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)>CalGapByLevel(gp.Total()+1))
              {
               AddShortPosition(i,gp.LastLevel()+1,"A"+IntegerToString(gp.LastLevel()+1)+" G"+IntegerToString(CalGapByLevel(gp.Total()+1)));
               short_add++;
              }
            break;
         default:
            break;
        }
     }
//   判断是否需要开启新的轮转网格
   if(pr.Total()==2) return;  // 多空网格均存在不开新的网格
   if(pr.Total()==0) OpenNewLongGridPosition(1,"NewOpen"); // 首次开启多头网格
   else // 判断是否需要开启轮转网格
     {
      CGridPosition *gp=pr.grid_pos.At(pr.Total()-1);
      if(gp.Total()>=n_new)
        {
         switch(gp.GetPosType())
           {
            case POSITION_TYPE_BUY :
               //if(pr.GetBuyLots()>pr.GetSellLots()-0.5) OpenNewShortGridPosition(CalFirstLevelByRisk(),"RotationOpen1");;
               OpenNewShortGridPosition(CalFirstLevelByRisk(),"RotationOpen");;
               break;
            case POSITION_TYPE_SELL:
               //if(pr.GetBuyLots()<pr.GetSellLots()+0.5) OpenNewLongGridPosition(CalFirstLevelByRisk(),"RotationOpen");
               OpenNewLongGridPosition(CalFirstLevelByRisk(),"RotationOpen");
               break;
            default:
               break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CLSRotationElasticStrategy::CalGapByLevel(int level)
  {
   if(level<=n_new) return gap_small;
   return gap_big;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CLSRotationElasticStrategy::CalFirstLevelByRisk(void)
  {
//if(MathAbs(pr.GetBuyLots()-pr.GetSellLots())>1) return 5;
   return 1;
  }
//+------------------------------------------------------------------+
