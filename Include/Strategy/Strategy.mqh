//+------------------------------------------------------------------+
//|                                                     Strategy.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#property strict
#define SOURCE ("ID " + (string)ExpertMagic() + "  " + __FUNCTION__) 
#include <Object.mqh>
#include <XML\XMLBase.mqh>          // Work with XML
#include "Logs.mqh"                 // Logging
#include "PositionMT5.mqh"          // A class of common positions
#include "TradeEnvironment.mqh"     // A class for detecting changes in trading environment
#include "NewBarDetector.mqh"       // New bar detector
#include "NewTickDetector.mqh"      // New tick detector
#include "Series.mqh"               // Provides easy access to OHLCV of the data series
#include "TradeControl.mqh"         // Trading module with additional methods of control of open positions
#include "TradeState.mqh"           // Trading module with additional methods of control of open positions
#include "MoneyManagment.mqh"
#include "PendingOrders.mqh"
//+------------------------------------------------------------------+
//| Defiles the type of market event.                                |
//+------------------------------------------------------------------+
enum ENUM_MARKET_EVENT_TYPE
  {
   MARKET_EVENT_TICK,               // Arrival of a new tick for the current symbol
   MARKET_EVENT_BAR_OPEN,           // Opening of a new bar of the current instrument
   MARKET_EVENT_TIMER,              // Timer
   MARKET_EVENT_BOOK_EVENT          // Depth of Market change (including tick arrival).
  };
//+------------------------------------------------------------------+
//| Parameters of the event that caused method call.                 |
//+------------------------------------------------------------------+
struct MarketEvent
  {
   ENUM_MARKET_EVENT_TYPE type;     // Event type.
   ENUM_TIMEFRAMES   period;        // Timeframe of the chart the event belongs to (only for MARKET_EVENT_BAR_OPEN).
   string            symbol;        // Name of the symbol on which the event occurred. For all events except
                                    // MARKET_EVENT_BOOK_EVENT, symbol name corresponds to the current instrument.
  };
//+------------------------------------------------------------------+
//| Main statistics of open positions of the strategy (instance)     |
//+------------------------------------------------------------------+
struct PositionsStat
  {
   int               open_buy;                  // Total number of open positions of a Buy strategy
   int               open_sell;                 // Total number of open positions of a Sell strategy
   int               open_total;                // Total number of open positions of the strategy
   int               open_complex;              // The total number of complex positions belonging to this strategy
  };
