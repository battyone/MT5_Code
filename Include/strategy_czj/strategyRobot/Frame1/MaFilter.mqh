//+------------------------------------------------------------------+
//|                                                     MaFilter.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMaFilter
  {
protected:
   int               h_ma_short;
   int               h_ma_long;
   double            value_ma_short[];
   double            value_ma_long[];
   int               code_map[];
public:
                     CMaFilter(void){};
                    ~CMaFilter(void){};
   void              SetFilterParameter(string sym,ENUM_TIMEFRAMES tf,int tau_short,int tau_long);
   void              SetCodeMap(int &c_map[]);
   int               MappingCode(MqlTick &tick);
   void              CopyMaValue();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMaFilter::SetFilterParameter(string sym,ENUM_TIMEFRAMES tf,int tau_short,int tau_long)
  {
   h_ma_short=iMA(sym,tf,tau_short,0,MODE_EMA,PRICE_CLOSE);
   h_ma_long=iMA(sym,tf,tau_long,0,MODE_EMA,PRICE_CLOSE);
  }
void CMaFilter::SetCodeMap(int &c_map[])
   {
    ArrayCopy(code_map,c_map);
   }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMaFilter::MappingCode(MqlTick &tick)
  {
   int c_code=0;
   if(value_ma_short[0]>value_ma_long[0]) // 短均线在长均线上方 
     {
      if(tick.bid>value_ma_short[0]) c_code=0;
      else if(tick.bid>value_ma_long[0]) c_code= 1;
      else c_code= 2;
     }
   else // 短均线在长均线下方
     {
      if(tick.ask<value_ma_short[0]) c_code= 5;
      else if(tick.bid<value_ma_long[0]) c_code= 4;
      else c_code= 3;
     }
   return code_map[c_code];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMaFilter::CopyMaValue(void)
  {
   CopyBuffer(h_ma_long,0,0,2,value_ma_long);
   CopyBuffer(h_ma_short,0,0,2,value_ma_short);
  }
//+------------------------------------------------------------------+
