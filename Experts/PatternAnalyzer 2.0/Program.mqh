//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <EasyAndFastGUI\WndEvents.mqh>
#include <EasyAndFastGUI\TimeCounter.mqh>
//--- Candlestick type
enum TYPE_CANDLESTICK
  {
   CAND_NONE,           //Undefined
   CAND_MARIBOZU,       //Marubozu
   CAND_DOJI,           //Doji
   CAND_SPIN_TOP,       //Spins
   CAND_HAMMER,         //Hammer
   CAND_INVERT_HAMMER,  //Inverted Hammer
   CAND_LONG,           //Long
   CAND_SHORT           //Short
  };
//--- Trend type
enum TYPE_TREND
  {
   UPPER,               //Uptrend
   DOWN,                //Downtrend
   FLAT                 //Flat
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct CANDLE_STRUCTURE
  {
   double            open,high,low,close;       // OHLC
   TYPE_TREND        trend;                     //Trend
   bool              bull;                      //Bullish candlestick
   double            bodysize;                  //Body size
   TYPE_CANDLESTICK  type;                      //Candlestick type
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct RATING_SET
  {
   int               a_uptrend;
   int               b_uptrend;
   int               c_uptrend;
   int               a_dntrend;
   int               b_dntrend;
   int               c_dntrend;
  };
//+------------------------------------------------------------------+
//| Class for creating an application                                |
//+------------------------------------------------------------------+
class CProgram : public CWndEvents
  {
protected:
   //--- Main window
   CWindow           m_window1;
   CWindow           m_window2;
   //--- Status Bar
   CStatusBar        m_status_bar;
   //--- Tabs
   CTabs             m_tabs1;
   //--- Edit fields
   CTextEdit         m_coef1;
   CTextEdit         m_coef2;
   CTextEdit         m_coef3;
   CTextEdit         m_threshold;
   CTextEdit         m_symb_filter1;
   CTextEdit         m_symb_filter2;
   CTextEdit         m_range1;
   CTextEdit         m_range2;
   CTextEdit         m_candle_coef1;
   CTextEdit         m_candle_coef2;
   //--- Buttons
   CButton           m_request1;
   CButton           m_request2;
   CButton           m_button1;
   CButton           m_button2;
   CButton           m_button3;
   CButton           m_button4;
   CButton           m_button5;
   CButton           m_button6;
   CButton           m_button7;
   CButton           m_button8;
   CButton           m_button9;
   CButton           m_button10;
   CButton           m_button11;
   CButton           m_save;
   CButton           m_cancel;
   //--- Icon
   CPicture          m_picture1;
   CPicture          m_picture2;
   CPicture          m_picture3;
   CPicture          m_picture4;
   CPicture          m_picture5;
   CPicture          m_picture6;
   //--- Rendered table
   CTable            m_table1;
   CTable            m_table2;
   CTable            m_symb_table1;
   CTable            m_symb_table2;
   //--- Text labels
   CTextLabel        m_text_label1;
   CTextLabel        m_text_label2;
   CTextLabel        m_text_label3;
   CTextLabel        m_text_label4;
   CTextLabel        m_text_label5;
   CTextLabel        m_candle_name1;
   CTextLabel        m_candle_name2;
   CTextLabel        m_candle_name3;
   CTextLabel        m_candle_name4;
   CTextLabel        m_candle_name5;
   CTextLabel        m_candle_name6;
   //--- Comboboxes
   CComboBox         m_timeframes1;
   CComboBox         m_timeframes2;
   CComboBox         m_lang_setting;
   //--- Time counters
   CTimeCounter      m_counter1;
   //--- List views
   CListView         m_listview1;
public:
                     CProgram(void);
                    ~CProgram(void);
   //--- Initialization/uninitialization
   void              OnInitEvent(void);
   void              OnDeinitEvent(const int reason);
   //--- Timer
   void              OnTimerEvent(void);
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   //--- Create the graphical interface of the program
   bool              CreateGUI(void);
   //--- 
   int               m_range_total1;
   int               m_range_total2;
   ENUM_TIMEFRAMES   m_timeframe1;
   ENUM_TIMEFRAMES   m_timeframe2;
   int               m_hummer_total;
   int               m_invert_hummer_total;
   int               m_handing_man_total;
   int               m_shooting_star_total;
   int               m_engulfing_bull_total;
   int               m_engulfing_bear_total;
   int               m_harami_bull_total;
   int               m_harami_bear_total;
   int               m_harami_cross_bull_total;
   int               m_harami_cross_bear_total;
   int               m_doji_star_bull_total;
   int               m_doji_star_bear_total;
   int               m_piercing_line_total;
   int               m_dark_cloud_cover_total;
   double            m_k1;
   double            m_k2;
   double            m_k3;
   int               m_threshold_value;
   double            m_long_coef;
   double            m_short_coef;
   double            m_doji_coef;
   double            m_maribozu_coef;
   double            m_spin_coef;
   double            m_hummer_coef1;
   double            m_hummer_coef2;
   int               m_candle_index;
   //---
   int               m_lang_index;
   //---
   int               m_total_candles;
   string            m_total_combination[];
   string            m_used_pattern[];
   int               m_pattern_size;
protected:
   //--- Main window
   bool              CreateWindow(const string text);
   bool              CreateWindowSetting(const string text);
   //--- Status Bar
   bool              CreateStatusBar(const int x_gap,const int y_gap);
   //--- Tab
   bool              CreateTabs(const int x_gap,const int y_gap);
   //---
   bool              CreateSymbolsFilter(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const int tab);
   bool              CreateRequest(CButton &button,const int x_gap,const int y_gap,const string text,const int tab);
   bool              CreateRange(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const int tab);
   //--- Tables
   bool              CreateTable1(CTable &table,const int x_gap,const int y_gap,const int tab);
   bool              CreateTable2(CTable &table,const int x_gap,const int y_gap,const int tab);
   bool              CreateSymbTable(CTable &table,const int x_gap,const int y_gap,const int tab);
   //--- Edit fields
   bool              CreateCoef(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const double value);
   bool              CreateThresholdValue(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const double value);
   bool              CreateSettingCoef(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const double value);
   //---
   bool              CreateCandle(CPicture &pic,CButton &button,CTextLabel &candlelabel,const string candlename,const int x_gap,const int y_gap,const string path);
   //--- Button
   bool              CreateButtonPic(CPicture &pic,CButton &button,const string path="");
   //--- Text label
   bool              CreateTextLabel(CTextLabel &text_label,const int x_gap,const int y_gap,string label_text);
   bool              CreateSettingTextLabel(CTextLabel &text_label,const int x_gap,const int y_gap,string label_text);
   //--- Combo box
   bool              CreateComboBoxTF(CComboBox &tf,const int x_gap,const int y_gap,const string text,const int tab);
   bool              CreateLanguageSetting(CComboBox &combobox,const int x_gap,const int y_gap,const string text,const int tab);
   //---
   bool              CreateSaveButton(const int x_gap,const int y_gap,const string text);
   //---
   bool              CreateCancelButton(const int x_gap,const int y_gap,const string text);
   //---
   bool              CreateListView(const int x_gap,const int y_gap);
   //---
   bool              CreateDualButton(CButton &lbutton,CButton &rbutton,const int x_gap,const int y_gap,const string ltext,const string rtext);
   //---
   bool              CreateTripleButton(CButton &lbutton,CButton &cbutton,CButton &rbutton,const int x_gap,const int y_gap);
   //---
   bool              CreateButton(CButton &button,const int x_gap,const int y_gap,const string text);
   //---
   bool              CreateButton1(CButton &button,const int x_gap,const int y_gap,const string text);
private:
   //--- Symbols for trading
   string            m_symbols[];
   //--- Requesting data
   bool              RequestData(const long id);
   //--- Get symbols
   void              GetSymbols(CTextEdit &textedit);
   //--- Changing the symbol
   bool              ChangeSymbol1(const long id);
   bool              ChangeSymbol2(const long id);
   //--- Changing the period
   bool              ChangePeriod1(const long id);
   bool              ChangePeriod2(const long id);
   //--- Rebuilding the table
   void              RebuildingTables(CTable &symbtable);
   //--- Recognizes candlestick type
   bool              GetCandleType(const string symbol,CANDLE_STRUCTURE &res,ENUM_TIMEFRAMES timeframe,const int shift);
   //--- Recognizing patterns
   bool              GetPatternType(const string symbol);
   bool              GetPatternType(const string symbol,string &total_combination[]);
   //--- Output of results in a table
   void              BuildingPatternTable(void);
   bool              BuildingAutoSearchTable(void);
   //---
   void              SetAnalyzeData(string pattern_name,int row,int patterns_total,int model_type);
   //--- Determining the profit categories
   bool              GetCategory(const string symbol,const int shift,RATING_SET &rate,ENUM_TIMEFRAMES timeframe);
   //--- Calculating coefficients for the table
   bool              CoefCalculation(CTable &table,const int row,RATING_SET &rate,int found);
   //--- Changing the language
   bool              ChangeLanguage(const long id);
   //--- The name of candlestick types
   bool              CreateNameCandle(CTextLabel &text_label,const int x_gap,const int y_gap,string label_text);
   //--- Output of candlestick combinations
   bool              GetCandleCombitaion(void);
   //---
   void              IndexToPatternType(CANDLE_STRUCTURE &res,const int index);
  };
//+------------------------------------------------------------------+
//| Creating controls                                                |
//+------------------------------------------------------------------+
#include "MainWindow.mqh"
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgram::CProgram(void) : m_long_coef(1.3),
                           m_short_coef(0.5),
                           m_doji_coef(0.04),
                           m_maribozu_coef(0.01),
                           m_spin_coef(1),
                           m_hummer_coef1(0.1),
                           m_hummer_coef2(2),
                           m_candle_index(0),
                           m_lang_index(0),
                           m_total_candles(11),
                           m_pattern_size(1)
  {
//--- Setting parameters for the time counters
   m_counter1.SetParameters(16,100);
//---
   ArrayResize(m_used_pattern,3);
   for(int i=0;i<3;i++)
      m_used_pattern[i]=(string)(i+1);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CProgram::~CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CProgram::OnInitEvent(void)
  {
  }
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void CProgram::OnDeinitEvent(const int reason)
  {
//--- Deleting the interface
   CWndEvents::Destroy();
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CProgram::OnTimerEvent(void)
  {
   CWndEvents::OnTimerEvent();
//---
   if(m_counter1.CheckTimeCounter())
     {
      //--- Get the value from the combo box drop-down list
      string tf1=m_timeframes1.GetListViewPointer().SelectedItemText();
      string tf2=m_timeframes2.GetListViewPointer().SelectedItemText();
      m_timeframe1=StringToTimeframe(tf1);
      m_timeframe2=StringToTimeframe(tf2);
      m_range_total1=(int)m_range1.GetValue();
      m_range_total2=(int)m_range2.GetValue();
      m_threshold_value=(int)m_threshold.GetValue();
      m_k1=(double)m_coef1.GetValue();
      m_k2=(double)m_coef2.GetValue();
      m_k3=(double)m_coef3.GetValue();
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CProgram::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- GUI creation event
   if(id==CHARTEVENT_CUSTOM+ON_END_CREATE_GUI)
     {
      //--- Requesting data
      RequestData(m_request1.Id());
      //---
      m_button7.IsLocked(true);
      m_button7.Update(true);
      //---
      m_button9.IsLocked(true);
      m_button9.Update();
     }
//--- Tab switching event
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_TAB)
     {
      if(m_tabs1.SelectedTab()==1)
         RequestData(m_request2.Id());
     }
//--- Event of pressing on the item of a list or table
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM)
     {
      //--- Changing the symbol
      if(ChangeSymbol1(lparam))
         Update(true);
      if(ChangeSymbol2(lparam))
         m_table2.Update(true);
     }
//--- Selection of item in a combo box
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM)
     {
      //--- Timeframe change
      if(ChangePeriod1(lparam))
         Update(true);
      if(ChangePeriod2(lparam))
         Update(true);
      //--- Changing the interface language
      if(ChangeLanguage(lparam))
         Update(true);
     }
//---
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      //--- Requesting data
      RequestData(lparam);
      //---

      string val;
      //--- If the button is pressed
      if(lparam==m_button7.Id())
        {
         m_button7.IsLocked(true);
         m_button8.IsLocked(false);
        }
      else if(lparam==m_button8.Id())
        {
         m_button7.IsLocked(false);
         m_button8.IsLocked(true);
        }
      //---
      if(lparam==m_button9.Id())
        {
         m_button9.IsLocked(true);
         m_button10.IsLocked(false);
         m_button11.IsLocked(false);
         m_pattern_size=1;
        }
      else if(lparam==m_button10.Id())
        {
         m_button10.IsLocked(true);
         m_button9.IsLocked(false);
         m_button11.IsLocked(false);
         m_pattern_size=2;
        }
      else if(lparam==m_button11.Id())
        {
         m_button11.IsLocked(true);
         m_button9.IsLocked(false);
         m_button10.IsLocked(false);
         m_pattern_size=3;
        }
      //---
      if(lparam==m_button1.Id())
        {
         m_candle_index=1;
         m_window2.OpenWindow();
         val=(m_lang_index==0)?"Настройка — Длинные свечи":"Setting — Long candles";
         m_window2.LabelText(val);
         val=(m_lang_index==0)?"Тело>(усредненное тело последних пяти свечей)*K1":"Body > (average body of the last five candles)*K1";
         m_text_label3.LabelText(val);
         m_candle_coef1.SetValue((string)m_long_coef);
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button2.Id())
        {
         m_candle_index=2;
         m_window2.OpenWindow();
         val=(m_lang_index==0)?"Настройка — Короткие свечи":"Setting — Short candles";
         m_window2.LabelText(val);
         val=(m_lang_index==0)?"Тело<(усредненное тело последних пяти свечей)*K1":"Body < (average body of the last five candles)*K1";
         m_text_label3.LabelText(val);
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.SetValue((string)m_short_coef);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button3.Id())
        {
         m_candle_index=3;
         m_window2.OpenWindow();
         val=(m_lang_index==0)?"Настройка — Волчки":"Setting — Spin";
         m_window2.LabelText(val);
         val=(m_lang_index==0)?"Нижняя тень > тело*K1  и  Верхняя тень > тело*K1":"Lower shadow>boby*K1 & Upper shadow>body*K1";
         m_text_label3.LabelText(val);
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.SetValue((string)m_spin_coef);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button4.Id())
        {
         m_candle_index=4;
         m_window2.OpenWindow();
         val=(m_lang_index==0)?"Настройка — Доджи":"Setting — Doji";
         m_window2.LabelText("Setup - Doji");
         val=(m_lang_index==0)?"Тело доджи < (диапазон от макс. to Low цены)*K1":"Doji body < (High-Low)+K1";
         m_text_label3.LabelText(val);
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.SetValue((string)m_doji_coef);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button5.Id())
        {
         m_candle_index=5;
         m_window2.OpenWindow();
         val=(m_lang_index==0)?"Настройка — Марибозу":"Setting — Marubozu";
         m_window2.LabelText(val);
         val=(m_lang_index==0)?"Нижняя тень < тело*K1  и  Верхняя тень < тело*K1":"Lower shadow<boby*K1 & Upper shadow<body*K1";
         m_text_label3.LabelText(val);
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.SetValue((string)m_maribozu_coef);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button6.Id())
        {
         m_candle_index=6;
         m_window2.OpenWindow();
         val=(m_lang_index==0)?"Настройка — Молот":"Setting — Hammer";
         m_window2.LabelText(val);
         val=(m_lang_index==0)?"Нижняя тень > тело*K1  и  Верхняя тень < тело*K2":"Lower shadow>boby*K1 & Upper shadow<body*K2";
         m_text_label3.LabelText(val);
         m_candle_coef2.IsLocked(false);
         m_candle_coef1.SetValue((string)m_hummer_coef1);
         m_candle_coef2.SetValue((string)m_hummer_coef2);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_candle_coef2.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      //---
      if(lparam==m_cancel.Id())
        {
         m_window2.CloseDialogBox();
        }
      //---
      else if(lparam==m_save.Id())
        {
         switch(m_candle_index)
           {
            case 1:
               m_long_coef=(double)m_candle_coef1.GetValue();
               break;
            case 2:
               m_short_coef=(double)m_candle_coef1.GetValue();
               break;
            case 3:
               m_spin_coef=(double)m_candle_coef1.GetValue();
               break;
            case 4:
               m_doji_coef=(double)m_candle_coef1.GetValue();
               break;
            case 5:
               m_maribozu_coef=(double)m_candle_coef1.GetValue();
               break;
            case 6:
               m_hummer_coef1=(double)m_candle_coef1.GetValue();
               m_hummer_coef2=(double)m_candle_coef2.GetValue();
               break;
            default:
               break;
           }
         m_candle_index=0;
         m_window2.CloseDialogBox();
        }
     }
  }
//+------------------------------------------------------------------+
//| Create the graphical interface of the program                    |
//+------------------------------------------------------------------+
bool CProgram::CreateGUI(void)
  {
//--- Creating a panel
   if(!CreateWindow("Pattern Analyzer 2.0"))
      return(false);
//--- Creating a dialog window
   if(!CreateWindowSetting("Настройки"))
      return(false);
//--- Finishing the creation of GUI
   CWndEvents::CompletedGUI();
   return(true);
  }
//+-----------------------------------------------------------------
