//+------------------------------------------------------------------+
//|                                                 Combination2.mq5 |
//|                                             Copyright 2018, DNG® |
//|                                 http://www.mql5.com/en/users/dng |
//+------------------------------------------------------------------+
//--- The library of trade functions
#include "Trade.mqh" 
CTradeBase Trade;
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
//--- Common parameters
input double               Inp_Lot=0.01;                          //Lot
input MarginMode           Inp_MMode=LOT;                         //MM
input int                  Inp_MagicNum=1111;                     //Magic number
input int                  Inp_Deviation = 2;                     //Deviation(points)
//---
input string               Trend_EaComment="Trend Strategy";      //Strategy Comment
input int                  Trend_StopLoss=25;                     //Stop Loss(points)
input int                  Trend_TakeProfit=90;                   //Take Profit(points)
//--- RSI_Color indicator parameters
input int                  Trend_RSIPeriod=28;                    //RSI Period
input double               Trend_Overbuying=70;                   //Overbuying zone
input double               Trend_Overselling=30;                  //Overselling zone
//--- ADX_Cloud indicator parameters
input int                  Trend_ADXPeriod=11;                    //ADX Period
input double               Trend_alpha1 = 0.25;                   //alpha1
input double               Trend_alpha2 = 0.25;                   //alpha2
//---
input string               Flat_EaComment="Flat Strategy";        //Strategy Comment
input int                  Flat_StopLoss=50;                      //Stop Loss(points)
input int                  Flat_TakeProfit=50;                    //Take Profit(points)
//--- WPR indicator parameters
input int                  Flat_WPRPeriod=7;                      //Period WPR
//--- ADX indicator parameter
input int                  Flat_ADXPeriod=11;                     //Period ADX
input int                  Flat_FlatLevel=40;                     //Flat Level ADX
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TrendInd_Handle1,TrendInd_Handle2;
double trend_adx[],trend_rsi1[],trend_rsi2[];
//---
int FlatInd_Handle1,FlatInd_Handle2;
double flat_wpr[],flat_adx[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Checking connection to a trade server
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print(Trend_EaComment,": No Connection!");
      return(INIT_FAILED);
     }
//--- Checking if automated trading is enabled
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Print(Trend_EaComment,": Trade is not allowed!");
      return(INIT_FAILED);
     }
   Trade.SetMM(Inp_MMode);
   Trade.SetDeviation(Inp_Deviation);
//--- Trend Init
//--- Getting the handle of the RSI Color indicator
   TrendInd_Handle1=iCustom(Symbol(),PERIOD_H1,"\\10Trend\\rsi_сolor.ex5",Trend_RSIPeriod,Trend_Overbuying,Trend_Overselling);
   if(TrendInd_Handle1==INVALID_HANDLE)
     {
      Print(Trend_EaComment,": Failed to get rsi_color handle");
      Print("Handle = ",TrendInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Getting the handle of the ADX Cloud indicator
   TrendInd_Handle2=iCustom(Symbol(),PERIOD_H1,"\\10Trend\\adxcloud.ex5",Trend_ADXPeriod,Trend_alpha1,Trend_alpha2);
   if(TrendInd_Handle2==INVALID_HANDLE)
     {
      Print(Trend_EaComment,": Failed to get adxcloud handle");
      Print("Handle = ",TrendInd_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- 
   ArrayInitialize(trend_adx,0.0);
   ArrayInitialize(trend_rsi1,0.0);
   ArrayInitialize(trend_rsi2,0.0);

   ArraySetAsSeries(trend_rsi1,true);
   ArraySetAsSeries(trend_rsi2,true);
   ArraySetAsSeries(trend_adx,true);
//--- Flat Init
//--- Getting the handle of the WPR indicator
   FlatInd_Handle1=iWPR(Symbol(),PERIOD_CURRENT,Flat_WPRPeriod);

   if(FlatInd_Handle1==INVALID_HANDLE)
     {
      Print(Flat_EaComment,": Failed to get WPR handle");
      Print("Handle = ",FlatInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Getting the handle of the ADX indicator
   FlatInd_Handle2=iADX(Symbol(),PERIOD_CURRENT,Flat_ADXPeriod);
   if(FlatInd_Handle2==INVALID_HANDLE)
     {
      Print(Flat_EaComment,": Failed to get ADX handle");
      Print("Handle = ",FlatInd_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//---
   ArrayInitialize(flat_wpr,0.0);
   ArrayInitialize(flat_adx,0.0);

   ArraySetAsSeries(flat_wpr,true);
   ArraySetAsSeries(flat_adx,true);
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
//--- Checking orders previously opened by the EA
   if(!Trade.IsOpenedBySymbol(_Symbol,Inp_MagicNum))
     {
      //--- Getting data for calculations

      if(!GetIndValue())
         return;
      //--- Open orders using the trend algorithm
      //--- Open an order if there is a buy signal
      if(TrendBuySignal())
         Trade.BuyPositionOpen(Symbol(),Inp_Lot,Trend_StopLoss,Trend_TakeProfit,Inp_MagicNum,Trend_EaComment);
      else
      //--- Open an order if there is a sell signal
      if(TrendSellSignal())
         Trade.SellPositionOpen(Symbol(),Inp_Lot,Trend_StopLoss,Trend_TakeProfit,Inp_MagicNum,Trend_EaComment);
      else
      //--- Open orders using the flat algorithm
      //--- Open an order if there is a buy signal
      if(FlatBuySignal())
         Trade.BuyPositionOpen(Symbol(),Inp_Lot,Flat_StopLoss,Flat_TakeProfit,Inp_MagicNum,Flat_EaComment);
      else
      //--- Open an order if there is a sell signal
      if(FlatSellSignal())
         Trade.SellPositionOpen(Symbol(),Inp_Lot,Flat_StopLoss,Flat_TakeProfit,Inp_MagicNum,Flat_EaComment);
     }
  }
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool TrendBuySignal()
  {
   return(trend_adx[0]>trend_adx[1] && trend_rsi1[0]==1 && trend_rsi1[1]==1 &&  flat_adx[0]>=Flat_FlatLevel)?true:false;
  }
bool FlatBuySignal()
  {
   return(flat_wpr[0]<-80 && flat_adx[0]<Flat_FlatLevel && trend_rsi2[0]!=1)?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool TrendSellSignal()
  {
   return(trend_adx[0]<trend_adx[1] && trend_rsi2[0]==1 && trend_rsi2[1]==1 && flat_adx[0]>=Flat_FlatLevel)?true:false;
  }
bool FlatSellSignal()
  {
   return(flat_wpr[0]>-20 && flat_adx[0]<Flat_FlatLevel && trend_rsi1[0]!=1)?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current indicator values                             |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(TrendInd_Handle1,0,0,2,trend_rsi1)  <=0   ||
          CopyBuffer(TrendInd_Handle1,1,0,2,trend_rsi2)  <=0   ||
          CopyBuffer(TrendInd_Handle2,0,0,2,trend_adx)   <=0   ||
          CopyBuffer(FlatInd_Handle1,0,0,2,flat_wpr)     <=0   ||
          CopyBuffer(FlatInd_Handle2,0,0,2,flat_adx)     <=0
          )?false:true;
  }
//+------------------------------------------------------------------+
