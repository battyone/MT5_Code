//+------------------------------------------------------------------+
//|                                                        Graph.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//+------------------------------------------------------------------+
//| Class for creating a chart                                       |
//+------------------------------------------------------------------+
class CGraph : public CElement
  {
private:
   //--- Objects for creating the element
   CGraphic          m_graph;
   //---
public:
                     CGraph(void);
                    ~CGraph(void);
   //--- Methods for creating the control
   bool              CreateGraph(const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const int x_gap,const int y_gap);
   bool              CreateGraphic(void);
   //---
public:
   //--- Returns the pointer to the chart
   CGraphic         *GetGraphicPointer(void) { return(::GetPointer(m_graph)); }
   //---
public:
   //--- Handler of chart events
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Moving the element
   virtual void      Moving(const bool only_visible=true);
   //--- Management
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //--- Apply the latest changes
   virtual void      Update(const bool redraw=false);
   //---
private:
   //--- Resizing
   void              Resize(const int width,const int height);
   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
   //--- Change the height at the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CGraph::CGraph(void)
  {
//--- Save the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CGraph::~CGraph(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CGraph::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handle the mouse move event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      return;
     }
  }
//+------------------------------------------------------------------+
//| Create a chart                                                   |
//+------------------------------------------------------------------+
bool CGraph::CreateGraph(const int x_gap,const int y_gap)
  {
//--- Exit, if there is no pointer to the main control
   if(!CElement::CheckMainPointer())
      return(false);
//--- Initialization of the properties
   InitializeProperties(x_gap,y_gap);
//--- Create element
   if(!CreateGraphic())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the properties                                 |
//+------------------------------------------------------------------+
void CGraph::InitializeProperties(const int x_gap,const int y_gap)
  {
   m_x  =CElement::CalculateX(x_gap);
   m_y  =CElement::CalculateY(y_gap);
//--- Calculate the sizes
   m_x_size =(m_x_size<1 || m_auto_xresize_mode)? m_main.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
   m_y_size =(m_y_size<1 || m_auto_yresize_mode)? m_main.Y2()-m_y-m_auto_yresize_bottom_offset : m_y_size;
//--- Save the size
   CElementBase::XSize(m_x_size);
   CElementBase::YSize(m_y_size);
//--- Offsets from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
//| Creates the object                                               |
//+------------------------------------------------------------------+
bool CGraph::CreateGraphic(void)
  {
//--- Adjust the sizes
   m_x_size =(m_x_size<1)? 50 : m_x_size;
   m_y_size =(m_y_size<1)? 20 : m_y_size;
//--- Forms the object name
   string name=CElementBase::ElementName("graph");
//--- Coordinates
   int x2=m_x+m_x_size;
   int y2=m_y+m_y_size;
//--- Удалим объект, если он есть
   if(::ObjectFind(m_chart_id,name)>=0)
     {
      ::ObjectDelete(m_chart_id,name);
     }
//--- Creates an object
   if(!m_graph.Create(m_chart_id,name,m_subwin,m_x,m_y,x2,y2))
      return(false);
//--- Properties
   ::ObjectSetString(m_chart_id,m_graph.ChartObjectName(),OBJPROP_TOOLTIP,"\n");
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving                                                           |
//+------------------------------------------------------------------+
void CGraph::Moving(const bool only_visible=true)
  {
//--- Exit if the element is hidden
   if(only_visible)
      if(!CElementBase::IsVisible())
         return;
//--- If the anchored to the right
   if(m_anchor_right_window_side)
     {
      //--- Save coordinates in the control fields
      CElementBase::X(m_main.X2()-XGap());
     }
   else
     {
      CElementBase::X(m_main.X()+XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      CElementBase::Y(m_main.Y2()-YGap());
     }
   else
     {
      CElementBase::Y(m_main.Y()+YGap());
     }
//--- Update coordinates of graphical objects
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_XDISTANCE,X());
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_YDISTANCE,Y());
  }
//+------------------------------------------------------------------+
//| Shows a menu item                                                |
//+------------------------------------------------------------------+
void CGraph::Show(void)
  {
//--- Exit, if this control is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving();
  }
//+------------------------------------------------------------------+
//| Hides a menu item                                                |
//+------------------------------------------------------------------+
void CGraph::Hide(void)
  {
//--- Exit if the element is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redraw                                                           |
//+------------------------------------------------------------------+
void CGraph::Reset(void)
  {
//--- Exit, if this is a drop-down element
   if(CElementBase::IsDropdown())
      return;
//--- Hide and show
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Deletion                                                         |
//+------------------------------------------------------------------+
void CGraph::Delete(void)
  {
//--- Delete series objects
   int total=m_graph.CurvesTotal();
   for(int i=total-1; i>=0; i--)
      m_graph.CurveRemoveByIndex(i);
//--- Delete the chart object
   m_graph.Destroy();
//--- Initializing of variables by default values
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Updating the control                                             |
//+------------------------------------------------------------------+
void CGraph::Update(const bool redraw=false)
  {
//--- Apply
   m_graph.Update();
  }
//+------------------------------------------------------------------+
//| Resize                                                           |
//+------------------------------------------------------------------+
void CGraph::Resize(const int width,const int height)
  {
   m_x_size=width;
   m_y_size=height;
//--- Delete the object
   ::ObjectDelete(m_chart_id,m_graph.ChartObjectName());
//--- Create the chart
   CreateGraphic();
//--- Hide all objects
   if(!CElementBase::IsVisible())
      ::ObjectSetInteger(m_chart_id,m_graph.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CGraph::ChangeWidthByRightWindowSide(void)
  {
//--- Exit, if the anchoring mode to the right side of the form is enabled
   if(m_anchor_right_window_side)
      return;
//--- Size
   int x_size=0;
//--- Calculate the size
   x_size=m_main.X2()-X()-m_auto_xresize_right_offset;
//--- Do not change the size, if it is less than the specified limit
   if(x_size<200 || x_size==m_x_size)
      return;
//--- Set the new size
   CElementBase::XSize(x_size);
   Resize(x_size,m_graph.Height());
//--- Update the data on the chart
   m_graph.Redraw(true);
  }
//+------------------------------------------------------------------+
//| Change the height at the bottom edge of the window               |
//+------------------------------------------------------------------+
void CGraph::ChangeHeightByBottomWindowSide(void)
  {
//--- Exit, if the anchoring mode to the bottom of the form is enabled
   if(m_anchor_bottom_window_side)
      return;
//--- Size
   int y_size=0;
//--- Calculate the size
   y_size=m_main.Y2()-Y()-m_auto_yresize_bottom_offset;
//--- Do not change the size, if it is less than the specified limit
   if(y_size<200 || y_size==m_y_size)
      return;
//--- Set the new size
   CElementBase::YSize(y_size);
   Resize(m_graph.Width(),y_size);
//--- Update the data on the chart
   m_graph.Redraw(true);
  }
//+------------------------------------------------------------------+