//+------------------------------------------------------------------+
//| Basic class of the layer strategy.                               |
//+------------------------------------------------------------------+
class CStrategy : public CObject
  {
private:
   MarketEvent       m_event;                     // Last or current market event.
   ulong             m_last_changed;              // Time of the last change of trading environment in micro seconds since launch.
   uint              m_expert_magic;              // A unique ID of the Expert Advisor.
   string            m_expert_name;               // Expert Advisor name.
   string            m_expert_symbol;             // The symbol the EA is running on 
   ENUM_TIMEFRAMES   m_timeframe;                 // The timeframe of the strategy
   ENUM_TRADE_STATE  m_trade_state;               // EA's trading state.

   CTradeEnvironment m_environment;               // The trading environment of the portfolio.
   CArrayObj         m_bars_detecors;             // Contain new bar detectors.
   CArrayObj         m_ticks_detectors;           // Contain new tick detectors.

   void              RebuildPositions(void);
   void              CallInit(const MarketEvent &event);
   void              CallSupport(const MarketEvent &event);
   void              SpyEnvironment(void);
   virtual void      ExitByStopRegim(CPosition *pos);
   void              NewBarsDetect(void);
   void              NewTickDetect(void);
   void              InitSeries(string symbol,ENUM_TIMEFRAMES period);
   void              RecalcStatistic(PositionsStat &positions);
   int               LastWorkExpDay(MqlDateTime &dt);
protected:
   CTradeState       m_state;              // Returns the trading state.
   CArrayObj         ActivePositions;      // The list of COMMON active classical positions.
   CArrayObj         ComplexPositions;     // The list of COMMON complex positions consisting of many classical positions
   PositionsStat     positions;            // Statistics of the strategy's positions
   CTradeControl     Trade;                // Trading class (CStrategy has no trading logic).
   CArrayObj         Modules;              // Additional support modules
   static CLog*      Log;                  // EA logs
/* MQL4-type access to quotes */
   CTime             Time;
   COpen             Open;
   CHigh             High;
   CLow              Low;
   CClose            Close;
   CVolume           Volume;
   double            Ask(void);
   double            Bid(void);
   double            Last(void);
   int               Digits();
   string            GetCurrentContract(string symbol);
   bool              CheckCurrentSL(double sl,ENUM_POSITION_TYPE type);
   COrdersEnvironment PendingOrders;
/* Subscription to events "opening of a new bar" and "formation of a new tick" */
   bool              AddBarOpenEvent(string symbol,ENUM_TIMEFRAMES timeframe);
   bool              AddTickEvent(string symbol);
   void              CheckVolumes(void);
/* The EA must redraw its indicators when the symbol and timeframe change,
         for this it should monitor appropriate events
      */
   virtual void      OnSymbolChanged(string symbol);
   virtual void      OnTimeframeChanged(ENUM_TIMEFRAMES tf);
/* Trading functions to override */
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      InitComplexPos(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      OnEvent(const MarketEvent &event);
public:
   CMoneyManagment   MM;          // Money management module
   CTrailing*        Trailing;    // Trailing stop management module for all positions
                     CStrategy(void);
                     CStrategy(string symbol,string exp_name,uint magic,ENUM_TIMEFRAMES tf);
                    ~CStrategy(void);
/*Common properties*/
   static CStrategy *GetStrategy(string name);
   virtual bool      ParseXmlParams(CXmlElement *params);
   uint              ExpertMagic(void);
   void              ExpertMagic(uint ExpertMagic);
   string            ExpertName(void);
   void              ExpertName(string name);
   virtual string    ExpertNameFull(void);
   string            ExpertSymbol();
   void              ExpertSymbol(string symbol);
   void              Timeframe(ENUM_TIMEFRAMES period);
   ENUM_TIMEFRAMES   Timeframe(void);
   ENUM_TRADE_STATE  TradeState(void);
   void              TradeState(ENUM_TRADE_STATE state);

/*External management*/
   void              Buy(double vol);
   void              Sell(double vol);

/*Passing events*/
   void              OnTick(void);
   void              OnTimer(void);
   void              OnBookEvent(string symbol);
   virtual void OnTradeTransaction(const MqlTradeTransaction &trans,
                                   const MqlTradeRequest &request,
                                   const MqlTradeResult &result){;}
                                   virtual int  Compare(const CObject *node,const int mode=0) const;
   void              OnChartEvent(const int id,// event id:if id-CHARTEVENT_CUSTOM=0-"initialization" event
                                  const long&   lparam, // chart period
                                  const double& dparam, // price
                                  const string& sparam  // symbol
                                  );
    void ReInitPositions(void); //重新载入EA时，读取已有的仓位信息至ActivePositions                           
  };
/*Placing static variables*/
CLog             *CStrategy::Log;
//+------------------------------------------------------------------+
//| Basic class of the layer strategy.                               |
//+------------------------------------------------------------------+
CStrategy::CStrategy(void)
  {
   m_last_changed = 0;
   m_expert_magic = 0;
   m_timeframe=PERIOD_CURRENT;
   Log=CLog::GetLog();
  }
//+------------------------------------------------------------------+
//| Basic class with the required parameters.                        |
//+------------------------------------------------------------------+
CStrategy::CStrategy(string symbol,string exp_name,uint magic,ENUM_TIMEFRAMES tf)
  {
   m_last_changed=0;
   Log=CLog::GetLog();
   ExpertSymbol(symbol);
   ExpertName(exp_name);
   Timeframe(tf);
   ExpertMagic(magic);
  }
//+------------------------------------------------------------------+
//| Destructor. Deletes the trailing stop module if it is used       |
//+------------------------------------------------------------------+
CStrategy::~CStrategy(void)
  {
   if(CheckPointer(Trailing)!=POINTER_INVALID)
      delete Trailing;
  }
//+------------------------------------------------------------------+
//| If the basic symbol has changed, the Expert Advisor needs to     |
//| redraw its indicators and other internal data to work with       |
//| this symbol, for this it needs to override this handler          |
//| of symbol change                                                 |
//+------------------------------------------------------------------+
void CStrategy::OnSymbolChanged(string symbol)
  {
  }
//+------------------------------------------------------------------+
//| If the working timeframe has changed, the Expert Advisor needs   |
//| to redraw its indicators and other internal data to work         |
//| with this timeframe, for which it needs to override this         |
//| handler of timeframe change                                      |
//+------------------------------------------------------------------+
void CStrategy::OnTimeframeChanged(ENUM_TIMEFRAMES tf)
  {
  }
//+------------------------------------------------------------------+
//| Override the method using the strategy rule, which being met     |
//| a LONG position should be opened. The position opening should    |
//| also be performed straight in this method                        |
//| IN:                                                              |
//|   event - the  structure described the event, upon receipt       |
//|           of which the method was called.                        |
//+------------------------------------------------------------------+
void CStrategy::InitBuy(const MarketEvent &event)
  {
  }
//+------------------------------------------------------------------+
//| Override the method using the strategy rule, which being met     |
//| a SHORT position should be opened. The position opening should   |
//| also be performed straight in this method                        |
//| IN:                                                              |
//|   event - the  structure described the event, upon receipt       |
//|           of which the method was called.                        |
//+------------------------------------------------------------------+
void CStrategy::InitSell(const MarketEvent &event)
  {
  }
//+------------------------------------------------------------------+
//| Override the method using the strategy rule, which being met     |
//| a COMPLEX (or arbitrage) position should be opened.              |
//| The opening of the position should be performed                  |
//| right in this method                                             |              
//| IN:                                                              |
//|   event - the  structure described the event, upon receipt       |
//|           of which the method was called.                        |
//+------------------------------------------------------------------+
void CStrategy::InitComplexPos(const MarketEvent &event)
  {
  }
//+------------------------------------------------------------------+
//| Override the method using the strategy rule, which being met     |
//| you should close the LONG position passed as the second          |
//| parameter. The closing of position should also be performed      |
//| right in this method                                             |
//| IN:                                                              |
//|   event - the  structure described the event, upon receipt       |
//|           of which the method was called.                        |
//|   pos - the position that you need to manage.                    |
//+------------------------------------------------------------------+
void CStrategy::SupportBuy(const MarketEvent &event,CPosition *pos)
  {
  }
//+------------------------------------------------------------------+
//| Override the method using the strategy rule, which being met     |
//| you should close the SHORT position passed as the second         |
//| parameter. The closing of position should also be performed      |
//| right in this method                                             |
//| IN:                                                              |
//|   event - the  structure described the event, upon receipt       |
//|           of which the method was called.                        |
//|   pos - the position that you need to manage.                    |
//+------------------------------------------------------------------+
void CStrategy::SupportSell(const MarketEvent &event,CPosition *pos)
  {
  }
//+------------------------------------------------------------------+
//| Common event OnEvent.  Returns upon receipt of any event         |
//| irrespective of the trade mode and the EA settings.              |
//+------------------------------------------------------------------+  
void CStrategy::OnEvent(const MarketEvent &event)
  {
  }
//+------------------------------------------------------------------+
//| Delegates the child strategy to parse its specific               |
//| parameters found in the <Params> section                         |
//+------------------------------------------------------------------+
bool CStrategy::ParseXmlParams(CXmlElement *xmlParams)
  {
   string text="Found specific xml-settings, but "+ExpertName()+" strategy does not handle them. Override the method ParseXmlParams";
   CMessage *msg=new CMessage(MESSAGE_WARNING,SOURCE,text);
   Log.AddMessage(msg);
   return false;
  }
//+------------------------------------------------------------------+
//| Sets a unique identifier of the Expert Advisor.                  |
//+------------------------------------------------------------------+
void CStrategy::ExpertMagic(uint ExpertMagic)
  {
   m_expert_magic=ExpertMagic;
   Trade.SetExpertMagicNumber(m_expert_magic);
  }
//+------------------------------------------------------------------+
//| Returns the unique identifier of the EA.                         |
//+------------------------------------------------------------------+
uint CStrategy::ExpertMagic(void)
  {
   return m_expert_magic;
  }
//+------------------------------------------------------------------+
//| Returns the name of the Expert Advisor (the name must be         |
//| previously set by the EA using the appropriate method).          |
//+------------------------------------------------------------------+
string CStrategy::ExpertName(void)
  {
   return m_expert_name;
  }
//+------------------------------------------------------------------+
//| Using this method, the EA sets its name.                         |
//+------------------------------------------------------------------+
void CStrategy::ExpertName(string name)
  {
   m_expert_name=name;
  }
//+------------------------------------------------------------------+
//| Returns the full (unique) name of the EA.                        |
//| (This method must be overridden in the derived class)            |
//+------------------------------------------------------------------+
string CStrategy::ExpertNameFull(void)
  {
   return ExpertName();
  }
//+------------------------------------------------------------------+
//| Returns the working symbol of the EA.                            |
//+------------------------------------------------------------------+
string CStrategy::ExpertSymbol(void)
  {
   if(m_expert_symbol==NULL || m_expert_symbol=="")
      return _Symbol;
   return m_expert_symbol;
  }
//+------------------------------------------------------------------+
//| Sets the working symbol of the EA.                               |
//+------------------------------------------------------------------+
void CStrategy::ExpertSymbol(string symbol)
  {
   m_expert_symbol=GetCurrentContract(symbol);
   InitSeries(symbol,Timeframe());
   OnSymbolChanged(m_expert_symbol);
  }
//+------------------------------------------------------------------+
//| Returns Ask price.                                               |
//+------------------------------------------------------------------+
double CStrategy::Ask(void)
  {
   double ask = SymbolInfoDouble(ExpertSymbol(), SYMBOL_ASK);
   int digits = (int)SymbolInfoInteger(ExpertSymbol(), SYMBOL_DIGITS);
   ask=NormalizeDouble(ask,digits);
   return ask;
  }
//+------------------------------------------------------------------+
//| Returns Bid price.                                               |
//+------------------------------------------------------------------+
double CStrategy::Bid(void)
  {
   double bid = SymbolInfoDouble(ExpertSymbol(), SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(ExpertSymbol(), SYMBOL_DIGITS);
   bid=NormalizeDouble(bid,digits);
   return bid;
  }
//+------------------------------------------------------------------+
//| Returns Last price.                                              |
//+------------------------------------------------------------------+
double CStrategy::Last(void)
  {
   double last= SymbolInfoDouble(ExpertSymbol(),SYMBOL_LAST);
   int digits =(int)SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS);
   last=NormalizeDouble(last,digits);
   return last;
  }
//+------------------------------------------------------------------+
//| Returns the number of decimal places for the working             |
//| instrument                                                       |
//+------------------------------------------------------------------+
int CStrategy::Digits(void)
  {
   int digits=(int)SymbolInfoInteger(ExpertSymbol(),SYMBOL_DIGITS);
   return digits;
  }
//+------------------------------------------------------------------+
//| Called by the strategy manager upon the system event             |
//| 'new tick'.                                                |
//+------------------------------------------------------------------+
void CStrategy::OnTick(void)
  {
   NewTickDetect();
   NewBarsDetect();
  }
//+------------------------------------------------------------------+
//| Called by the strategy manager upon the system event             |
//| 'OnTimer'.                                                 |
//+------------------------------------------------------------------+
void CStrategy::OnTimer(void)
  {
   m_event.symbol=Symbol();
   m_event.type=MARKET_EVENT_TIMER;
   m_event.period=(ENUM_TIMEFRAMES)Period();
   OnEvent(m_event);
   CallSupport(m_event);
   CallInit(m_event);
   NewTickDetect();
   NewBarsDetect();
  }
//+------------------------------------------------------------------+
//| Called by the strategy manager upon the system event             |
//| 'OnBookEvent'.                                                   |
//+------------------------------------------------------------------+
void CStrategy::OnBookEvent(string symbol)
  {
   m_event.symbol=symbol;
   m_event.type=MARKET_EVENT_BOOK_EVENT;
   m_event.period=PERIOD_CURRENT;
   OnEvent(m_event);
   CallSupport(m_event);
   CallInit(m_event);
   NewTickDetect();
   NewBarsDetect();
  }
//+------------------------------------------------------------------+
//| On behalf of the EA, buy the volume of vol                       |
//+------------------------------------------------------------------+
void CStrategy::Buy(double vol)
  {
   Trade.Buy(vol,ExpertSymbol(),"hand buy");
  }
//+------------------------------------------------------------------+
//| On behalf of the EA, sell the volume of vol                      |
//+------------------------------------------------------------------+
void CStrategy::Sell(double vol)
  {
   Trade.Sell(vol,ExpertSymbol(),"hand sell");
  }
//+------------------------------------------------------------------+
//| Returns the current trading state of the EA.                     |
//+------------------------------------------------------------------+
ENUM_TRADE_STATE CStrategy::TradeState(void)
  {
   return m_trade_state;
  }
//+------------------------------------------------------------------+
//| Sets the current trading state of the EA.                        |
//+------------------------------------------------------------------+
void CStrategy::TradeState(ENUM_TRADE_STATE state)
  {
   if(state!=m_state.GetTradeState())
     {
      m_state.SetTradeState(D'00:00',D'23:59',ALL_DAYS_OF_WEEK,state);
      string text="The mode of the current strategy has been changed to "+EnumToString(m_state.GetTradeState())+
                  ". The changes will come into force at receipt of new events";
      CMessage *msg=new CMessage(MESSAGE_INFO,SOURCE,text);
      Log.AddMessage(msg);
     }
  }
//+------------------------------------------------------------------+
//| Calls position opening logic provided that the trading           |
//| state does not explicitly restrict this.                         |
//+------------------------------------------------------------------+
void CStrategy::CallInit(const MarketEvent &event)
  {
   m_trade_state=m_state.GetTradeState();
   if(m_trade_state == TRADE_STOP)return;
   if(m_trade_state == TRADE_WAIT)return;
   if(m_trade_state == TRADE_NO_NEW_ENTRY)return;
   SpyEnvironment();
   InitComplexPos(event);
   if(m_trade_state==TRADE_BUY_AND_SELL || m_trade_state==TRADE_BUY_ONLY)
      InitBuy(event);
   if(m_trade_state==TRADE_BUY_AND_SELL || m_trade_state==TRADE_SELL_ONLY)
      InitSell(event);
  }
//+------------------------------------------------------------------+
//| Calls position maintenance logic provided that the trading       |
//| state not equal to TRADE_WAIT                                   |
//+------------------------------------------------------------------+
void CStrategy::CallSupport(const MarketEvent &event)
  {
   m_trade_state=m_state.GetTradeState();
   if(m_trade_state == TRADE_WAIT)return;
   SpyEnvironment();
   for(int i=ActivePositions.Total()-1; i>=0; i--)
     {
      CPosition *pos=ActivePositions.At(i);
      if(pos.ExpertMagic()!=m_expert_magic)continue;
      if(pos.Symbol()!=ExpertSymbol())continue;
      if(CheckPointer(Trailing)!=POINTER_INVALID)
        {
         if(CheckPointer(pos.Trailing)==POINTER_INVALID)
           {
            pos.Trailing=Trailing.Copy();
            pos.Trailing.SetPosition(pos);
           }
         pos.Trailing.Modify();
         if(!pos.IsActive())
            continue;
        }
      if(pos.Direction()==POSITION_TYPE_BUY)
         SupportBuy(event,pos);
      else
         SupportSell(event,pos);
      if(m_trade_state==TRADE_STOP && pos.IsActive())
         ExitByStopRegim(pos);
     }
// Deleting pending orders when mode is changed
   if(PendingOrders.Total()>0 && (m_trade_state==TRADE_STOP || 
      m_trade_state==TRADE_BUY_ONLY || m_trade_state==TRADE_SELL_ONLY))
     {
      for(int p=PendingOrders.Total()-1; p>=0; p--)
        {
         CPendingOrder *pend=PendingOrders.GetOrder(p);
         if(!pend.IsMain(ExpertSymbol(),ExpertMagic()))continue;
         bool needDelete=m_trade_state==TRADE_STOP;
         // SELL_ONLY - deleting pending buy orders
         if(!needDelete)
           {
            needDelete=m_trade_state==TRADE_SELL_ONLY && 
                       (pend.Type() == ORDER_TYPE_BUY_STOP ||
                       pend.Type() == ORDER_TYPE_BUY_LIMIT);
                       }
         // BUY_ONLY - deleting pending sell orders
         if(!needDelete)
           {
            needDelete=m_trade_state==TRADE_BUY_ONLY && 
                       (pend.Type() == ORDER_TYPE_SELL_STOP ||
                       pend.Type() == ORDER_TYPE_SELL_LIMIT);
                       }
         if(needDelete)
            pend.Delete();
        }
     }
  }
//+------------------------------------------------------------------+
//| Tracks changes in the trading environment.                       |
//+------------------------------------------------------------------+
void CStrategy::SpyEnvironment(void)
  {
   if(m_environment.ChangeEnvironment())
     {
      printf(ExpertNameFull()+". Trading environment has changed. Rebuild the environment");
      RebuildPositions();
      RecalcStatistic(positions);
      m_environment.RememberEnvironment();
     }
  }
//+------------------------------------------------------------------+
//| Recalculates statistics of positions and fills in appropriate    |
//| structure.                                                       |
//+------------------------------------------------------------------+
void CStrategy::RecalcStatistic(PositionsStat &pos)
  {
   pos.open_buy=0;
   pos.open_sell=0;
   pos.open_total=0;
   pos.open_complex=0;
   for(int i=0; i<ActivePositions.Total(); i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()!=ExpertSymbol())continue;
      pos.open_total+=1;
      if(cpos.Direction()==POSITION_TYPE_BUY)
         pos.open_buy++;
      else
         pos.open_sell++;
     }
  }
