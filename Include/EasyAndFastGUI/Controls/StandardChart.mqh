//+------------------------------------------------------------------+
//|                                                StandardChart.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Pointer.mqh"
//+------------------------------------------------------------------+
//| Class for creating a standard chart                              |
//+------------------------------------------------------------------+
class CStandardChart : public CElement
  {
private:
   //--- Objects for creating the element
   CSubChart         m_sub_chart[];
   CPointer          m_x_scroll;
   //--- Chart properties:
   long              m_sub_chart_id[];
   string            m_sub_chart_symbol[];
   ENUM_TIMEFRAMES   m_sub_chart_tf[];
   //--- Horizontal scrolling mode
   bool              m_x_scroll_mode;
   //--- Variables associated with the chart horizontal scrolling
   int               m_prev_x;
   int               m_new_x_point;
   int               m_prev_new_x_point;
   //--- Mode of changing the subwindow height
   bool              m_drag_border_window_mode;
   //---
public:
                     CStandardChart(void);
                    ~CStandardChart(void);
   //--- Methods for creating the standard chart
   bool              CreateStandardChart(const int x_gap,const int y_gap);
   //---
private:
   bool              CreateSubCharts(void);
   bool              CreateXScrollPointer(void);
   //---
public:
   //--- (1) Returns the pointer to the mouse cursor, (2) returns the size of the array of charts
   CPointer         *GetMousePointer(void)                        { return(::GetPointer(m_x_scroll)); }
   int               SubChartsTotal(void)                   const { return(::ArraySize(m_sub_chart)); }
   //--- Returns pointer to the subchart at the specified index
   CSubChart        *GetSubChartPointer(const uint index);
   //--- Horizontal scrolling mode
   void              XScrollMode(const bool mode) { m_x_scroll_mode=mode; }
   //--- Adds a subchart with specified properties before creation
   void              AddSubChart(const string symbol,const ENUM_TIMEFRAMES tf);
   //--- Jump to the specified date
   void              SubChartNavigate(const datetime date);
   //--- Reset charts
   void              ResetCharts(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Moving the element
   virtual void      Moving(const bool only_visible=true);
   //--- Management
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Delete(void);
   //--- (1) Set, (2) reset priorities for clicking the left mouse button
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //---
private:
   //--- Handling the clicking on the subchart
   bool              OnClickSubChart(const string clicked_object);

   //--- Checking the symbol
   bool              CheckSymbol(const string symbol);
   //--- Horizontal scrolling
   void              HorizontalScroll(void);
   //--- Zeroing the horizontal scrolling variables
   void              ZeroHorizontalScrollVariables(void);

   //--- Checking the resizing mode of the chart subwindow
   bool              CheckDragBorderWindowMode(void);

   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
   //--- Change the height at the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStandardChart::CStandardChart(void) : m_prev_x(0),
                                       m_new_x_point(0),
                                       m_prev_new_x_point(0),
                                       m_x_scroll_mode(false),
                                       m_drag_border_window_mode(false)
  {
//--- Save the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStandardChart::~CStandardChart(void)
  {
  }
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
void CStandardChart::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handle the mouse move event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Exit, if in the subwindow resizing mode
      if(CheckDragBorderWindowMode())
         return;
      //--- If in focus, check the horizontal scrollbar of the chart
      if(CElementBase::MouseFocus())
         HorizontalScroll();
      //--- If there is no focus and the left mouse button is released
      else if(!m_mouse.LeftButtonState())
        {
         if(!m_x_scroll.IsVisible())
            return;
         //---
         m_prev_x=0;
         //--- Hide the horizontal scrollbar pointer
         m_x_scroll.Hide();
         ::ChartRedraw();
         //--- Send a message to determine the available controls
         
::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
         //--- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
      //---
      return;
     }
//--- Handle the left mouse button press on the object even
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(OnClickSubChart(sparam))
         return;
     }
  }
//+------------------------------------------------------------------+
//| Creates the "Standard chart" control                             |
//+------------------------------------------------------------------+
bool CStandardChart::CreateStandardChart(const int x_gap,const int y_gap)
  {
//--- Exit, if there is no pointer to the main control
   if(!CElement::CheckMainPointer())
      return(false);
//--- Initialization of the properties
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
   m_x_size   =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
   m_y_size   =(m_y_size<1 || m_auto_yresize_mode)? m_main.Y2()-m_y-m_auto_yresize_bottom_offset : m_y_size;
//--- Offsets from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Priority as in the main control, since the control does not have its own area for clicking
   CElement::Z_Order(m_main.Z_Order());
//--- Creating the chart 
   if(!CreateSubCharts())
      return(false);
   if(!CreateXScrollPointer())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates charts                                                   |
//+------------------------------------------------------------------+
bool CStandardChart::CreateSubCharts(void)
  {
//--- Get the number of subcharts
   int sub_charts_total=SubChartsTotal();
//--- If there is no subchart in a group, report
   if(sub_charts_total<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if a group contains at least one subchart! Use the CStandardChart::AddSubChart() method");
      return(false);
     }
//--- Calculate the coordinates and size
   int x=m_x;
   int x_size=(sub_charts_total>1)? m_x_size/sub_charts_total : m_x_size;
//--- Create specified number of subcharts
   for(int i=0; i<sub_charts_total; i++)
     {
      //--- Forms the object name
      string name=CElementBase::ProgramName()+"_sub_chart_"+(string)i+"__"+(string)CElementBase::Id();
      //--- Calculation of the X coordinate
      x=(i>0)? x+x_size-1 : x;
      //--- Adjust the width of the last subchart
      if(i+1>=sub_charts_total)
         x_size=m_x_size-(x_size*(sub_charts_total-1)-(sub_charts_total-1));
      //--- Set a button
      if(!m_sub_chart[i].Create(m_chart_id,name,m_subwin,x,m_y,x_size,m_y_size))
         return(false);
      //--- Hide
      m_sub_chart[i].Timeframes(OBJ_NO_PERIODS);
      //--- Get and store the identifier of the created subchart
      m_sub_chart_id[i]=m_sub_chart[i].GetInteger(OBJPROP_CHART_ID);
      //--- Set the properties
      m_sub_chart[i].Symbol(m_sub_chart_symbol[i]);
      m_sub_chart[i].Period(m_sub_chart_tf[i]);
      m_sub_chart[i].Z_Order(m_zorder+1);
      m_sub_chart[i].Tooltip("\n");
      //--- Fixed scale mode
      //::ChartSetInteger(m_sub_chart_id[i],CHART_SCALEFIX,true);
      //--- Maximum and minimum
      //::ChartSetDouble(m_sub_chart_id[i],CHART_FIXED_MAX,2.0);
      //::ChartSetDouble(m_sub_chart_id[i],CHART_FIXED_MIN,1.0);
      //--- Save the size
      m_sub_chart[i].XSize(x_size);
      m_sub_chart[i].YSize(m_y_size);
      //--- Offsets from the extreme point
      m_sub_chart[i].XGap(CElement::CalculateXGap(x));
      m_sub_chart[i].YGap(CElement::CalculateYGap(m_y));
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the horizontal scrollbar pointer                         |
//+------------------------------------------------------------------+
bool CStandardChart::CreateXScrollPointer(void)
  {
//--- Exit, if the horizontal scrolling is not needed
   if(!m_x_scroll_mode)
      return(true);
//--- Setting properties
   m_x_scroll.XGap(0);
   m_x_scroll.YGap(-20);
   m_x_scroll.Id(CElementBase::Id());
   m_x_scroll.Type(MP_X_SCROLL);
//--- Create element
   if(!m_x_scroll.CreatePointer(m_chart_id,m_subwin))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns pointer to the subchart at the specified index           |
//+------------------------------------------------------------------+
CSubChart *CStandardChart::GetSubChartPointer(const uint index)
  {
   uint array_size=::ArraySize(m_sub_chart);
//--- If there is no subchart, report
   if(array_size<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if a group contains at least one subchart!");
     }
//--- Adjustment in case the range has been exceeded
   uint i=(index>=array_size)? array_size-1 : index;
//--- Return the pointer
   return(::GetPointer(m_sub_chart[i]));
  }
//+------------------------------------------------------------------+
//| Adds a subchart                                                  |
//+------------------------------------------------------------------+
void CStandardChart::AddSubChart(const string symbol,const ENUM_TIMEFRAMES tf)
  {
//--- Check if the symbol is available on the server
   if(!CheckSymbol(symbol))
     {
      ::Print(__FUNCTION__," > The "+symbol+" symbol is not available on the server!");
      return;
     }
//---
   int reserve=10;
//--- Increase the size of the arrays by one element
   int array_size=::ArraySize(m_sub_chart);
   int new_size=array_size+1;
   ::ArrayResize(m_sub_chart,new_size,reserve);
   ::ArrayResize(m_sub_chart_id,new_size,reserve);
   ::ArrayResize(m_sub_chart_symbol,new_size,reserve);
   ::ArrayResize(m_sub_chart_tf,new_size,reserve);
//--- Save the values of passed parameters
   m_sub_chart_symbol[array_size] =symbol;
   m_sub_chart_tf[array_size]     =tf;
  }
//+------------------------------------------------------------------+
//| Jump to the specified date                                       |
//+------------------------------------------------------------------+
void CStandardChart::SubChartNavigate(const datetime date)
  {
//--- (1) The current date on the chart and (2) the newly selected in the calendar
   datetime current_date  =::StringToTime(::TimeToString(::TimeCurrent(),TIME_DATE));
   datetime selected_date =date;
//--- Disable auto-scrolling and shift from the right edge
   ::ChartSetInteger(m_chart_id,CHART_AUTOSCROLL,false);
   ::ChartSetInteger(m_chart_id,CHART_SHIFT,false);
//--- If the selected date in the calendar is greater than the current
   if(selected_date>=current_date)
     {
      //--- Go to the current date on all charts
      ::ChartNavigate(m_chart_id,CHART_END);
      ResetCharts();
      return;
     }
//--- Get the number of bars from the date specified
   int  bars_total    =::Bars(::Symbol(),::Period(),selected_date,current_date);
   int  visible_bars  =(int)::ChartGetInteger(m_chart_id,CHART_VISIBLE_BARS);
   long seconds_today =::TimeCurrent()-current_date;
   int  bars_today    =int(seconds_today/::PeriodSeconds())+2;
//--- Set the shift from the right edge for all charts
   m_prev_new_x_point=m_new_x_point=-((bars_total-visible_bars)+bars_today);
   ::ChartNavigate(m_chart_id,CHART_END,m_new_x_point);
//---
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
     {
      //--- Disable auto-scrolling and shift from the right edge
      ::ChartSetInteger(m_sub_chart_id[i],CHART_AUTOSCROLL,false);
      ::ChartSetInteger(m_sub_chart_id[i],CHART_SHIFT,false);
      //--- Get the number of bars from the date specified
      bars_total   =::Bars(m_sub_chart[i].Symbol(),(ENUM_TIMEFRAMES)m_sub_chart[i].Period(),selected_date,current_date);
      visible_bars =(int)::ChartGetInteger(m_sub_chart_id[i],CHART_VISIBLE_BARS);
      bars_today   =int(seconds_today/::PeriodSeconds((ENUM_TIMEFRAMES)m_sub_chart[i].Period()))+2;
      //--- Shift from the right edge of the chart
      m_prev_new_x_point=m_new_x_point=-((bars_total-visible_bars)+bars_today);
      ::ChartNavigate(m_sub_chart_id[i],CHART_END,m_new_x_point);
     }
  }
//+------------------------------------------------------------------+
//| Reset charts                                                     |
//+------------------------------------------------------------------+
void CStandardChart::ResetCharts(void)
  {
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      ::ChartNavigate(m_sub_chart_id[i],CHART_END);
//--- Zero the auxiliary variables for horizontal scrolling of charts
   ZeroHorizontalScrollVariables();
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CStandardChart::Moving(const bool only_visible=true)
  {
//--- Exit if the element is hidden
   if(only_visible)
      if(!CElementBase::IsVisible())
         return;
//--- Update the position
   CElement::Moving();
//---
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
     {
      //--- If the anchored to the right
      if(m_anchor_right_window_side)
        {
         //--- Save coordinates in the control fields
         CElementBase::X(m_main.X2()-XGap());
         //--- Save coordinates in the fields of the objects
         m_sub_chart[i].X(m_main.X2()-m_sub_chart[i].XGap());
        }
      //--- If the anchored to the left
      else
        {
         CElementBase::X(m_main.X()+XGap());
         m_sub_chart[i].X(m_main.X()+m_sub_chart[i].XGap());
        }
      //--- If the anchored to the bottom
      if(m_anchor_bottom_window_side)
        {
         CElementBase::Y(m_main.Y2()-YGap());
         m_sub_chart[i].Y(m_main.Y2()-m_sub_chart[i].YGap());
        }
      //--- If the anchored to the top
      else
        {
         CElementBase::Y(m_main.Y()+YGap());
         m_sub_chart[i].Y(m_main.Y()+m_sub_chart[i].YGap());
        }
      //--- Update coordinates of graphical objects
      m_sub_chart[i].X_Distance(m_sub_chart[i].X());
      m_sub_chart[i].Y_Distance(m_sub_chart[i].Y());
     }
//--- Zero the auxiliary variables for horizontal scrolling of charts
   ZeroHorizontalScrollVariables();
  }
//+------------------------------------------------------------------+
//| Shows the button                                                 |
//+------------------------------------------------------------------+
void CStandardChart::Show(void)
  {
//--- Exit, if this control is already visible
   if(CElementBase::IsVisible())
      return;
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving();
//--- Make all the objects visible
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Timeframes(OBJ_ALL_PERIODS);
  }
//+------------------------------------------------------------------+
//| Hides the button                                                 |
//+------------------------------------------------------------------+
void CStandardChart::Hide(void)
  {
//--- Exit if the element is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide the horizontal scrollbar pointer
   m_x_scroll.Hide();
//--- Hide all objects
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Deletion                                                         |
//+------------------------------------------------------------------+
void CStandardChart::Delete(void)
  {
   m_x_scroll.Delete();
//--- Deleting objects
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Delete();
//--- Emptying the control arrays
   ::ArrayFree(m_sub_chart);
//--- Initializing of variables by default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Set the priorities                                               |
//+------------------------------------------------------------------+
void CStandardChart::SetZorders(void)
  {
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Z_Order(m_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CStandardChart::ResetZorders(void)
  {
   int sub_charts_total=SubChartsTotal();
   for(int i=0; i<sub_charts_total; i++)
      m_sub_chart[i].Z_Order(WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Handling the pressing of a button                                |
//+------------------------------------------------------------------+
bool CStandardChart::OnClickSubChart(const string clicked_object)
  {
//--- Exit, if the pressing was not on the menu item
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_sub_chart_",0)<0)
      return(false);
//--- Get the identifier and the index from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
//--- Exit, if the identifier does not match
   if(id!=CElementBase::Id())
      return(false);
//--- Get the index
   int group_index=CElementBase::IndexFromObjectName(clicked_object);
//--- Send a signal about it
   ::EventChartCustom(m_chart_id,ON_CLICK_SUB_CHART,CElementBase::Id(),group_index,m_sub_chart_symbol[group_index]);
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking the availability of symbol                              |
//+------------------------------------------------------------------+
bool CStandardChart::CheckSymbol(const string symbol)
  {
   bool flag=false;
//--- Check the symbol in the Market Watch
   int symbols_total=::SymbolsTotal(true);
   for(int i=0; i<symbols_total; i++)
     {
      //--- If this symbol is available, stop the loop
      if(::SymbolName(i,true)==symbol)
        {
         flag=true;
         break;
        }
     }
//--- If the symbol is not available in the Market Watch, then ...
   if(!flag)
     {
      //--- ... try to find it in the general list
      symbols_total=::SymbolsTotal(false);
      for(int i=0; i<symbols_total; i++)
        {
         //--- If this symbol is available, then...
         if(::SymbolName(i,false)==symbol)
           {
            //--- ... add it to the Market Watch and stop the cycle
            ::SymbolSelect(symbol,true);
            flag=true;
            break;
           }
        }
     }
//--- Return the search results
   return(flag);
  }
//+------------------------------------------------------------------+
//| Horizontal scrolling of the chart                                |
//+------------------------------------------------------------------+
void CStandardChart::HorizontalScroll(void)
  {
//--- Exit, if the horizontal scrolling is disabled
   if(!m_x_scroll_mode)
      return;
//--- If the mouse button is pressed
   if(m_mouse.LeftButtonState())
     {
      //--- Save current X coordinates of the cursor
      if(m_prev_x==0)
        {
         m_prev_x      =m_mouse.X()+m_prev_new_x_point;
         m_new_x_point =m_prev_new_x_point;
         //--- Update the cursor coordinates and make it visible
         m_x_scroll.Moving(m_mouse.X(),m_mouse.Y());
         m_x_scroll.Reset();
         //--- Send a message to determine the available controls
         ::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),0,"");
         //--- Send a message about the change in the graphical interface
         ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
        }
      else
         m_new_x_point=m_prev_x-m_mouse.X();
      //--- Update coordinates of cursor
      m_x_scroll.Moving(m_mouse.X(),m_mouse.Y());
     }
   else
     {
      if(m_prev_x==0)
         return;
      //---
      m_prev_x=0;
      //--- Hide the cursor
      m_x_scroll.Hide();
      m_chart.Redraw();
      //--- Send a message to determine the available controls
      
::EventChartCustom(m_chart_id,ON_SET_AVAILABLE,CElementBase::Id(),1,"");
      //--- Send a message about the change in the graphical interface
      ::EventChartCustom(m_chart_id,ON_CHANGE_GUI,CElementBase::Id(),0,"");
      return;
     }
//--- Exit, if the value is positive
   if(m_new_x_point>0)
      return;
//--- Save the current location
   m_prev_new_x_point=m_new_x_point;
//--- Apply to all charts
   int symbols_total=SubChartsTotal();
//--- Disable auto-scrolling and shift from the right edge
   for(int i=0; i<symbols_total; i++)
     {
      if(::ChartGetInteger(m_sub_chart_id[i],CHART_AUTOSCROLL))
         ::ChartSetInteger(m_sub_chart_id[i],CHART_AUTOSCROLL,false);
      if(::ChartGetInteger(m_sub_chart_id[i],CHART_SHIFT))
         ::ChartSetInteger(m_sub_chart_id[i],CHART_SHIFT,false);
     }
//--- Reset the last error
   ResetLastError();
//--- Shift the charts
   for(int i=0; i<symbols_total; i++)
      if(!::ChartNavigate(m_sub_chart_id[i],CHART_END,m_new_x_point))
         ::Print(__FUNCTION__," > error: ",::GetLastError());
//--- Refresh the chart
   ::ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Zeroing the horizontal scrolling variables                       |
//+------------------------------------------------------------------+
void CStandardChart::ZeroHorizontalScrollVariables(void)
  {
   m_prev_x           =0;
   m_new_x_point      =0;
   m_prev_new_x_point =0;
  }
//+------------------------------------------------------------------+
//| Checking the resizing mode of the chart subwindow                |
//+------------------------------------------------------------------+
bool CStandardChart::CheckDragBorderWindowMode(void)
  {
//--- Get the height of the main chart
   int chart_y_size=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- If the left mouse button is pressed
   if(m_mouse.LeftButtonState())
     {
      //--- If the mode is disabled
      if(!m_drag_border_window_mode)
        {
         //--- Save the state, if the mouse cursor is within the border capture area for changing the subwindow height
         if((m_mouse.SubWindowNumber()==m_subwin && m_mouse.Y()<2) ||
            (m_mouse.SubWindowNumber()==m_subwin && m_mouse.Y()==chart_y_size+1) ||
            (m_mouse.SubWindowNumber()==m_subwin-1 && m_mouse.Y()>=chart_y_size-2))
           {
            m_drag_border_window_mode=true;
            return(false);
           }
        }
     }
//--- Reset the state of disabled mode
   else
      m_drag_border_window_mode=false;
//--- Return the result of active mode
   if(m_drag_border_window_mode)
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CStandardChart::ChangeWidthByRightWindowSide(void)
  {
//--- Coordinates
   int x=0;
//--- Size
   int x_size=0;
//--- Calculate the new size
   x_size=m_main.X2()-m_sub_chart[0].X()-m_auto_xresize_right_offset;
//--- Do not change the size, if it is less than the specified limit
   if(x_size<80)
      return;
//--- Set the new total size
   CElementBase::XSize(x_size);
//--- Get the number of subcharts in the group
   int sub_charts_total=SubChartsTotal();
//--- Calculating coordinates and size
   x=m_x;
   x_size=(sub_charts_total>1)? x_size/sub_charts_total : x_size;
//--- If more than one subchart
   if(sub_charts_total>1)
     {
      for(int i=0; i<sub_charts_total; i++)
        {
         //--- Calculation of the X coordinate
         x=(i>0)? x+x_size-1 : x;
         //--- Adjust the width of the last subchart
         if(i+1>=sub_charts_total)
            x_size=m_x_size-(x_size*(sub_charts_total-1)-(sub_charts_total-1));
         //---
         m_sub_chart[i].X(x);
         m_sub_chart[i].X_Distance(x);
         //---
         m_sub_chart[i].XSize(x_size);
         m_sub_chart[i].X_Size(x_size);
         //--- Offsets from the extreme point
         m_sub_chart[i].XGap(CElement::CalculateXGap(x));
        }
     }
   else
     {
      //--- Set the new size
      CElementBase::XSize(x_size);
      m_sub_chart[0].XSize(x_size);
      m_sub_chart[0].X_Size(x_size);
     }
//--- Update the position of objects
   Moving();
  }
//+------------------------------------------------------------------+
//| Change the height at the bottom edge of the window               |
//+------------------------------------------------------------------+
void CStandardChart::ChangeHeightByBottomWindowSide(void)
  {
//--- Coordinates
   int y=0;
//--- Size
   int y_size=0;
//--- Calculate the new size
   y_size=m_main.Y2()-m_y-m_auto_yresize_bottom_offset;
//--- Do not change the size, if it is less than the specified limit
   if(y_size<50)
      return;
//--- Get the number of subcharts in the group
   int sub_charts_total=SubChartsTotal();
//--- If more than one subchart
   if(sub_charts_total>1)
     {
      //--- Set the new size
      CElementBase::YSize(y_size);
      for(int i=0; i<sub_charts_total; i++)
        {
         m_sub_chart[i].YSize(y_size);
         m_sub_chart[i].Y_Size(y_size);
        }
     }
   else
     {
      //--- Set the new size
      CElementBase::YSize(y_size);
      m_sub_chart[0].YSize(y_size);
      m_sub_chart[0].Y_Size(y_size);
     }
//--- Update the position of objects
   Moving();
  }
//+------------------------------------------------------------------+
