//+------------------------------------------------------------------+
//|                                           ClasssifyOneCandle.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "BaseClassify.mqh"
#include <strategy_czj\common\SymbolCharacter.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum CandleCombineType
  {
   ENUM_CANDLE_TYPE_ONE,// 单蜡烛形态(16)
   ENUM_CANDLE_TYPE_TWO,   // 双蜡烛形态(256)
   ENUM_CANDLE_TYPE_THREE, // 三蜡烛形态(4096)
   ENUM_CANDLE_TYPE_ONE_D1H4H1, // D1H4H1三周期每周期1烛线(4096)
   ENUM_CANDLE_TYPE_TWO_D1H4H1, // D1H4H1三周期每周期2烛线(16777216)
   ENUM_CANDLE_TYPE_THREE_D1H4H1 // D1H4H1三周期每周期三烛线()
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CClassifyOneCandle:public CBaseClassify
  {
protected:
   int               num_rates;  // 拷贝的bar数
   int               index_rates;   // 识别bar形态的索引
   int               range_points;
   double            upper_shadow; // 上影线
   double            lower_shadow; // 下影线
   double            body;   // 实体
   bool              is_positivae_line; // 是否是阳线
   double            range;  // high-low
protected:
   void              SetComment();   
public:
                     CClassifyOneCandle(void){};
                    ~CClassifyOneCandle(void){};
   void              InitOneCandle(string sym,ENUM_TIMEFRAMES tf,int r_num=1,int r_i=0); // 设置蜡烛线的波动幅度阈值
   virtual void      CalClassifyResult();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CClassifyOneCandle::InitOneCandle(string sym,ENUM_TIMEFRAMES tf,int r_num=1,int r_i=0)
  {
   symbol=sym;
   period=tf;
   num_rates=r_num;
   index_rates=r_i;
   cret=ENUM_CLASSIFY_REFRESH_BAR;
   
   CSymbolCharacter *sc=new CSymbolCharacter();
   SymbolRange sr=sc.GetSymbolRange(symbol,period);
   range_points=sr.mean;
   Print("波动点数:",range_points);
   SetTotal(16);
   SetComment();
   SetClassifyName(EnumToString(tf)+"Candle分类器");
  }
void CClassifyOneCandle::SetComment(void)
   {
    class_comment[0]="大波动|阳线|大上影线|大下影线";
    class_comment[1]="大波动|阳线|大上影线|小下影线";
    class_comment[2]="大波动|阳线|小上影线|大下影线";
    class_comment[3]="大波动|阳线|小上影线|小下影线";
    class_comment[4]="大波动|阴线|大上影线|大下影线";
    class_comment[5]="大波动|阴线|大上影线|小下影线";
    class_comment[6]="大波动|阴线|小上影线|大下影线";
    class_comment[7]="大波动|阴线|小上影线|小下影线";
    
    class_comment[8]="小波动|阳线|大上影线|大下影线";
    class_comment[9]="小波动|阳线|大上影线|小下影线";
    class_comment[10]="小波动|阳线|小上影线|大下影线";
    class_comment[11]="小波动|阳线|小上影线|小下影线";
    class_comment[12]="小波动|阴线|大上影线|大下影线";
    class_comment[13]="小波动|阴线|大上影线|小下影线";
    class_comment[14]="小波动|阴线|小上影线|大下影线";
    class_comment[15]="小波动|阴线|小上影线|小下影线";
    for(int i=0;i<16;i++) class_comment[i]=EnumToString(period)+"_"+class_comment[i];
   }  
//+------------------------------------------------------------------+
//|              根据rate数据判断类别                                |
//+------------------------------------------------------------------+
void CClassifyOneCandle::CalClassifyResult()
  {
   CopyRates(symbol,period,1,num_rates,rates);
   
   upper_shadow=rates[index_rates].high-MathMax(rates[index_rates].open,rates[index_rates].close);
   lower_shadow=MathMin(rates[index_rates].open,rates[index_rates].close)-rates[index_rates].low;
   body=MathAbs(rates[index_rates].open-rates[index_rates].close);
   is_positivae_line=rates[index_rates].close>rates[index_rates].open?true:false;
   range=rates[index_rates].high-rates[index_rates].low;
   if(range>range_points*SymbolInfoDouble(symbol,SYMBOL_POINT)) // 当前蜡烛波动大
     {
      if(is_positivae_line) // 阳线
        {
         if(upper_shadow>body) // 上影线大于实体
           {
            if(lower_shadow>body) class_result=0; // 下影线大于实体
            else class_result=1;
           }
         else
           {
            if(lower_shadow>body) class_result=2; // 下影线大于实体
            else class_result=3;
           }
        }
      else
        {
         if(upper_shadow>body) // 上影线大于实体
           {
            if(lower_shadow>body) class_result=4; // 下影线大于实体
            else class_result=5;
           }
         else
           {
            if(lower_shadow>body) class_result=6; // 下影线大于实体
            else class_result=7;
           }
        }
     }
   else // 当前蜡烛波动小
     {
      if(is_positivae_line) // 阳线
        {
         if(upper_shadow>body) // 上影线大于实体
           {
            if(lower_shadow>body) class_result=8; // 下影线大于实体
            else class_result=9;
           }
         else
           {
            if(lower_shadow>body) class_result=10; // 下影线大于实体
            else class_result=11;
           }
        }
      else
        {
         if(upper_shadow>body) // 上影线大于实体
           {
            if(lower_shadow>body) class_result=12; // 下影线大于实体
            else class_result=13;
           }
         else
           {
            if(lower_shadow>body) class_result=14; // 下影线大于实体
            else class_result=15;
           }
        }
     }
  }

//+------------------------------------------------------------------+