//+------------------------------------------------------------------+
//| Rearranges lists of positions                                    |
//+------------------------------------------------------------------+
void CStrategy::RebuildPositions(void)
  {
   ActivePositions.Clear();
   ENUM_ACCOUNT_MARGIN_MODE mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(mode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      for(int i=0; i<PositionsTotal(); i++)
        {
         string symbol=PositionGetSymbol(i);
         PositionSelect(symbol);
         CPosition *pos=new CPosition();
         ActivePositions.Add(pos);
        }
     }
   else
     {
      for(int i=0; i<PositionsTotal(); i++)
        {
         ulong ticket=PositionGetTicket(i);
         PositionSelectByTicket(ticket);
         CPosition *pos=new CPosition();
         ActivePositions.Add(pos);
        }
     }
  }
//+------------------------------------------------------------------+
//| Sets working timeframe of the strategy.                          |
//+------------------------------------------------------------------+
void CStrategy::Timeframe(ENUM_TIMEFRAMES period)
  {
   m_timeframe=period;
   InitSeries(ExpertSymbol(),m_timeframe);
   OnTimeframeChanged(m_timeframe);
  }
//+------------------------------------------------------------------+
//| Returns working timeframe of strategy.                           |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES CStrategy::Timeframe(void)
  {
   return m_timeframe;
  }
