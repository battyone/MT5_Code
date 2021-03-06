//+------------------------------------------------------------------+
//|                                        strategyBasedOnZigZag.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>

class CStrategyBasedOnZigZag:public CStrategy
  {
protected:
   int num_zz; // ZIGZAG 非零值的个数
   double  zz_value[]; // ZIGZAG 值
   int     zz_index[];  // zigzag非零值对应的水平index
   double  dist_v[]; // zigzag高度差
   double  dist_h[]; // zigzag水平差
   int handle_zz;  // zigzag句柄
   
   PositionInfor  pos_state;  // 持仓状态
   
public:
                     CStrategyBasedOnZigZag(void);
                    ~CStrategyBasedOnZigZag(void){};
                    void SetZigZagBaseParameter(int zz_depth=12);
protected:
   void              GetZigZagValues();  // 取zigzag的非0值
   void              RefreshPositionState(); // 刷新仓位信息
private:
   void              CalVH(); // 计算hist-v, hist-h
  };
CStrategyBasedOnZigZag::CStrategyBasedOnZigZag(void)
   {
    num_zz=5;
    ArrayResize(zz_value,num_zz);
    ArrayResize(zz_index,num_zz);
    ArrayResize(dist_v,num_zz-1);
    ArrayResize(dist_h,num_zz-1);
    SetZigZagBaseParameter();
   }
void CStrategyBasedOnZigZag::SetZigZagBaseParameter(int zz_depth=12)
   {
    handle_zz=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag",zz_depth,5,3);
   }
CStrategyBasedOnZigZag::GetZigZagValues(void)
   {
    //复制zigzag指标数值--并取得极值点
   double zigzag_value[];
   ArrayResize(zigzag_value,num_zz*50);
   int counter=0;
   CopyBuffer(handle_zz,0,0,num_zz*50,zigzag_value);
   for(int i=ArraySize(zigzag_value)-2;i>=0;i--)
     {
      if(zigzag_value[i]==0) continue;//过滤为0的值
      if(counter==num_zz) break;//极值数量达到给定的值不再取值
      counter++;
      zz_value[counter-1]=zigzag_value[i];
      zz_index[counter-1]=i;
      CalVH();
     }
   }
CStrategyBasedOnZigZag::CalVH(void)
   {
    for(int i=0;i<num_zz-1;i++)
      {
       dist_v[i]=MathAbs(zz_value[i]-zz_value[i+1]);
       dist_h[i]=MathAbs(zz_index[i]-zz_index[i+1]);
      }
   }
void CStrategyBasedOnZigZag::RefreshPositionState(void)
   {
    pos_state.Init();
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=ExpertMagic()) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) pos_state.num_buy++;
      else pos_state.num_sell++;
     }
   }