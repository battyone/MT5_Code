//+------------------------------------------------------------------+
//|                                                      Program.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "ForexMarketDataAnalizer.mqh"
#include "MarketPrice.mqh"
#include <EasyAndFastGUI\WndEvents.mqh>
#include <EasyAndFastGUI\TimeCounter.mqh>
//CForexMarketDataAnalyzier da;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


class CProgram:public CWndEvents
  {
protected:
   CTimeCounter      m_counter1; // for updating the execution process
   CTimeCounter      m_counter2; // for updating the items in the status bar

   CWindow           m_window1;

   CStatusBar        m_status_bar;
   CTabs             m_tabs1;

   //---第一个Tab的元素
   CPicture          m_picture1;
   CComboBox         m_period_type;//周期
   CComboBox         m_symbol_type;//品种对类别
   CButtonsGroup     m_select_data_type;//价格显示类型选择
   CButtonsGroup     m_select_data_range;//价格数据的区间设置选择
                                         //   CTextEdit         m_fix_time_begin;//固定时间类型-开始点设置
   CDropCalendar     m_drop_calendar_from;
   CDropCalendar     m_drop_calendar_to;
   CDropCalendar     m_drop_calendar_begin;
   CTimeEdit         m_time_edit_from;
   CTimeEdit         m_time_edit_to;
   CTimeEdit         m_time_edit_begin;

   CTextEdit         m_fix_num;//固定数量设置
   CSeparateLine     m_sep_line1;//分割线
   CSeparateLine     m_sep_line2;//分割线
   CGraph            m_graph1;//监控外汇品种对数据图表
   ForexClassMarketPrice fcmp;//存储外汇品种对类别数据

   //---第二个Tab的元素
   CButton  m_button_reset;
   CDropCalendar         m_drop_calendar_long_from;
   CDropCalendar         m_drop_calendar_long_to;
   CDropCalendar          m_drop_calendar_middle_from;
   CDropCalendar          m_drop_calendar_middle_to;
   CDropCalendar          m_drop_calendar_short_from;
   CDropCalendar          m_drop_calendar_short_to;
   CDropCalendar          m_drop_calendar_user_from;
   CDropCalendar          m_drop_calendar_user_to;
   CTable   m_table_result;
   CTextLabel label_from;
   CTextLabel label_to;
   CTextLabel label_long;
   CTextLabel label_medium;
   CTextLabel label_short;
   CTextLabel label_user;
   
   //---第三个tab的元素
   CComboBox tab3_symbols_type;
   CComboBox tab3_period_type;
   CDropCalendar     tab3_calendar_from;
   CDropCalendar     tab3_calendar_to;
   CDropCalendar     tab3_calendar_begin;
   CTimeEdit         tab3_edit_from;
   CTimeEdit         tab3_edit_to;
   CTimeEdit         tab3_edit_begin;
   CTextEdit         tab3_fix_num;
   CButtonsGroup     tab3_data_range;//价格数据的区间设置选择
   CTable   tab3_corr_table;


public:
                     CProgram(void);
   bool              CreateGUI(void);
   void              OnTimerEvent(void);
   void              OnDeinitEvent(const int reason);

protected:
   bool              CreateWindow(const string text);//创建主窗口
   bool              CreateStatusBar(const int x_gap,const int y_gap);//创建状态栏
   bool              CreatePicture1(const int x_gap,const int y_gap);//创建可变大小图片标识
   bool              CreateTabs1(const int x_gap,const int y_gap);//创建分类TAB标签

//创建第一个tab元素
   bool              CreateComboBoxPeriodType(const int x_gap,const int y_gap,const string text);
   bool              CreateComboBoxSymbolType(const int x_gap,const int y_gap,const string text);
   bool              CreateButtonsGroupDataType(const int x_gap,const int y_gap,const string text);//创建价格类型选择框
   bool              CreateButtonsGroupDataRange(const int x_gap,const int y_gap,const string text);//创建数据长度类型选择框
   bool              CreateCalendarFrom(const int x_gap,const int y_gap,const string text);
   bool              CreateCalendarTo(const int x_gap,const int y_gap,const string text);
   bool              CreateCalendarBegin(const int x_gap,const int y_gap,const string text);
   bool              CreateTimeEditFrom(const int x_gap,const int y_gap,const string text);
   bool              CreateTimeEditTo(const int x_gap,const int y_gap,const string text);
   bool              CreateTimeEditBegin(const int x_gap,const int y_gap,const string text);
   bool              CreateTextEditFixNum(const int x_gap,const int y_gap,const string text);//创建固定数量--文本框
   bool              CreateSepLine1(const int x_gap,const int y_gap);//创建分割线
   bool              CreateSepLine2(const int x_gap,const int y_gap);//创建分割线

//创建第二个tab元素
   bool              Test(const int x_gap,const int y_gap,const string text);//测试
   bool  CreateTableResult(const int x_gap,const int y_gap);
   bool  CreateCalendarTab2(const int x_gap,const int y_gap);

                                                                             //第一个tab元素的交互
   bool              CreateGraph1(const int x_gap,const int y_gap);
   void              UpdateGraph(void);
   void              ResetGraph(void);
   void              InitGraphArrays();
   void              ResizeGraphArrays(const int new_size);

   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
//---创建第3个tab元素
   bool              CreateTab3ComboBoxPeriodType(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3ComboBoxSymbolType(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3ButtonsGroupDataRange(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3CalendarFrom(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3CalendarTo(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3CalendarBegin(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3TimeEditFrom(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3TimeEditTo(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3TimeEditBegin(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3TextEditFixNum(const int x_gap,const int y_gap,const string text);
   bool              CreateTab3CorrTable(const int x_gap,const int y_gap);
   CArrayObj              *GetCorrData();
   bool  UpdateTab3CorrTable(void);
   void  ClearTab3CorrTableText(void);


  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CProgram::CProgram(void)
  {
   m_counter1.SetParameters(10,10000);
   m_counter2.SetParameters(30,35);
  }

#include "MainWindow.mqh"
#include "Tab1.mqh"
#include "Tab2.mqh"
#include "Tab3.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateGUI(void)
  {
   if(!CreateWindow("Forex Market Analyzer"))
      return false;
   if(!CreateStatusBar(1,25))
      return false;
   if(!CreatePicture1(10,10))
      return false;
   if(!CreateTabs1(7,45))
      return false;

//   创建第一个tab的元素
   if(!CreateComboBoxSymbolType(10,10,"Symbol"))
      return false;
   if(!CreateComboBoxPeriodType(10,50,"Period"))
      return false;

   if(!CreateButtonsGroupDataType(140,10,"Price type"))
      return false;
   if(!CreateButtonsGroupDataRange(220,10,"Price range"))
      return false;

   if(!CreateTimeEditFrom(290,10,"from"))
      return false;
   if(!CreateTimeEditTo(290,30,"to"))
      return false;
   if(!CreateTimeEditBegin(290,55,"begin"))
      return false;

   if(!CreateCalendarFrom(500,10,""))
      return false;
   if(!CreateCalendarTo(500,30,""))
      return false;
   if(!CreateCalendarBegin(500,55,""))
      return false;


   if(!CreateTextEditFixNum(290,95,"Num"))
      return false;
   if(!CreateSepLine1(130,10))
      return false;
   if(!CreateSepLine2(210,10))
      return false;
   if(!CreateGraph1(10,120))
      return false;

//    创建第二个tab的元素
   if(!CreateCalendarTab2(10,10))
      return false;   
   
   if(!CreateTableResult(10,100))
      return false;
    
    //---创建第三个tab元素
    if(!CreateTab3ComboBoxSymbolType(10,10,"symbols"))
      return false;
    if(!CreateTab3ComboBoxPeriodType(10,50,"Period"))
      return false;
    if(!CreateTab3ButtonsGroupDataRange(220,10,"Price range"))
      return false;
    if(!CreateTab3TimeEditFrom(290,10,"from"))
      return false;
   if(!CreateTab3TimeEditTo(290,30,"to"))
      return false;
   if(!CreateTab3TimeEditBegin(290,55,"begin"))
      return false;
//
   if(!CreateTab3CalendarFrom(500,10,""))
      return false;
   if(!CreateTab3CalendarTo(500,30,""))
      return false;
   if(!CreateTab3CalendarBegin(500,55,""))
      return false;
   if(!CreateTab3TextEditFixNum(290,95,"Num"))
      return false;
   if(!CreateTab3CorrTable(10,130))
      return false;
   if(!UpdateTab3CorrTable())
      return false;   
//   
   CWndEvents::CompletedGUI();
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProgram::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//复选框点击事件
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM)
     {
      if(lparam==m_symbol_type.Id())//品种类别选择
        {
         ResetGraph();
         return;
        }
      if(lparam==m_period_type.Id())//周期选择
        {
         ResetGraph();
         return;
        }
      if(lparam==tab3_symbols_type.Id())
        {
         UpdateTab3CorrTable();
         return;
        }
     }
//编辑框结束编辑事件
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT || id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      bool fix_time_change=(lparam==m_drop_calendar_from.Id() || lparam==m_drop_calendar_to.Id() || lparam==m_time_edit_from.Id() || lparam==m_time_edit_to.Id());
      bool dynamic_change=(lparam==m_drop_calendar_begin.Id()||lparam==m_time_edit_begin.Id());
      bool fix_num_change=(lparam==m_fix_num.Id());
      bool tab3_fix_num_change=(lparam==tab3_fix_num.Id());
      bool tab3_edit_event_fix_time=(lparam==tab3_calendar_from.Id()||lparam==tab3_calendar_to.Id()||lparam==tab3_edit_from.Id()||lparam==tab3_edit_to.Id());
      bool tab3_edit_event_dynamic=(lparam==tab3_calendar_begin.Id()||lparam==tab3_edit_begin.Id());
      if(fix_num_change && m_select_data_range.SelectedButtonIndex()==2)//固定数量编辑框事件
        {
         Print("固定数量编辑框事件触发");
         ResetGraph();
         return;
        }
      if(fix_time_change && m_select_data_range.SelectedButtonIndex()==0)
        {
         Print("固定时间编辑框事件触发");
         ResetGraph();
         return;
        }
      if(dynamic_change && m_select_data_range.SelectedButtonIndex()==1)
        {
         Print("动态时间编辑框事件触发");
         ResetGraph();
         return;
        }
      if(tab3_fix_num_change&&tab3_data_range.SelectedButtonIndex()==2)
        {
         Print("相关性监控——数据数量变更");
         UpdateTab3CorrTable();
         return;
        }
      if(tab3_edit_event_dynamic&&tab3_data_range.SelectedButtonIndex()==1)
         {
          Print("相关性监控——动态数据起点变更");
          UpdateTab3CorrTable();
          return;
         }
      if(tab3_edit_event_fix_time&&tab3_data_range.SelectedButtonIndex()==0)
         {
          Print("相关性监控——固定数据区间变更");
          UpdateTab3CorrTable();
          return;
         }
     }
     
      

   if(id==CHARTEVENT_CUSTOM+ON_CLICK_GROUP_BUTTON)
     {
      if(lparam==m_select_data_range.Id() || lparam==m_select_data_type.Id())
        {
         ResetGraph();
         return;
        }
      if(lparam==tab3_data_range.Id())
         {
          UpdateTab3CorrTable();
          return;
         } 
     }
  }
//+------------------------------------------------------------------+
void CProgram::OnTimerEvent(void)
  {
   CWndEvents::OnTimerEvent();
//--- Update the chart by timer
   if(m_counter1.CheckTimeCounter())
     {
      Print("on timer");
      if(m_select_data_range.SelectedButtonIndex()==1 || m_select_data_range.SelectedButtonIndex()==2)
        {
         Print("Update Graph!");
         ResetGraph();
        }

     }
//---
   if(m_counter2.CheckTimeCounter())
     {
      if(m_status_bar.IsVisible())
        {
         static int index=0;
         index=(index+1>3)? 0 : index+1;
         m_status_bar.GetItemPointer(1).ChangeImage(0,index);
         m_status_bar.GetItemPointer(1).Update(true);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProgram::OnDeinitEvent(const int reason)
  {
//--- Removing the interface
   CWndEvents::Destroy();
  }
//+------------------------------------------------------------------+