//+------------------------------------------------------------------+
//| Sets OHLCV series for the current instrument and timeframe.      |
//+------------------------------------------------------------------+
void CStrategy::InitSeries(string symbol,ENUM_TIMEFRAMES period)
  {
   Time.Symbol(symbol);
   Time.Timeframe(period);
   Open.Symbol(symbol);
   Open.Timeframe(period);
   High.Symbol(symbol);
   High.Timeframe(period);
   Low.Symbol(symbol);
   Low.Timeframe(period);
   Close.Symbol(symbol);
   Close.Timeframe(period);
   Volume.Symbol(symbol);
   Volume.Timeframe(period);
  }
//+------------------------------------------------------------------+
//| Closes position by the Stop mode.                                |
//+------------------------------------------------------------------+
void CStrategy::ExitByStopRegim(CPosition *pos)
  {
   ResetLastError();
   CMessage *msg_info=new CMessage(MESSAGE_INFO,ExpertName(),"Try close position #"+(string)pos.ID()+" by stop regim...");
   Log.AddMessage(msg_info);
   bool res=pos.CloseAtMarket("Exit by StopRegim");
   if(res)
      CMessage *msg=new CMessage(MESSAGE_INFO,ExpertName(),"Out of position #"+(string)pos.ID()+" successfully completed.");
// If position closure failed, the pos.CloseAtMarket method will notify if this.
  }
