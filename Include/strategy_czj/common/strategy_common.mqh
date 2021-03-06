//+------------------------------------------------------------------+
//|                                              strategy_common.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

//仓位信息结构体
struct PositionInfor
  {
   double            profits_buy;
   double            profits_sell;
   int               num_buy;
   int               num_sell;
   double            lots_buy;
   double            lots_sell;
   double            buy_hold_time_hours;
   double            sell_hold_time_hours;
   void              Init();
   double            GetProfitsTotal(){return profits_buy+profits_sell;};
   double            GetLotsTotal(){ return lots_buy+lots_sell;};
   double            GetProfitsPerLots(){ return GetLotsTotal()==0?0:GetProfitsTotal()/GetLotsTotal();};
   double            GetProfitsLongPerLots(){return lots_buy==0?0:profits_buy/lots_buy;};
   double            GetProfitsShortPerLots(){return lots_sell==0?0:profits_sell/lots_sell;};
   int               GetTotalNum(){return num_buy+num_sell;};
   double            GetLotsBuyToSell(){return lots_buy-lots_sell;};
  };
//+------------------------------------------------------------------+
//|             初始化仓位信息                                            |
//+------------------------------------------------------------------+
void PositionInfor::Init(void)
  {
   profits_buy=0;
   profits_sell=0;
   num_buy=0;
   num_sell=0;
   lots_buy=0.0;
   lots_sell=0.0;
   buy_hold_time_hours=0;
   sell_hold_time_hours=0;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|       套利仓位信息                                               |
//+------------------------------------------------------------------+
struct ArbitragePosition
  {
   int               pair_open_buy;
   int               pair_open_sell;
   int               pair_open_total;
   double            pair_buy_profit;
   double            pair_sell_profit;
   void              Init();
  };
//+------------------------------------------------------------------+
//|         初始化套利仓位信息                                       |
//+------------------------------------------------------------------+
void ArbitragePosition::Init(void)
  {
   pair_open_buy=0;
   pair_open_sell=0;
   pair_open_total=0;
   pair_buy_profit=0.0;
   pair_sell_profit=0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct PositionStates
  {
   int               open_buy;
   int               open_sell;
   int               open_total;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OpenSignal
  {
   OPEN_SIGNAL_BUY,
   OPEN_SIGNAL_SELL,
   OPEN_SIGNAL_NULL
  };
string SYMBOLS_28[]=
  {
   "EURGBP","EURAUD","EURNZD","EURUSD","EURCAD","EURCHF","EURJPY",
   "GBPAUD","GBPNZD","GBPUSD","GBPCAD","GBPCHF","GBPJPY",
   "AUDNZD","AUDUSD","AUDCAD","AUDCHF","AUDJPY",
   "NZDUSD","NZDCAD","NZDCHF","NZDJPY",
   "USDCAD","USDCHF","USDJPY",
   "CADCHF","CADJPY",
   "CHFJPY"
  };
string SYMBOLS_7[]=
  {
   "EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"
  };  
enum CurrencyType
  {
   ENUM_CURRENCIES_EUR,
   ENUM_CURRENCIES_GBP,
   ENUM_CURRENCIES_AUD,
   ENUM_CURRENCIES_NZD,
   ENUM_CURRENCIES_USD,
   ENUM_CURRENCIES_CAD,
   ENUM_CURRENCIES_CHF,
   ENUM_CURRENCIES_JPY
  };
  
//+------------------------------------------------------------------+
//|         网格手数的计算类型                                       |
//+------------------------------------------------------------------+
enum GridLotsCalType
  {
   ENUM_GRID_LOTS_FIBONACCI,// Fibo数列(1,1,2,3...)
   ENUM_GRID_LOTS_FIBONACCI_1,// Fibo数列(1,2,3,5...)
   ENUM_GRID_LOTS_EXP,// 默认指数
   ENUM_GRID_LOTS_EXP15, // 第15个仓位为1
   ENUM_GRID_LOTS_EXP20, // 第20个仓位为1
   ENUM_GRID_LOTS_GEMINATION,// 双倍手数
   ENUM_GRID_LOTS_EXP_NUM,// 第n个仓位为1手
   ENUM_GRID_LOTS_FBS,// 同FBS账户一致
   ENUM_GRID_LOTS_LINEAR,   // 线性序列
   ENUM_GRID_LOTS_CONST,   //常数序列
   ENUM_GRID_LOTS_LINEAR_STEP_N,  // 线性序列，步长指定(N*0.01)
   ENUM_GRID_LOTS_EXP_FILTER_5,    // 过滤5波网格后指数增长
   ENUM_GRID_LOTS_EXP_FILTER_10    // 过滤10波网格后指数增长
  };
  
//+------------------------------------------------------------------+
//|            根据不同的方式计算对应手数                            |
//+------------------------------------------------------------------+
double CalGridLots(int num_pos,double base_l,GridLotsCalType lots_type,int num_pos_1=15)
  {
   double pos_lots=base_l;
   double alpha,beta;
   switch(lots_type)
     {
      case ENUM_GRID_LOTS_EXP :
         pos_lots=NormalizeDouble(base_l*0.7*exp(0.4*num_pos),2);
         break;
      case ENUM_GRID_LOTS_EXP15:
         pos_lots=NormalizeDouble(base_l*0.7197*exp(0.3289*num_pos),2);
         break;
      case ENUM_GRID_LOTS_EXP20:
         pos_lots=NormalizeDouble(base_l*0.7848*exp(0.2424*num_pos),2);
         break;
      case ENUM_GRID_LOTS_FIBONACCI:
         pos_lots=NormalizeDouble(base_l*(1/sqrt(5)*(MathPow((1+sqrt(5))/2,num_pos)-MathPow((1-sqrt(5))/2,num_pos))),2);
         break;
      case ENUM_GRID_LOTS_FIBONACCI_1:
         pos_lots=NormalizeDouble(base_l*(1/sqrt(5)*(MathPow((1+sqrt(5))/2,num_pos+1)-MathPow((1-sqrt(5))/2,num_pos+1))),2);
         break;
      case ENUM_GRID_LOTS_GEMINATION:
         pos_lots=NormalizeDouble(base_l*MathPow(2,num_pos),2);
         break;
      case ENUM_GRID_LOTS_EXP_NUM:
         beta=MathLog(100)/(num_pos_1-1);
         alpha=1/MathExp(beta);
         pos_lots=NormalizeDouble(base_l*alpha*exp(beta*num_pos),2);
         break;
      case ENUM_GRID_LOTS_FBS:
         pos_lots=NormalizeDouble(base_l*0.76*exp(0.2628*num_pos),2);
         break;
      case ENUM_GRID_LOTS_LINEAR:
         pos_lots=NormalizeDouble(base_l*num_pos,2);
         break;
      case ENUM_GRID_LOTS_CONST:
         pos_lots=NormalizeDouble(base_l,2);
         break;
      case ENUM_GRID_LOTS_LINEAR_STEP_N:
         pos_lots=NormalizeDouble(0.01*num_pos_1*num_pos+base_l,2);
         break; 
      case ENUM_GRID_LOTS_EXP_FILTER_5:
         beta=MathLog(100)/(num_pos_1-1);
         alpha=1/MathExp(beta);
         pos_lots=num_pos<=5?0.01:NormalizeDouble(base_l*alpha*exp(beta*(num_pos-5)),2);
         break; 
      case ENUM_GRID_LOTS_EXP_FILTER_10:
         beta=MathLog(100)/(num_pos_1-1);
         alpha=1/MathExp(beta);
         pos_lots=num_pos<=10?0.01:NormalizeDouble(base_l*alpha*exp(beta*(num_pos-10)),2);
         break; 
      default:
         break;
     }
   return pos_lots;
  }
//+------------------------------------------------------------------+
