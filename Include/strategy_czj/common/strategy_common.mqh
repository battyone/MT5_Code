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