//+------------------------------------------------------------------+
//| Detects emergence of a new bar and generates an appropriate      |
//| event for the EA.                                                |
//+------------------------------------------------------------------+
void CStrategy::NewBarsDetect(void)
  {
   if(m_bars_detecors.Total()==0)
      AddBarOpenEvent(ExpertSymbol(),Timeframe());
   for(int i=0; i<m_bars_detecors.Total(); i++)
     {
      CBarDetector *bar=m_bars_detecors.At(i);
      if(bar.IsNewBar())
        {
         m_event.period = bar.Timeframe();
         m_event.symbol = bar.Symbol();
         m_event.type=MARKET_EVENT_BAR_OPEN;
         OnEvent(m_event);
         CallSupport(m_event);
         CallInit(m_event);
        }
     }
  }
//+------------------------------------------------------------------+
//| Detects the arrival of new ticks of multi-instruments.           |
//+------------------------------------------------------------------+
void CStrategy::NewTickDetect(void)
  {
   if(m_ticks_detectors.Total()==0)
      AddTickEvent(ExpertSymbol());
   for(int i=0; i<m_ticks_detectors.Total(); i++)
     {
      CTickDetector *tick=m_ticks_detectors.At(i);
      if(tick.IsNewTick())
        {
         m_event.period=PERIOD_CURRENT;
         m_event.type=MARKET_EVENT_TICK;
         m_event.symbol=tick.Symbol();
         OnEvent(m_event);
         CallSupport(m_event);
         CallInit(m_event);
        }
     }
  }
