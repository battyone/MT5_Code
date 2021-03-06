//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
//+------------------------------------------------------------------+
//| Creates a form for controls                                      |
//+------------------------------------------------------------------+
bool CProgram::CreateWindow(const string caption_text)
  {
//--- Add the pointer to the window array
   CWndContainer::AddWindow(m_window1);
//--- Properties
   m_window1.XSize(750);
   m_window1.YSize(500);
   m_window1.FontSize(9);
   m_window1.IsMovable(true);
   m_window1.CloseButtonIsUsed(true);
   m_window1.CollapseButtonIsUsed(true);
   m_window1.FullscreenButtonIsUsed(true);
//--- Creating the form
   if(!m_window1.CreateWindow(m_chart_id,m_subwin,caption_text,5,5))
      return(false);
//--- Tabs
   if(!CreateTabs(3,43))
      return(false);
//--- Input fields
   if(!CreateSymbolsFilter(10,10,"Symbols:"))
      return(false);
   if(!CreateRequest(250,10,"Search"))
      return(false);
   if(!CreateRange(485,10,"Range:"))
      return(false);
//--- Combo boxes
   if(!CreateComboBoxTF(350,10,"Timeframes:"))
      return(false);
//--- Creating a table of symbols
   if(!CreateSymbTable(10,50))
      return(false);
//--- Creating a table of results
   if(!CreateTable(120,50))
      return(false);
//--- Status bar
   if(!CreateStatusBar(1,26))
      return(false);
//--- Creating candlestick settings
   if(!CreateCandle(m_picture1,m_button1,10,10,"Images\\EasyAndFastGUI\\Candles\\long.bmp"))
      return(false);
   if(!CreateCandle(m_picture2,m_button2,104,10,"Images\\EasyAndFastGUI\\Candles\\short.bmp"))
      return(false);
   if(!CreateCandle(m_picture3,m_button3,198,10,"Images\\EasyAndFastGUI\\Candles\\spin.bmp"))
      return(false);
   if(!CreateCandle(m_picture4,m_button4,292,10,"Images\\EasyAndFastGUI\\Candles\\doji.bmp"))
      return(false);
   if(!CreateCandle(m_picture5,m_button5,386,10,"Images\\EasyAndFastGUI\\Candles\\maribozu.bmp"))
      return(false);
   if(!CreateCandle(m_picture6,m_button6,480,10,"Images\\EasyAndFastGUI\\Candles\\hammer.bmp"))
      return(false);
//--- Text labels
   if(!CreateTextLabel(m_text_label1,10,100,"Weight coefficients"))
      return(false);
   if(!CreateTextLabel(m_text_label2,10,200,"Threshold trend value in points"))
      return(false);
//--- Input fields
   if(!CreateCoef(m_coef1,10,140,"K1",1))
      return(false);
   if(!CreateCoef(m_coef2,100,140,"K2",0.5))
      return(false);
   if(!CreateCoef(m_coef3,200,140,"K3",0.25))
      return(false);
   if(!CreateThresholdValue(m_threshold,10,240,"",50))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates form 2 for controls                                      |
//+------------------------------------------------------------------+
bool CProgram::CreateWindowSetting(const string caption_text)
  {
//--- Add the pointer to the window array
   CWndContainer::AddWindow(m_window2);
//--- Coordinates
   int x=(m_window2.X()>0) ? m_window2.X() : 100;
   int y=(m_window2.Y()>0) ? m_window2.Y() : 200;
//--- Properties
   m_window2.IsMovable(true);
   m_window2.XSize(300);
   m_window2.YSize(300);
   m_window2.CloseButtonIsUsed(true);
   m_window2.WindowType(W_DIALOG);

//--- Creating the form
   if(!m_window2.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
//--- Text label
   if(!CreateSettingTextLabel(m_text_label3,10,40,""))
      return(false);
//--- Input fields
   if(!CreateSettingCoef(m_candle_coef1,10,73,"K1",0.55))
      return(false);
   if(!CreateSettingCoef(m_candle_coef2,10,108,"K2",0.55))
      return(false);
//--- Save button
   if(!CreateSaveButton(100,250,"Save"))
      return(false);
//--- Cancel button
   if(!CreateCancelButton(200,250,"Cancel"))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the status bar                                           |
//+------------------------------------------------------------------+

bool CProgram::CreateStatusBar(const int x_gap,const int y_gap)
  {
#define STATUS_LABELS_TOTAL 1
//--- Save the pointer to the main control
   m_status_bar.MainPointer(m_window1);

//--- Properties
   m_status_bar.YSize(25);
   m_status_bar.AutoXResizeMode(true);
   m_status_bar.AutoXResizeRightOffset(1);
   m_status_bar.AnchorBottomWindowSide(true);
   m_status_bar.AddItem(0);
//--- Add the text
   m_status_bar.SetValue(0,"No symbol selected for analysis");

//--- Create a control
   if(!m_status_bar.CreateStatusBar(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_status_bar);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a group with tabs 1                                       |
//+------------------------------------------------------------------+
bool CProgram::CreateTabs(const int x_gap,const int y_gap)
  {
#define TABS1_TOTAL 2
//--- Save the pointer to the main control
   m_tabs1.MainPointer(m_window1);
//--- Properties
   m_tabs1.IsCenterText(true);
   m_tabs1.PositionMode(TABS_TOP);
   m_tabs1.AutoXResizeMode(true);
   m_tabs1.AutoYResizeMode(true);
   m_tabs1.AutoXResizeRightOffset(3);
   m_tabs1.AutoYResizeBottomOffset(25);
   m_tabs1.FontSize(12);
//--- Add tabs with the specified properties
   string tabs_names[TABS1_TOTAL]={"Analyze","Settings"};
   for(int i=0; i<TABS1_TOTAL; i++)
      m_tabs1.AddTab(tabs_names[i],150);
//--- Create a control
   if(!m_tabs1.CreateTabs(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_tabs1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a checkbox with the "Symbols filter" input field          |
//+------------------------------------------------------------------+
bool CProgram::CreateSymbolsFilter(const int x_gap,const int y_gap,const string text)
  {
//--- Save the pointer to the main control
   m_symb_filter.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(0,m_symb_filter);
//--- Properties
   m_symb_filter.SetValue("USD"); // "EUR,USD" "EURUSD,GBPUSD" "EURUSD,GBPUSD,AUDUSD,NZDUSD,USDCHF"
   m_symb_filter.CheckBoxMode(true);
   m_symb_filter.AutoXResizeMode(true);
   m_symb_filter.AutoXResizeRightOffset(500);
   m_symb_filter.GetTextBoxPointer().XGap(65);
   m_symb_filter.GetTextBoxPointer().XSize(160);
   m_symb_filter.GetTextBoxPointer().AutoSelectionMode(true);
   m_symb_filter.GetTextBoxPointer().DefaultText("Example: EURUSD,GBP,USD");
//--- Create a control
   if(!m_symb_filter.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Enable the checkbox
   m_symb_filter.IsPressed(true);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_symb_filter);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a button for updating the symbol list                     |
//+------------------------------------------------------------------+
bool CProgram::CreateRequest(const int x_gap,const int y_gap,const string text)
  {
//--- Save the pointer to the main control
   m_request.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(0,m_request);
//--- Properties
   m_request.XSize(80);
   m_request.IsCenterText(true);
//--- Create a control
   if(!m_request.CreateButton(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,m_request);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create an entry field for a data range                          |
//+------------------------------------------------------------------+
bool CProgram::CreateRange(const int x_gap,const int y_gap,const string text)
  {
//--- Save the pointer to the main control
   m_range.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(0,m_range);
//--- Properties
   m_range.XSize(100);
   m_range.MaxValue(100000);
   m_range.MinValue(4);
   m_range.StepValue(1);
   m_range.SetDigits(0);
   m_range.SpinEditMode(true);
   m_range.SetValue((string)8000);
   m_range.GetTextBoxPointer().XSize(50);
   m_range.GetTextBoxPointer().AutoSelectionMode(true);
   m_range.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_range.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_range);
   m_range_total=(int)m_range.GetValue();
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a rendered table                                          |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\arrow_up.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\arrow_down.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\circle_gray.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\calendar.bmp"
//---
bool CProgram::CreateTable(const int x_gap,const int y_gap)
  {
#define COLUMNS1_TOTAL 7
//--- Save the pointer to the main control
   m_table.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(0,m_table);

//--- Array of column widths
   int width[COLUMNS1_TOTAL];
   ::ArrayInitialize(width,80);
   width[0]=100;
   width[2]=100;

//--- Array of text offset along the X axis in the columns
   int text_x_offset[COLUMNS1_TOTAL];
   ::ArrayInitialize(text_x_offset,7);
//--- Array of text alignment in columns
   ENUM_ALIGN_MODE align[COLUMNS1_TOTAL];
   ::ArrayInitialize(align,ALIGN_CENTER);
//--- Properties
   m_table.XSize(602);
   m_table.YSize(100);
   m_table.CellYSize(20);
   m_table.TableSize(COLUMNS1_TOTAL,0);
   m_table.TextAlign(align);
   m_table.ColumnsWidth(width);
   m_table.TextXOffset(text_x_offset);
   m_table.ShowHeaders(true);
   m_table.IsSortMode(false);
   m_table.LightsHover(true);
   m_table.IsWithoutDeselect(true);
   m_table.IsZebraFormatRows(clrWhiteSmoke);
   m_table.AutoYResizeMode(true);
   m_table.AutoYResizeBottomOffset(5);
   m_table.HeadersColor(C'0,130,225');
   m_table.HeadersColorHover(clrCornflowerBlue);
   m_table.HeadersTextColor(clrWhite);
   m_table.DataType(1,TYPE_INT);
   m_table.DataType(2,TYPE_DOUBLE);
   m_table.DataType(3,TYPE_DOUBLE);
   m_table.DataType(4,TYPE_DOUBLE);
   m_table.DataType(5,TYPE_DOUBLE);
   m_table.DataType(6,TYPE_DOUBLE);

//--- Create a control
   if(!m_table.CreateTable(x_gap,y_gap))
      return(false);
//--- Set the header titles
   m_table.SetHeaderText(0,"Pattern name");
   m_table.SetHeaderText(1,"Found");
   m_table.SetHeaderText(2,"Occurrence,%");
   m_table.SetHeaderText(3,"P,Uptrend");
   m_table.SetHeaderText(4,"P,DnTrend");
   m_table.SetHeaderText(5,"K,UpTrend");
   m_table.SetHeaderText(6,"K,DnTrend");
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_table);
//m_table.SortData(9);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a symbol table                                         |
//+------------------------------------------------------------------+
bool CProgram::CreateSymbTable(const int x_gap,const int y_gap)
  {
//--- Save the pointer to the main control
   m_symb_table.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(0,m_symb_table);
//--- Array of column widths
   int width[1]={100};
//--- Array of text alignment in columns
   ENUM_ALIGN_MODE align[1]={ALIGN_CENTER};
//--- Array of text offset along the X axis in the columns
   int text_x_offset[1]={5};
//--- Properties
   m_symb_table.XSize(105);
   m_symb_table.TableSize(1,1);
   m_symb_table.ColumnsWidth(width);
   m_symb_table.TextAlign(align);
   m_symb_table.TextXOffset(text_x_offset);
   m_symb_table.ShowHeaders(true);
   m_symb_table.LightsHover(true);
   m_symb_table.SelectableRow(true);
   m_symb_table.IsZebraFormatRows(clrWhiteSmoke);
   m_symb_table.AutoYResizeMode(true);
   m_symb_table.AutoYResizeBottomOffset(5);
   m_symb_table.HeadersColor(C'0,130,225');
   m_symb_table.HeadersTextColor(clrWhite);
//--- Create a control
   if(!m_symb_table.CreateTable(x_gap,y_gap))
      return(false);
//--- Set the header titles
   m_symb_table.SetHeaderText(0,"Symbol");
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_symb_table);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a candlestick                                             |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\settings_dark.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\long.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\short.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\doji.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\spin.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\maribozu.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\hammer.bmp"
//---
bool CProgram::CreateCandle(CPicture &pic,CButton &button,const int x_gap,const int y_gap,string path)
  {
//--- Save the pointer to the main control
   pic.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(1,pic);
//--- Properties
   pic.XSize(64);
   pic.YSize(64);
   pic.IconFile(path);
//--- Create a button
   if(!pic.CreatePicture(x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,pic);
   CreateButton(pic,button,"Images\\EasyAndFastGUI\\Icons\\bmp16\\settings_dark.bmp");
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a button with an image                                    |
//+------------------------------------------------------------------+
bool CProgram::CreateButton(CPicture &pic,CButton &button,string path="")
  {
//--- Save the pointer to the main control
   button.MainPointer(pic);
//--- Attach to tab
   m_tabs1.AddToElementsArray(1,button);
//--- Properties
   button.XSize(20);
   button.YSize(20);
   button.IconXGap(2);
   button.IconYGap(2);
   button.IconFile(path);
//--- Create a control
   if(!button.CreateButton("",pic.XSize()-button.XSize()/2,0))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a text label on the first tab                             |
//+------------------------------------------------------------------+
bool CProgram::CreateTextLabel(CTextLabel &text_label,const int x_gap,const int y_gap,string label_text)
  {
//--- Save the window pointer
   text_label.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(1,text_label);
//---
   text_label.FontSize(12);
   text_label.XSize(300);
//--- Create a button
   if(!text_label.CreateTextLabel(label_text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,text_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the combo box for selecting timeframes                    |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxTF(const int x_gap,const int y_gap,const string text)
  {
//--- Total number of the list view items
#define ITEMS_TOTAL2 21
//--- Pass the object to the panel
   m_timeframes.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(0,m_timeframes);
//--- Properties
   m_timeframes.XSize(115);
   m_timeframes.ItemsTotal(ITEMS_TOTAL2);
   m_timeframes.GetButtonPointer().XSize(50);
   m_timeframes.GetButtonPointer().AnchorRightWindowSide(true);
//--- Save the item values in the combo box list view
   string items_text[ITEMS_TOTAL2]={"M1","M2","M3","M4","M5","M6","M10","M12","M15","M20","M30","H1","H2","H3","H4","H6","H8","H12","D1","W1","MN"};
   for(int i=0; i<ITEMS_TOTAL2; i++)
      m_timeframes.SetValue(i,items_text[i]);
//--- Get the list view pointer
   CListView *lv=m_timeframes.GetListViewPointer();
//--- Set the list view properties
   lv.LightsHover(true);
   lv.SelectItem(4);
//--- Create a control
   if(!m_timeframes.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,m_timeframes);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create an entry field for the weight coefficient                 |
//+------------------------------------------------------------------+
bool CProgram::CreateCoef(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const double value)
  {
//--- Save the pointer to the main control
   text_edit.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(1,text_edit);
//--- Properties
   text_edit.XSize(80);
   text_edit.MaxValue(1000);
   text_edit.MinValue(0.01);
   text_edit.StepValue(0.01);
   text_edit.SetDigits(2);
   text_edit.SpinEditMode(true);
   text_edit.SetValue((string)value);
   text_edit.GetTextBoxPointer().XSize(50);
   text_edit.GetTextBoxPointer().AutoSelectionMode(true);
   text_edit.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!text_edit.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,text_edit);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create an entry field for the threshold profit value             |
//+------------------------------------------------------------------+
bool CProgram::CreateThresholdValue(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const double value)
  {
//--- Save the pointer to the main control
   text_edit.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(1,text_edit);
//--- Properties
   text_edit.XSize(80);
   text_edit.MaxValue(1000);
   text_edit.MinValue(1);
   text_edit.SpinEditMode(true);
   text_edit.SetValue((string)value);
   text_edit.GetTextBoxPointer().XSize(50);
   text_edit.GetTextBoxPointer().AutoSelectionMode(true);
   text_edit.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!text_edit.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,text_edit);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool CProgram::CreateSettingTextLabel(CTextLabel &text_label,const int x_gap,const int y_gap,string label_text)
  {
//--- Save the window pointer
   text_label.MainPointer(m_window2);
//---
   text_label.FontSize(9);
   text_label.XSize(280);
//--- Create a button
   if(!text_label.CreateTextLabel(label_text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(1,text_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create an entry field for the weight coefficient                 |
//+------------------------------------------------------------------+
bool CProgram::CreateSettingCoef(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const double value)
  {
//--- Save the pointer to the main control
   text_edit.MainPointer(m_window2);
//--- Properties
   text_edit.XSize(80);
   text_edit.MaxValue(5);
   text_edit.MinValue(0.01);
   text_edit.StepValue(0.01);
   text_edit.SetDigits(2);
   text_edit.SpinEditMode(true);
   text_edit.SetValue((string)value);
   text_edit.GetTextBoxPointer().XSize(50);
   text_edit.GetTextBoxPointer().AutoSelectionMode(true);
   text_edit.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!text_edit.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(1,text_edit);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a button for updating the symbol list                     |
//+------------------------------------------------------------------+
bool CProgram::CreateSaveButton(const int x_gap,const int y_gap,const string text)
  {
//--- Save the pointer to the main control
   m_save.MainPointer(m_window2);
//--- Properties
   m_save.XSize(80);
   m_save.YSize(30);
   m_save.FontSize(10);
   m_save.IsCenterText(true);
//--- Create a control
   if(!m_save.CreateButton(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(1,m_save);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a button for updating the symbol list                     |
//+------------------------------------------------------------------+
bool CProgram::CreateCancelButton(const int x_gap,const int y_gap,const string text)
  {
//--- Save the pointer to the main control
   m_cancel.MainPointer(m_window2);
//--- Properties
   m_cancel.XSize(80);
   m_cancel.YSize(30);
   m_cancel.FontSize(10);
   m_cancel.IsCenterText(true);
//--- Create a control
   if(!m_cancel.CreateButton(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(1,m_cancel);
   return(true);
  }
//+------------------------------------------------------------------+
//| Data request                                                     |
//+------------------------------------------------------------------+
bool CProgram::RequestData(const long id)
  {
//--- Check the element ID
   if(id!=m_request.Id())
      return(false);
//--- Hide the table
   m_symb_table.Hide();
//--- Initializing the chart and the table
   GetSymbols();
   RebuildingTables();
//--- Get the value from the combo box drop-down list
   string tf=m_timeframes.GetListViewPointer().SelectedItemText();
//--- Show the table
   m_symb_table.Show();
   return(true);
  }
//+------------------------------------------------------------------+
//| Get symbols                                                      |
//+------------------------------------------------------------------+
void CProgram::GetSymbols(void)
  {
//--- Release the symbol array
   ::ArrayFree(m_symbols);
//--- Array of row elements
   string elements[];
//--- Symbol name filter
   if(m_symb_filter.IsPressed())
     {
      string text=m_symb_filter.GetValue();
      if(text=="MAJOR" || text=="Major" || text=="major")
         text="EURUSD,GBPUSD,AUDUSD,NZDUSD,USDCHF,USDJPY,USDCAD";
      if(text!="")
        {
         ushort sep=::StringGetCharacter(",",0);
         ::StringSplit(text,sep,elements);
         //---
         int elements_total=::ArraySize(elements);
         for(int e=0; e<elements_total; e++)
           {
            //--- Clearing the edges
            ::StringTrimLeft(elements[e]);
            ::StringTrimRight(elements[e]);
           }
        }
     }
//--- Assemble the array of Forex symbols
   int symbols_total=::SymbolsTotal(false);
   for(int i=0; i<symbols_total; i++)
     {
      //--- Get the symbol name
      string symbol_name=::SymbolName(i,false);
      //--- Hide it in the Market Watch window
      ::SymbolSelect(symbol_name,false);
      //--- If not a Forex symbol, go to the next one
      if(::SymbolInfoInteger(symbol_name,SYMBOL_TRADE_CALC_MODE)!=SYMBOL_CALC_MODE_FOREX)
         continue;
      //--- Symbol name filter
      if(m_symb_filter.IsPressed())
        {
         bool check=false;
         int elements_total=::ArraySize(elements);
         for(int e=0; e<elements_total; e++)
           {
            //--- Search for a match in a symbol name
            if(::StringFind(symbol_name,elements[e])>-1)
              {
               check=true;
               break;
              }
           }
         //--- Go to the next one if not passed by the filter
         if(!check)
            continue;
        }
      //--- Save a symbol to the array
      int array_size=::ArraySize(m_symbols);
      ::ArrayResize(m_symbols,array_size+1);
      m_symbols[array_size]=symbol_name;
     }
//--- If the array is empty, set the current symbol as a default one
   int array_size=::ArraySize(m_symbols);
   if(array_size<1)
     {
      ::ArrayResize(m_symbols,array_size+1);
      m_symbols[array_size]=::Symbol();
     }
//--- Display in the Market Watch window
   int selected_symbols_total=::ArraySize(m_symbols);
   for(int i=0; i<selected_symbols_total; i++)
      ::SymbolSelect(m_symbols[i],true);
  }
//+------------------------------------------------------------------+
//| Rebuild the table of symbols                                     |
//+------------------------------------------------------------------+
void CProgram::RebuildingTables(void)
  {
//--- Delete all rows
   m_symb_table.DeleteAllRows();
//--- Set the number of rows by the number of symbols
   int symbols_total=::ArraySize(m_symbols);
   for(int i=0; i<symbols_total-1; i++)
      m_symb_table.AddRow(i);
//--- Set the values to the first column
   uint rows_total=m_symb_table.RowsTotal();
   for(uint r=0; r<(uint)rows_total; r++)
     {
      //--- Set the values
      m_symb_table.SetValue(0,r,m_symbols[r]);
     }
//--- Update the table
   m_symb_table.Update(true);
   m_symb_table.GetScrollVPointer().Update(true);
   m_symb_table.GetScrollHPointer().Update(true);
  }
//+------------------------------------------------------------------+
//| Symbol change                                                    |
//+------------------------------------------------------------------+
bool CProgram::ChangeSymbol(const long id)
  {
//--- Check the element ID
   if(id!=m_symb_table.Id())
      return(false);
//--- Exit if the line is not highlighted
   if(m_symb_table.SelectedItem()==WRONG_VALUE)
     {
      //--- Show full symbol description in the status bar
      m_status_bar.SetValue(0,"No symbol selected for analysis");
      m_status_bar.GetItemPointer(0).Update(true);
      return(false);
     }
//--- Get a symbol
   string symbol=m_symb_table.GetValue(0,m_symb_table.SelectedItem());
//--- Show full symbol description in the status bar
   m_status_bar.SetValue(0,"Selected symbol: "+::SymbolInfoString(symbol,SYMBOL_DESCRIPTION));
   m_status_bar.GetItemPointer(0).Update(true);
   PatternType(symbol);
   return(true);
  }
//+------------------------------------------------------------------+
//| Timeframe change                                                 |
//+------------------------------------------------------------------+
bool CProgram::ChangePeriod(const long id)
  {
//--- Check the element ID
   if(id!=m_timeframes.Id() || m_symb_table.SelectedItem()==WRONG_VALUE)
      return(false);
//--- Get the value from the combo box drop-down list
   m_timeframe=StringToTimeframe(m_timeframes.GetListViewPointer().SelectedItemText());
//--- Get a symbol
   PatternType(m_symb_table.GetValue(0,m_symb_table.SelectedItem()));
   return(true);
  }
//+------------------------------------------------------------------+
//| Candlestick type recognition                                     |
//+------------------------------------------------------------------+
bool CProgram::CandleType(const string symbol,CANDLE_STRUCTURE &res,int shift)
  {
   MqlRates rt[];
   int aver_period=5;
   double ma[],aver;
   int copied=CopyRates(symbol,m_timeframe,shift,aver_period+1,rt);
//--- Get details of the previous candlestick
   if(copied<aver_period)
      return(false);
//---
   res.open=rt[aver_period].open;
   res.high=rt[aver_period].high;
   res.low=rt[aver_period].low;
   res.close=rt[aver_period].close;

//--- Determine the trend direction
   int InpInd_Handle1=iMA(symbol,m_timeframe,aver_period,0,MODE_SMA,PRICE_CLOSE);

   if(InpInd_Handle1==INVALID_HANDLE)
     {
      Print("Pattern Analyzer: Failed to get ma handle");
      Print("Handle = ",InpInd_Handle1,"  error = ",GetLastError());
      return(false);
     }

   if(CopyBuffer(InpInd_Handle1,0,shift,1,ma)<1)
      return(false);

   aver=ma[0];

   if(aver<res.close)
      res.trend=UPPER;
   if(aver>res.close)
      res.trend=DOWN;
   if(aver==res.close)
      res.trend=FLAT;
//--- Determine if it is a bullish or a bearish candlestick
   res.bull=res.open<res.close;
//--- Get the absolute size of candlestick body
   res.bodysize=MathAbs(res.open-res.close);
//--- Get sizes of shadows
   double shade_low=res.close-res.low;
   double shade_high=res.high-res.open;
   if(res.bull)
     {
      shade_low=res.open-res.low;
      shade_high=res.high-res.close;
     }
   double HL=res.high-res.low;
//--- Calculate average body size of previous candlesticks
   double sum=0;
   for(int i=1; i<=aver_period; i++)
      sum=sum+MathAbs(rt[i].open-rt[i].close);
   sum=sum/aver_period;

//--- Determine the candlestick type   
   res.type=CAND_NONE;
//--- long 
   if(res.bodysize>sum*m_long_coef)
      res.type=CAND_LONG;
//--- sort 
   if(res.bodysize<sum*m_short_coef)
      res.type=CAND_SHORT;
//--- doji
   if(res.bodysize<HL*m_doji_coef)
      res.type=CAND_DOJI;
//--- maribozu
   if((shade_low<res.bodysize*m_maribozu_coef || shade_high<res.bodysize*m_maribozu_coef) && res.bodysize>0)
      res.type=CAND_MARIBOZU;
//--- hammer
   if(shade_low>res.bodysize*m_hummer_coef2 && shade_high<res.bodysize*m_hummer_coef1)
      res.type=CAND_HAMMER;
//--- invert hammer
   if(shade_low<res.bodysize*m_hummer_coef1 && shade_high>res.bodysize*m_hummer_coef2)
      res.type=CAND_INVERT_HAMMER;
//--- spinning top
   if(res.type==CAND_SHORT && shade_low>res.bodysize*m_spin_coef && shade_high>res.bodysize*m_spin_coef)
      res.type=CAND_SPIN_TOP;
//---
   ArrayFree(rt);
   return(true);
  }
//+------------------------------------------------------------------+
//| Pattern recognition                                              |
//+------------------------------------------------------------------+
bool CProgram::PatternType(const string symbol)
  {
   CANDLE_STRUCTURE cand1,cand2;
//---
   m_hummer_total=0;
   m_invert_hummer_total=0;
   m_handing_man_total=0;
   m_shooting_star_total=0;
   m_engulfing_bull_total=0;
   m_engulfing_bear_total=0;
   m_harami_cross_bull_total=0;
   m_harami_cross_bear_total=0;
   m_harami_bull_total=0;
   m_harami_bear_total=0;
   m_doji_star_bull_total=0;
   m_doji_star_bear_total=0;
   m_piercing_line_total=0;
   m_dark_cloud_cover_total=0;

   int hummer_coef[],invert_hummer_coef[],handing_man_coef[],shooting_star_coef[],engulfing_bull_coef[],
   engulfing_bear_coef[],harami_cross_bull_coef[],harami_cross_bear_coef[],harami_bull_coef[],harami_bear_coef[],
   doji_star_bull_coef[],doji_star_bear_coef[],piercing_line_coef[],dark_cloud_cover_coef[];
   ArrayResize(hummer_coef,6);
   ArrayResize(invert_hummer_coef,6);
   ArrayResize(handing_man_coef,6);
   ArrayResize(shooting_star_coef,6);
   ArrayResize(engulfing_bull_coef,6);
   ArrayResize(engulfing_bear_coef,6);
   ArrayResize(harami_cross_bull_coef,6);
   ArrayResize(harami_cross_bear_coef,6);
   ArrayResize(harami_bull_coef,6);
   ArrayResize(harami_bear_coef,6);
   ArrayResize(doji_star_bull_coef,6);
   ArrayResize(doji_star_bear_coef,6);
   ArrayResize(piercing_line_coef,6);
   ArrayResize(dark_cloud_cover_coef,6);

   ArrayInitialize(hummer_coef,0);
   ArrayInitialize(invert_hummer_coef,0);
   ArrayInitialize(handing_man_coef,0);
   ArrayInitialize(shooting_star_coef,0);
   ArrayInitialize(engulfing_bull_coef,0);
   ArrayInitialize(engulfing_bear_coef,0);
   ArrayInitialize(harami_cross_bull_coef,0);
   ArrayInitialize(harami_cross_bear_coef,0);
   ArrayInitialize(harami_bull_coef,0);
   ArrayInitialize(harami_bear_coef,0);
   ArrayInitialize(doji_star_bull_coef,0);
   ArrayInitialize(doji_star_bear_coef,0);
   ArrayInitialize(piercing_line_coef,0);
   ArrayInitialize(dark_cloud_cover_coef,0);

//---
   for(int i=m_range_total;i>3;i--)
     {
      CandleType(symbol,cand2,i);                                                      // Previous candlestick
      CandleType(symbol,cand1,i-1);                                                    // Current candlestick

      //--- Inverted Hammer, bullish model
      if(cand2.trend==DOWN &&                                                             // Check the trend direction
         cand2.type==CAND_INVERT_HAMMER)                                                  // Checking "Inverted Hammer"
        {
         m_invert_hummer_total++;
         GetCategory(symbol,i-3,invert_hummer_coef);
        }

      //--- Hanging man, bearish
      if(cand2.trend==UPPER &&                                                            // Check the trend direction
         cand2.type==CAND_HAMMER)                                                         // Checking "Hammer"
        {
         m_handing_man_total++;
         GetCategory(symbol,i-3,handing_man_coef);
        }
      //--- Hammer, bullish model
      if(cand2.trend==DOWN &&                                                             // Check the trend direction
         cand2.type==CAND_HAMMER)                                                         // Checking "Hammer"
        {
         m_hummer_total++;
         GetCategory(symbol,i-3,hummer_coef);
        }
      //---
      //--- Shooting Star, bearish model
      if(cand1.trend==UPPER && cand2.trend==UPPER &&                                      // Check the trend direction
         cand2.type==CAND_INVERT_HAMMER && cand1.close<=cand2.open)                       // Checking "Inverted Hammer"
        {
         m_shooting_star_total++;
         GetCategory(symbol,i-4,shooting_star_coef);
        }

      //--- Engulfing, bullish model
      if(cand1.trend==DOWN && cand1.bull && cand2.trend==DOWN && !cand2.bull && // Check trend direction and candlestick direction
         cand1.bodysize>cand2.bodysize &&
         cand1.close>=cand2.open && cand1.open<cand2.close)
        {
         m_engulfing_bull_total++;
         GetCategory(symbol,i-4,engulfing_bull_coef);
        }

      //--- Engulfing, bearish model
      if(cand1.trend==UPPER && cand1.bull && cand2.trend==UPPER && !cand2.bull && // Check trend direction and candlestick direction
         cand1.bodysize<cand2.bodysize &&
         cand1.close<=cand2.open && cand1.open>cand2.close)
        {
         m_engulfing_bear_total++;
         GetCategory(symbol,i-4,engulfing_bear_coef);
        }

      //--- Harami Cross, bullish
      if(cand2.trend==DOWN && !cand2.bull &&                                              // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && cand1.type==CAND_DOJI && // Check the "long" first candlestick and the doji candlestick
         cand1.close<cand2.open && cand1.open>=cand2.close)                               // Doji is inside the first candlestick body
        {
         m_harami_cross_bull_total++;
         GetCategory(symbol,i-4,harami_cross_bull_coef);
        }

      //--- Harami Cross, bearish model
      if(cand2.trend==UPPER && cand2.bull &&                                              // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && cand1.type==CAND_DOJI && // Check the "long" first candlestick and the doji candlestick
         cand1.close>cand2.open && cand1.open<=cand2.close)                               // Doji is inside the first candlestick body
 
        {
         m_harami_cross_bear_total++;
         GetCategory(symbol,i-4,harami_cross_bear_coef);
        }

      //--- Harami, bullish
      if(cand1.trend==DOWN && cand1.bull && !cand2.bull &&                                // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU)  &&                         // Checking the "long" first candlestick
         cand1.type!=CAND_DOJI && cand1.bodysize<cand2.bodysize &&                        // the second candle is not Doji and first candlestick body is bigger than that of the second one
         cand1.close<cand2.open && cand1.open>=cand2.close)                               // body of the second candlestick is inside of body of the first one 
        {
         m_harami_bull_total++;
         GetCategory(symbol,i-4,harami_bull_coef);
        }

      //--- Harami, bearish
      if(cand1.trend==UPPER && !cand1.bull && cand2.bull &&                               // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) &&                          // Checking the "long" first candlestick
         cand1.type!=CAND_DOJI && cand1.bodysize<cand2.bodysize &&                        // the second candle is not Doji and first candlestick body is bigger than that of the second one
         cand1.close>cand2.open && cand1.open<=cand2.close)                               // body of the second candlestick is inside of body of the first one 
        {
         m_harami_bear_total++;
         GetCategory(symbol,i-4,harami_bear_coef);
        }

      //--- Doji Star, bullish
      if(cand1.trend==DOWN && !cand2.bull && // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && cand1.type==CAND_DOJI && // check 1st "long" candlestick and 2nd doji
         cand1.close<=cand2.open)                                                         // Doji Open is lower or equal to 1st candle Close 
        {
         m_doji_star_bull_total++;
         GetCategory(symbol,i-4,doji_star_bull_coef);
        }

      //--- Doji Star, bearish
      if(cand1.trend==UPPER && cand2.bull && // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && cand1.type==CAND_DOJI && // check 1st "long" candlestick and 2nd doji
         cand1.open>=cand2.close)                                                         //Doji Open price is higher or equal to 1st candle Close
        {
         m_doji_star_bear_total++;
         GetCategory(symbol,i-4,doji_star_bear_coef);
        }

      //--- Piercing, bullish model
      if(cand1.trend==DOWN && cand1.bull && !cand2.bull && // Check trend direction and candlestick direction
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU) && (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && // Check the "long" candlestick
         cand1.close>(cand2.close+cand2.open)/2 && // 2nd candle Close is above the middle of the 1st candlestick
         cand2.open>cand1.close && cand2.close>=cand1.open)
        {
         m_piercing_line_total++;
         GetCategory(symbol,i-4,piercing_line_coef);
        }

      //--- Dark Cloud Cover, bearish
      if(cand1.trend==UPPER && !cand1.bull && cand2.bull && // Check trend direction and candlestick direction
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU) && (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && // Check the "long" candlestick
         cand1.close<(cand2.close+cand2.open)/2 && // 2nd candle Close is below the middle of the 1st candlestick body
         cand1.close<cand2.open && cand2.close<=cand1.open)
        {
         m_dark_cloud_cover_total++;
         GetCategory(symbol,i-4,dark_cloud_cover_coef);
        }
     }

//---
   BuildingPatternTable();
   CoefCalculation(0,hummer_coef,m_hummer_total);
   CoefCalculation(1,invert_hummer_coef,m_invert_hummer_total);
   CoefCalculation(2,handing_man_coef,m_handing_man_total);
   CoefCalculation(3,shooting_star_coef,m_shooting_star_total);
   CoefCalculation(4,engulfing_bull_coef,m_engulfing_bull_total);
   CoefCalculation(5,engulfing_bear_coef,m_engulfing_bear_total);
   CoefCalculation(6,harami_cross_bull_coef,m_harami_cross_bull_total);
   CoefCalculation(7,harami_cross_bear_coef,m_harami_cross_bear_total);
   CoefCalculation(8,harami_bull_coef,m_harami_bull_total);
   CoefCalculation(9,harami_bear_coef,m_harami_bear_total);
   CoefCalculation(10,doji_star_bull_coef,m_doji_star_bull_total);
   CoefCalculation(11,doji_star_bear_coef,m_doji_star_bear_total);
   CoefCalculation(12,piercing_line_coef,m_piercing_line_total);
   CoefCalculation(13,dark_cloud_cover_coef,m_dark_cloud_cover_total);
   return(true);
  }
//+------------------------------------------------------------------+
//| Determine profit categories                                      |
//+------------------------------------------------------------------+
bool CProgram::GetCategory(const string symbol,const int shift,int &category[])
  {
   MqlRates rt[];
   int copied=CopyRates(symbol,m_timeframe,shift,4,rt);
   int rating=0;
//--- Get details of the previous candlestick
   if(copied<4)
      return(false);
   double high1,high2,high3,low1,low2,low3,close0,point;
   close0=rt[0].close;
   high1=rt[1].high;
   high2=rt[2].high;
   high3=rt[3].high;
   low1=rt[1].low;
   low2=rt[2].low;
   low3=rt[3].low;
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(false);

//--- Check if it is the Uptrend
   if((int)((high1-close0)/point)>=m_threshold_value)
     {
      category[0]++;
     }
   else if((int)((high2-close0)/point)>=m_threshold_value)
     {
      category[1]++;
     }
   else if((int)((high3-close0)/point)>=m_threshold_value)
     {
      category[2]++;
     }

//--- Check if it is the Downtrend

   if((int)((close0-low1)/point)>=m_threshold_value)
     {
      category[3]++;
     }
   else if((int)((close0-low2)/point)>=m_threshold_value)
     {
      category[4]++;
     }
   else if((int)((close0-low3)/point)>=m_threshold_value)
     {
      category[5]++;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculate efficiency assessment coefficients                     |
//+------------------------------------------------------------------+
bool CProgram::CoefCalculation(const int row,int &category[],int found)
  {
   double p1,p2,k1,k2;
   int sum1=0,sum2=0;
   for(int i=0;i<3;i++)
     {
      sum1+=category[i];
      sum2+=category[i+3];
     }
//---
   p1=(found>0)?NormalizeDouble((double)sum1/found*100,2):0;
   p2=(found>0)?NormalizeDouble((double)sum2/found*100,2):0;
   k1=(found>0)?NormalizeDouble((m_k1*category[0]+m_k2*category[1]+m_k3*category[2])/found,3):0;
   k2=(found>0)?NormalizeDouble((m_k1*category[3]+m_k2*category[4]+m_k3*category[5])/found,3):0;

   m_table.SetValue(3,row,(string)p1,2);
   m_table.SetValue(4,row,(string)p2,2);
   m_table.SetValue(5,row,(string)k1,2);
   m_table.SetValue(6,row,(string)k2,2);
//--- Update the table
   m_table.Update(true);
   m_table.GetScrollVPointer().Update(true);
   m_table.GetScrollHPointer().Update(true);
   return(true);
  }
//+------------------------------------------------------------------+
//| Re-arrange the table of patterns                                 |
//+------------------------------------------------------------------+
void CProgram::BuildingPatternTable(void)
  {
//--- Delete all rows
   m_table.DeleteAllRows();
//--- Set the number of rows by the number of symbols
   for(int i=0; i<13; i++)
      m_table.AddRow(i);
//---
   SetAnalyzeData("Hummer",0,m_hummer_total,1);
   SetAnalyzeData("Invert Hummer",1,m_invert_hummer_total,1);
   SetAnalyzeData("Handing Man",2,m_handing_man_total,-1);
   SetAnalyzeData("Shooting Star",3,m_shooting_star_total,-1);
   SetAnalyzeData("Engulfing Bull",4,m_engulfing_bull_total,1);
   SetAnalyzeData("Engulfing Bear",5,m_engulfing_bear_total,-1);
   SetAnalyzeData("Harami Cross Bull",6,m_harami_cross_bull_total,1);
   SetAnalyzeData("Harami Cross Bear",7,m_harami_cross_bear_total,-1);
   SetAnalyzeData("Harami Bull",8,m_harami_bull_total,1);
   SetAnalyzeData("Harami Bear",9,m_harami_bear_total,-1);
   SetAnalyzeData("Doji Star Bull",10,m_doji_star_bull_total,1);
   SetAnalyzeData("Doji Star Bear",11,m_doji_star_bear_total,-1);
   SetAnalyzeData("Piercing Line",12,m_piercing_line_total,1);
   SetAnalyzeData("Dark Cloud Cover",13,m_dark_cloud_cover_total,-1);

//--- Update the table
   m_table.Update(true);
   m_table.GetScrollVPointer().Update(true);
   m_table.GetScrollHPointer().Update(true);
  }
//+------------------------------------------------------------------+
//| Calculation of data for the table                                |
//+------------------------------------------------------------------+
void CProgram::SetAnalyzeData(string pattern_name,int row,int patterns_total,int model_type)
  {
   color clr=(model_type==1)?clrForestGreen:clrCrimson;
   m_table.SetValue(0,row,pattern_name);
   m_table.TextColor(0,row,clr);
   m_table.SetValue(1,row,(string)patterns_total);
   m_table.SetValue(2,row,(string)((double)patterns_total/m_range_total*100),2);
  }
//+------------------------------------------------------------------+
//| Returning the timeframe by string                                |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES StringToTimeframe(const string timeframe)
  {
   if(timeframe=="M1")  return(PERIOD_M1);
   if(timeframe=="M2")  return(PERIOD_M2);
   if(timeframe=="M3")  return(PERIOD_M3);
   if(timeframe=="M4")  return(PERIOD_M4);
   if(timeframe=="M5")  return(PERIOD_M5);
   if(timeframe=="M6")  return(PERIOD_M6);
   if(timeframe=="M10") return(PERIOD_M10);
   if(timeframe=="M12") return(PERIOD_M12);
   if(timeframe=="M15") return(PERIOD_M15);
   if(timeframe=="M20") return(PERIOD_M20);
   if(timeframe=="M30") return(PERIOD_M30);
   if(timeframe=="H1")  return(PERIOD_H1);
   if(timeframe=="H2")  return(PERIOD_H2);
   if(timeframe=="H3")  return(PERIOD_H3);
   if(timeframe=="H4")  return(PERIOD_H4);
   if(timeframe=="H6")  return(PERIOD_H6);
   if(timeframe=="H8")  return(PERIOD_H8);
   if(timeframe=="H12") return(PERIOD_H12);
   if(timeframe=="D1")  return(PERIOD_D1);
   if(timeframe=="W1")  return(PERIOD_W1);
   if(timeframe=="MN")  return(PERIOD_MN1);
//--- The default value
   return(::Period());
  }
//+------------------------------------------------------------------+
