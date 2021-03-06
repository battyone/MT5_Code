//+------------------------------------------------------------------+
//|                                                 ArbSynthetic.mq5 |
//|                                   Copyright 2016, Dmitrievsky Max|
//|                        https://www.mql5.com/ru/users/dmitrievsky |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Dmitrievsky Max."
#property link      "https://www.mql5.com/ru/users/dmitrievsky"
#property version   "1.01"
#property strict

#include <Trade\Trade.mqh>        
#include <Trade\PositionInfo.mqh> 
#include <Trade\AccountInfo.mqh>

CTrade            m_Trade;
CPositionInfo     m_Position;
CAccountInfo myaccount;
CPositionInfo myposition;

input int spread=35;      //Spread deviations in points (between synthetic and base pair)
input long delay=1000;    //Delays in milliseconds (between synthetic and base pair)
input int checkout=5000;  //Check signal every (ms)
input string ettings="MONEY MANAGEMENT SETTINGS";
input string SymbolSuffix="";
input int MaximumSpread = 30;
input int StopLoss=250;
input double MaximumRisk=0.01;

int PricesDOM = 5;
double MedianEURUSD, MedianGBPUSD, MedianEURGBP, MedianSynthetic, 
       Diff, EURdiff, GBPdiff, GBPsynthetic, EURsynthetic, 
       DiffMax, DiffMin, EurDiffMax, EurDiffMin, GbpDiffMax, GbpDiffMin; 
long msTime,esTime,gsTime,mEur,mGbp,mEurGbp,timeDiff,timeEurDiff,timeGbpDiff;

MqlTick tickEUR,tickGBP,tickEURGBP;