//+------------------------------------------------------------------+
//| Subscribes the EA to receive an event of new bar opening         |
//| for the specified 'symbol' and 'timeframe'. If the EA is already |
//| subscribed to the event, method returns false. If subscription   |
//| successful, returns true.                                        |
//+------------------------------------------------------------------+
bool CStrategy::AddBarOpenEvent(string symbol,ENUM_TIMEFRAMES timeframe)
  {
   for(int i=0; i<m_bars_detecors.Total(); i++)
     {
      CBarDetector *d=m_bars_detecors.At(i);
      if(d.Symbol()==symbol && d.Timeframe()==timeframe)
        {
         string text="You are already subscribed to the opening bars of said symbol and timeframe.";
         CMessage *message=new CMessage(MESSAGE_INFO,__FUNCTION__,text);
         return false;
        }
     }
   datetime time[];
   if(CopyTime(symbol,timeframe,0,3,time)==0)
     {
      string text="A symbol "+symbol+" that you want to monitor is not available in the terminal."+
                  " Make sure that the name of the instrument and its timeframe"+EnumToString(timeframe)+" are correct.";
      CMessage *message=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      return false;
     }
   CBarDetector *bar=new CBarDetector(symbol,timeframe);
   return m_bars_detecors.Add(bar);
  }
