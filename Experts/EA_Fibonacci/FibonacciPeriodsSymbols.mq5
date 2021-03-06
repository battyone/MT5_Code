//+------------------------------------------------------------------+
//|                               FibonacciMultiSymbolMultiLevel.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\Fibonacci.mqh>
#include <Strategy\StrategiesList.mqh>

input int period_search_mode=12;   //搜素模式的大周期
input int range_period=4; //模式的最大数据长度
input int range_point_short=500; //短周期模式的最小点数差
input int range_point_long=1000;//长周期模式的最小点数差

input double open_level1=0.618; //开仓点
input double open_level2=0.5; //开仓点
input double open_level3=0.382; //开仓点

input double tp_level1=0.882; //止盈平仓点
input double tp_level2=0.786; //止盈平仓点
input double tp_level3=0.618; //止盈平仓点

input double sl_level1=-1.0; //止损平仓点
input double sl_level2=-1.0; //止损平仓点
input double sl_level3=-1.0; //止损平仓点

input double open_lots1=0.01; //开仓手数
input double open_lots2=0.01; //开仓手数
input double open_lots3=0.02; //开仓手数

input double lots_ratio=1.0;// 长周期下单相对于短周期的手数倍数
input ENUM_TIMEFRAMES short_period=PERIOD_H1;//短周期
input ENUM_TIMEFRAMES long_period=PERIOD_D1;//长周期
input int EA_MAGIC=11805100;
input string Inp_Symbols_enable="1,1,1,1,1,1,1";// EURUSD,GBPUSD,AUDUSD,NZDUSD,USDCAD,USDCHF,USDJPY


CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {  
   double level_open[3],level_win[3],level_loss[3],level_lots[3];
   level_open[0]=open_level1;
   level_open[1]=open_level2;
   level_open[2]=open_level3;
   level_win[0]=tp_level1;
   level_win[1]=tp_level2;
   level_win[2]=tp_level3;
   level_loss[0]=sl_level1;
   level_loss[1]=sl_level2;
   level_loss[2]=sl_level3;
   level_lots[0]=open_lots1;
   level_lots[1]=open_lots2;
   level_lots[2]=open_lots3;
   
   string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   string symbol_enable[];
   StringSplit(Inp_Symbols_enable,StringGetCharacter(",",0),symbol_enable); 
   ENUM_TIMEFRAMES periods_arr[2];
   periods_arr[0]=short_period;
   periods_arr[1]=long_period;
   
   int mode_points_range[2];
   mode_points_range[0]=range_point_short;
   mode_points_range[1]=range_point_long; 
   
   double period_lots_ratio[2];
   period_lots_ratio[0]=1;
   period_lots_ratio[1]=lots_ratio;
   
   int num_symbol=ArraySize(symbols);
   FibonacciRatioStrategy *strategy[7][2][3];
   for(int i=0;i<num_symbol;i++)
     {
      for(int j=0;j<2;j++)
        {
         for(int k=0;k<3;k++)
           {
            strategy[i][j][k]=new FibonacciRatioStrategy();
            strategy[i][j][k].ExpertMagic(EA_MAGIC+i*100+j*10+k*1);
            strategy[i][j][k].Timeframe(periods_arr[j]);
            strategy[i][j][k].ExpertSymbol(symbols[i]);
            strategy[i][j][k].ExpertName("FiboRatio_"+symbols[i]+"_"+EnumToString(periods_arr[j])+"_Level"+string(k+1));
            strategy[i][j][k].SetPatternParameter(period_search_mode,range_period,mode_points_range[j]);
            strategy[i][j][k].SetOpenRatio(level_open[k]);
            strategy[i][j][k].SetCloseRatio(level_win[k],level_loss[k]);
            strategy[i][j][k].SetLots(level_lots[k]*period_lots_ratio[j]);
            strategy[i][j][k].SetEventDetect(symbols[i],periods_arr[j]);
            strategy[i][j][k].ReInitPositions();
            if(StringToInteger(symbol_enable[i]))
              {
               Manager.AddStrategy(strategy[i][j][k]);
              }
            
           }
        }
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
