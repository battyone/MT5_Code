//+------------------------------------------------------------------+
//|                                                 ClassMapping.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct C333
  {
   int               code[9];
   string            to_str();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string C333::to_str(void)
  {
   string s;
   for(int i=0;i<9;i++) StringAdd(s,IntegerToString(code[i]));
   return s;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CClassMapping333
  {
protected:
   int               total_map;
   C333              map_code[];
   int               current_code_index;
public:
                     CClassMapping333(void){};
                    ~CClassMapping333(void){};
   void              InitMapping();
   void              SetCurrentCodeIndex(int c_i=0){current_code_index=c_i;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CClassMapping333::InitMapping()
  {
   total_map=MathPow(3,(3*3));
   ArrayResize(map_code,total_map);
   for(int i=0;i<total_map;i++)
     {
      int k=8;
      int m=i;
      int t=m;
      while(t)
        {
         t/=3;
         map_code[i].code[k--]=m-3*t;
         m=t;
        }
      //Print("i=",i," 10进制:",i,";三进制:",map_code[i].to_str());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBandsRsiMapping:public CClassMapping333
  {
protected:
   int               h_band;
   int               h_rsi;
   double            value_band_up[];
   double            value_band_down[];
   double            value_rsi[];
public:
                     CBandsRsiMapping(void){};
                    ~CBandsRsiMapping(void){};
   void              InitHandles(string sym,ENUM_TIMEFRAMES tf_band=PERIOD_H1,int ma_band=24,double d_band=2.0,ENUM_TIMEFRAMES tf_rsi=PERIOD_H1,int ma_rsi=14);
   int               Classify(MqlTick &tick);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBandsRsiMapping::InitHandles(string sym,ENUM_TIMEFRAMES tf_band=PERIOD_H1,int ma_band=24,double d_band=2.0,ENUM_TIMEFRAMES tf_rsi=PERIOD_H1,int ma_rsi=14)
  {
   h_band=iBands(sym,tf_band,ma_band,0,d_band,PRICE_CLOSE);
   h_rsi=iRSI(sym,tf_rsi,ma_rsi,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBandsRsiMapping::Classify(MqlTick &tick)
  {
   CopyBuffer(h_band,0,0,1,value_band_up);
   CopyBuffer(h_band,1,0,1,value_band_down);
   CopyBuffer(h_rsi,0,0,1,value_rsi);
   int c_band;
   int c_rsi;

   if(tick.bid>value_band_up[0]) c_band=0;
   else if(tick.ask<value_band_down[0]) c_band=2;
   else c_band=1;

   if(value_rsi[0]>70) c_rsi=0;
   else if(value_rsi[0]<30) c_rsi=2;
   else c_rsi=1;
//return 3*c_band+c_rsi;
   return map_code[current_code_index].code[3*c_band+c_rsi];
  }
//+------------------------------------------------------------------+