//+------------------------------------------------------------------+
//| Subscribes the EA to receive the 'new tick' event                |
//| for a selected symbol. If the EA is already subscribed to the    |
//| event, method returns false. If subscription                      |
//| successful, returns true.                                        |
//+------------------------------------------------------------------+
bool CStrategy::AddTickEvent(string symbol)
  {
   for(int i=0; i<m_ticks_detectors.Total(); i++)
     {
      CTickDetector *d=m_ticks_detectors.At(i);
      if(d.Symbol()==symbol)
        {
         string text="You are already subscribed to new tick event of said symbol.";
         CMessage *message=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
         return false;
        }
     }
   datetime time[];
   if(CopyTime(symbol,PERIOD_D1,0,3,time)==0)
     {
      string text="A symbol "+symbol+" that you want to monitor is not available in the terminal."+
                  " Make sure that the name of the instrument are correct.";
      CMessage *message=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      return false;
     }
   CTickDetector *tick=new CTickDetector(symbol);
   return m_ticks_detectors.Add(tick);
  }
//+------------------------------------------------------------------+
//| Returns the full name of the current contract for FORTS that     |
//| corresponds to the passed symbol. E.g., if the current date is   |
//| is 02.10.2015, and the passed symbol is "Si", the method returns |
//| the name of nearest contract: Si-12.15.                          |
//| Before returning symbol name, it checks its actual availability  |
//| for trading; and if it is unavailable, the method returns        
//| NULL. Otherwise returns the full name of the contract.           |
//+------------------------------------------------------------------+
string CStrategy::GetCurrentContract(string symbol)
  {
   datetime time[];
   if(SymbolInfoInteger(symbol,SYMBOL_SELECT))
      return symbol;
   MqlDateTime dt={0};
   TimeCurrent(dt);
   int mon=0;
   int year=0;
   if((dt.mon==12 && dt.day>=14) || dt.mon==1 || dt.mon==2 || (dt.mon==3 && dt.day<14))
     {
      mon=3;
      year=dt.year+1;
     }
   if((dt.mon==3 && dt.day>=14) || dt.mon==4 || dt.mon==5 || (dt.mon==6 && dt.day<14))
     {
      mon=6;
      year=dt.year;
     }
   if((dt.mon==6 && dt.day>=14) || dt.mon==7 || dt.mon==8 || (dt.mon==9 && dt.day<14))
     {
      mon=9;
      year=dt.year;
     }
   if((dt.mon==9 && dt.day>=14) || dt.mon==10 || dt.mon==11 || (dt.mon==12 && dt.day<14))
     {
      mon=12;
      year=dt.year;
     }
   if(mon==0 || year==0)
     {
      string text="The current date is outside the execution of futures";
      CMessage *msg=new CMessage(MESSAGE_ERROR,__FUNCTION__,text);
      return NULL;
     }
//Let's try to generate a symbol and receive its details
   string full_symbol=symbol+"-"+(string)mon+"."+StringSubstr((string)year,2);
   if(!SymbolInfoInteger(full_symbol,SYMBOL_SELECT))
     {
      string text="Symbol "+symbol+" is not not selected in market watch. Check the name of the instrument";
      CMessage *msg=new CMessage(MESSAGE_ERROR,__FUNCTION__,text);
      Log.AddMessage(msg);
      return NULL;
     }
   return full_symbol;
  }
