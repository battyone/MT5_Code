//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Object.mqh>
#include "Event.mqh"
///
///
///
class CEventRefresh : public CEvent
  {
public:
                     CEventRefresh() : CEvent(EVENT_FREFRESH){;}
  };
//+------------------------------------------------------------------+
