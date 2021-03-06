//+------------------------------------------------------------------+
//|                                 GridShockBaseOperateGradeOut.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "分级出场震荡网格的基本操作集成"
#property description "每次根据最后的仓位和最初的仓位来判断是否可以止盈出场"
#include "GridShockBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridShockBaseOperateGradeOut:public CGridShockBaseOperate
  {
public:
                     CGridShockBaseOperateGradeOut(void){};
                    ~CGridShockBaseOperateGradeOut(void){};
   //--- 获取仓位等级，手数，仓位号等信息                                        
   double            GetLongPositionLotsAt(int index);   // 获取多头仓位指定索引的手数
   double            GetShortPositionLotsAt(int index);   // 获取空头仓位指定索引的手数
   int               GetLastLongLevel();   // 获取最后一个多头仓位的级别
   int               GetLastShortLevel();   //获取最后一个空头仓位的级别                    
   long               GetLongPositionIdAt(int index){return long_pos_id.At(index);};  // 获取多头指定索引的仓位ID
   long               GetShortPositionIdAt(int index){return short_pos_id.At(index);}; // 获取空头指定索引的仓位ID
   //--- 获取仓位的不同获利情况   
   double            GetPartialLongPositionProfitsPerLots(const int &indexs[]);  // 获取多头部分仓位组合的每手获利结果
   double            GetPartialShortPositionProfitsPerLots(const int &indexs[]);  // 获取空头部分仓位组合的每手获利结果
   double            GetPartialLongPositionProfits(const int &indexs[]);  // 获取多头部分仓位组合的获利结果
   double            GetPartialShortPositionProfits(const int &indexs[]);  // 获取空头部分仓位组合的获利结果 
   double            GetTotalPositionProfitsPerLots(){return pos_state.GetProfitsPerLots();};   // 获取所有仓位的每手盈利情况
   double            GetAllLongPositionProfitsPerLots(){return pos_state.GetProfitsLongPerLots();}; // 获取多头所有仓位的每手盈利的结果
   double            GetAllShortPositionProfitsPerLots(){return pos_state.GetProfitsShortPerLots();}; // 获取空头所有仓位的每手盈利的结果
   //--- 建仓和平仓操作   
   void              ClosePartialLongPosition(const int &indexs[]);       // 平掉部分多头仓位
   void              ClosePartialShortPosition(const int &indexs[]);       // 平掉部分空头仓位
   void              BuildLongPosition(double bl=0);  // 多头建仓
   void              BuildShortPosition(double bl=0); // 空头建仓
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockBaseOperateGradeOut::ClosePartialLongPosition(const int &indexs[])
  {
   for(int i=0;i<ArraySize(indexs);i++)
     {
      Trade.PositionClose(long_pos_id.At(indexs[i]),close_flag);
     }
   for(int i=ArraySize(indexs)-1;i>=0;i--)
     {
      long_pos_id.Delete(indexs[i]);
      long_pos_level.Delete(indexs[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockBaseOperateGradeOut::ClosePartialShortPosition(const int &indexs[])
  {
   for(int i=0;i<ArraySize(indexs);i++)
     {
      Trade.PositionClose(short_pos_id.At(indexs[i]),close_flag);
     }
   for(int i=ArraySize(indexs)-1;i>=0;i--)
     {
      short_pos_id.Delete(indexs[i]);
      short_pos_level.Delete(indexs[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridShockBaseOperateGradeOut::GetPartialLongPositionProfitsPerLots(const int &indexs[])
  {
   double sum_lots=0,sum_profits=0;
   for(int i=0;i<ArraySize(indexs);i++)
     {
      PositionSelectByTicket(long_pos_id.At(indexs[i]));
      sum_lots+=PositionGetDouble(POSITION_VOLUME);
      sum_profits+=PositionGetDouble(POSITION_PROFIT);
     }
   if(sum_lots>0) return sum_profits/sum_lots;
   else return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridShockBaseOperateGradeOut::GetPartialShortPositionProfitsPerLots(const int &indexs[])
  {
   double sum_lots=0,sum_profits=0;
   for(int i=0;i<ArraySize(indexs);i++)
     {
      PositionSelectByTicket(short_pos_id.At(indexs[i]));
      sum_lots+=PositionGetDouble(POSITION_VOLUME);
      sum_profits+=PositionGetDouble(POSITION_PROFIT);
     }
   if(sum_lots>0) return sum_profits/sum_lots;
   else return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridShockBaseOperateGradeOut::GetPartialLongPositionProfits(const int &indexs[])
  {
   double sum_lots=0,sum_profits=0;
   for(int i=0;i<ArraySize(indexs);i++)
     {
      PositionSelectByTicket(long_pos_id.At(indexs[i]));
      sum_lots+=PositionGetDouble(POSITION_VOLUME);
      sum_profits+=PositionGetDouble(POSITION_PROFIT);
     }
   if(sum_lots>0) return sum_profits;
   else return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridShockBaseOperateGradeOut::GetPartialShortPositionProfits(const int &indexs[])
  {
   double sum_lots=0,sum_profits=0;
   for(int i=0;i<ArraySize(indexs);i++)
     {
      PositionSelectByTicket(short_pos_id.At(indexs[i]));
      sum_lots+=PositionGetDouble(POSITION_VOLUME);
      sum_profits+=PositionGetDouble(POSITION_PROFIT);
     }
   if(sum_lots>0) return sum_profits;
   else return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockBaseOperateGradeOut::BuildLongPosition(double bl=0)
  {
   double l=bl==0?CalLotsDefault(GetLastLongLevel()+1,base_lots_buy):bl;
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l,latest_price.ask,0,0,"GradeOutLong-Add "+IntegerToString(GetLastLongLevel()+1)))
     {
      long_pos_id.Add(Trade.ResultOrder());
      long_pos_level.Add(GetLastLongLevel()+1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockBaseOperateGradeOut::BuildShortPosition(double bl=0)
  {
   double l=bl==0?CalLotsDefault(GetLastShortLevel()+1,base_lots_sell):bl;
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l,latest_price.bid,0,0,"GradeOutShort-Add "+IntegerToString(GetLastShortLevel()+1)))
     {
      short_pos_id.Add(Trade.ResultOrder());
      short_pos_level.Add(GetLastShortLevel()+1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGridShockBaseOperateGradeOut::GetLastLongLevel(void)
  {
   if(long_pos_level.Total()==0) return 0;
   return long_pos_level.At(long_pos_level.Total()-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGridShockBaseOperateGradeOut::GetLastShortLevel(void)
  {
   if(short_pos_level.Total()==0) return 0;
   return short_pos_level.At(short_pos_level.Total()-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridShockBaseOperateGradeOut::GetLongPositionLotsAt(int index)
  {
   PositionSelectByTicket(long_pos_id.At(index));
   return PositionGetDouble(POSITION_VOLUME);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridShockBaseOperateGradeOut::GetShortPositionLotsAt(int index)
  {
   PositionSelectByTicket(short_pos_id.At(index));
   return PositionGetDouble(POSITION_VOLUME);
  }
//+------------------------------------------------------------------+
