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
   CAND_MARIBOZU,       //Maribozu
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
//| Class for creating an application                                |
//+------------------------------------------------------------------+
class CProgram : public CWndEvents
  {
protected:
   //--- Main window
   CWindow           m_window1;
   CWindow           m_window2;
   //--- Status bar
   CStatusBar        m_status_bar;
   //--- Tabs
   CTabs             m_tabs1;
   //--- Input fields
   CTextEdit         m_coef1;
   CTextEdit         m_coef2;
   CTextEdit         m_coef3;
   CTextEdit         m_threshold;
   CTextEdit         m_symb_filter;
   CTextEdit         m_range;
   CTextEdit         m_candle_coef1;
   CTextEdit         m_candle_coef2;
   //--- Buttons
   CButton           m_request;
   CButton           m_button1;
   CButton           m_button2;
   CButton           m_button3;
   CButton           m_button4;
   CButton           m_button5;
   CButton           m_button6;
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
   CTable            m_table;
   CTable            m_symb_table;
   //--- Text labels
   CTextLabel        m_text_label1;
   CTextLabel        m_text_label2;
   CTextLabel        m_text_label3;
   //--- Combo boxes
   CComboBox         m_timeframes;
   //--- Time counters
   CTimeCounter      m_counter1;
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
   int               m_range_total;
   ENUM_TIMEFRAMES   m_timeframe;
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

protected:
   //--- Main window
   bool              CreateWindow(const string text);
   bool              CreateWindowSetting(const string text);
   //--- Status bar
   bool              CreateStatusBar(const int x_gap,const int y_gap);
   //--- Tab
   bool              CreateTabs(const int x_gap,const int y_gap);
   //---
   bool              CreateSymbolsFilter(const int x_gap,const int y_gap,const string text);
   bool              CreateRequest(const int x_gap,const int y_gap,const string text);
   bool              CreateRange(const int x_gap,const int y_gap,const string text);
   //--- Tables
   bool              CreateTable(const int x_gap,const int y_gap);
   bool              CreateSymbTable(const int x_gap,const int y_gap);
   //--- Input fields
   bool              CreateCoef(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const double value);
   bool              CreateThresholdValue(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const double value);
   bool              CreateSettingCoef(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const double value);
   //---
   bool              CreateCandle(CPicture &pic,CButton &button,const int x_gap,const int y_gap,const string path);
   //--- Button
   bool              CreateButton(CPicture &pic,CButton &button,const string path="");
   //--- Text label
   bool              CreateTextLabel(CTextLabel &text_label,const int x_gap,const int y_gap,string label_text);
   bool              CreateSettingTextLabel(CTextLabel &text_label,const int x_gap,const int y_gap,string label_text);
   //--- Combo box
   bool              CreateComboBoxTF(const int x_gap,const int y_gap,const string text);
   //---
   bool              CreateSaveButton(const int x_gap,const int y_gap,const string text);
   //---
   bool              CreateCancelButton(const int x_gap,const int y_gap,const string text);

private:
   //--- Symbols for trading
   string            m_symbols[];
   //--- Requesting data
   bool              RequestData(const long id);
   //--- Get symbols
   void              GetSymbols(void);
   //--- Changing the symbol
   bool              ChangeSymbol(const long id);
   //--- Changing the period
   bool              ChangePeriod(const long id);
   //--- Rebuilding the table
   void              RebuildingTables(void);
   //--- Recognizing candlestick type
   bool              CandleType(const string symbol,CANDLE_STRUCTURE &res,const int shift);
   //--- Recognizing patterns
   bool              PatternType(const string symbol);
   //--- Output of results in a table
   void              BuildingPatternTable(void);
   //---
   void              SetAnalyzeData(string pattern_name,int row,int patterns_total,int model_type);
   //--- Determining the profit categories
   bool              GetCategory(const string symbol,const int shift,int &category[]);
   //--- Calculating coefficients for the table
   bool              CoefCalculation(const int row,int &category[],int found);
  };
//+------------------------------------------------------------------+
//| Creating controls                                                |
//+------------------------------------------------------------------+
#include "MainWindow.mqh"
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgram::CProgram(void)
  {
//--- Setting parameters for the time counters
   m_counter1.SetParameters(16,100);
//---
   m_long_coef=1.3;
   m_short_coef=0.5;
   m_doji_coef=0.04;
   m_maribozu_coef=0.01;
   m_spin_coef=1;
   m_hummer_coef1=0.1;
   m_hummer_coef2=2;
   m_candle_index=0;
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
      string tf=m_timeframes.GetListViewPointer().SelectedItemText();
      m_timeframe=StringToTimeframe(tf);
      m_range_total=(int)m_range.GetValue();
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
      RequestData(m_request.Id());
      return;
     }
//--- Event of pressing on the list view item or table
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM)
     {
      //--- Changing the symbol
      if(ChangeSymbol(lparam))
         Update(true);
     }
//--- Selection of an item in a combo box
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_COMBOBOX_ITEM)
     {
      //--- Timeframe change
      if(ChangePeriod(lparam))
         Update(true);
     }
//---
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_BUTTON)
     {
      //--- Requesting data
      if(RequestData(lparam))
         return;
      //--- If the button is pressed
      if(lparam==m_button1.Id())
        {
         m_candle_index=1;
         m_window2.OpenWindow();
         m_window2.LabelText("Setup - Long candlesticks");
         m_text_label3.LabelText("Body > (average body over the last 5 days)*K1");
         m_candle_coef1.SetValue((string)m_long_coef);
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button2.Id())
        {
         m_candle_index=2;
         m_window2.OpenWindow();
         m_window2.LabelText("Setup - Short candlesticks");
         m_text_label3.LabelText("Body < (average body over the last 5 days)*K1");
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.SetValue((string)m_short_coef);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button3.Id())
        {
         m_candle_index=3;
         m_window2.OpenWindow();
         m_window2.LabelText("Setup - Spinning Top");
         m_text_label3.LabelText("Lower shadow > body*K1 and Upper shadow > body*K1");
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.SetValue((string)m_spin_coef);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button4.Id())
        {
         m_candle_index=4;
         m_window2.OpenWindow();
         m_window2.LabelText("Setup - Doji");
         m_text_label3.LabelText("Doji body < (range from High to Low price)*K1");
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.SetValue((string)m_doji_coef);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button5.Id())
        {
         m_candle_index=5;
         m_window2.OpenWindow();
         m_window2.LabelText("Setup - Marubozu");
         m_text_label3.LabelText("Lower shadow < body*K1 or Upper shadow < body*K1");
         m_candle_coef2.IsLocked(true);
         m_candle_coef1.SetValue((string)m_maribozu_coef);
         m_candle_coef1.GetTextBoxPointer().Update(true);
         m_text_label3.Update(true);
        }
      else if(lparam==m_button6.Id())
        {
         m_candle_index=6;
         m_window2.OpenWindow();
         m_window2.LabelText("Setup - Hammer");
         m_text_label3.LabelText("Lower shadow > body*K1 and Upper shadow < body*K2");
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
   if(!CreateWindow("Pattern Analyzer"))
      return(false);
//--- Creating a dialog window
   if(!CreateWindowSetting("Settings"))
      return(false);
//--- Finishing the creation of GUI
   CWndEvents::CompletedGUI();
   return(true);
  }
//+-----------------------------------------------------------------
