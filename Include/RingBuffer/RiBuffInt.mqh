//+------------------------------------------------------------------+
//|                                                   RingBuffer.mqh |
//|                                 Copyright 2016, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| Double ring buffer                                               |
//+------------------------------------------------------------------+
class CRiBuffInt
{
private:
   bool           m_full_buff;
   int            m_max_total;
   int            m_head_index;
   int         m_buffer[];
protected:
   virtual void   OnAddValue(int value);
   virtual void   OnRemoveValue(int value);
   virtual void   OnChangeValue(int index, int prev_value, int new_value);
   virtual void   OnChangeArray(void);
   virtual void   OnSetMaxTotal(int max_total);
   int            ToRealInd(int index);
public:
                  CRiBuffInt(void);
   void           AddValue(int value);
   void           ChangeValue(int index, int new_value);
   int         GetValue(int index);
   int            GetTotal(void);
   int            GetMaxTotal(void);
   void           SetMaxTotal(int max_total);
   void           ToArray(int& array[]);
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CRiBuffInt::CRiBuffInt(void) :   m_full_buff(false),
                                 m_head_index(-1),
                                 m_max_total(0)
{
   SetMaxTotal(3);
}
//+------------------------------------------------------------------+
//| Called when a new value is received                              |
//+------------------------------------------------------------------+
void CRiBuffInt::OnAddValue(int value)
{
}
//+------------------------------------------------------------------+
//| Called when an old value is removed                              |
//+------------------------------------------------------------------+
void CRiBuffInt::OnRemoveValue(int value)
{
}
//+------------------------------------------------------------------+
//| Called when an old value is changed                              |
//+------------------------------------------------------------------+
void CRiBuffInt::OnChangeValue(int index,int prev_value,int new_value)
{
}
//+------------------------------------------------------------------+
//| Called when changing the number of elements in the buffer        |
//+------------------------------------------------------------------+
void CRiBuffInt::OnSetMaxTotal(int max_total)
{
}
//+------------------------------------------------------------------+
//| Called if the entire array should be counted                     |
//+------------------------------------------------------------------+
void CRiBuffInt::OnChangeArray(void)
{
}
//+------------------------------------------------------------------+
//| Set the new size of the ring buffer                              |
//+------------------------------------------------------------------+
void CRiBuffInt::SetMaxTotal(int max_total)
{
   if(ArraySize(m_buffer) == max_total)
      return;
   m_max_total = ArrayResize(m_buffer, max_total);
   OnSetMaxTotal(m_max_total);
}
//+------------------------------------------------------------------+
//| Get the actual ring buffer size                                  |
//+------------------------------------------------------------------+
int CRiBuffInt::GetMaxTotal(void)
{
   return m_max_total;
}
//+------------------------------------------------------------------+
//| Get the index value                                              |
//+------------------------------------------------------------------+
int CRiBuffInt::GetValue(int index)
{
   return m_buffer[ToRealInd(index)];
}
//+------------------------------------------------------------------+
//| Get the total number of elements                                 |
//+------------------------------------------------------------------+
int CRiBuffInt::GetTotal(void)
{
   if(m_full_buff)
      return m_max_total;
   return m_head_index+1;
}
//+------------------------------------------------------------------+
//| Add a new value to the ring buffer                               |
//+------------------------------------------------------------------+
void CRiBuffInt::AddValue(int value)
{
   if(++m_head_index == m_max_total)
   {
      m_head_index = 0;
      m_full_buff = true;
   }  
   int last_value = 0.0;
   if(m_full_buff)
      last_value = m_buffer[m_head_index];
   m_buffer[m_head_index] = value;
   OnAddValue(value);
   if(m_full_buff)
      OnRemoveValue(last_value);
   OnChangeArray();
}
//+------------------------------------------------------------------+
//| Replace the previously added value with the new one              |
//+------------------------------------------------------------------+
void CRiBuffInt::ChangeValue(int index, int value)
{
   int r_index = ToRealInd(index);
   int prev_value = m_buffer[r_index];
   m_buffer[r_index] = value;
   OnChangeValue(index, prev_value, value);
   OnChangeArray();
}
//+------------------------------------------------------------------+
//| Convert the virtual index into a real one                        |
//+------------------------------------------------------------------+
int CRiBuffInt::ToRealInd(int index)
{
   if(index >= GetTotal() || index < 0)
      return m_max_total;
   if(!m_full_buff)
      return index;
   int delta = (m_max_total-1) - m_head_index;
   if(index < delta)
      return m_max_total + (index - delta);
   return index - delta;
}
//+------------------------------------------------------------------+
//| Get the array of values                                          |
//+------------------------------------------------------------------+
void CRiBuffInt::ToArray(int &array[])
{
   ArrayResize(array, GetTotal());
   int start = ToRealInd(0);
   if(start > m_head_index)
   {
      int lt = m_max_total-start;
      ArrayCopy(array, m_buffer, 0, start, lt);
      ArrayCopy(array, m_buffer, lt, 0, m_head_index+1);
   }
   else
      ArrayCopy(array, m_buffer, 0, 0, m_head_index);
}