int OnInit()
  {
   
   EventSetMillisecondTimer(checkout);  
//---
   GetSymbolByName("EURUSD"+SymbolSuffix);  //выбираем символы в "обзоре рынка" если они отсутствуют
   GetSymbolByName("GBPUSD"+SymbolSuffix);
   GetSymbolByName("EURGBP"+SymbolSuffix);
  
   ObjectCreate(0,"MedianMainLine",OBJ_HLINE,0,0,MedianEURGBP);
   ObjectSetInteger(0,"MedianMainLine",OBJPROP_COLOR,clrOrangeRed);
   ObjectSetInteger(0,"MedianMainLine",OBJPROP_STYLE,4);
   ObjectSetInteger(0,"MedianMainLine",OBJPROP_BACK,true);
   
   ObjectCreate(0,"SyntheticLine",OBJ_HLINE,0,0,MedianSynthetic);
   ObjectSetInteger(0,"SyntheticLine",OBJPROP_COLOR,Blue);
   ObjectSetInteger(0,"SyntheticLine",OBJPROP_STYLE,4);
   ObjectSetInteger(0,"SyntheticLine",OBJPROP_BACK,true);
    
   ObjectCreate(0,"BuyPrice",OBJ_ARROW_RIGHT_PRICE,0,TimeCurrent(),MedianEURGBP+spread*_Point);
   ObjectSetInteger(0,"BuyPrice",OBJPROP_COLOR,clrOrangeRed);
   ObjectSetInteger(0,"BuyPrice",OBJPROP_WIDTH,1);
    
   ObjectCreate(0,"SellPrice",OBJ_ARROW_RIGHT_PRICE,0,TimeCurrent(),MedianEURGBP-spread*_Point);
   ObjectSetInteger(0,"SellPrice",OBJPROP_COLOR,clrOrangeRed);
   ObjectSetInteger(0,"SellPrice",OBJPROP_WIDTH,1);
//---
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
 {
  EventKillTimer();
  ObjectDelete(0,"MedianMainLine");
  ObjectDelete(0,"SyntheticLine");
  ObjectDelete(0,"BuyPrice");
  ObjectDelete(0,"SellPrice");
 }
  
void OnTimer()
  {    
   if(!SymbolInfoTick("EURUSD"+SymbolSuffix,tickEUR)) {Print("EURUSD price has not been received"); return;}
   if(!SymbolInfoTick("GBPUSD"+SymbolSuffix,tickGBP)) {Print("GBPUSD price has not been received"); return;}
   if(!SymbolInfoTick("EURGBP"+SymbolSuffix,tickEURGBP)) {Print("EURGBP price has not been received"); return;}
  
   if(tickEUR.ask!=0 && tickEUR.bid!=0)  //получаем котировки по каждому из символов, рассчитываем среднюю цену
    {
     if(MedianEURUSD!=NormalizeDouble(tickEUR.ask-(tickEUR.ask-tickEUR.bid)/2,_Digits)) 
      {
       MedianEURUSD=NormalizeDouble(tickEUR.ask-(tickEUR.ask-tickEUR.bid)/2,_Digits);
       mEur=tickEUR.time_msc;
      }
    } else return; 
    
   if(tickGBP.ask!=0 && tickGBP.bid!=0)
    {
     if(MedianGBPUSD!=NormalizeDouble(tickGBP.ask-(tickGBP.ask-tickGBP.bid)/2,_Digits))
      { 
       MedianGBPUSD=NormalizeDouble(tickGBP.ask-(tickGBP.ask-tickGBP.bid)/2,_Digits);
       mGbp=tickGBP.time_msc;
      }
    } else return;
    
   if(tickEURGBP.ask!=0 && tickEURGBP.bid!=0) 
    {
     if(MedianEURGBP!=NormalizeDouble(tickEURGBP.ask-(tickEURGBP.ask-tickEURGBP.bid)/2,_Digits)) 
      {
       MedianEURGBP=NormalizeDouble(tickEURGBP.ask-(tickEURGBP.ask-tickEURGBP.bid)/2,_Digits);
       mEurGbp=tickEURGBP.time_msc;
      }
    } else return;
   
   if(MedianSynthetic!=NormalizeDouble(MedianEURUSD/MedianGBPUSD,_Digits)) //если средние цены по инструменту изменились, сохраняем новую цену и ее время
    {
     MedianSynthetic=NormalizeDouble(MedianEURUSD/MedianGBPUSD,_Digits);  
     if(tickEUR.time_msc<tickGBP.time_msc) msTime=tickEUR.time_msc; else msTime=tickGBP.time_msc;
    }
   if(EURsynthetic!=NormalizeDouble(MedianGBPUSD*MedianEURGBP,_Digits))
    {
     EURsynthetic=NormalizeDouble(MedianGBPUSD*MedianEURGBP,_Digits);
     if(tickEURGBP.time_msc<tickGBP.time_msc) esTime=tickEURGBP.time_msc; else esTime=tickGBP.time_msc;
    }
   if(GBPsynthetic!=NormalizeDouble(MedianEURUSD/MedianEURGBP,_Digits))
    {
     GBPsynthetic=NormalizeDouble(MedianEURUSD/MedianEURGBP,_Digits);
     if(tickEURGBP.time_msc<tickEUR.time) gsTime=tickEURGBP.time_msc; else gsTime=tickEUR.time_msc;
    }
   
   Diff=NormalizeDouble(MedianSynthetic-MedianEURGBP,_Digits); //счтаем разницу между валютными парами и их синтетиками
   EURdiff=NormalizeDouble(EURsynthetic-MedianEURUSD,_Digits);
   GBPdiff=NormalizeDouble(GBPsynthetic-MedianGBPUSD,_Digits);
   timeDiff=msTime-mEurGbp;
   timeEurDiff=esTime-mEur;
   timeGbpDiff=gsTime-mGbp;
   
   if(Diff>DiffMax)DiffMax=Diff;             //рассчитываем минимиальные и максиальне исторические отклонения
   if(EURdiff>EurDiffMax)EurDiffMax=EURdiff;
   if(GBPdiff>GbpDiffMax)GbpDiffMax=GBPdiff;
   if(Diff<DiffMin)DiffMin=Diff;
   if(EURdiff<EurDiffMin)EurDiffMin=EURdiff;
   if(GBPdiff<GbpDiffMin)GbpDiffMin=GBPdiff;
          
   TradeFunc("EURGBP"+SymbolSuffix,Diff,timeDiff,spread,delay);      //проверяем торговые сигалы для каждой пары
   TradeFunc("EURUSD"+SymbolSuffix,EURdiff,timeEurDiff,spread,delay);
   TradeFunc("GBPUSD"+SymbolSuffix,GBPdiff,timeGbpDiff,spread,delay);
   
   ObjectMove(0,"MedianMainLine",0,0,MedianEURGBP);
   ObjectMove(0,"SyntheticLine",0,0,MedianSynthetic);
   ObjectMove(0,"BuyPrice",0,TimeCurrent(),MedianEURGBP+spread*_Point);
   ObjectMove(0,"SellPrice",0,TimeCurrent(),MedianEURGBP-spread*_Point);
   
   Comment("EURGBP difference: "+DoubleToString(Diff/_Point,0),"   ", "MAX: "+DoubleToString(DiffMax/_Point,0),"   ","MIN: "+DoubleToString(DiffMin/_Point,0),"   ", "Delay:"+" "+string(timeDiff),"\n",
           "EURUSD difference: "+DoubleToString(EURdiff/_Point,0),"   ", "MAX: "+DoubleToString(EurDiffMax/_Point,0),"   ","MIN: "+DoubleToString(EurDiffMin/_Point,0),"   ", "Delay:"+" "+string(timeEurDiff),"\n",
           "GBPUSD difference: "+DoubleToString(GBPdiff/_Point,0),"   ", "MAX: "+DoubleToString(GbpDiffMax/_Point,0),"   ","MIN: "+DoubleToString(GbpDiffMin/_Point,0),"   ", "Delay:"+" "+string(timeGbpDiff),"\n");
  }

void TradeFunc(string symbol, double diff, long time, int Spread, long timedif) //ф-я проверяет наличие сигнала по каждому иснтрументу и открывает сделки
  {
    if(diff>0)
     {
      int stp = StopLoss;
      double Lot=LotsOptimized();  
      double priceBuy=SymbolInfoDouble(symbol,SYMBOL_ASK);
      double stoploss = NormalizeDouble(priceBuy-stp*_Point,_Digits);
      long stoplvl = SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
      if(stp<stoplvl) stoploss=NormalizeDouble(priceBuy-stoplvl*_Point,_Digits);
      if(m_Position.Select(symbol))
        { 
         if(m_Position.PositionType()==POSITION_TYPE_SELL && m_Position.Profit()+m_Position.Commission()>0) m_Trade.PositionClose(symbol);
        }  
      if(diff>Spread*0.00001 && time>timedif && SufficiencyOfEquity())  
      {
      if(CountPosBuy(symbol)==0 && CountPosSell(symbol)==0) 
       {
        if(SymbolInfoInteger(symbol,SYMBOL_SPREAD)<MaximumSpread && StopLoss>stoplvl) m_Trade.PositionOpen(symbol,ORDER_TYPE_BUY,Lot,priceBuy,stoploss,0,"Diff: "+DoubleToString(diff/_Point,0)+" Delay: "+string(timedif));    
        else Print("Current spread on "+ symbol+" " + string(SymbolInfoInteger(symbol,SYMBOL_SPREAD)) +" more than MaximumSpread:"+" "+ (string)MaximumSpread+" "+ "deal aborted.");    
       } 
      }
     }
     
   if(diff<0)
     {
      int stp = StopLoss;
      double Lot=LotsOptimized();
      double priceSell=SymbolInfoDouble(symbol,SYMBOL_BID);
      double stoploss = NormalizeDouble(priceSell+stp*_Point,_Digits);
      long stoplvl = SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
      if(stp<stoplvl) stoploss=NormalizeDouble(priceSell+stoplvl*_Point,_Digits);
       if(m_Position.Select(symbol))
        { 
         if(m_Position.PositionType()==POSITION_TYPE_BUY && m_Position.Profit()+m_Position.Commission()>0) m_Trade.PositionClose(symbol);
        } 
       if(diff<Spread*0.00001*-1 && time<timedif*-1 && SufficiencyOfEquity())
       { 
       if(CountPosSell(symbol)==0 && CountPosBuy(symbol)==0) 
        {
         if(SymbolInfoInteger(symbol,SYMBOL_SPREAD)<MaximumSpread) m_Trade.PositionOpen(symbol,ORDER_TYPE_SELL,Lot,priceSell,stoploss,0,"Diff: "+DoubleToString(diff/_Point,0)+" Delay: "+string(timedif));   
         else Print("Current spread on "+ symbol+" "+ string(SymbolInfoInteger(symbol,SYMBOL_SPREAD)) +" more than MaximumSpread:"+" " +(string)MaximumSpread +" " + "deal aborted."); 
        }
       }
     }
  }
     
double LotsOptimized()
  {
   double lot;
//---- select lot size
   lot=NormalizeDouble(myaccount.FreeMargin()*MaximumRisk/1000.0,1);
//---- return lot size
   if(lot<0.01) lot=0.01;
   if(lot>90) lot=90;
   return(lot);
  }
  
int CountPosBuy(string symbol)
  {
   int result=0;
   for(int k=0; k<PositionsTotal(); k++)
     {
      if(myposition.Select(symbol)==true)
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {result++;}
         else
           {}
        }
     }
    return(result);
   }

