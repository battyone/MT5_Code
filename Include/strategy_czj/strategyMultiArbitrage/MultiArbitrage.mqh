//+------------------------------------------------------------------+
//|                                               MultiArbitrage.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Arrays\ArrayLong.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Math\Alglib\matrix.mqh>
#include <Math\Alglib\alglib.mqh>
#include <RingBuffer\RiBuffDbl.mqh>
#include <Math\czj\math_tools.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMultiArbitrage:public CStrategy
  {
private:
   string            symbols[];
   int               win_points;
   int               tau;
   double            delta;
   double            base_lots;
   double            hold_time_max;
   double            r2_min;

   int               num_symbols;

   MqlTick           latest_price[];
   CMatrixDouble     cm;
   CMatrixDouble     cm_tranpose;

   CArrayLong        long_position_id;
   CArrayLong        short_position_id;
   PositionInfor     pos_state;
   CRiBuffDbl        ribuffer_price[];
   double            mean_price[];
   double            std_price[];

   //double            regression_coffe[];
   //double            error_lm[];
   //double            std_error;
   double            regress_coeff[];
   double            regress_e[];
   double            regress_std_e;
   double            regress_r2;
   double            current_e;
   bool              valid_regress;

   double            symbol_lots[];
   CAlglib           alg;

public:
                     CMultiArbitrage(void);
                    ~CMultiArbitrage(void){};
   void              InitStrategy(string &arb_symbols[],int points_win,int arb_tau,double arb_delta,double arb_lots,double arb_time_out,double arb_min_r2);
   virtual void      OnEvent(const MarketEvent &event);
protected:
   void              RefreshPositionState(void);
   bool              CloseLongCondition(void);
   bool              CloseShortCondition(void);
   void              CloseLongPosition(void);
   void              CloseShortPosition(void);
   bool              UpdateCointergrationOnBar(void);
   void              RegressionAnalysis(CMatrixDouble &data,double &coeff[],double &e[],double &std_e,double &R2);
   bool              OpenLongCondition(void);
   bool              OpenShortCondition(void);
   void              OpenLongPosition(void);
   void              OpenShortPosition(void);
   void              CalSymbolsLots(void);
   double            CalCurrentE(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMultiArbitrage::CMultiArbitrage(void)
  {
//string symbol_default[]={"USDCHF","EURUSD"};
  // string symbol_default[]={"USDJPY","XAUUSD"};
   string symbol_default[]={"USDCHF","USDJPY","GBPUSD","AUDUSD","NZDUSD","USDCAD","EURUSD"};
   win_points=100;
   tau=24*12;
   delta=1.0;
   base_lots=1;
   hold_time_max=24000;
   r2_min=0.8;
   num_symbols=ArraySize(symbol_default);
   ArrayCopy(symbols,symbol_default);
   ArrayResize(latest_price,num_symbols);
   ArrayResize(ribuffer_price,num_symbols);
   ArrayResize(std_price,num_symbols);
   ArrayResize(mean_price,num_symbols);
//ArrayResize(regression_coffe,num_symbols);
   ArrayResize(symbol_lots,num_symbols);
//ArrayResize(error_lm,tau);
   cm.Resize(num_symbols,tau);
   cm_tranpose.Resize(tau,num_symbols);
   for(int i=0;i<num_symbols;i++)
     {
      ribuffer_price[i].SetMaxTotal(tau);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMultiArbitrage::InitStrategy(string &arb_symbols[],int points_win,int arb_tau,double arb_delta,double arb_lots,double arb_time_out,double arb_min_r2)
  {
   win_points=points_win;
   tau=arb_tau;
   delta=arb_delta;
   base_lots=arb_lots;
   hold_time_max=arb_time_out;
   r2_min=arb_min_r2;
   num_symbols=ArraySize(arb_symbols);
   ArrayCopy(symbols,arb_symbols);
   ArrayResize(latest_price,num_symbols);
   ArrayResize(ribuffer_price,num_symbols);
   ArrayResize(std_price,num_symbols);
   ArrayResize(mean_price,num_symbols);
   ArrayResize(symbol_lots,num_symbols);
   cm.Resize(num_symbols,tau);
   cm_tranpose.Resize(tau,num_symbols);
   for(int i=0;i<num_symbols;i++)
     {
      ribuffer_price[i].SetMaxTotal(tau);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMultiArbitrage::OnEvent(const MarketEvent &event)
  {
//    Tick事件的处理
   if(event.type==MARKET_EVENT_TICK)
     {
      //       获取最新的报价
      for(int i=0;i<ArraySize(symbols);i++)
         SymbolInfoTick(symbols[i],latest_price[i]);
      //    刷新仓位信息
      RefreshPositionState();
      //     进行平仓判断  
      if(CloseLongCondition()) CloseLongPosition();
      if(CloseShortCondition()) CloseShortPosition();

      //    刷新仓位信息
      RefreshPositionState();
      //      进行开仓判断
      if(valid_regress)
        {
         current_e=CalCurrentE();
         if(OpenLongCondition()) OpenLongPosition();
         if(OpenShortCondition()) OpenShortPosition();
        }
     }
//    bar事件处理
   if(event.period==Timeframe() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      //    刷新仓位信息
      RefreshPositionState();
      //     更新协整序列
      valid_regress=UpdateCointergrationOnBar();
      //if(valid_regress)
      //  {
      //   //      进行开仓判断
      //   if(OpenLongCondition()) OpenLongPosition();
      //   if(OpenShortCondition()) OpenShortPosition();
      //  }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMultiArbitrage::RefreshPositionState(void)
  {
   pos_state.Init();
   for(int i=0;i<long_position_id.Total();i++)
     {
      PositionSelectByTicket(long_position_id.At(i));
      pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_buy+=1;
      pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
      pos_state.buy_hold_time_hours=(int(TimeCurrent())-int(PositionGetInteger(POSITION_TIME)))/60/60;
     }
   for(int i=0;i<short_position_id.Total();i++)
     {
      PositionSelectByTicket(short_position_id.At(i));
      pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_sell+=1;
      pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
      pos_state.sell_hold_time_hours=(int(TimeCurrent())-int(PositionGetInteger(POSITION_TIME)))/60/60;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMultiArbitrage::CloseLongCondition(void)
  {
   if(pos_state.num_buy>0&&pos_state.profits_buy/pos_state.lots_buy>win_points) return true;
   if(pos_state.buy_hold_time_hours>hold_time_max) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMultiArbitrage::CloseShortCondition(void)
  {
   if(pos_state.num_sell>0&&pos_state.profits_sell/pos_state.lots_sell>win_points) return true;
   if(pos_state.sell_hold_time_hours>hold_time_max) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiArbitrage::CloseLongPosition(void)
  {
   for(int i=0;i<long_position_id.Total();i++)
     {
      Trade.PositionClose(long_position_id.At(i));
     }
   long_position_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiArbitrage::CloseShortPosition(void)
  {
   for(int i=0;i<short_position_id.Total();i++)
     {
      Trade.PositionClose(short_position_id.At(i));
     }
   short_position_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMultiArbitrage::UpdateCointergrationOnBar(void)
  {
   for(int i=0;i<num_symbols;i++)
     {
      ribuffer_price[i].AddValue((latest_price[i].ask+latest_price[i].bid)/2);
      if(ribuffer_price[i].GetTotal()<ribuffer_price[i].GetMaxTotal()) return false;
     }
//   数据长度足够的情况
   for(int i=0;i<num_symbols;i++)
     {
      double arr[];
      ribuffer_price[i].ToArray(arr);
      double moments_mean,moments_var,moments_sk,moments_kur;
      alg.SampleMoments(arr,moments_mean,moments_var,moments_sk,moments_kur);
      if(moments_var==0)
        {
         Print("var=0",symbols[i]);
        }
      std_price[i]=sqrt(moments_var);
      mean_price[i]=moments_mean;
      for(int j=0;j<tau;j++)
        {
         arr[j]=(arr[j]-mean_price[i])/std_price[i];
        }
      cm[i]=arr;
     }
   alg.RMatrixTranspose(num_symbols,tau,cm,0,0,cm_tranpose,0,0);

//      对标准化的数据进行主成分分析
//int out_infor;
//double out_s2[];
//CMatrixDouble out_v;
//alg.PCABuildBasis(cm_tranpose,tau,num_symbols,out_infor,out_s2,out_v);

//      多元回归分析
   RegressionAnalysis(cm_tranpose,regress_coeff,regress_e,regress_std_e,regress_r2);
   if(regress_r2<r2_min) return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiArbitrage::RegressionAnalysis(CMatrixDouble &data,double &coeff[],double &e[],double &std_e,double &R2)
  {
   int num_variable=data[0].Size();
   int num_sample=data.Size();
   ArrayResize(coeff,num_variable);
   ArrayResize(e,num_sample);

   int lr_infor;
   CLinearModelShell lm;
   CLRReportShell ar;
   alg.LRBuildZ(data,num_sample,num_variable-1,lr_infor,lm,ar);//---使用无截距的回归模型
                                                               //回归系数
   for(int i=0;i<num_variable;i++)
     {
      coeff[i]=lm.GetInnerObj().m_w[i+4];
     }
// 计算残差序列
   for(int i=0;i<num_sample;i++)
     {
      double y_estimate=0;
      for(int j=0;j<num_variable-1;j++)
        {
         y_estimate+=coeff[j]*data[i][j];
        }
      e[i]=data[i][num_variable-1]-y_estimate;
     }
//     计算残差序列的矩
   double moments_mean,moments_var,moments_sk,moments_kur;
   alg.SampleMoments(e,moments_mean,moments_var,moments_sk,moments_kur);
   std_e=sqrt(moments_var);
//   计算R2
   double sst=0,sse=0;
   for(int i=0;i<num_sample;i++)
     {
      sst+=(data[i][num_variable-1]-0)*(data[i][num_variable-1]-0);
      sse+=e[i]*e[i];
     }
   R2=1-(sse/(num_sample-num_variable+1))/(sst/(num_sample-1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMultiArbitrage::CalCurrentE(void)
  {
   double y_standard_estimate=0;
   double y_standard_real=((latest_price[num_symbols-1].ask+latest_price[num_symbols-1].bid)/2-mean_price[num_symbols-1])/std_price[num_symbols-1];
   for(int i=0;i<num_symbols-1;i++)
     {
      double standard_xi=((latest_price[i].ask+latest_price[i].bid)/2-mean_price[i])/std_price[i];
      y_standard_estimate+=regress_coeff[i]*standard_xi;
     }

   return y_standard_real-y_standard_estimate;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMultiArbitrage::OpenLongCondition(void)
  {
   if(pos_state.num_buy>0) return false;
   if(current_e<-delta*regress_std_e) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMultiArbitrage::OpenShortCondition(void)
  {
   if(pos_state.num_sell>0) return false;
   if(current_e>delta*regress_std_e) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiArbitrage::OpenLongPosition(void)
  {
   CalSymbolsLots();
   if(symbol_lots[num_symbols-1]>=0.01)
     {
      Trade.PositionOpen(symbols[num_symbols-1],ORDER_TYPE_BUY,symbol_lots[num_symbols-1],latest_price[num_symbols-1].ask,0,0,"long-buy");
      long_position_id.Add(Trade.ResultOrder());
     }

   for(int i=0;i<num_symbols-1;i++)
     {
      if(symbol_lots[i]<0.01) continue;
      double adjust_price=regress_coeff[i]>0?latest_price[i].bid:latest_price[i].ask;
      ENUM_ORDER_TYPE order_type=regress_coeff[i]>0?ORDER_TYPE_SELL:ORDER_TYPE_BUY;
      Trade.PositionOpen(symbols[i],order_type,symbol_lots[i],adjust_price,0,0,"long-open"+DoubleToString(regress_coeff[i],2)+"R2:"+regress_r2);
      long_position_id.Add(Trade.ResultOrder());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiArbitrage::OpenShortPosition(void)
  {
   CalSymbolsLots();
//for(int i=0;i<num_symbols;i++)
//  {
//   Print("lots:",symbol_lots[i]);
//  }
   if(symbol_lots[num_symbols-1]>=0.01)
     {
      Trade.PositionOpen(symbols[num_symbols-1],ORDER_TYPE_SELL,symbol_lots[num_symbols-1],latest_price[num_symbols-1].bid,0,0,"short-open");
      short_position_id.Add(Trade.ResultOrder());
     }

   for(int i=0;i<num_symbols-1;i++)
     {
      if(symbol_lots[i]<0.01) continue;
      double adjust_price=regress_coeff[i]>0?latest_price[i].ask:latest_price[i].bid;
      ENUM_ORDER_TYPE order_type=regress_coeff[i]>0?ORDER_TYPE_BUY:ORDER_TYPE_SELL;

      Trade.PositionOpen(symbols[i],order_type,symbol_lots[i],adjust_price,0,0,"short-open"+DoubleToString(regress_coeff[i],2)+"R2:"+regress_r2);
      short_position_id.Add(Trade.ResultOrder());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiArbitrage::CalSymbolsLots(void)
  {
   double sum_coeff=1/std_price[num_symbols-1];
   for(int i=0;i<num_symbols-1;i++)
     {
      sum_coeff+=MathAbs(regress_coeff[i])/std_price[i];
     }

   for(int i=0;i<num_symbols-1;i++)
     {
      symbol_lots[i]=MathAbs(NormalizeDouble(regress_coeff[i]/std_price[i]/sum_coeff*base_lots,2));
     }
   symbol_lots[num_symbols-1]=NormalizeDouble(1/std_price[num_symbols-1]/sum_coeff*base_lots,2);
  }
//void CMultiArbitrage::CalSymbolsLots(void)
//  {
//   
//   for(int i=0;i<num_symbols-1;i++)
//     {
//      symbol_lots[i]=NormalizeDouble(regression_coffe[i]*base_lots,2);
//     }
//   symbol_lots[num_symbols-1]=NormalizeDouble(base_lots,2);
//  }
//void CMultiArbitrage::CalSymbolsLots(void)
//  {
//   
//   for(int i=0;i<num_symbols-1;i++)
//     {
//      symbol_lots[i]=NormalizeDouble(regression_coffe[i]*std_price[i]/std_price[num_symbols-1]*base_lots,2);
//     }
//   symbol_lots[num_symbols-1]=NormalizeDouble(base_lots,2);
//  }
//+------------------------------------------------------------------+
