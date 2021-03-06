//+------------------------------------------------------------------+
//|                                                    CisNewBar.mqh |
//|                                            Copyright 2010, Lizar |
//|                                               Lizar-2010@mail.ru |
//|                                              Revision 2010.09.27 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class CisNewBar.                                                 |
//| Appointment: Function class for determining appearance of new bar|
//+------------------------------------------------------------------+

class CisNewBar 
  {
   protected:
      datetime          m_lastbar_time;   // Opening time of the last bar

      string            m_symbol;         // Symbol name
      ENUM_TIMEFRAMES   m_period;         // Chart timeframe
      
      uint              m_retcode;        // Result code of detecting a new bar 
      int               m_new_bars;       // Number of new bars
      string            m_comment;        // Comment of execution
      
   public:
      void              CisNewBar();      // CisNewBar constructor      
      //--- Methods of access to protected data:
      uint              GetRetCode() const      {return(m_retcode);     }  // Result code of detecting a new bar 
      datetime          GetLastBarTime() const  {return(m_lastbar_time);}  // Opening time of the last bar
      int               GetNewBars() const      {return(m_new_bars);    }  // Number of new bars
      string            GetComment() const      {return(m_comment);     }  // Comment of execution
      string            GetSymbol() const       {return(m_symbol);      }  // Symbol name
      ENUM_TIMEFRAMES   GetPeriod() const       {return(m_period);      }  // Chart timeframe
      //--- Methods of initializing of protected data:
      void              SetLastBarTime(datetime lastbar_time){m_lastbar_time=lastbar_time;                            }
      void              SetSymbol(string symbol)             {m_symbol=(symbol==NULL || symbol=="")?Symbol():symbol;  }
      void              SetPeriod(ENUM_TIMEFRAMES period)    {m_period=(period==PERIOD_CURRENT)?Period():period;      }
      //--- Methods of a new bar detection:
      bool              isNewBar(datetime new_Time);                       // First type of request for a new bar.
      int               isNewBar();                                        // Second type of request for a new bar. 
  };
   
//+------------------------------------------------------------------+
//| CisNewBar constructor.                                           |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CisNewBar::CisNewBar()
  {
   m_retcode=0;         // Result code of detecting a new bar 
   m_lastbar_time=0;    // Opening time of the last bar
   m_new_bars=0;        // Number of new bars
   m_comment="";        // Comment of execution
   m_symbol=Symbol();   // Symbol name, by default the symbol of the current chart
   m_period=Period();   // Chart timeframe, by default the timeframe of the current chart    
  }

//+------------------------------------------------------------------+
//| First type of request for a new bar.                     |
//| INPUT:  newbar_time - time of opening of presumably a new bar    |
//| OUTPUT: true   - if new bar(s) has(ve) appeared                  |
//|         false  - if there is no new bar or in case of an error   |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CisNewBar::isNewBar(datetime newbar_time)
  {
   //--- Initialization of protected variables
   m_new_bars = 0;      // Number of new bars
   m_retcode  = 0;      // Result code of detecting a new bar: 0 - no error
   m_comment  =__FUNCTION__+" Successful check for a new bar";
   //---
   
   //--- To be sure check if the time of the presumably new bar m_newbar_time is less than the time of the last bar m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // If the new bar is older than the last bar, then print an error message
      m_comment=__FUNCTION__+" Synchronization error: time of previous bar "+TimeToString(m_lastbar_time)+
                                                  ", time of new bar request "+TimeToString(newbar_time);
      m_retcode=-1;     // Result code of detecting a new bar: return -1 - synchronization error
      return(false);
     }
   //---
        
   //--- if it's the first call 
   if(m_lastbar_time==0)
     {  
      m_lastbar_time=newbar_time; //--- set time of last bar and exit
      m_comment   =__FUNCTION__+" Initialization of lastbar_time="+TimeToString(m_lastbar_time);
      return(false);
     }   
   //---

   //--- Check for a new bar: 
   if(m_lastbar_time<newbar_time)       
     { 
      m_new_bars=1;               // Number of new bars
      m_lastbar_time=newbar_time; // remember time of last bar
      return(true);
     }
   //---
   
   //--- if we've reached this line, then the bar is not new; return false
   return(false);
  }

//+------------------------------------------------------------------+
//| Second type of request for a new bar.                     |
//| INPUT:  no.                                                      |
//| OUTPUT: m_new_bars - numbers of new bars                         |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CisNewBar::isNewBar()
  {
   datetime newbar_time;
   datetime lastbar_time=m_lastbar_time;
      
   //--- Request the opening time of the last bar:
   ResetLastError(); // Set value of predefined variable _LastError as zero.
   if(!SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE,newbar_time))
     { // If request has failed, print error message:
      m_retcode=GetLastError();  // Result code of detecting a new bar: write value of variable _LastError
      m_comment=__FUNCTION__+" Error when getting time of the last bar opening: "+IntegerToString(m_retcode);
      return(0);
     }
   //---
   
   //---Next use first type of request for a new bar, to complete analysis:
   if(!isNewBar(newbar_time)) return(0);
   
   //---Specify the number of new bars:
   m_new_bars=Bars(m_symbol,m_period,lastbar_time,newbar_time)-1;

   //--- if we've reached this line - then there is(are) new bar(s), return their number:
   return(m_new_bars);
  }
  