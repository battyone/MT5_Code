//+------------------------------------------------------------------+
//|                                                        Event.mqh |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Object.mqh>
//+------------------------------------------------------------------+
//| A custom event type enumeration                                  |
//+------------------------------------------------------------------+
enum ENUM_EVENT_TYPE
  {
   EVENT_TYPE_NULL=0,      // no event
   //---
   EVENT_TYPE_INDICATOR=1, // indicator event
   EVENT_TYPE_ORDER=2,     // order event
   EVENT_TYPE_EXTERNAL=3,  // external event
  };
//+------------------------------------------------------------------+
//| A custom event data                                              |
//+------------------------------------------------------------------+
struct SEventData
  {
   long              lparam;
   double            dparam;
   string            sparam;
   //--- default constructor
   void SEventData::SEventData(void)
     {
      lparam=0;
      dparam=0.0;
      sparam=NULL;
     }
   //--- copy constructor
   void  SEventData:: SEventData(const SEventData &_src_data)
     {
      lparam=_src_data.lparam;
      dparam=_src_data.dparam;
      sparam=_src_data.sparam;
     }
   //--- assignment operator
   void operator=(const SEventData &_src_data)
     {
      lparam=_src_data.lparam;
      dparam=_src_data.dparam;
      sparam=_src_data.sparam;
     }
  };
//+------------------------------------------------------------------+
//| Class CEventBase.                                                |
//| Purpose: base class for a custom event                           |
//| Derives from class CObject.                                      |
//+------------------------------------------------------------------+
class CEventBase : public CObject
  {
protected:
   ENUM_EVENT_TYPE   m_type;
   ushort            m_id;
   SEventData        m_data;

public:
   void              CEventBase(void)
     {
      this.m_id=0;
      this.m_type=EVENT_TYPE_NULL;
     };
   void             ~CEventBase(void){};
   //--
   bool              Generate(const ushort _event_id,const SEventData &_data,
                              const bool _is_custom=true);
   ushort            GetId(void) {return this.m_id;};

private:
   virtual bool      Validate(void) {return true;};
  };
//+------------------------------------------------------------------+
//| Generate a custom event                                          |
//+------------------------------------------------------------------+
bool CEventBase::Generate(const ushort _event_id,const SEventData &_data,
                          const bool _is_custom=true)
  {
//--- generation flag
   bool is_generated=true;

//--- record data
   this.m_id=(ushort)(CHARTEVENT_CUSTOM+_event_id);
   this.m_data=_data;

//--- if to call EventChartCustom()
   if(_is_custom)
     {
      ResetLastError();
      is_generated=EventChartCustom(0,_event_id,this.m_data.lparam,
                                    this.m_data.dparam,this.m_data.sparam);
      //--- if error
      if(!is_generated)
         Print("Error while generating a custom event: ",_LastError);
     }

//--- validate
   if(is_generated)
     {
      is_generated=this.Validate();
      //--- if failed to validate - reset id
      if(!is_generated)
         this.m_id=0;
     }

//---
   return is_generated;
  }
//+------------------------------------------------------------------+
//| Class CIndicatorEvent.                                           |
//| Purpose: class of indicator event                                |
//| Derives from class CEventBase.                                   |
//+------------------------------------------------------------------+
class CIndicatorEvent: public CEventBase
  {
protected:

public:
   //---
   void              CIndicatorEvent(void)
     {
      this.m_type=EVENT_TYPE_INDICATOR;
     };
   void              CIndicatorEvent(const ushort _event_id);
   void             ~CIndicatorEvent(void){};
   //---
private:
   virtual bool      Validate(void);
  };
//+------------------------------------------------------------------+
//| Parameter constructor                                            |
//+------------------------------------------------------------------+
void CIndicatorEvent::CIndicatorEvent(const ushort _event_id)
  {
   this.m_id=_event_id;
   this.m_type=EVENT_TYPE_INDICATOR;
  };
//+------------------------------------------------------------------+
//| Validate the indicator event                                     |
//+------------------------------------------------------------------+
bool CIndicatorEvent::Validate(void)
  {
   return this.m_id>CHARTEVENT_CUSTOM && this.m_id<CHARTEVENT_CUSTOM+5;
  }
//+------------------------------------------------------------------+
//| Class COrderEvent.                                               |
//| Purpose: class of indicator event                                |
//| Derives from class CEventBase.                                   |
//+------------------------------------------------------------------+
class COrderEvent: public CEventBase
  {
protected:

public:
   void              COrderEvent(void)
     {
      this.m_type=EVENT_TYPE_ORDER;
     };
   //---
   void              COrderEvent(const ushort _event_id);
   void             ~COrderEvent(void){};
   //---
private:
   virtual bool      Validate(void);
  };
//+------------------------------------------------------------------+
//| Parameter constructor                                            |
//+------------------------------------------------------------------+
void COrderEvent::COrderEvent(const ushort _event_id)
  {
   this.m_id=_event_id;
   this.m_type=EVENT_TYPE_ORDER;
  };
//+------------------------------------------------------------------+
//| Validate the order event                                         |
//+------------------------------------------------------------------+
bool COrderEvent::Validate(void)
  {
   return this.m_id>CHARTEVENT_CUSTOM+4 && this.m_id<CHARTEVENT_CUSTOM+7;
  }
//+------------------------------------------------------------------+
//| Class CExternalEvent.                                            |
//| Purpose: class of external event                                 |
//| Derives from class CEventBase.                                   |
//+------------------------------------------------------------------+
class CExternalEvent: public CEventBase
  {
protected:

public:
   void              CExternalEvent(void)
     {
      this.m_type=EVENT_TYPE_EXTERNAL;
     };
   //---
   void              CExternalEvent(const ushort _event_id);
   void             ~CExternalEvent(void){};
   //---
private:
   virtual bool      Validate(void);
  };
//+------------------------------------------------------------------+
//| Parameter constructor                                            |
//+------------------------------------------------------------------+
void CExternalEvent::CExternalEvent(const ushort _event_id)
  {
   this.m_id=_event_id;
   this.m_type=EVENT_TYPE_EXTERNAL;
  };
//+------------------------------------------------------------------+
//| Validate the external event                                      |
//+------------------------------------------------------------------+
bool CExternalEvent::Validate(void)
  {
   return this.m_id>CHARTEVENT_CUSTOM+6 && this.m_id<CHARTEVENT_CUSTOM+9;
  }
//--- [EOF]
