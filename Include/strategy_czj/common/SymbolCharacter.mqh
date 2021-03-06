//+------------------------------------------------------------------+
//|                                              SymbolCharacter.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Object.mqh>
#include "strategy_common.mqh"
//+------------------------------------------------------------------+
//|        品种单根bar线high-low的分布信息                         |
//+------------------------------------------------------------------+
struct SymbolRange
  {
   int mean;
   int sigma;
   void Init(int _mean,int _sigma){mean=_mean;sigma=_sigma;};
  };
  
struct SymbolRangePeriod
   {
    SymbolRange h1;
    SymbolRange h4;
    SymbolRange d1;
    SymbolRange w1;
    void Init(int w1_m,int w1_s,int d1_m,int d1_s,int h4_m,int h4_s,int h1_m,int h1_s);
    SymbolRange GetSR(ENUM_TIMEFRAMES period);
   };
void SymbolRangePeriod::Init(int w1_m,int w1_s,int d1_m,int d1_s,int h4_m,int h4_s,int h1_m,int h1_s)
   {
    w1.Init(w1_m,w1_s);
    d1.Init(d1_m,d1_s);
    h4.Init(h4_m,h4_s);
    h1.Init(h1_m,h1_s);
   }   
SymbolRange SymbolRangePeriod::GetSR(ENUM_TIMEFRAMES period)
   {
    switch(period)
      {
       case PERIOD_W1 :return w1;
          break;
       case PERIOD_D1 :return d1;
          break;
       case PERIOD_H4 :return h4;
          break;
       case PERIOD_H1 :return h1;
          break;
       default:
         return h1;
         break;
      }
   }   
class CSymbolCharacter:public CObject
  {
private:
   string   symbols[28];  
   SymbolRangePeriod srp[];  
public:
                     CSymbolCharacter(void);
                    ~CSymbolCharacter(void){};
                    int GetSymbolIndex(string s);
                    SymbolRange GetSymbolRange(string s,ENUM_TIMEFRAMES period);
  };  
CSymbolCharacter::CSymbolCharacter(void)
   { 
    ArrayCopy(symbols,SYMBOLS_28);
    ArrayResize(srp,28);
    srp[0].Init(1765,935,767,479,288,238,141,124); // eurgbp
    srp[1].Init(3153,1489,1388,776,547,366,271,193);    // euraud
    srp[2].Init(3488,1418,1561,767,627,382,312,206);    // eurnzd
    srp[3].Init(1929,761,843,443,317,227,153,119);    // eurusd
    srp[4].Init(2939,1313,1319,675,500,366,247,190);   // eurcad
    srp[5].Init(1092,597,518,284,208,149,105,77);// eurchf
    srp[6].Init(2607,1426,1123,735,439,329,215,176); //eurjpy
    srp[7].Init(4272,2187,1868,1118,737,540,364,282);
    srp[8].Init(4769,2527,2090,1162,844,575,419,306);
    srp[9].Init(2931,1909,1256,959,468,439,227,223);
    srp[10].Init(3988,2244,1746,1114,668,556,329,287);
    srp[11].Init(2948,1810,1269,902,483,431,240,220);
    srp[12].Init(4417,3128,1821,1469,700,635,341,329);
    srp[13].Init(1746,667,772,335,315,167,158,94);
    srp[14].Init(1614,605,722,333,283,160,137,90);
    srp[15].Init(1679,586,782,327,315,170,158,96);
    srp[16].Init(1657,676,736,372,291,176,145,95);
    srp[17].Init(2262,1374,979,638,383,279,188,150);
    srp[18].Init(1660,592,734,304,288,159,141,90);
    srp[19].Init(1913,622,862,347,348,184,173,104);
    srp[20].Init(1547,551,704,316,286,160,143,89);
    srp[21].Init(2021,1114,892,563,357,253,177,137);
    srp[22].Init(2464,928,1054,489,400,267,193,143);
    srp[23].Init(1704,643,734,333,282,184,139,100);
    srp[24].Init(2526,1235,1055,604,409,281,198,156);
    srp[25].Init(1525,611,687,323,267,177,133,95);
    srp[26].Init(2304,1195,980,569,378,267,185,144);        
    srp[27].Init(2184,1131,975,588,395,268,198,149);
   }   
int CSymbolCharacter::GetSymbolIndex(string s)
   {
    for(int i=0;i<28;i++) if(symbols[i]==s) return i;
    return -1;
   }   
SymbolRange CSymbolCharacter::GetSymbolRange(string s,ENUM_TIMEFRAMES period)
   {
    int s_index=GetSymbolIndex(s);
    return srp[s_index].GetSR(period);
   }   
//+------------------------------------------------------------------+
