//+------------------------------------------------------------------+
//|                                      XAUUSD_USDJPY_SUM_POINT.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "Close"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input string   forex_symbol="USDJPY";
//--- indicator buffers
double         CloseBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,CloseBuffer,INDICATOR_DATA);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[],
                )
  {
//--
   int i,limit;
   limit = 0;
   if(prev_calculated==0)
      limit=0;
   else 
      {
         limit=prev_calculated;
      }
   double  close_other_symbol[];
   CopyClose(forex_symbol,PERIOD_CURRENT,0,rates_total,close_other_symbol);
   int num_loss = rates_total-ArraySize(close_other_symbol);
   
   for(i=limit;i<rates_total;i++)
        {
         if(num_loss>0 && i<num_loss)
            CloseBuffer[i]=close_other_symbol[0];
         else
            CloseBuffer[i]=close_other_symbol[i-num_loss];
         //Print(i, " ", CloseBuffer[i], "in for");
        }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
