//+------------------------------------------------------------------+
//|                                                   Strategy_1.mq5 |
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
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+
input string               Inp_EaComment="Strategy #1";                 //EA Comment
input double               Inp_Lot=0.01;                                //Lot
input MarginMode           Inp_MMode=LOT;                               //MM
input  int                 Inp_MagicNum=1111;                           //Magic number
input int                  Inp_StopLoss=400;                            //Stop Loss(points)
input int                  Inp_TakeProfit=600;                          //Take Profit(points)
input int                  Inp_Deviation = 20;                          //Deviation(points)

//--- RSI_Color indicator parameters

input int                  Inp_RSIPeriod=11;                            //RSI Period
input double               Inp_Overbuying=70;                           //Overuying zone
input double               Inp_Overselling=30;                          //Overselling zone
//--- ADX_Cloud indicator parameters

input int                  Inp_ADXPeriod=8;                             //ADX Period
input double               Inp_alpha1 = 0.25;                           //alpha1
input double               Inp_alpha2 = 0.25;                           //alpha2
//---

int InpInd_Handle1,InpInd_Handle2;
double adx[],rsi1[],rsi2[];
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

//--- Getting the handle of the RSI Color indicator
   InpInd_Handle1=iCustom(Symbol(),PERIOD_H1,"10Trend\\rsi_color",Inp_RSIPeriod,Inp_Overbuying,Inp_Overselling);
   if(InpInd_Handle1==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get rsi_color handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- Getting the handle of the ADX Cloud indicator
   InpInd_Handle2=iCustom(Symbol(),PERIOD_H1,"10Trend\\adxcloud",Inp_ADXPeriod,Inp_alpha1,Inp_alpha2);
   if(InpInd_Handle2==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get adxcloud handle");
      Print("Handle = ",InpInd_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//--- 
   ArrayInitialize(adx,0.0);
   ArrayInitialize(rsi1,0.0);
   ArrayInitialize(rsi2,0.0);

   ArraySetAsSeries(rsi1,true);
   ArraySetAsSeries(rsi2,true);
   ArraySetAsSeries(adx,true);
   return(INIT_SUCCEEDED);
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
   return(adx[0]>0 && adx[1]<0 && rsi1[0]==1)?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(adx[0]<0 && adx[1]>0 && rsi2[0]==1)?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle1,0,0,2,rsi1)<=0 ||
          CopyBuffer(InpInd_Handle1,1,0,2,rsi2)<=0 ||
          CopyBuffer(InpInd_Handle2,0,0,2,adx)<=0
          )?false:true;
  }
//+------------------------------------------------------------------+
