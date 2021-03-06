//+------------------------------------------------------------------+
//|                                                        Test2.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//#include <Arrays\ArrayObj.mqh>
//#include <Arrays\ArrayString.mqh>
//#include <Math\Alglib\alglib.mqh>
//#include <czj_tools\Cointegration.mqh>
//#include <RiskManage_czj\MarketMoment.mqh>
#include <Math\Alglib\matrix.mqh>
#include <Math\Alglib\alglib.mqh>
//#include <Math\czj\math_tools.mqh>
    CAlglib alg;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
    string symbols[]={"EURUSD","USDCHF"};
    //string symbols[]={"EURUSD","GBPUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
    CMatrixDouble cm,cm_t;

    cm.Resize(ArraySize(symbols),100);
    cm_t.Resize(100,ArraySize(symbols));
    for(int i=0;i<ArraySize(symbols);i++)
      {
       double arr[];
       CopyClose(symbols[i],PERIOD_M1,0,100,arr);
       double moments_mean,moments_var,moments_sk,moments_kur;
       alg.SampleMoments(arr,moments_mean,moments_var,moments_sk,moments_kur);
       for(int j=0;j<ArraySize(arr);j++)
         {
          arr[j]=(arr[j]-moments_mean)/sqrt(moments_var);
         }
       cm[i]=arr;
      }
    alg.RMatrixTranspose(ArraySize(symbols),100,cm,0,0,cm_t,0,0);
    double regress_coeff[],regress_e[],regress_std_e,regress_r2;
    RegressionAnalysis(cm_t,regress_coeff,regress_e,regress_std_e,regress_r2);
   
  }
//+------------------------------------------------------------------+
void RegressionAnalysis(CMatrixDouble &data,double &coeff[],double &e[],double &std_e,double &R2)
   {
   int num_varibale=data[0].Size();
   int num_sample=data.Size();
   ArrayResize(coeff,num_varibale);
   ArrayResize(e,num_sample);
   int lr_infor;
   CLinearModelShell lm;
   CLRReportShell ar;
   
   CMatrixDouble res_c;
   alg.PearsonCorrM(data,res_c);
   for(int i=0;i<res_c.Size();i++)
     {
      for(int j=0;j<res_c[i].Size();j++)
        {
         Print(res_c[i][j]);
        }
     }
     
   alg.LRBuildZ(data,num_sample,num_varibale-1,lr_infor,lm,ar);//---使用无截距的回归模型
   Print("infor:",lr_infor);
   for(int i=0;i<ArraySize(lm.GetInnerObj().m_w);i++)
     {
      Print("m_w: ", lm.GetInnerObj().m_w[i]);
     }
   
   //回归系数
   for(int i=0;i<num_varibale;i++)
      {
         coeff[i]=lm.GetInnerObj().m_w[i+4];
         //Print(coeff[i],"系数");
      }
   // 计算残差序列
   for(int i=0;i<num_sample;i++)
     {
      double y_estimate=0;
      for(int j=0;j<num_varibale-1;j++)
        {
         y_estimate+=coeff[j]*data[i][j];
        }
      e[i]=data[i][num_varibale-1]-y_estimate;
     }
//     计算残差序列的矩
   double moments_mean,moments_var,moments_sk,moments_kur;
   alg.SampleMoments(e,moments_mean,moments_var,moments_sk,moments_kur);
   std_e=sqrt(moments_var);
//   计算R2
   double sst=0,sse=0;
   for(int i=0;i<num_sample;i++)
     {
      sst+=(data[i][num_varibale-1]-0)*(data[i][num_varibale-1]-0);
      sse+=e[i]*e[i];
     }
    R2=1-(sse/(num_sample-num_varibale+1))/(sst/(num_sample-1));
   }