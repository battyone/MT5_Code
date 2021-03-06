//+------------------------------------------------------------------+
//|                                                        test1.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
#include <Math\Alglib\alglib.mqh>
#include <czj_tools\Cointegration.mqh>
#include <RiskManage_czj\MarketMoment.mqh>
#include <Math\Alglib\matrix.mqh>
#include <Math\Alglib\alglib.mqh>
#include <Math\czj\math_tools.mqh>
#include<strategy_czj\strategyZigZag\ClusterZigZag.mqh>
#include <strategy_czj\common\MarketInfor.mqh>
#include <strategy_czj\strategyRobot\ClassMapping.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
  test_mapping();
//test_bar_num();
//test_symbol_points();
//test_CMatrixDouble();
//test_regression();
//test_new_row();
//test_down_load_data();
//get_market_infor();
//test_datetime_to_others();
//test_resize();
//test_indicator();
//func_test_main();
//test_symbols_digits();
//test_market_valid();
//test_array_search();
  // market_symbols();
   //Test_marketmoment();
//test_matrix();
//test_pca();
   //test_matrix_multiply();
   //test_regression_mul();
   //test_message();
   //test_cluster_zigzag();
   //test_market_infor();
  // test_rate();
  }
void test_mapping()
   {
    CClassMapping333 code=new CClassMapping333();
    code.InitMapping();
   }  
void test_rate()
   {
    MqlRates rates[];
    int num =CopyRates(_Symbol,PERIOD_M1,0,1000,rates);
    for(int i=0;i<num-100;i++)
      {
       Print(i,":",rates[i].time,"*****", rates[i+100].time);
      }
    
   }
void test_market_infor()
   {
    CMarketInfor mi=new CMarketInfor();
    mi.CopyRatesData(PERIOD_D1,5);
    mi.SortCurrencies();
   }
void test_cluster_zigzag()
   {
    CClusterZigZag test = new CClusterZigZag();
    test.GetZigZagValues();
    test.Cluster();
    int infor;
    double c[];
    int num_c[];
    test.GetClusterResult(infor,c,num_c);
    Print("infor:", infor);
    int size = ArraySize(c);
    for(int i=0;i<size;i++)
      {
       Print("value:",c[i]," num:",num_c[i]);
      }
    test.CreateHline();
   }
void test_message()
   {
    bool res=SendNotification("来自EA的通知");
    if(!res) Print("Failed");
    else Print("Success");
    
   }
void test_regression_mul()
   {
    string symbols[]={"EURUSD","USDCHF"};
    //string symbols[]={"EURUSD","GBPUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
    CMatrixDouble cm,cm_t;
    CAlglib alg;
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
    int lr_infor;
    CLinearModelShell lm;
    CLRReportShell ar;
    alg.LRBuildZ(cm_t,100,ArraySize(symbols)-1,lr_infor,lm,ar);
    Print("infor", lr_infor);
    Print("Lm:");
    for(int i=0;i<ArraySize(lm.GetInnerObj().m_w);i++)
      {
       Print("i-",i," ",lm.GetInnerObj().m_w[i]);
      }
   
   CMatrixDouble res_c;
   alg.PearsonCorrM(cm_t,res_c);
   for(int i=0;i<res_c.Size();i++)
     {
      for(int j=0;j<res_c[i].Size();j++)
        {
         Print(res_c[i][j]);
        }
     }
//    Print("ar");
//    Print(ar.GetAvgError(),"avg error");
//    Print(ar.GetAvgRelError(),"avg real error");
//    Print(ar.GetCVAvgError(),"cv avg error");
//    Print(ar.GetCVAvgRelError(),"cv avg real error");
//    Print(ar.GetRMSError(),"RMSE");
//    double sst,sse,y_estimate;
//    for(int i=0;i<100;i++)
//      {
//       sst+=cm_t[i][ArraySize(symbols)-1]*cm_t[i][ArraySize(symbols)-1];
//       y_estimate=(lm.GetInnerObj().m_w[4])*cm_t[i][0];
//       sse+=(cm_t[i][ArraySize(symbols)-1]-y_estimate)*(cm_t[i][ArraySize(symbols)-1]-y_estimate);
//      }
//      
//    Print("R2=",1-sse/sst);
   }
void test_matrix_multiply()
   {
    CMatrixDouble cm1,cm2,cm3;
    cm1.Resize(2,2);
    cm2.Resize(2,3);
    
    double arr1_row1[]={1,2};
    double arr1_row2[]={2,1};
    double arr2_row1[]={1,2,3};
    double arr2_row2[]={2,1,3};
    
    cm1[0]=arr1_row1;
    cm1[1]=arr1_row2;
    
    cm2[0]=arr2_row1;
    cm2[1]=arr2_row2;
    
    czj_tools tools;
    tools.RMatrixMultiply(cm1,cm2,cm3);
    for(int i=0;i<cm3.Size();i++)
      {
       for(int j=0;j<cm3[i].Size();j++)
         {
          Print(cm3[i][j]);
         }
      }
    
   }
