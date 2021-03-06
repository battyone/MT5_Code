//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
//+------------------------------------------------------------------+
//| Creates the main application window                              |
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
   m_window1.TooltipsButtonIsUsed(true);
//--- Creating the form
   if(!m_window1.CreateWindow(m_chart_id,m_subwin,caption_text,5,5))
      return(false);
//--- Tabs
   if(!CreateTabs(3,43))
      return(false);
//--- The Analyze tab
//--- Edit fields
   if(!CreateSymbolsFilter(m_symb_filter1,10,10,"Symbol",0))
      return(false);
   if(!CreateRequest(m_request1,250,10,"Search",0))
      return(false);
   if(!CreateRange(m_range1,485,10,"Range",0))
      return(false);
//--- Comboboxes
   if(!CreateComboBoxTF(m_timeframes1,350,10,"Timeframe",0))
      return(false);
//--- Creating a table of symbols
   if(!CreateSymbTable(m_symb_table1,10,50,0))
      return(false);
//--- Creating a table of results
   if(!CreateTable1(m_table1,120,50,0))
      return(false);

//--- The AutoSearch tab
//--- Edit fields
   if(!CreateSymbolsFilter(m_symb_filter2,10,10,"Symbol",1))
      return(false);
   if(!CreateRequest(m_request2,250,10,"Поиск",1))
      return(false);
   if(!CreateRange(m_range2,485,10,"Range",1))
      return(false);
//--- Comboboxes
   if(!CreateComboBoxTF(m_timeframes2,350,10,"Timeframe",1))
      return(false);
//--- Creating a table of symbols
   if(!CreateSymbTable(m_symb_table2,10,50,1))
      return(false);
//--- Creating a table of results
   if(!CreateTable2(m_table2,120,50,1))
      return(false);

//--- The Settings tab
//--- Creating candlestick settings
   if(!CreateCandle(m_picture1,m_button1,m_candle_name1,"Long",10,10,"Images\\EasyAndFastGUI\\Candles\\long.bmp"))
      return(false);
   if(!CreateCandle(m_picture2,m_button2,m_candle_name2,"Short",104,10,"Images\\EasyAndFastGUI\\Candles\\short.bmp"))
      return(false);
   if(!CreateCandle(m_picture3,m_button3,m_candle_name3,"Spinning Top",198,10,"Images\\EasyAndFastGUI\\Candles\\spin.bmp"))
      return(false);
   if(!CreateCandle(m_picture4,m_button4,m_candle_name4,"Doji",292,10,"Images\\EasyAndFastGUI\\Candles\\doji.bmp"))
      return(false);
   if(!CreateCandle(m_picture5,m_button5,m_candle_name5,"Marubozu",386,10,"Images\\EasyAndFastGUI\\Candles\\maribozu.bmp"))
      return(false);
   if(!CreateCandle(m_picture6,m_button6,m_candle_name6,"Hammer",480,10,"Images\\EasyAndFastGUI\\Candles\\hammer.bmp"))
      return(false);
//--- Text labels
   if(!CreateTextLabel(m_text_label1,10,140,"Weight coefficients"))
      return(false);
   if(!CreateTextLabel(m_text_label2,10,240,"Threshold trend value in points"))
      return(false);
   if(!CreateTextLabel(m_text_label4,300,140,"Used candlesticks"))
      return(false);
   if(!CreateTextLabel(m_text_label5,488,240,"The number of candlesticks in the pattern"))
      return(false);
//--- Edit fields
   if(!CreateCoef(m_coef1,10,180,"K1",1))
      return(false);
   if(!CreateCoef(m_coef2,100,180,"K2",0.5))
      return(false);
   if(!CreateCoef(m_coef3,200,180,"K3",0.25))
      return(false);
   if(!CreateThresholdValue(m_threshold,10,280,"",100))
      return(false);
   if(!CreateLanguageSetting(m_lang_setting,10,340,"Язык интерфейса",2))
      return(false);
//--- List views
   if(!CreateListView(300,180))
      return(false);
//--- Buttons
   if(!CreateDualButton(m_button7,m_button8,488,180,"С повторами","Без повторов"))
      return(false);
   if(!CreateTripleButton(m_button9,m_button10,m_button11,488,270))
      return(false);
//--- Status Bar
   if(!CreateStatusBar(1,26))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a window of individual settings for simple candle types  |
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
//--- Edit fields
   if(!CreateSettingCoef(m_candle_coef1,10,73,"K1",0.55))
      return(false);
   if(!CreateSettingCoef(m_candle_coef2,10,108,"K2",0.55))
      return(false);
//--- Save button
   if(!CreateSaveButton(100,250,"Сохранить"))
      return(false);
//--- Cancel button
   if(!CreateCancelButton(200,250,"Отмена"))
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
   m_status_bar.AddItem(1);
//--- Add the text
   m_status_bar.SetValue(0,"Не выбран символ для анализа");
   m_status_bar.SetValue(1,"Количество сгенерированныхпаттернов: ");

