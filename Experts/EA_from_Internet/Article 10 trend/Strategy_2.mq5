//+------------------------------------------------------------------+
//|                                                   Strategy_2.mq5 |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Alexander Fedosov"
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.00"

//--- A library of trade function

#include "TradeFunctions.mqh" 

CTradeBase Trade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Trend
  {
   Middle=1,
   Maximum
  };
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
input string               Inp_EaComment="Strategy #2";                 //EA Comment
input double               Inp_Lot=0.01;                                //Lot
input MarginMode           Inp_MMode=LOT;                               //MM
input  int                 Inp_MagicNum=1111;                           //Magic number
input int                  Inp_StopLoss=400;                            //Stop Loss(points)
input int                  Inp_TakeProfit=600;                          //Take Profit(points)
input int                  Inp_Deviation = 20;                          //Deviation(points)

//--- ColorStDev indicator parameters

input int                  period = 12;                                 //Smoothing period StDev
input ENUM_MA_METHOD       MA_Method=MODE_EMA;                          //Histogram smoothing method
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE;                   //Applied price
input int                  MaxTrendLevel=90;                            //Maximum trend level
input int                  MiddLeTrendLevel=50;                         //Middle trend level
input int                  FlatLevel=20;                                //Flat level
input Trend                TrendLevel=Maximum;                          //Used trend
//--- Параметры индикатора ColorZerolagRVI

input uint                 smoothing=15;                                //Smoothing period RVI
input double               Factor1=0.05;                                //Weight coef.1
input int                  RVI_period1=14;                              //RVI Period 1
input double               Factor2=0.10;                                //Weight coef.2
input int                  RVI_period2=28;                              //RVI Period 2
input double               Factor3=0.16;                                //Weight coef.3
input int                  RVI_period3=45;                              //RVI Period 3
input double               Factor4=0.26;                                //Weight coef.4
input int                  RVI_period4=65;                              //RVI Period 4
input double               Factor5=0.43;                                //Weight coef.5
input int                  RVI_period5=75;                              //RVI Period 5

int InpInd_Handle1,InpInd_Handle2;
double stdev[],rvi_fast[],rvi_slow[];
int trend;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Checking connection to a trade server

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print(Inp_EaComment,": No Connection!");
      return(INIT_FAILED);
     }
//--- Checking if automated trading is enabled

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Print(Inp_EaComment,": Trade is not allowed!");
      return(INIT_FAILED);
     }
//--- Получение хэндла индикатора ColorStDev

   InpInd_Handle1=iCustom(Symbol(),PERIOD_H1,"10Trend\\colorstddev",
                          period,
                          MA_Method,
                          applied_price,
                          MaxTrendLevel,
                          MiddLeTrendLevel,
                          FlatLevel
                          );
   if(InpInd_Handle1==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get colorstddev handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Getting handle of the ColorZerolagRVI indicator

   InpInd_Handle2=iCustom(Symbol(),PERIOD_H1,"10Trend\\colorzerolagrvi",
                          smoothing,
                          Factor1,
                          RVI_period1,
                          Factor2,
                          RVI_period2,
                          Factor3,
                          RVI_period3,
                          Factor4,
                          RVI_period4,
                          Factor5,
                          RVI_period5
                          );
   if(InpInd_Handle2==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get colorzerolagrvi handle");
      Print("Handle = ",InpInd_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Defining the type of the used trend

   if(TrendLevel==1)
      trend=MiddLeTrendLevel;
   else if(TrendLevel==2)
      trend=MaxTrendLevel;
//---

   ArrayInitialize(stdev,0.0);
   ArrayInitialize(rvi_fast,0.0);
   ArrayInitialize(rvi_slow,0.0);

   ArraySetAsSeries(stdev,true);
   ArraySetAsSeries(rvi_fast,true);
   ArraySetAsSeries(rvi_slow,true);
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
//--- Checking orders previously opened by the EA
   if(!Trade.IsOpened(Inp_MagicNum))
     {
      //--- Getting data for calculations

      if(!GetIndValue())
         return;
      //--- Opening an order if there is a buy signal

      if(BuySignal())
         Trade.BuyPositionOpen(true,Symbol(),Inp_Lot,Inp_MMode,Inp_Deviation,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
      //--- Opening an order if there is a sell signal

      if(SellSignal())
         Trade.SellPositionOpen(true,Symbol(),Inp_Lot,Inp_MMode,Inp_Deviation,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
     }
  }
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   return(stdev[0]>trend && rvi_fast[0]>rvi_slow[0])?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(stdev[0]>trend && rvi_fast[0]<rvi_slow[0])?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle1,0,0,2,stdev)<=0 ||
          CopyBuffer(InpInd_Handle2,0,0,2,rvi_fast)<=0 ||
          CopyBuffer(InpInd_Handle2,1,0,2,rvi_slow)<=0
          )?false:true;
  }
//+------------------------------------------------------------------+
