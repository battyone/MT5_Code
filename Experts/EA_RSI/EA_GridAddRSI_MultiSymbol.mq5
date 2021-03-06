//+------------------------------------------------------------------+
//|                                             EA_BreakPointRSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRSI\GridAddRSI.mqh>
#include <strategy_czj\common\symbols.mqh>


input int Inp_rsi_period=14; //RSI计算周期
input double Inp_rsi_up_open=70;//RSI开空阈值
input double Inp_rsi_down_open=30;//RSI开多阈值
input double Inp_lots_init=0.1;//初始手数
input int Inp_num_position=5;//最大持仓数
input int Inp_points_win1=100;//止盈点数1--达到RSI平仓阈值后的要求每手盈利点
input int Inp_points_win2=300;//止盈点数2--无论RSI平仓阈值是否达到每手的盈利点
input double Inp_rsi_up_close=50;//RSI平空阈值
input double Inp_rsi_down_close=50;//RSI平多阈值
input RSI_type Inp_rsi_type=ENUM_RSI_TYPE_5;//RSI计算类型
input int Inp_points_add=500;//加仓必须满足的回撤点数
input ENUM_SYMBOL_COMBINATION Inp_symbol_type=ENUM_SYMBOL_COMBINATION_MAJOR7;//品种组合类型
input string Inp_symbols="CADCHF,GBPNZD,AUDCAD,GBPUSD,EURGBP,AUDNZD,CHFJPY,GBPJPY,EURCAD,EURJPY";//自定义品种组合
input int EA_MAGIC=9000;//EA标识符
string symbols[];
CStrategyList Manager;
int symbol_num=SymbolsTotal(true);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string symbols_str;
   switch(Inp_symbol_type)
     {
      case ENUM_SYMBOL_COMBINATION_MAJOR7:
        symbols_str="GBPUSD,EURUSD,NZDUSD,AUDUSD,USDJPY,USDCAD,USDCHF";
        break;
      case ENUM_SYMBOL_COMBINATION_MAJOR28:
         symbols_str="AUDCAD,AUDCHF,AUDJPY,AUDNZD,AUDUSD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,EURUSD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,GBPUSD,NZDCAD,NZDCHF,NZDJPY,NZDUSD,USDCAD,USDCHF,USDJPY";
         break;
      case ENUM_SYMBOL_COMBINATION_CROSS21:
         symbols_str="AUDCAD,AUDCHF,AUDJPY,AUDNZD,CADCHF,CADJPY,CHFJPY,EURAUD,EURCAD,EURCHF,EURGBP,EURJPY,EURNZD,GBPAUD,GBPCAD,GBPCHF,GBPJPY,GBPNZD,NZDCAD,NZDCHF,NZDJPY";
         break;
      case ENUM_SYMBOL_COMBINATION_CROSS4:
         symbols_str="EURGBP,AUDCAD,EURCHF,AUDNZD";
         break;
      case ENUM_SYMBOL_COMBINATION_DEFINE:
         symbols_str=Inp_symbols;
      default:
        break;
     }
   symbol_num=StringSplit(symbols_str,StringGetCharacter(",",0),symbols);
   
   CGridAddRSIStrategy *rsi_s[];
   ArrayResize(rsi_s,symbol_num);
   for(int i=0;i<symbol_num;i++)
     {
      rsi_s[i]=new CGridAddRSIStrategy();
      rsi_s[i].ExpertName("RSI网格加仓策略-"+symbols[i]);
      rsi_s[i].ExpertMagic(EA_MAGIC+i);
      rsi_s[i].Timeframe(_Period);
      rsi_s[i].ExpertSymbol(symbols[i]);
      rsi_s[i].SetEventDetect(symbols[i],_Period);
      rsi_s[i].InitStrategy(Inp_rsi_period,
                            Inp_rsi_up_open,
                            Inp_rsi_down_open,
                            Inp_lots_init,
                            Inp_num_position,
                            Inp_points_win1,
                            Inp_points_win2,
                            Inp_rsi_up_close,
                            Inp_rsi_down_close,
                            Inp_rsi_type,
                            Inp_points_add);
      Manager.AddStrategy(rsi_s[i]);
      
     }
   
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