//--- Creating a control
   if(!m_status_bar.CreateStatusBar(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_status_bar);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a group with tabs                                         |
//+------------------------------------------------------------------+
bool CProgram::CreateTabs(const int x_gap,const int y_gap)
  {
#define TABS1_TOTAL 3
//--- Save the pointer to the main control
   m_tabs1.MainPointer(m_window1);
//--- Properties
   m_tabs1.IsCenterText(true);
   m_tabs1.PositionMode(TABS_TOP);
   m_tabs1.AutoXResizeMode(true);
   m_tabs1.AutoYResizeMode(true);
   m_tabs1.AutoXResizeRightOffset(3);
   m_tabs1.AutoYResizeBottomOffset(25);

//--- Add tabs with the specified properties
   string tabs_names[TABS1_TOTAL]={"Анализ","Автопоиск","Настройки"};
   for(int i=0; i<TABS1_TOTAL; i++)
      m_tabs1.AddTab(tabs_names[i],150);
//--- Creating a control
   if(!m_tabs1.CreateTabs(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_tabs1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a checkbox with the "Symbols filter" input field          |
//+------------------------------------------------------------------+
bool CProgram::CreateSymbolsFilter(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const int tab)
  {
//--- Save the pointer to the main control
   text_edit.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(tab,text_edit);
//--- Properties
   text_edit.SetValue("USD");
   text_edit.CheckBoxMode(true);
   text_edit.AutoXResizeMode(true);
   text_edit.AutoXResizeRightOffset(500);
   text_edit.GetTextBoxPointer().XGap(65);
   text_edit.GetTextBoxPointer().XSize(160);
   text_edit.GetTextBoxPointer().AutoSelectionMode(true);
   if(m_lang_index==0)
      text_edit.GetTextBoxPointer().DefaultText("Пример: EURUSD,GBP,USD,Major");
   else if(m_lang_index==1)
      text_edit.GetTextBoxPointer().DefaultText("Example: EURUSD,GBP,USD,Major");
//--- Creating a control
   if(!text_edit.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Enable the checkbox
   text_edit.IsPressed(true);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,text_edit);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a button for updating the symbols list                   |
//+------------------------------------------------------------------+
bool CProgram::CreateRequest(CButton &button,const int x_gap,const int y_gap,const string text,const int tab)
  {
//--- Save the pointer to the main control
   button.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(tab,button);
//--- Properties
   button.XSize(80);
   button.IsCenterText(true);
//--- Creating a control
   if(!button.CreateButton(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create an entry field for a data range                           |
//+------------------------------------------------------------------+
bool CProgram::CreateRange(CTextEdit &text_edit,const int x_gap,const int y_gap,const string text,const int tab)
  {
//--- Save the pointer to the main control
   text_edit.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(tab,text_edit);
//--- Properties
   text_edit.XSize(100);
   text_edit.MaxValue(100000);
   text_edit.MinValue(4);
   text_edit.StepValue(1);
   text_edit.SetDigits(0);
   text_edit.SpinEditMode(true);
   text_edit.SetValue((string)8000);
   text_edit.GetTextBoxPointer().XSize(50);
   text_edit.GetTextBoxPointer().AutoSelectionMode(true);
   text_edit.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Creating a control
   if(!text_edit.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,text_edit);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a table of results of defined patterns                   |
//+------------------------------------------------------------------+
bool CProgram::CreateTable1(CTable &table,const int x_gap,const int y_gap,const int tab)
  {
#define COLUMNS1_TOTAL 7
//--- Save the pointer to the main control
   table.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(tab,table);

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
   table.XSize(602);
   table.YSize(100);
   table.CellYSize(20);
   table.TableSize(COLUMNS1_TOTAL,0);
   table.TextAlign(align);
   table.ColumnsWidth(width);
   table.TextXOffset(text_x_offset);
   table.ShowHeaders(true);
   table.IsSortMode(false);
   table.LightsHover(true);
   table.IsWithoutDeselect(true);
   table.IsZebraFormatRows(clrWhiteSmoke);
   table.AutoYResizeMode(true);
   table.AutoYResizeBottomOffset(5);
   table.HeadersColor(C'0,130,225');
   table.HeadersColorHover(clrCornflowerBlue);
   table.HeadersTextColor(clrWhite);
   table.DataType(1,TYPE_INT);
   table.DataType(2,TYPE_DOUBLE);
   table.DataType(3,TYPE_DOUBLE);
   table.DataType(4,TYPE_DOUBLE);
   table.DataType(5,TYPE_DOUBLE);
   table.DataType(6,TYPE_DOUBLE);

//--- Creating a control
   if(!table.CreateTable(x_gap,y_gap))
      return(false);
//--- Set the header titles
   table.SetHeaderText(0,"Имя паттерна");
   table.SetHeaderText(1,"Найдено");
   table.SetHeaderText(2,"Встречаемость,%");
   table.SetHeaderText(3,"P,Uptrend");
   table.SetHeaderText(4,"P,DnTrend");
   table.SetHeaderText(5,"K,UpTrend");
   table.SetHeaderText(6,"K,DnTrend");
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,table);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a table of results of generated patterns                 |
//+------------------------------------------------------------------+
bool CProgram::CreateTable2(CTable &table,const int x_gap,const int y_gap,const int tab)
  {
#define COLUMNS2_TOTAL 7
//--- Save the pointer to the main control
   table.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(tab,table);

//--- Array of column widths
   int width[COLUMNS2_TOTAL];
   ::ArrayInitialize(width,80);
   width[0]=100;
   width[2]=100;

//--- Array of text offset along the X axis in the columns
   int text_x_offset[COLUMNS2_TOTAL];
   ::ArrayInitialize(text_x_offset,7);
//--- Array of text alignment in columns
   ENUM_ALIGN_MODE align[COLUMNS2_TOTAL];
   ::ArrayInitialize(align,ALIGN_CENTER);
//--- Properties
   table.XSize(602);
   table.YSize(100);
   table.CellYSize(20);
   table.TableSize(COLUMNS2_TOTAL,0);
   table.TextAlign(align);
   table.ColumnsWidth(width);
   table.TextXOffset(text_x_offset);
   table.ShowHeaders(true);
   table.IsSortMode(false);
   table.SelectableRow(true);
   table.LightsHover(true);
   table.IsWithoutDeselect(true);
   table.IsZebraFormatRows(clrWhiteSmoke);
   table.AutoYResizeMode(true);
   table.AutoYResizeBottomOffset(5);
   table.HeadersColor(C'85,65,190');
   table.SelectedRowColor(C'120,100,225');
   table.HeadersColorHover(clrCornflowerBlue);
   table.HeadersTextColor(clrWhite);
   table.DataType(1,TYPE_INT);
   table.DataType(2,TYPE_DOUBLE);
   table.DataType(3,TYPE_DOUBLE);
   table.DataType(4,TYPE_DOUBLE);
   table.DataType(5,TYPE_DOUBLE);
   table.DataType(6,TYPE_DOUBLE);

//--- Creating a control
   if(!table.CreateTable(x_gap,y_gap))
      return(false);
//--- Set the header titles
   table.SetHeaderText(0,"Набор");
   table.SetHeaderText(1,"Найдено");
   table.SetHeaderText(2,"Встречаемость,%");
   table.SetHeaderText(3,"P,Uptrend");
   table.SetHeaderText(4,"P,DnTrend");
   table.SetHeaderText(5,"K,UpTrend");
   table.SetHeaderText(6,"K,DnTrend");
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,table);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a table of symbols                                       |
//+------------------------------------------------------------------+
bool CProgram::CreateSymbTable(CTable &table,const int x_gap,const int y_gap,const int tab)
  {
//--- Save the pointer to the main control
   table.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(tab,table);
//--- Array of column widths
   int width[1]={100};
//--- Array of text alignment in columns
   ENUM_ALIGN_MODE align[1]={ALIGN_CENTER};
//--- Array of text offset along the X axis in the columns
   int text_x_offset[1]={5};
//--- Properties
   table.XSize(100);
   table.TableSize(1,1);
   table.ColumnsWidth(width);
   table.TextAlign(align);
   table.TextXOffset(text_x_offset);
   table.ShowHeaders(true);
   table.LightsHover(true);
   table.SelectableRow(true);
   table.IsWithoutDeselect(true);
   table.IsZebraFormatRows(clrWhiteSmoke);
   table.AutoYResizeMode(true);
   table.AutoYResizeBottomOffset(5);
   if(tab==0)
      table.HeadersColor(C'0,130,225');
   else if(tab==1)
     {
      table.HeadersColor(C'85,64,191');
      table.SelectedRowColor(C'120,100,225');
     }
   table.HeadersColorHover(clrCornflowerBlue);
   table.HeadersTextColor(clrWhite);
//--- Creating a control
   if(!table.CreateTable(x_gap,y_gap))
      return(false);
//--- Set the header titles
   table.SetHeaderText(0,"Символ");
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,table);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates candlestick setup element                                |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\settings_dark.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\long.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\short.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\doji.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\spin.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\maribozu.bmp"
#resource "\\Images\\EasyAndFastGUI\\Candles\\hammer.bmp"
//---
bool CProgram::CreateCandle(CPicture &pic,CButton &button,CTextLabel &candlelabel,const string candlename,const int x_gap,const int y_gap,string path)
  {
//--- Save the pointer to the main control
   pic.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,pic);
//--- Properties
   pic.XSize(64);
   pic.YSize(64);
   pic.IconFile(path);
//--- Create a button
   if(!pic.CreatePicture(x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,pic);
   CreateButtonPic(pic,button,"Images\\EasyAndFastGUI\\Icons\\bmp16\\settings_dark.bmp");
   CreateNameCandle(candlelabel,x_gap,y_gap+pic.YSize(),candlename);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a button with an image                                    |
//+------------------------------------------------------------------+
bool CProgram::CreateButtonPic(CPicture &pic,CButton &button,string path="")
  {
//--- Save the pointer to the main control
   button.MainPointer(pic);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,button);
//--- Properties
   button.XSize(20);
   button.YSize(20);
   button.IconXGap(2);
   button.IconYGap(2);
   button.BackColor(clrAliceBlue);
   button.IconFile(path);
//--- Creating a control
   if(!button.CreateButton("",pic.XSize()-button.XSize()/2,0))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a text label in the Settings tab                         |
//+------------------------------------------------------------------+
bool CProgram::CreateTextLabel(CTextLabel &text_label,const int x_gap,const int y_gap,string label_text)
  {
//--- Save the window pointer
   text_label.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,text_label);
//---
   text_label.FontSize(12);
   text_label.XSize(255);
   text_label.LabelColor(C'0,100,255');
//--- Create a button
   if(!text_label.CreateTextLabel(label_text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,text_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a text label in the Settings tab                         |
//+------------------------------------------------------------------+
bool CProgram::CreateNameCandle(CTextLabel &text_label,const int x_gap,const int y_gap,string label_text)
  {
//--- Save the window pointer
   text_label.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,text_label);
//---
   text_label.FontSize(10);
   text_label.IsCenterText(true);
   text_label.XSize(64);
//--- Create a button
   if(!text_label.CreateTextLabel(label_text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,text_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a combo box for selecting timeframes                     |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxTF(CComboBox &tf,const int x_gap,const int y_gap,const string text,const int tab)
  {
//--- Total number of the list items
#define ITEMS_TOTAL2 21
//--- Pass the object to the panel
   tf.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(tab,tf);
//--- Properties
   tf.XSize(115);
   tf.ItemsTotal(ITEMS_TOTAL2);
   tf.GetButtonPointer().XSize(50);
   tf.GetButtonPointer().AnchorRightWindowSide(true);
//--- Save the item values in the combobox list view
   string items_text[ITEMS_TOTAL2]={"M1","M2","M3","M4","M5","M6","M10","M12","M15","M20","M30","H1","H2","H3","H4","H6","H8","H12","D1","W1","MN"};
   for(int i=0; i<ITEMS_TOTAL2; i++)
      tf.SetValue(i,items_text[i]);
//--- Get the list view pointer
   CListView *lv=tf.GetListViewPointer();
//--- Set the list view properties
   lv.LightsHover(true);
   lv.SelectItem(4);
//--- Creating a control
   if(!tf.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,tf);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a combo box for selecting the interface language         |
//+------------------------------------------------------------------+
bool CProgram::CreateLanguageSetting(CComboBox &combobox,const int x_gap,const int y_gap,const string text,const int tab)
  {
//--- Total number of the list items
#define ITEMS_TOTAL 2
//--- Pass the object to the panel
   combobox.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(tab,combobox);
//--- Properties
   combobox.XSize(300);
   combobox.YSize(25);
   combobox.FontSize(12);
   combobox.ItemsTotal(ITEMS_TOTAL);
   combobox.GetButtonPointer().XSize(100);
   combobox.GetButtonPointer().XGap(150);
   combobox.GetButtonPointer().FontSize(10);
   combobox.GetListViewPointer().FontSize(10);
   combobox.LabelColor(C'0,100,255');
//--- Save the item values in the combobox list view
   string items_text[ITEMS_TOTAL]={"Русский","English"};
   for(int i=0; i<ITEMS_TOTAL; i++)
      combobox.SetValue(i,items_text[i]);
//--- Get the list view pointer
   CListView *lv=combobox.GetListViewPointer();
//--- Set the list view properties
   lv.LightsHover(true);
   lv.SelectItem(m_lang_index);
//--- Creating a control
   if(!combobox.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,combobox);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a list of simple candlestick types                       |
//+------------------------------------------------------------------+
bool CProgram::CreateListView(const int x_gap,const int y_gap)
  {
//--- Size of the list view
#define CANDLE_TOTAL 11
//--- Save the pointer to the main control
   m_listview1.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,m_listview1);
//--- Properties
   m_listview1.XSize(175);
   m_listview1.YSize(250);
   m_listview1.ItemYSize(19);
   m_listview1.LabelXGap(25);
   m_listview1.LightsHover(true);
   m_listview1.CheckBoxMode(true);
   m_listview1.ListSize(CANDLE_TOTAL);
   m_listview1.AutoYResizeMode(true);
   m_listview1.AutoYResizeBottomOffset(10);
   m_listview1.FontSize(10);
   m_listview1.GreenCheckBox(true);
//--- Filling the list view with data
   string cand_name[CANDLE_TOTAL]=
     {
      "Длинная — бычья",
      "Длинная — медвежья",
      "Короткая — бычья",
      "Короткая — медвежья",
      "Волчок — бычья",
      "Волчок — медвежья",
      "Доджи",
      "Марибозу — бычья",
      "Марибозу — медвежья",
      "Молот — бычья",
      "Молот — медвежья"
     };
   for(int r=0; r<CANDLE_TOTAL; r++)
     {
      m_listview1.SetValue(r,(string)(r+1)+". "+cand_name[r]);
      //_listview1.SelectItem(r);
     }
//--- Create the list view
   if(!m_listview1.CreateListView(x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,m_listview1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the Repeat mode switch                                   |
//+------------------------------------------------------------------+
bool CProgram::CreateDualButton(CButton &lbutton,CButton &rbutton,const int x_gap,const int y_gap,const string ltext,const string rtext)
  {
   CreateButton(lbutton,x_gap,y_gap,ltext);
   CreateButton(rbutton,x_gap+99,y_gap,rtext);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a button for the Repeat mode switch                      |
//+------------------------------------------------------------------+
bool CProgram::CreateButton(CButton &button,const int x_gap,const int y_gap,const string text)
  {
//--- Save the pointer to the main control
   button.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,button);
//--- Properties
   button.XSize(100);
   button.YSize(30);
   button.Font("Trebuchet");
   button.FontSize(10);
   button.IsCenterText(true);
   button.BorderColor(C'0,100,255');
   button.BackColor(clrAliceBlue);
   button.BackColorLocked(C'50,180,75');
   button.BorderColorLocked(C'50,180,75');
   button.LabelColorLocked(clrWhite);
//--- Creating a control
   if(!button.CreateButton(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a set of three buttons for selecting the pattern size    |
//+------------------------------------------------------------------+
bool CProgram::CreateTripleButton(CButton &lbutton,CButton &cbutton,CButton &rbutton,const int x_gap,const int y_gap)
  {
   CreateButton1(lbutton,x_gap,y_gap,m_used_pattern[0]);
   CreateButton1(cbutton,x_gap+49,y_gap,m_used_pattern[1]);
   CreateButton1(rbutton,x_gap+49*2,y_gap,m_used_pattern[2]);
   return(true);
  }
//+------------------------------------------------------------------+
//| Button for selecting the size                                    |
//+------------------------------------------------------------------+
bool CProgram::CreateButton1(CButton &button,const int x_gap,const int y_gap,const string text)
  {
//--- Save the pointer to the main control
   button.MainPointer(m_tabs1);
//--- Attach to tab
   m_tabs1.AddToElementsArray(2,button);
//--- Properties
   button.XSize(50);
   button.YSize(50);
   button.Font("Trebuchet");
   button.FontSize(12);
   button.IsHighlighted(false);
   button.IsCenterText(true);
   button.BorderColor(C'0,100,255');
   button.BackColor(clrAliceBlue);
   button.BackColorLocked(C'50,180,75');
   button.BorderColorLocked(C'50,180,75');
   button.LabelColorLocked(clrWhite);
//--- Creating a control
   if(!button.CreateButton(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(0,button);
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
   m_tabs1.AddToElementsArray(2,text_edit);
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
//--- Creating a control
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
   m_tabs1.AddToElementsArray(2,text_edit);
//--- Properties
   text_edit.XSize(80);
   text_edit.MaxValue(1000);
   text_edit.MinValue(1);
   text_edit.SpinEditMode(true);
   text_edit.SetValue((string)value);
   text_edit.GetTextBoxPointer().XSize(50);
   text_edit.GetTextBoxPointer().AutoSelectionMode(true);
   text_edit.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Creating a control
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
//--- Creating a control
   if(!text_edit.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(1,text_edit);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a button for updating the symbols list                   |
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
//--- Creating a control
   if(!m_save.CreateButton(text,x_gap,y_gap))
      return(false);
//--- Add a pointer to element to the base
   CWndContainer::AddToElementsArray(1,m_save);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a button for updating the symbols list                   |
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
//--- Creating a control
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
//if(id!=m_request1.Id() || id!=m_request2.Id())
//   return(false);
//---
   if(id==m_request1.Id())
     {
      //--- Hide the table
      m_symb_table1.Hide();
      //--- Initializing the chart and the table
      GetSymbols(m_symb_filter1);
      RebuildingTables(m_symb_table1);
      //--- Get the value from the combo box drop-down list
      string tf=m_timeframes1.GetListViewPointer().SelectedItemText();
      //--- Show the table
      m_symb_table1.Show();
     }
   else if(id==m_request2.Id())
     {
      //--- Hide the table
      m_symb_table2.Hide();
      //--- Initializing the chart and the table
      GetSymbols(m_symb_filter2);
      RebuildingTables(m_symb_table2);
      //--- Get the value from the combo box drop-down list
      string tf=m_timeframes2.GetListViewPointer().SelectedItemText();
      //--- Show the table
      m_symb_table2.Show();
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Get symbols                                                      |
//+------------------------------------------------------------------+
void CProgram::GetSymbols(CTextEdit &textedit)
  {
//--- Free the symbol array
   ::ArrayFree(m_symbols);
//--- Array of row elements
   string elements[];
//--- Symbol name filter
   if(textedit.IsPressed())
     {
      string text=textedit.GetValue();
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
            //--- Clear the edges
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
      if(textedit.IsPressed())
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
//| Redraws the table of symbols                                     |
//+------------------------------------------------------------------+
void CProgram::RebuildingTables(CTable &symbtable)
  {
//--- Delete all rows
   symbtable.DeleteAllRows();
//--- Set the number of rows by the number of symbols
   int symbols_total=::ArraySize(m_symbols);
   for(int i=0; i<symbols_total-1; i++)
      symbtable.AddRow(i);
//--- Set the values to the first column
   uint rows_total=symbtable.RowsTotal();
   for(uint r=0; r<(uint)rows_total; r++)
     {
      //--- Set the values
      symbtable.SetValue(0,r,m_symbols[r]);
     }
//--- Update the table
   symbtable.Update(true);
   symbtable.GetScrollVPointer().Update(true);
   symbtable.GetScrollHPointer().Update(true);
  }
//+------------------------------------------------------------------+
//| Symbol change                                                    |
//+------------------------------------------------------------------+
bool CProgram::ChangeSymbol1(const long id)
  {
//--- Check the element ID
   if(id!=m_symb_table1.Id())
      return(false);
//--- Exit if the line is not highlighted
   if(m_symb_table1.SelectedItem()==WRONG_VALUE)
     {
      //--- Show full symbol description in the status bar
      m_status_bar.SetValue(0,"Не выбран символ для анализа");
      m_status_bar.GetItemPointer(0).Update(true);
      return(false);
     }
//--- Get a symbol
   string symbol=m_symb_table1.GetValue(0,m_symb_table1.SelectedItem());
//--- Show full symbol description in the status bar
   string val=(m_lang_index==0)?"Выбранный символ: ":"Selected symbol: ";
   m_status_bar.SetValue(0,val+::SymbolInfoString(symbol,SYMBOL_DESCRIPTION));
   m_status_bar.GetItemPointer(0).Update(true);
   GetPatternType(symbol);
   return(true);
  }
//+------------------------------------------------------------------+
//| Symbol change                                                    |
//+------------------------------------------------------------------+
bool CProgram::ChangeSymbol2(const long id)
  {
//--- Check the element ID
   if(id!=m_symb_table2.Id())
      return(false);
//--- Exit if the line is not highlighted
   if(m_symb_table2.SelectedItem()==WRONG_VALUE)
     {
      //--- Show the full symbol description in the status bar
      m_status_bar.SetValue(0,"Не выбран символ для анализа");
      m_status_bar.GetItemPointer(0).Update(true);
      return(false);
     }
//--- Get a symbol
   string symbol=m_symb_table2.GetValue(0,m_symb_table2.SelectedItem());
//--- Show the full symbol description in the status bar
   string val=(m_lang_index==0)?"Выбранный символ: ":"Selected symbol: ";
   m_status_bar.SetValue(0,val+::SymbolInfoString(symbol,SYMBOL_DESCRIPTION));
   m_status_bar.GetItemPointer(0).Update(true);
   if(!BuildingAutoSearchTable())
      return(false);
   GetPatternType(symbol,m_total_combination);
   return(true);
  }
//+------------------------------------------------------------------+
//| Timeframe change                                                 |
//+------------------------------------------------------------------+
bool CProgram::ChangePeriod1(const long id)
  {
//--- Check the element ID
   if(id!=m_timeframes1.Id() || m_symb_table1.SelectedItem()==WRONG_VALUE)
      return(false);
//--- Get a symbol
   GetPatternType(m_symb_table1.GetValue(0,m_symb_table1.SelectedItem()));
   return(true);
  }
//+------------------------------------------------------------------+
//| Timeframe change                                                 |
//+------------------------------------------------------------------+
bool CProgram::ChangePeriod2(const long id)
  {
//--- Check the element ID
   if(id!=m_timeframes2.Id())
      return(false);
//---
   if(!BuildingAutoSearchTable())
      return(false);
   GetPatternType(m_symb_table1.GetValue(0,m_symb_table2.SelectedItem()),m_total_combination);
   return(true);
  }
//+------------------------------------------------------------------+
//| Changing the interface language                                  |
//+------------------------------------------------------------------+
bool CProgram::ChangeLanguage(const long id)
  {
//--- Check the element ID
   if(id!=m_lang_setting.Id())
      return(false);
   m_lang_index=m_lang_setting.GetListViewPointer().SelectedItemIndex();
//---
   if(m_lang_index==0)
     {
      m_tabs1.Text(0,"Анализ");
      m_tabs1.Text(1,"Автопоиск");
      m_tabs1.Text(2,"Настройки");
      m_symb_filter1.LabelText("Символы");
      m_symb_filter2.LabelText("Символы");
      m_request1.LabelText("Поиск");
      m_request2.LabelText("Поиск");
      m_timeframes1.LabelText("Таймфрейм");
      m_timeframes2.LabelText("Таймфрейм");
      m_range1.LabelText("Диапазон");
      m_range2.LabelText("Диапазон");
      m_symb_table1.SetHeaderText(0,"Символ");
      m_symb_table2.SetHeaderText(0,"Символ");
      m_table1.SetHeaderText(0,"Имя паттерна");
      m_table1.SetHeaderText(1,"Найдено");
      m_table1.SetHeaderText(2,"Встречаемость,%");
      m_table2.SetHeaderText(0,"Набор");
      m_table2.SetHeaderText(1,"Найдено");
      m_table2.SetHeaderText(2,"Встречаемость,%");
      m_candle_name1.LabelText("Длинная");
      m_candle_name2.LabelText("Короткая");
      m_candle_name3.LabelText("Волчок");
      m_candle_name4.LabelText("Доджи");
      m_candle_name5.LabelText("Марибозу");
      m_candle_name6.LabelText("Молот");
      m_text_label1.LabelText("Весовые коэффициенты");
      m_text_label2.LabelText("Пороговое значение тренда (пункты)");
      m_text_label4.LabelText("Используемые свечи");
      m_text_label5.LabelText("Число свечей в паттерне");
      m_button7.LabelText("С повторами");
      m_button8.LabelText("Без повторов");
      m_lang_setting.LabelText("Язык интерфейса");
      m_status_bar.SetValue(0,"Не выбран символ для анализа");
      m_save.LabelText("Сохранить");
      m_cancel.LabelText("Отмена");
      string cand_name[11]=
        {
         "Длинная — бычья",
         "Длинная — медвежья",
         "Короткая — бычья",
         "Короткая — медвежья",
         "Волчок — бычья",
         "Волчок — медвежья",
         "Доджи",
         "Марибозу — бычья",
         "Марибозу — медвежья",
         "Молот — бычья",
         "Молот — медвежья"
        };
      for(int r=0; r<11; r++)
         m_listview1.SetValue(r,(string)(r+1)+". "+cand_name[r]);
     }
   else
     {
      m_tabs1.Text(0,"Analyze");
      m_tabs1.Text(1,"AutoSearch");
      m_tabs1.Text(2,"Settings");
      m_symb_filter1.LabelText("Symbols");
      m_symb_filter2.LabelText("Symbols");
      m_request1.LabelText("Search");
      m_request2.LabelText("Search");
      m_timeframes1.LabelText("Timeframe");
      m_timeframes2.LabelText("Timeframe");
      m_range1.LabelText("Range");
      m_range2.LabelText("Range");
      m_symb_table1.SetHeaderText(0,"Symbol");
      m_symb_table2.SetHeaderText(0,"Symbol");
      m_table1.SetHeaderText(0,"Pattern name");
      m_table1.SetHeaderText(1,"Found");
      m_table1.SetHeaderText(2,"Coincidence,%");
      m_table2.SetHeaderText(0,"Set");
      m_table2.SetHeaderText(1,"Found");
      m_table2.SetHeaderText(2,"Coincidence,%");
      m_candle_name1.LabelText("Long");
      m_candle_name2.LabelText("Short");
      m_candle_name3.LabelText("Spin");
      m_candle_name4.LabelText("Doji");
      m_candle_name5.LabelText("Maribozu");
      m_candle_name6.LabelText("Hammer");
      m_text_label1.LabelText("Weighting coefficients");
      m_text_label2.LabelText("Trend threshold in points");
      m_text_label4.LabelText("Used candles");
      m_text_label5.LabelText("Number of candles in the pattern");
      m_button7.LabelText("Repeat");
      m_button8.LabelText("No repeat");
      m_lang_setting.LabelText("Interface language");
      m_status_bar.SetValue(0,"No symbol selected for analysis");
      m_save.LabelText("Save");
      m_cancel.LabelText("Cancel");
      string cand_name[11]=
        {
         "Long — bullish",
         "Long — bearish",
         "Short — bullish",
         "Short — bearish",
         "Spin — bullish",
         "Spin — bearish",
         "Doji",
         "Maribozu — bullish",
         "Maribozu — bearish",
         "Hammer — bullish",
         "Hammer — bearish"
        };
      for(int r=0; r<11; r++)
         m_listview1.SetValue(r,(string)(r+1)+". "+cand_name[r]);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Candlestick type recognition                                     |
//+------------------------------------------------------------------+
bool CProgram::GetCandleType(const string symbol,CANDLE_STRUCTURE &res,ENUM_TIMEFRAMES timeframe,const int shift)
  {
   MqlRates rt[];
   int aver_period=5;
   double ma[],aver;
   SymbolSelect(symbol,true);
   int copied=CopyRates(symbol,timeframe,shift,aver_period+1,rt);
//--- Get details of the previous candlestick
   if(copied<aver_period)
      return(false);
//---
   res.open=rt[aver_period].open;
   res.high=rt[aver_period].high;
   res.low=rt[aver_period].low;
   res.close=rt[aver_period].close;

//--- Determine the trend direction
   aver=0;
   for(int i=0;i<aver_period;i++)
      aver+=rt[i].close;

   aver=aver/aver_period;

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
//--- marubozu
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
//| Recognizing pre-defined patterns                                 |
//+------------------------------------------------------------------+
bool CProgram::GetPatternType(const string symbol)
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

   RATING_SET hummer_coef={0,0,0,0,0,0};
   RATING_SET invert_hummer_coef={0,0,0,0,0,0};
   RATING_SET handing_man_coef={0,0,0,0,0,0};
   RATING_SET shooting_star_coef={0,0,0,0,0,0};
   RATING_SET engulfing_bull_coef={0,0,0,0,0,0};
   RATING_SET engulfing_bear_coef={0,0,0,0,0,0};
   RATING_SET harami_cross_bull_coef={0,0,0,0,0,0};
   RATING_SET harami_cross_bear_coef={0,0,0,0,0,0};
   RATING_SET harami_bull_coef={0,0,0,0,0,0};
   RATING_SET harami_bear_coef={0,0,0,0,0,0};
   RATING_SET doji_star_bull_coef={0,0,0,0,0,0};
   RATING_SET doji_star_bear_coef={0,0,0,0,0,0};
   RATING_SET piercing_line_coef={0,0,0,0,0,0};
   RATING_SET dark_cloud_cover_coef={0,0,0,0,0,0};
//---
   for(int i=m_range_total1;i>3;i--)
     {
      GetCandleType(symbol,cand2,m_timeframe1,i);                                         // Previous candlestick
      GetCandleType(symbol,cand1,m_timeframe1,i-1);                                       // Current candlestick

      //--- Inverted Hammer, bullish model
      if(cand2.trend==DOWN &&                                                             // Check the trend direction
         cand2.type==CAND_INVERT_HAMMER)                                                  // Checking "Inverted Hammer"
        {
         m_invert_hummer_total++;
         GetCategory(symbol,i-3,invert_hummer_coef,m_timeframe1);
        }

      //--- Hanging man, bearish
      if(cand2.trend==UPPER &&                                                            // Check the trend direction
         cand2.type==CAND_HAMMER)                                                         // Checking "Hammer"
        {
         m_handing_man_total++;
         GetCategory(symbol,i-3,handing_man_coef,m_timeframe1);
        }
      //--- Hammer, bullish model
      if(cand2.trend==DOWN &&                                                             // Check the trend direction
         cand2.type==CAND_HAMMER)                                                         // Checking "Hammer"
        {
         m_hummer_total++;
         GetCategory(symbol,i-3,hummer_coef,m_timeframe1);
        }
      //---
      //--- Shooting Star, bearish model
      if(cand1.trend==UPPER && cand2.trend==UPPER &&                                      // Check the trend direction
         cand2.type==CAND_INVERT_HAMMER && cand1.close<=cand2.open)                       // Checking "Inverted Hammer"
        {
         m_shooting_star_total++;
         GetCategory(symbol,i-4,shooting_star_coef,m_timeframe1);
        }

      //--- Engulfing, bullish model
      if(cand1.trend==DOWN && cand1.bull && cand2.trend==DOWN && !cand2.bull && // Check trend direction and candlestick direction
         cand1.bodysize>cand2.bodysize &&
         cand1.close>=cand2.open && cand1.open<cand2.close)
        {
         m_engulfing_bull_total++;
         GetCategory(symbol,i-4,engulfing_bull_coef,m_timeframe1);
        }

      //--- Engulfing, bearish model
      if(cand1.trend==UPPER && cand1.bull && cand2.trend==UPPER && !cand2.bull && // Check trend direction and candlestick direction
         cand1.bodysize<cand2.bodysize &&
         cand1.close<=cand2.open && cand1.open>cand2.close)
        {
         m_engulfing_bear_total++;
         GetCategory(symbol,i-4,engulfing_bear_coef,m_timeframe1);
        }

      //--- Harami Cross, bullish
      if(cand2.trend==DOWN && !cand2.bull &&                                              // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && cand1.type==CAND_DOJI && // Check the "long" first candlestick and the doji candlestick
         cand1.close<cand2.open && cand1.open>=cand2.close)                               // Doji is inside the first candlestick body
        {
         m_harami_cross_bull_total++;
         GetCategory(symbol,i-4,harami_cross_bull_coef,m_timeframe1);
        }

      //--- Harami Cross, bearish model
      if(cand2.trend==UPPER && cand2.bull &&                                              // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && cand1.type==CAND_DOJI && // Check the "long" first candlestick and the doji candlestick
         cand1.close>cand2.open && cand1.open<=cand2.close)                               // Doji is inside the first candlestick body
 
        {
         m_harami_cross_bear_total++;
         GetCategory(symbol,i-4,harami_cross_bear_coef,m_timeframe1);
        }

      //--- Harami, bullish
      if(cand1.trend==DOWN && cand1.bull && !cand2.bull &&                                // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU)  &&                         // Checking the "long" first candlestick
         cand1.type!=CAND_DOJI && cand1.bodysize<cand2.bodysize &&                        // The second candle is not Doji and first candlestick body is bigger than that of the second one
         cand1.close<cand2.open && cand1.open>=cand2.close)                               // Body of the second candlestick is inside of body of the first one 
        {
         m_harami_bull_total++;
         GetCategory(symbol,i-4,harami_bull_coef,m_timeframe1);
        }

      //--- Harami, bearish
      if(cand1.trend==UPPER && !cand1.bull && cand2.bull &&                               // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) &&                          // Checking the "long" first candlestick
         cand1.type!=CAND_DOJI && cand1.bodysize<cand2.bodysize &&                        // The second candle is not Doji and first candlestick body is bigger than that of the second one
         cand1.close>cand2.open && cand1.open<=cand2.close)                               // Body of the second candlestick is inside of body of the first one 
        {
         m_harami_bear_total++;
         GetCategory(symbol,i-4,harami_bear_coef,m_timeframe1);
        }

      //--- Doji Star, bullish
      if(cand1.trend==DOWN && !cand2.bull && // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && cand1.type==CAND_DOJI && // Check 1st "long" candlestick and 2nd doji
         cand1.close<=cand2.open)                                                         // Doji Open is lower or equal to 1st candle Close 
        {
         m_doji_star_bull_total++;
         GetCategory(symbol,i-4,doji_star_bull_coef,m_timeframe1);
        }

      //--- Doji Star, bearish
      if(cand1.trend==UPPER && cand2.bull && // Check trend direction and candlestick direction
         (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && cand1.type==CAND_DOJI && // Check 1st "long" candlestick and 2nd doji
         cand1.open>=cand2.close)                                                         //Doji Open price is higher or equal to 1st candle Close
        {
         m_doji_star_bear_total++;
         GetCategory(symbol,i-4,doji_star_bear_coef,m_timeframe1);
        }

      //--- Piercing, bullish model
      if(cand1.trend==DOWN && cand1.bull && !cand2.bull && // Check trend direction and candlestick direction
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU) && (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && // Check the "long" candlestick
         cand1.close>(cand2.close+cand2.open)/2 && // 2nd candle Close is above the middle of the 1st candlestick
         cand2.open>cand1.close && cand2.close>=cand1.open)
        {
         m_piercing_line_total++;
         GetCategory(symbol,i-4,piercing_line_coef,m_timeframe1);
        }

      //--- Dark Cloud Cover, bearish
      if(cand1.trend==UPPER && !cand1.bull && cand2.bull && // Check trend direction and candlestick direction
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU) && (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU) && // Check the "long" candlestick
         cand1.close<(cand2.close+cand2.open)/2 && // 2nd candle Close is below the middle of the 1st candlestick body
         cand1.close<cand2.open && cand2.close<=cand1.open)
        {
         m_dark_cloud_cover_total++;
         GetCategory(symbol,i-4,dark_cloud_cover_coef,m_timeframe1);
        }
     }

//---
   BuildingPatternTable();
   CoefCalculation(m_table1,0,hummer_coef,m_hummer_total);
   CoefCalculation(m_table1,1,invert_hummer_coef,m_invert_hummer_total);
   CoefCalculation(m_table1,2,handing_man_coef,m_handing_man_total);
   CoefCalculation(m_table1,3,shooting_star_coef,m_shooting_star_total);
   CoefCalculation(m_table1,4,engulfing_bull_coef,m_engulfing_bull_total);
   CoefCalculation(m_table1,5,engulfing_bear_coef,m_engulfing_bear_total);
   CoefCalculation(m_table1,6,harami_cross_bull_coef,m_harami_cross_bull_total);
   CoefCalculation(m_table1,7,harami_cross_bear_coef,m_harami_cross_bear_total);
   CoefCalculation(m_table1,8,harami_bull_coef,m_harami_bull_total);
   CoefCalculation(m_table1,9,harami_bear_coef,m_harami_bear_total);
   CoefCalculation(m_table1,10,doji_star_bull_coef,m_doji_star_bull_total);
   CoefCalculation(m_table1,11,doji_star_bear_coef,m_doji_star_bear_total);
   CoefCalculation(m_table1,12,piercing_line_coef,m_piercing_line_total);
   CoefCalculation(m_table1,13,dark_cloud_cover_coef,m_dark_cloud_cover_total);
   return(true);
  }
//+------------------------------------------------------------------+
//| Recognizing generated patterns                                   |
//+------------------------------------------------------------------+
bool CProgram::GetPatternType(const string symbol,string &total_combination[])
  {
   CANDLE_STRUCTURE cand1[],cand2[],cand3[],cur_cand,prev_cand,prev_cand2;
   RATING_SET ratings[];
   int total_patterns,m_pattern_total[];
   string elements[];
//---
   total_patterns=ArraySize(total_combination);
   ArrayResize(cand1,total_patterns);
   ArrayResize(cand2,total_patterns);
   ArrayResize(cand3,total_patterns);
   ArrayResize(m_pattern_total,total_patterns);
   ArrayResize(ratings,total_patterns);
   ArrayResize(elements,m_pattern_size);
//---
   for(int i=0;i<total_patterns;i++)
     {
      StringReplace(total_combination[i],"[","");
      StringReplace(total_combination[i],"]","");
      if(m_pattern_size>1)
        {
         ushort sep=StringGetCharacter(",",0);
         StringSplit(total_combination[i],sep,elements);
        }
      ZeroMemory(ratings[i]);
      m_pattern_total[i]=0;
      if(m_pattern_size==1)
         IndexToPatternType(cand1[i],(int)total_combination[i]);
      else if(m_pattern_size==2)
        {
         IndexToPatternType(cand1[i],(int)elements[0]);
         IndexToPatternType(cand2[i],(int)elements[1]);
        }
      else if(m_pattern_size==3)
        {
         IndexToPatternType(cand1[i],(int)elements[0]);
         IndexToPatternType(cand2[i],(int)elements[1]);
         IndexToPatternType(cand3[i],(int)elements[2]);
        }
     }
//---
   for(int i=m_range_total2;i>5;i--)
     {
      if(m_pattern_size==1)
        {
         //--- Get the current candlestick type
         GetCandleType(symbol,cur_cand,m_timeframe2,i);                                         // Current candlestick
         //---
         for(int j=0;j<total_patterns;j++)
           {
            if(cur_cand.type==cand1[j].type && cur_cand.bull==cand1[j].bull)
              {
               m_pattern_total[j]++;
               GetCategory(symbol,i-3,ratings[j],m_timeframe2);
              }
           }
        }
      else if(m_pattern_size==2)
        {
         //--- Get the current candlestick type
         GetCandleType(symbol,prev_cand,m_timeframe2,i);                                        // Previous candlestick
         GetCandleType(symbol,cur_cand,m_timeframe2,i-1);                                       // Current candlestick
         //---
         for(int j=0;j<total_patterns;j++)
           {
            if(cur_cand.type==cand1[j].type && cur_cand.bull==cand1[j].bull && 
               prev_cand.type==cand2[j].type && prev_cand.bull==cand2[j].bull)
              {
               m_pattern_total[j]++;
               GetCategory(symbol,i-4,ratings[j],m_timeframe2);
              }
           }
        }
      else if(m_pattern_size==3)
        {
         //--- Get the current candlestick type
         GetCandleType(symbol,prev_cand2,m_timeframe2,i);                                       // Previous candlestick
         GetCandleType(symbol,prev_cand,m_timeframe2,i-1);                                      // Previous candlestick
         GetCandleType(symbol,cur_cand,m_timeframe2,i-2);                                       // Current candlestick
         //---
         for(int j=0;j<total_patterns;j++)
           {
            if(cur_cand.type==cand1[j].type && cur_cand.bull==cand1[j].bull && 
               prev_cand.type==cand2[j].type && prev_cand.bull==cand2[j].bull && 
               prev_cand2.type==cand3[j].type && prev_cand2.bull==cand3[j].bull)
              {
               m_pattern_total[j]++;
               GetCategory(symbol,i-5,ratings[j],m_timeframe2);
              }
           }
        }
     }
//---
   for(int i=0;i<total_patterns;i++)
      CoefCalculation(m_table2,i,ratings[i],m_pattern_total[i]);
   return(true);
  }
//+------------------------------------------------------------------+
//| Converting index into the pattern type                           |
//+------------------------------------------------------------------+
void CProgram::IndexToPatternType(CANDLE_STRUCTURE &res,const int index)
  {
//--- Long - bullish
   if(index==1)
     {
      res.bull=true;
      res.type=CAND_LONG;
     }
//--- Long - bearish
   else if(index==2)
     {
      res.bull=false;
      res.type=CAND_LONG;
     }
//--- Short - bullish
   else if(index==3)
     {
      res.bull=true;
      res.type=CAND_SHORT;
     }
//--- Short - bearish
   else if(index==4)
     {
      res.bull=false;
      res.type=CAND_SHORT;
     }
//--- Spinning Top - bullish
   else if(index==5)
     {
      res.bull=true;
      res.type=CAND_SPIN_TOP;
     }
//--- Spinning Top - bearish
   else if(index==6)
     {
      res.bull=false;
      res.type=CAND_SPIN_TOP;
     }
//--- Doji
   else if(index==7)
     {
      res.bull=true;
      res.type=CAND_DOJI;
     }
//--- Marubozu - bullish
   else if(index==8)
     {
      res.bull=true;
      res.type=CAND_MARIBOZU;
     }
//--- Marubozu - bearish
   else if(index==9)
     {
      res.bull=false;
      res.type=CAND_MARIBOZU;
     }
//--- Hammer - bullish
   else if(index==10)
     {
      res.bull=true;
      res.type=CAND_HAMMER;
     }
//--- Hammer - bearish
   else if(index==11)
     {
      res.bull=false;
      res.type=CAND_HAMMER;
     }
  }
//+------------------------------------------------------------------+
//| Determine profit categories                                      |
//+------------------------------------------------------------------+
bool CProgram::GetCategory(const string symbol,const int shift,RATING_SET &rate,ENUM_TIMEFRAMES timeframe)
  {
   MqlRates rt[];
   int copied=CopyRates(symbol,timeframe,shift,4,rt);
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
      rate.a_uptrend++;
     }
   else if((int)((high2-close0)/point)>=m_threshold_value)
     {
      rate.b_uptrend++;
     }
   else if((int)((high3-close0)/point)>=m_threshold_value)
     {
      rate.c_uptrend++;
     }

//--- Check if it is the Downtrend
   if((int)((close0-low1)/point)>=m_threshold_value)
     {
      rate.a_dntrend++;
     }
   else if((int)((close0-low2)/point)>=m_threshold_value)
     {
      rate.b_dntrend++;
     }
   else if((int)((close0-low3)/point)>=m_threshold_value)
     {
      rate.c_dntrend++;
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculate efficiency assessment coefficients                     |
//+------------------------------------------------------------------+
bool CProgram::CoefCalculation(CTable &table,const int row,RATING_SET &rate,int found)
  {
   double p1,p2,k1,k2;
   int sum1=0,sum2=0;
   sum1=rate.a_uptrend+rate.b_uptrend+rate.c_uptrend;
   sum2=rate.a_dntrend+rate.b_dntrend+rate.c_dntrend;
//---
   p1=(found>0)?NormalizeDouble((double)sum1/found*100,2):0;
   p2=(found>0)?NormalizeDouble((double)sum2/found*100,2):0;
   k1=(found>0)?NormalizeDouble((m_k1*rate.a_uptrend+m_k2*rate.b_uptrend+m_k3*rate.c_uptrend)/found,3):0;
   k2=(found>0)?NormalizeDouble((m_k1*rate.a_dntrend+m_k2*rate.b_dntrend+m_k3*rate.c_dntrend)/found,3):0;

   table.SetValue(1,row,(string)found);
   table.SetValue(2,row,(string)((double)found/m_range_total2*100),2);
   table.SetValue(3,row,(string)p1,2);
   table.SetValue(4,row,(string)p2,2);
   table.SetValue(5,row,(string)k1,2);
   table.SetValue(6,row,(string)k2,2);
//--- Update the table
   table.Update(true);
   table.GetScrollVPointer().Update(true);
   table.GetScrollHPointer().Update(true);
   return(true);
  }
//+------------------------------------------------------------------+
//| Redraws the table of patterns                                    |
//+------------------------------------------------------------------+
void CProgram::BuildingPatternTable(void)
  {
//--- Delete all rows
   m_table1.DeleteAllRows();
//--- Set the number of rows by the number of symbols
   for(int i=0; i<13; i++)
      m_table1.AddRow(i);
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
   m_table1.Update(true);
   m_table1.GetScrollVPointer().Update(true);
   m_table1.GetScrollHPointer().Update(true);
  }
//+------------------------------------------------------------------+
//| Data calculation for the table                                   |
//+------------------------------------------------------------------+
void CProgram::SetAnalyzeData(string pattern_name,int row,int patterns_total,int model_type)
  {
   color clr=(model_type==1)?clrForestGreen:clrCrimson;
   m_table1.SetValue(0,row,pattern_name);
   m_table1.TextColor(0,row,clr);
   m_table1.SetValue(1,row,(string)patterns_total);
   m_table1.SetValue(2,row,(string)((double)patterns_total/m_range_total1*100),2);
  }
//+------------------------------------------------------------------+
//| Rebuilds the pattern auto search table                           |
//+------------------------------------------------------------------+
bool CProgram::BuildingAutoSearchTable(void)
  {
//---
   if(!GetCandleCombitaion())
     {
      if(m_lang_index==0)
         MessageBox("Число выбранных свечей меньше размера исследуемого паттерна!","Ошибка");
      else if(m_lang_index==1)
         MessageBox("The number of selected candles is less than the size of the studied pattern!","Error");
      return(false);
     }
//--- Delete all rows
   m_table2.DeleteAllRows();
//--- Set the number of rows by the number of symbols
   for(int i=0; i<ArraySize(m_total_combination); i++)
     {
      m_table2.AddRow(i);
      m_table2.SetValue(0,i,m_total_combination[i]);
     }
   m_table2.DeleteRow(ArraySize(m_total_combination));
//--- Update the table
   m_table2.Update(true);
   m_table2.GetScrollVPointer().Update(true);
   m_table2.GetScrollHPointer().Update(true);
   return(true);
  }
//+------------------------------------------------------------------+
//| Generating patterns based on simple candlesticks                 |
//+------------------------------------------------------------------+
bool CProgram::GetCandleCombitaion(void)
  {
   string candlenumber[];
   int selected_candles=0,n;
   ArrayResize(candlenumber,m_total_candles);
//---
   for(int i=0;i<m_total_candles;i++)
     {
      if(m_listview1.GetState(i))
        {
         candlenumber[selected_candles]=(string)(i+1);
         selected_candles++;
        }
     }
//---
   if((m_pattern_size==2 && selected_candles<2) || (m_pattern_size==3 && selected_candles<2) || selected_candles<1)
      return(false);
//--- Calculation of the number of combinations
   if(m_pattern_size>1)
      n=(m_button7.IsLocked())?(int)MathPow(selected_candles,m_pattern_size):(int)MathPow(selected_candles,m_pattern_size)-selected_candles;
   else
      n=selected_candles;
   ArrayResize(m_total_combination,n);

   n=0;
//--- A set of one candlestick
   if(m_pattern_size==1)
     {
      for(int i=0;i<selected_candles;i++)
         m_total_combination[i]="["+candlenumber[i]+"]";
     }
//--- A set of two candlesticks
   else if(m_pattern_size==2)
     {
      //--- Repeat mode enabled
      if(m_button7.IsLocked())
        {
         for(int i=0;i<selected_candles;i++)
           {
            for(int j=0;j<selected_candles;j++)
              {
               m_total_combination[n]="["+candlenumber[i]+","+candlenumber[j]+"]";
               n++;
              }
           }
        }
      //--- Repeat mode disabled
      else if(m_button8.IsLocked())
        {
         for(int i=0;i<selected_candles;i++)
           {
            for(int j=0;j<selected_candles;j++)
              {
               if(j!=i)
                 {
                  m_total_combination[n]="["+candlenumber[i]+","+candlenumber[j]+"]";
                  n++;
                 }
              }
           }
        }
     }
//--- Set of three candlesticks
   else if(m_pattern_size==3)
     {
      //--- Repeat mode enabled
      if(m_button7.IsLocked())
        {
         for(int i=0;i<selected_candles;i++)
           {
            for(int j=0;j<selected_candles;j++)
              {
               for(int k=0;k<selected_candles;k++)
                 {
                  m_total_combination[n]="["+candlenumber[i]+","+candlenumber[j]+","+candlenumber[k]+"]";
                  n++;
                 }
              }
           }
        }
      //--- Repeat mode disabled
      else if(m_button8.IsLocked())
        {
         for(int i=0;i<selected_candles;i++)
           {
            for(int j=0;j<selected_candles;j++)
               for(int k=0;k<selected_candles;k++)
                 {
                  if(i==j && i==k)
                     continue;
                  m_total_combination[n]="["+candlenumber[i]+","+candlenumber[j]+","+candlenumber[k]+"]";
                  n++;
                 }
           }
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns the timeframe by string                                  |
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
