//+------------------------------------------------------------------+
//|                                                  PriceFilter.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPriceFilter
  {
protected:
   string            sym;
   ENUM_TIMEFRAMES   tf;
   int               n_long;
   int               n_short;
   int               code_map[];
   double            long_max_price;
   double            long_min_price;
   double            short_max_price;
   double            short_min_price;
public:
                     CPriceFilter(void){};
                    ~CPriceFilter(void){};
   void              SetFilterParameter(string sym_,ENUM_TIMEFRAMES tf_,int num_long,int num_short);
   void              SetCodeMap(int &c_map[]);
   int               MappingCode(MqlTick &tick);
   void              CopyPrice();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPriceFilter::SetFilterParameter(string sym_,ENUM_TIMEFRAMES tf_,int num_long,int num_short)
  {
   n_long=num_long;
   n_short=num_short;
   sym=sym_;
   tf=tf_;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPriceFilter::SetCodeMap(int &c_map[])
  {
   ArrayCopy(code_map,c_map);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPriceFilter::CopyPrice(void)
  {
   double l_high[],l_low[],s_high[],s_low[];
   CopyHigh(sym,tf,1,n_long,l_high);
   CopyLow(sym,tf,1,n_long,l_low);
   CopyHigh(sym,tf,1,n_short,s_high);
   CopyLow(sym,tf,1,n_short,s_low);
   long_max_price=l_high[ArrayMaximum(l_high)];
   long_min_price=l_low[ArrayMinimum(l_low)];
   short_max_price=s_high[ArrayMaximum(s_high)];
   short_min_price=s_low[ArrayMinimum(s_low)];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CPriceFilter::MappingCode(MqlTick &tick)
  {
   int c_code=0;
   if(tick.bid>long_max_price-(long_max_price-long_min_price)*0.25) //  
     {
      if(tick.bid>short_max_price-(short_max_price-short_min_price)*0.25) c_code=0;
      else if(tick.ask<short_min_price+(short_max_price-short_min_price)*0.25) c_code=1;
      else c_code=2;
     }
   else if(tick.ask<long_min_price+(long_max_price-long_min_price)*0.25)// 
     {
      if(tick.bid>short_max_price-(short_max_price-short_min_price)*0.25) c_code=3;
      else if(tick.ask<short_min_price+(short_max_price-short_min_price)*0.25) c_code=4;
      else c_code=5;
     }
   else
     {
      if(tick.bid>short_max_price-(short_max_price-short_min_price)*0.25) c_code=6;
      else if(tick.ask<short_min_price+(short_max_price-short_min_price)*0.25) c_code=7;
      else c_code=8;
     }
   return code_map[c_code];
  }
//+------------------------------------------------------------------+
