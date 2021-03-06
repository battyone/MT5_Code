//+------------------------------------------------------------------+
//|                                             ClassifyDoubleMa.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "BaseClassify.mqh"
//+------------------------------------------------------------------+
//|              双均线分类器                                        |
//+------------------------------------------------------------------+
class CClassifyDoubleMa:public CBaseClassify
  {
protected:
   int               h_long;
   int               h_short;
   double            ma_long[];
   double            ma_short[];
protected:
   void              SetComment();   
public:
                     CClassifyDoubleMa(void){};
                    ~CClassifyDoubleMa(void){};
   void              InitDoubleMa(string sym,ENUM_TIMEFRAMES tf=PERIOD_H1,int tau_long=200,int tau_short=24);
   virtual void       CalClassifyResult();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CClassifyDoubleMa::InitDoubleMa(string sym,ENUM_TIMEFRAMES tf=16385,int tau_long=200,int tau_short=24)
  {
   symbol=sym;
   period=tf;
   cret=ENUM_CLASSIFY_REFRESH_TICK;
   h_long=iMA(sym,tf,tau_long,0,MODE_EMA,PRICE_CLOSE);
   h_short=iMA(sym,tf,tau_short,0,MODE_EMA,PRICE_CLOSE);
   SetTotal(6);
   SetComment();
   SetClassifyName("双均线分类器");
  }
void CClassifyDoubleMa::SetComment(void)
   {
    class_comment[0]="价格>短均线>长均线";
    class_comment[1]="短均线>长均线>价格";
    class_comment[2]="短均线>价格>长均线";
    class_comment[3]="价格<短均线<长均线";
    class_comment[4]="短均线<长均线<价格";
    class_comment[5]="短均线<价格<长均线";
   }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CClassifyDoubleMa::CalClassifyResult()
  {
   CopyBuffer(h_long,0,1,1,ma_long);
   CopyBuffer(h_short,0,1,1,ma_short);
   SymbolInfoTick(symbol,latest_tick);
   if(ma_short[0]>ma_long[0])
     {
      if(latest_tick.bid>ma_short[0]) class_result= 0;
      else if(latest_tick.ask<ma_long[0])  class_result= 1;
      else class_result= 2;
     }
   else
     {
      if(latest_tick.ask<ma_short[0]) class_result= 3;
      else if(latest_tick.bid>ma_long[0]) class_result= 4;
      else class_result= 5;
     }
  }
//+------------------------------------------------------------------+