int CountPosSell(string symbol)
     {
      int result=0;
      for(int k=0; k<PositionsTotal(); k++)
        {
         if(myposition.Select(symbol)==true)
           {
            if(myposition.PositionType()==POSITION_TYPE_SELL)
              {result++;}
            else
              {}
           }
         }
       return(result);
      }

//+------------------------------------------------------------------+
//| Добавляет указанный символ в окно "Обзор рынка"                  |
//+------------------------------------------------------------------+
string GetSymbolByName(string symbol)
  {
   string symbol_name="";   // Имя символа на сервере
//--- Если передали пустую строку, вернем пустую строку
   if(symbol=="")
      return("");
//--- Пройтись по списку всех символов на сервере
   for(int s=0; s<SymbolsTotal(false); s++)
     {
      //--- Получим имя символа
      symbol_name=SymbolName(s,false);
      //--- Если искомый символ есть на сервере
      if(symbol==symbol_name)
        {
         //--- Выберем его в окне "Обзор рынка"
         SymbolSelect(symbol,true);
         //--- Вернем имя символа
         return(symbol);
        }
     }
//--- Если искомого символа нет, вернем пустую строку
   Print("Символ "+symbol+" не найден на сервере!");
   return("");
  }
  
bool SufficiencyOfEquity()
  {
   if(100000*LotsOptimized()/AccountInfoInteger(ACCOUNT_LEVERAGE)*SymbolInfoDouble(_Symbol,SYMBOL_BID) < myaccount.FreeMargin()) return(true);
   else return(false);
  }