//+------------------------------------------------------------------+
//| Overrides magic based comparison                                 |
//+------------------------------------------------------------------+
int CStrategy::Compare(const CObject *obj,const int mode=0)const
  {
   const CStrategy *str=obj;
   if(m_expert_magic > str.m_expert_magic)return 1;
   if(m_expert_magic < str.m_expert_magic)return -1;
   return 0;
  }
//+------------------------------------------------------------------+
//| 根据跟踪的图表产生Tick事件                                                                 |
//+------------------------------------------------------------------+
void CStrategy::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {

   if(id>=CHARTEVENT_CUSTOM)
     {
      m_event.period=(ENUM_TIMEFRAMES)lparam;
      m_event.symbol=sparam;
      m_event.type=MARKET_EVENT_TICK;
      OnEvent(m_event);
      CallSupport(m_event);
      CallInit(m_event);
     }

  }
void CStrategy::ReInitPositions(void)
   {
    for(int i=0;i<PositionsTotal();i++)
      {
       ulong ticket = PositionGetTicket(i);
       if(PositionSelectByTicket(ticket))
         {
          CPosition *cpos = new CPosition();
          if(cpos.ExpertMagic()==ExpertMagic())
             {
               ActivePositions.Add(cpos);  
              }
         } 
      }
    if(ActivePositions.Total()>0) Print("已有仓位:",ActivePositions.Total());
   }
#include <Strategy\StrategyFactory.mqh>
//+------------------------------------------------------------------+