void test_pca()
   {
    string symbols[]={"EURUSD","GBPUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
    CMatrixDouble cm,cm_t;
    CAlglib alg;
    cm.Resize(ArraySize(symbols),100);
    cm_t.Resize(100,ArraySize(symbols));
    for(int i=0;i<ArraySize(symbols);i++)
      {
       double arr[];
       CopyClose(symbols[i],PERIOD_H1,0,10000,arr);
       double moments_mean,moments_var,moments_sk,moments_kur;
       alg.SampleMoments(arr,moments_mean,moments_var,moments_sk,moments_kur);
       for(int j=0;j<ArraySize(arr);j++)
         {
          arr[j]=arr[j]/sqrt(moments_var);
         }
       cm[i]=arr;
      }
    alg.RMatrixTranspose(ArraySize(symbols),100,cm,0,0,cm_t,0,0);
    int out_infor;
    double out_s2[];
    CMatrixDouble out_v;
    alg.PCABuildBasis(cm_t,100,ArraySize(symbols),out_infor,out_s2,out_v);
    Print("OK");
    Print("infor:",out_infor);
    for(int i=0;i<ArraySize(out_s2);i++)
      {
       Print("s2 ", out_s2[i]);
      }
    Print("v size:", out_v.Size());
    for(int i=0;i<out_v.Size();i++)
      {
       for(int j=0;j<out_v[i].Size();j++)
         {
          Print("row-",i," col-",j,":",out_v[i][j]);
         }
      }
   }
//+------------------------------------------------------------------+
void test_matrix()
   {
    CMatrixDouble cm;
    double arr1[]={11,12,13,14};
    double arr2[]={21,22,23,24};
    double arr3[]={31,32,33,34};
    
    cm.Resize(3,4);
    cm[0]=arr1;
    cm[1]=arr2;
    cm[2]=arr3;
    
    for(int i=0;i<3;i++)
      {
       string infor_row="";
       for(int j=0;j<4;j++)
         {
          infor_row=infor_row +" "+ DoubleToString(cm[i][j],0);
         }
        Print(infor_row);
      }
    CMatrixDouble cm2;
    cm2.Resize(4,3);
    CAlglib alg;
    //alg.RMatrixCopy(3,3,cm,0,0,cm2,0,0);
    alg.RMatrixTranspose(3,4,cm,0,0,cm2,0,0);
    Print(cm2.Size());   
    for(int i=0;i<4;i++)
      {
       string infor_row="";
       for(int j=0;j<3;j++)
         {
          infor_row=infor_row +" "+ DoubleToString(cm2[i][j],0);
         }
        Print(infor_row);
      }
    
   }
void test_bar_num()
  {
   string symbols[]={"XAUUSD","USDJPY","XTIUSD","XBRUSD","GBPUSD"};
   ENUM_TIMEFRAMES period=PERIOD_M1;
   for(int i=0;i<ArraySize(symbols);i++)
     {
      double price[];
      CopyClose(symbols[i],period,D'2017.05.01',D'2017.06.01',price);
      Print(symbols[i]," ",ArraySize(price)," ",price[0]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_symbol_points()
  {
   string symbols[]={"XAUUSD","GBPUSD","EURUSD","NZDUSD","AUDUSD","USDJPY","USDCAD","XTIUSD","XBRUSD","GBPUSD"};
   for(int i=0;i<ArraySize(symbols);i++)
     {
      Print(symbols[i]," ",SymbolInfoDouble(symbols[i],SYMBOL_POINT));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_new_row()
  {
   Print("1");
   Print("3\n\r,5");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_down_load_data()
  {
   MqlRates rates[];
   datetime dt_begin=D'2016.12.02';
datetime d1=D'2016.07.19 12:30:27';
datetime d2=D'2016.07.19 15:30:27';
Print(int(d2)-int(d2));
   //datetime dt_end=D'2017.03.01';
//Print("download data");
   //if(CopyRates(_Symbol,_Period,dt_begin,dt_end,rates)<0)
   //   Print(false);
   //Print(ArraySize(rates));
   //Print(rates[0].time);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_market_infor()
  {
   int handle_file=FileOpen("symbols_name_CFDFutures_13.csv",FILE_WRITE|FILE_CSV);
   for(int i=0;i<SymbolsTotal(true);i++)
     {
      FileWrite(handle_file,SymbolName(i,true));
     }
   FileClose(handle_file);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_datetime_to_others()
  {
   datetime dt_begin=D'2017.03.02 12:00';
   datetime dt_end=D'2017.03.02 11:15';
   Print(dt_begin," ",dt_end);
   Print((int)dt_begin," ",(int)dt_end);
   Print((long)dt_begin," ",(long)dt_end);
   Print((dt_begin-dt_end));
   Print(long(dt_begin-dt_end));
   Print(PeriodSeconds(PERIOD_M15));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_resize()
  {
   int a[];
   for(int i=0;i<5;i++)
     {
      ArrayResize(a,i+1);
      a[i]=i;
     }
   for(int i=0;i<5;i++)
     {
      Print(a[i]);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_indicator()
  {
   int rsi_handle1=iRSI("XAUUSD",PERIOD_H1,12,PRICE_CLOSE);
   int rsi_handle2=iRSI("CADCHF",PERIOD_H1,12,PRICE_CLOSE);
   Print(rsi_handle1," ",rsi_handle2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_test(const double &arr[],bool &big5,bool &less0)
  {
   for(int i=0;i<ArraySize(arr);i++)
     {
      if(arr[i]>5)
        {
         big5=true;
        }
      if(arr[i]<0)
        {
         less0=true;
        }
     }
   Print(big5,less0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_test_main()
  {
   bool is_big_5=false;
   bool is_less_0=false;
   double a[]={-3,6,8};
   Print(is_big_5,is_less_0);
   func_test(a,is_big_5,is_less_0);
   Print(is_big_5,is_less_0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_symbols_digits()
  {
   for(int i=0;i<SymbolsTotal(true);i++)
     {
      string symbol_choose=SymbolName(i,true);
      double point= SymbolInfoDouble(symbol_choose,SYMBOL_POINT);
      long digits = SymbolInfoInteger(symbol_choose,SYMBOL_DIGITS);
      double tick_size=SymbolInfoDouble(symbol_choose,SYMBOL_TRADE_TICK_SIZE);
      double size=SymbolInfoDouble(symbol_choose,SYMBOL_TRADE_CONTRACT_SIZE);

      Print("Symbol:",symbol_choose," Point:",point," Digits:",digits," Tick Size:",tick_size," Size:",size);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_market_valid()
  {
   MqlTick mql_tick;
   Print(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void test_array_search()
  {
   CArrayString *arr_str=new CArrayString;
   if(arr_str==NULL)
     {
      Print("Failed");
      return;
     }
   string currency_XUSD[]={"EUR","GBP","AUD","NZD"};
   arr_str.AssignArray(currency_XUSD);
   Print(arr_str.Total(),arr_str.At(1));
   Print(arr_str.IsSorted());
   int i =arr_str.Search("GBP");
   int j =arr_str.Search("NZD");
   Print(i," ",j);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void market_symbols()
  {
   string currency[]={"USD","EUR","GBP","AUD","NZD","CAD","CHF","JPY"};
   string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   int sign[]={1,1,1,1,-1,-1,-1};
   int points_matrix[2][8][8];

   ENUM_TIMEFRAMES period[]={PERIOD_H1,PERIOD_D1};
   MqlRates rates[];
   for(int k=0;k<2;k++)
     {
      for(int i=0;i<ArraySize(symbols);i++)
        {
         CopyRates(symbols[i],period[k],0,1,rates);
         points_matrix[k][0][i+1]=(int)((rates[0].close-rates[0].open)/SymbolInfoDouble(symbols[i],SYMBOL_POINT))*sign[i];
        }
      for(int i=1;i<8;i++)
        {
         for(int j=0;j<8;j++)
           {
            if(i==j) continue;
            if(i<j) points_matrix[k][i][j]=points_matrix[k][0][i]-points_matrix[k][0][j];
            else points_matrix[k][i][j]=-points_matrix[k][j][i];
           }
        }
      for(int i=0;i<8;i++)
        {
         int sum_points=0;
         for(int j=0;j<8;j++)
           {
            if(i!=j) sum_points+=points_matrix[k][i][j];
           }
         points_matrix[k][i][i]=sum_points;
        }
     }
    for(int i=0;i<8;i++)
      {
       //Print(symbols[i],":");
       Print(currency[i]," ",EnumToString(period[0]),":",points_matrix[0][i][i],";",EnumToString(period[1]),":",points_matrix[1][i][i]);
      }
  }
//void Test_marketmoment()
//   {
//    CurrenciesMoment *moment = new CurrenciesMoment(PERIOD_H1,3);
//    moment.GetCurrenciesMoments();
//   }
//+------------------------------------------------------------------+
