//+------------------------------------------------------------------+
//|                                                  MarketPrice.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "ForexClass.mqh"
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
#include <Graphics\Curve.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ForexClassMarketPrice
  {
protected:
   ENUM_TIMEFRAMES   period;
   int               price_num;
   CArrayObj         arr_obj_y;
   CArrayObj         arr_obj_x;
public:
   ForexFamily       ff;
                     ForexClassMarketPrice(void){};
                    ~ForexClassMarketPrice(void){};
   void              Init3(string forex_family_name="USD",ENUM_TIMEFRAMES period_price=PERIOD_M1,int price_num=100);//固定数量的初始化方法
   void              Init1(string forex_family_name="USD",ENUM_TIMEFRAMES period_price=PERIOD_M1,datetime from=D'2017.01.01',datetime to=D'2017.10.10');//固定起点和终点的初始化方法
   void              Init2(string forex_family_name="USD",ENUM_TIMEFRAMES period_price=PERIOD_M1,datetime begin=D'2017.01.01');//固定起始点的初始化方法
   void              GetMarketPriceAt(const int symbol_i,const string cal_type,double &price[],double &time[]);
   int               GetPriceNum(void){return price_num;};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ForexClassMarketPrice::Init3(string forex_family_name="USD",ENUM_TIMEFRAMES period_price=PERIOD_M1,int num=100)
  {
   arr_obj_x.Shutdown();
   arr_obj_y.Shutdown();

   ff.Init(forex_family_name);
   period=period_price;
   price_num=num;

   double data_temp[1];
   for(int i=0;i<ff.GetSymbolNum();i++)
     {
      CArrayDouble *price=new CArrayDouble();
      CArrayDouble *time=new CArrayDouble();
      datetime dt=TimeCurrent();
      for(int j=num-1;j>=0;j--)
        {
         CopyClose(ff.GetSymbolNameAt(i),period,dt-PeriodSeconds(period)*j,1,data_temp);
         price.Add(data_temp[0]);
         time.Add((double)(dt-PeriodSeconds(period)*j));
        }
      arr_obj_x.Add(time);
      arr_obj_y.Add(price);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ForexClassMarketPrice::Init1(string forex_family_name="USD",ENUM_TIMEFRAMES period_price=PERIOD_M1,datetime from=D'2017.01.01',datetime to=D'2017.10.10')
  {
   arr_obj_x.Shutdown();
   arr_obj_y.Shutdown();
   ff.Init(forex_family_name);
   period=period_price;
   for(int i=0;i<ff.GetSymbolNum();i++)
     {
      MqlRates rates[];
      CopyRates(ff.GetSymbolNameAt(i),period,from,to,rates);
      int size=ArraySize(rates);
      CArrayDouble *price=new CArrayDouble();
      CArrayDouble *time=new CArrayDouble();

      for(int j=0;j<size;j++)
        {
         price.Add(rates[j].close);
         time.Add((double)(rates[j].time));
        }
      arr_obj_x.Add(time);
      arr_obj_y.Add(price);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ForexClassMarketPrice::Init2(string forex_family_name="USD",ENUM_TIMEFRAMES period_price=PERIOD_M1,datetime begin=D'2017.01.01')
  {
   Init1(forex_family_name,period_price,begin,TimeCurrent());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ForexClassMarketPrice::GetMarketPriceAt(const int symbol_i,const string cal_type,double &price[],double &time[])
  {
   CArrayDouble *price_origin=new CArrayDouble();
   CArrayDouble *time_origin=new CArrayDouble();
   price_origin.AssignArray(arr_obj_y.At(symbol_i));
   time_origin.AssignArray(arr_obj_x.At(symbol_i));
   int size=price_origin.Total();
   ArrayResize(price,size);
   ArrayResize(time,size);
   if(cal_type=="ratio")
     {
      for(int i=0;i<size;i++)
        {
         price[i]=MathPow(price_origin.At(i)/price_origin.At(0),ff.GetCoeffAt(symbol_i));
         time[i]=(time_origin.At(i)-time_origin.At(0))/PeriodSeconds(period);
        }
     }
   else
     {
      for(int i=0;i<size;i++)
        {
         price[i]=(price_origin.At(i)-price_origin.At(0))/SymbolInfoDouble(ff.GetSymbolNameAt(symbol_i),SYMBOL_POINT)*ff.GetCoeffAt(symbol_i);
         time[i]=(time_origin.At(i)-time_origin.At(0))/PeriodSeconds(period);
        }
     }

   delete price_origin;
   delete time_origin;
  }
//+------------------------------------------------------------------+
