//+------------------------------------------------------------------+
//|                                                EventListener.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"
#include <Strategy\Strategy.mqh>
#include <Strategy\SignalAdapter.mqh>
input int pattern_usage=1;
//+------------------------------------------------------------------+
//| Strategy receives events and displays in terminal.               |
//+------------------------------------------------------------------+
class CAdapterMACD : public CStrategy
  {
private:
   CSignalAdapter    my_signal;
   MqlSignalParams   m_params;
public:
                     CAdapterMACD(void);
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      SetParams(const string symbol,const ENUM_TIMEFRAMES period,const bool every_tick,
                               ENUM_SIGNAL_TYPE signal_type,const int magic,const double point,const int usage_pattern);
   virtual void      SetSignalParams(int period_fast,int period_slow,int period_siganl);
  };
//+------------------------------------------------------------------+
//| Configuring the adapter                                          |
//+------------------------------------------------------------------+
CAdapterMACD::CAdapterMACD(void)
  {
   m_params.symbol = Symbol();
   m_params.period = Period();
   m_params.every_tick=false;
   m_params.signal_type=SIGNAL_MACD;
   m_params.magic = 1234;
   m_params.point = 1.0;
   m_params.usage_pattern= pattern_usage;
   CSignalMACD *macd=my_signal.CreateSignal(m_params);
   macd.PeriodFast(12);
   macd.PeriodSlow(26);
   macd.PeriodSignal(9);
  }
//+------------------------------------------------------------------+
//| 配置适配器参数                                                                 |
//+------------------------------------------------------------------+
CAdapterMACD::SetParams(const string symbol,const ENUM_TIMEFRAMES period,const bool every_tick,ENUM_SIGNAL_TYPE signal_type,
                        const int magic,const double point,const int usage_pattern)
  {
   m_params.symbol = symbol;
   m_params.period = period;
   m_params.every_tick=every_tick;
   m_params.signal_type=signal_type;
   m_params.magic = magic;
   m_params.point = point;
   m_params.usage_pattern=usage_pattern;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAdapterMACD::SetSignalParams(int period_fast,int period_slow,int period_siganl)
  {
   CSignalMACD *macd=my_signal.CreateSignal(m_params);
   macd.PeriodFast(period_fast);
   macd.PeriodSlow(period_slow);
   macd.PeriodSignal(period_siganl);
  }
//+------------------------------------------------------------------+
//| Buying.                                                          |
//+------------------------------------------------------------------+
void CAdapterMACD::InitBuy(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_BAR_OPEN)
      return;
   if(my_signal.LongSignal())
      Trade.Buy(0.01,event.symbol,StringFormat("MODE [%d] BUY", m_params.usage_pattern));
  }
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
void CAdapterMACD::SupportBuy(const MarketEvent &event,CPosition *pos)
  {
   if(event.type!=MARKET_EVENT_BAR_OPEN)
      return;
   if(my_signal.ShortSignal())
      pos.CloseAtMarket();
  }
//+------------------------------------------------------------------+
//| Selling.                                                         |
//+------------------------------------------------------------------+
void CAdapterMACD::InitSell(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_BAR_OPEN)
      return;
   if(my_signal.ShortSignal())
      Trade.Sell(0.01,event.symbol,StringFormat("MODE [%d] SELL", m_params.usage_pattern));
  }
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
void CAdapterMACD::SupportSell(const MarketEvent &event,CPosition *pos)
  {
   if(event.type!=MARKET_EVENT_BAR_OPEN)
      return;
   if(my_signal.LongSignal())
      pos.CloseAtMarket();
  }
//+------------------------------------------------------------------+
