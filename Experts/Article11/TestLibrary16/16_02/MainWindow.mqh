//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Program.mqh"
//+------------------------------------------------------------------+
//| Creates a form for controls                                      |
//+------------------------------------------------------------------+
bool CProgram::CreateWindow(const string caption_text)
  {
//--- Add the window pointer to the window array
   CWndContainer::AddWindow(m_window);
//--- Coordinates
   int x=(m_window.X()>0) ? m_window.X() : 1;
   int y=(m_window.Y()>0) ? m_window.Y() : 1;
//--- Properties
   m_window.XSize(518);
   m_window.YSize(600);
   m_window.Alpha(200);
   m_window.IconXGap(3);
   m_window.IconYGap(2);
   m_window.IsMovable(true);
   m_window.ResizeMode(true);
   m_window.CloseButtonIsUsed(true);
   m_window.FullscreenButtonIsUsed(true);
   m_window.CollapseButtonIsUsed(true);
   m_window.TooltipsButtonIsUsed(true);
   m_window.RollUpSubwindowMode(true,true);
   m_window.TransparentOnlyCaption(true);
//--- Set the tooltips
   m_window.GetCloseButtonPointer().Tooltip("Close");
   m_window.GetFullscreenButtonPointer().Tooltip("Fullscreen/Minimize");
   m_window.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
   m_window.GetTooltipButtonPointer().Tooltip("Tooltips");
//--- Creating a form
   if(!m_window.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the status bar                                           |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_1.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_2.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_3.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_4.bmp"
//---
bool CProgram::CreateStatusBar(const int x_gap,const int y_gap)
  {
#define STATUS_LABELS_TOTAL 2
//--- Store the pointer to the main control
   m_status_bar.MainPointer(m_window);
//--- Width
   int width[]={0,130};
//--- Properties
   m_status_bar.YSize(22);
   m_status_bar.AutoXResizeMode(true);
   m_status_bar.AutoXResizeRightOffset(1);
   m_status_bar.AnchorBottomWindowSide(true);
//--- Add items
   for(int i=0; i<STATUS_LABELS_TOTAL; i++)
      m_status_bar.AddItem(width[i]);
//--- Setting the text
   m_status_bar.SetValue(0,"For Help, press F1");
   m_status_bar.SetValue(1,"Disconnected...");
//--- Setting the icons
   m_status_bar.GetItemPointer(1).LabelXGap(25);
   m_status_bar.GetItemPointer(1).AddImagesGroup(5,3);
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_1.bmp");
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_2.bmp");
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_3.bmp");
   m_status_bar.GetItemPointer(1).AddImage(0,"Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_4.bmp");
//--- Create a control
   if(!m_status_bar.CreateStatusBar(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_status_bar);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create icon 1                                                    |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\resize_window.bmp"
//---
bool CProgram::CreatePicture1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_picture1.MainPointer(m_status_bar);
//--- Properties
   m_picture1.XSize(8);
   m_picture1.YSize(8);
   m_picture1.IconFile("Images\\EasyAndFastGUI\\Controls\\resize_window.bmp");
   m_picture1.AnchorRightWindowSide(true);
   m_picture1.AnchorBottomWindowSide(true);
//--- Creating the button
   if(!m_picture1.CreatePicture(x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_picture1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Animate" checkbox                                    |
//+------------------------------------------------------------------+
bool CProgram::CreateCheckBoxAnimate(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_animate.MainPointer(m_window);
//--- Set properties before creation
   m_animate.XSize(90);
   m_animate.YSize(14);
   m_animate.IsPressed(false);
//--- Create a control
   if(!m_animate.CreateCheckBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_animate);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Array size" edit box                                 |
//+------------------------------------------------------------------+
bool CProgram::CreateSpinEditArraySize(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_array_size.MainPointer(m_window);
//--- Properties
   m_array_size.XSize(140);
   m_array_size.MaxValue(10000);
   m_array_size.MinValue(3);
   m_array_size.StepValue(1);
   m_array_size.SetDigits(0);
   m_array_size.SpinEditMode(true);
   m_array_size.SetValue((string)1000);
   m_array_size.GetTextBoxPointer().XSize(70);
   m_array_size.GetTextBoxPointer().AutoSelectionMode(true);
   m_array_size.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_array_size.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_array_size);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Random" button                                       |
//+------------------------------------------------------------------+
bool CProgram::CreateButtonRandom(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_random.MainPointer(m_window);
//--- Properties
   m_random.XSize(140);
   m_random.YSize(20);
   m_random.IconXGap(3);
   m_random.IconYGap(3);
   m_random.IsCenterText(true);
//--- Create a control
   if(!m_random.CreateButton(text,x_gap,y_gap))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_random);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a separation line                                        |
//+------------------------------------------------------------------+
bool CProgram::CreateSepLine2(const int x_gap,const int y_gap)
  {
//--- Store the window pointer
   m_sep_line2.MainPointer(m_window);
//--- Size
   int x_size=2;
   int y_size=72;
//--- Properties
   m_sep_line2.DarkColor(C'150,150,150');
   m_sep_line2.LightColor(clrWhite);
   m_sep_line2.TypeSepLine(V_SEP_LINE);
//--- Create control
   if(!m_sep_line2.CreateSeparateLine(x_gap,y_gap,x_size,y_size))
      return(false);
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_sep_line2);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Period" edit box                                     |
//+------------------------------------------------------------------+
bool CProgram::CreateSpinEditIndPeriod(const int x_gap,const int y_gap,const string text)
  {
//--- Store the pointer to the main control
   m_ind_period.MainPointer(m_window);
//--- Properties
   m_ind_period.XSize(135);
   m_ind_period.MaxValue(100);
   m_ind_period.MinValue(1);
   m_ind_period.StepValue(1);
   m_ind_period.SetDigits(0);
   m_ind_period.SpinEditMode(true);
   m_ind_period.SetValue((string)100);
   m_ind_period.GetTextBoxPointer().XSize(70);
   m_ind_period.GetTextBoxPointer().AutoSelectionMode(true);
   m_ind_period.GetTextBoxPointer().AnchorRightWindowSide(true);
//--- Create a control
   if(!m_ind_period.CreateTextEdit(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_ind_period);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Curve type" combo box                                |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxCurveType(const int x_gap,const int y_gap,const string text)
  {
#define ROWS3_TOTAL 5
//--- Store the pointer to the main control
   m_curve_type.MainPointer(m_window);
//--- Properties
   m_curve_type.XSize(215);
   m_curve_type.ItemsTotal(ROWS3_TOTAL);
   m_curve_type.GetButtonPointer().XSize(150);
   m_curve_type.GetButtonPointer().AnchorRightWindowSide(true);
//--- Array of the chart line types
   string array[]={"CURVE_POINTS","CURVE_LINES","CURVE_POINTS_AND_LINES","CURVE_STEPS","CURVE_HISTOGRAM"};
//--- Populate the combo box list
   for(int i=0; i<ROWS3_TOTAL; i++)
      m_curve_type.SetValue(i,array[i]);
//--- List properties
   CListView *lv=m_curve_type.GetListViewPointer();
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 1 : lv.SelectedItemIndex());
//--- Create a control
   if(!m_curve_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_curve_type);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Point type" combo box                                |
//+------------------------------------------------------------------+
bool CProgram::CreateComboBoxPointType(const int x_gap,const int y_gap,const string text)
  {
#define ROWS4_TOTAL 10
//--- Store the pointer to the main control
   m_point_type.MainPointer(m_window);
//--- Properties
   m_point_type.XSize(215);
   m_point_type.ItemsTotal(ROWS4_TOTAL);
   m_point_type.GetButtonPointer().XSize(150);
   m_point_type.GetButtonPointer().AnchorRightWindowSide(true);
//--- Array of the chart point types
   string array[]=
     {
      "POINT_CIRCLE","POINT_SQUARE","POINT_DIAMOND","POINT_TRIANGLE","POINT_TRIANGLE_DOWN",
      "POINT_X_CROSS","POINT_PLUS","POINT_STAR","POINT_HORIZONTAL_DASH","POINT_VERTICAL_DASH"
     };
//--- Populate the combo box list
   for(int i=0; i<ROWS4_TOTAL; i++)
      m_point_type.SetValue(i,array[i]);
//--- List properties
   CListView *lv=m_point_type.GetListViewPointer();
   lv.YSize(183);
   lv.LightsHover(true);
   lv.SelectItem(lv.SelectedItemIndex()==WRONG_VALUE ? 0 : lv.SelectedItemIndex());
//--- Create a control
   if(!m_point_type.CreateComboBox(text,x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_point_type);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create chart 1                                                   |
//+------------------------------------------------------------------+
bool CProgram::CreateGraph1(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_graph1.MainPointer(m_window);
//--- Properties
   m_graph1.AutoXResizeMode(true);
   m_graph1.AutoYResizeMode(true);
   m_graph1.AutoXResizeRightOffset(2);
   m_graph1.AutoYResizeBottomOffset(230);
//--- Create control
   if(!m_graph1.CreateGraph(x_gap,y_gap))
      return(false);
//--- Chart properties
   CGraphic *graph=m_graph1.GetGraphicPointer();
   graph.BackgroundColor(::ColorToARGB(clrWhiteSmoke));
//--- Initialize the arrays
   InitGraph1Arrays();
//--- Create the curves
   CCurve *curve1=graph.CurveAdd(data1,::ColorToARGB(clrCornflowerBlue),CURVE_LINES);
   CCurve *curve2=graph.CurveAdd(data2,::ColorToARGB(clrRed),CURVE_LINES);
//--- Plot the data on the chart
   graph.CurvePlotAll();
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_graph1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create chart 2                                                   |
//+------------------------------------------------------------------+
bool CProgram::CreateGraph2(const int x_gap,const int y_gap)
  {
//--- Store the pointer to the main control
   m_graph2.MainPointer(m_window);
//--- Properties
   m_graph2.AutoXResizeMode(true);
   m_graph2.AutoYResizeMode(true);
   m_graph2.AutoXResizeRightOffset(2);
   m_graph2.AutoYResizeBottomOffset(23);
   m_graph2.AnchorBottomWindowSide(true);
//--- Create control
   if(!m_graph2.CreateGraph(x_gap,y_gap))
      return(false);
//--- Chart properties
   CGraphic *graph=m_graph2.GetGraphicPointer();
   graph.BackgroundColor(::ColorToARGB(clrWhiteSmoke));
//--- Initialize the arrays
   InitGraph2Arrays();
//--- Create the curves
   CCurve *curve1=graph.CurveAdd(data3,::ColorToARGB(clrCornflowerBlue),CURVE_LINES);
   CCurve *curve2=graph.CurveAdd(data4,::ColorToARGB(clrRed),CURVE_LINES);
//--- Plot the data on the chart
   graph.CurvePlotAll();
//--- Add the pointer to control to the base
   CWndContainer::AddToElementsArray(0,m_graph2);
   return(true);
  }
//+------------------------------------------------------------------+
//| Resize the arrays 1                                              |
//+------------------------------------------------------------------+
void CProgram::ResizeGraph1Arrays(void)
  {
   int array_size =::ArraySize(data1);
   int new_size   =(int)m_array_size.GetValue();
//--- Leave, if the size has not changed
   if(array_size==new_size)
      return;
//--- Set the new size
   ResizeGraph1Arrays(new_size);
//--- Initialization
   ZeroGraph1Arrays();
  }
//+------------------------------------------------------------------+
//| Resize the arrays 2                                              |
//+------------------------------------------------------------------+
void CProgram::ResizeGraph2Arrays(void)
  {
   int array_size =::ArraySize(data3);
   int new_size   =(int)m_array_size.GetValue();
//--- Leave, if the size has not changed
   if(array_size==new_size)
      return;
//--- Set the new size
   ResizeGraph2Arrays(new_size);
//--- Initialization
   ZeroGraph2Arrays();
  }
//+------------------------------------------------------------------+
//| Resize the arrays 1                                              |
//+------------------------------------------------------------------+
void CProgram::ResizeGraph1Arrays(const int new_size)
  {
   ::ArrayResize(data1,new_size);
   ::ArrayResize(data2,new_size);
  }
//+------------------------------------------------------------------+
//| Resize the arrays 1                                              |
//+------------------------------------------------------------------+
void CProgram::ResizeGraph2Arrays(const int new_size)
  {
   ::ArrayResize(data3,new_size);
   ::ArrayResize(data4,new_size);
  }
//+------------------------------------------------------------------+
//| Initialization of arrays                                         |
//+------------------------------------------------------------------+
void CProgram::InitGraph1Arrays(void)
  {
//--- Resize the arrays
   ResizeGraph1Arrays();
//--- Fill the arrays with random data
   int total=(int)m_array_size.GetValue();
   for(int i=0; i<total; i++)
      SetGraph1Value(i);
  }
//+------------------------------------------------------------------+
//| Initialization of arrays                                         |
//+------------------------------------------------------------------+
void CProgram::InitGraph2Arrays(void)
  {
//--- Resize the arrays
   ResizeGraph2Arrays();
//--- The current period
   int period=(int)m_ind_period.GetValue();
//--- Calculate the indicator values
   int total=(int)m_array_size.GetValue();
   for(int i=period; i<total; i++)
      SetGraph2Value(i);
  }
//+------------------------------------------------------------------+
//| Zero the arrays 1                                                |
//+------------------------------------------------------------------+
void CProgram::ZeroGraph1Arrays(void)
  {
   ::ArrayInitialize(data1,NULL);
   ::ArrayInitialize(data2,NULL);
  }
//+------------------------------------------------------------------+
//| Zero the arrays 2                                                |
//+------------------------------------------------------------------+
void CProgram::ZeroGraph2Arrays(void)
  {
   ::ArrayInitialize(data3,NULL);
   ::ArrayInitialize(data4,NULL);
  }
//+------------------------------------------------------------------+
//| Calculate and update series on the chart                         |
//+------------------------------------------------------------------+
void CProgram::UpdateGraph(void)
  {
   UpdateGraph1();
   UpdateGraph2();
  }
//+------------------------------------------------------------------+
//| Calculate and update series on the chart                         |
//+------------------------------------------------------------------+
void CProgram::UpdateGraph1(void)
  {
//--- Ger the values of the curve properties
   ENUM_CURVE_TYPE curve_type =(ENUM_CURVE_TYPE)m_curve_type.GetListViewPointer().SelectedItemIndex();
   ENUM_POINT_TYPE point_type =(ENUM_POINT_TYPE)m_point_type.GetListViewPointer().SelectedItemIndex();
//---
   CGraphic *graph1=m_graph1.GetGraphicPointer();
//--- Update all series of the chart
   int total=graph1.CurvesTotal();
   for(int i=0; i<total; i++)
     {
      CCurve *curve=graph1.CurveGetByIndex(i);
      //--- Set the data arrays
      if(i<1)
         curve.Update(data1);
      else
         curve.Update(data2);
      //--- Set the properties
      curve.PointsType(point_type);
      curve.Type(curve_type);
     }
//--- Apply 
   graph1.Redraw(true);
   graph1.Update();
  }
//+------------------------------------------------------------------+
//| Calculate and update series on the chart                         |
//+------------------------------------------------------------------+
void CProgram::UpdateGraph2(void)
  {
//--- Ger the values of the curve properties
   ENUM_CURVE_TYPE curve_type =(ENUM_CURVE_TYPE)m_curve_type.GetListViewPointer().SelectedItemIndex();
   ENUM_POINT_TYPE point_type =(ENUM_POINT_TYPE)m_point_type.GetListViewPointer().SelectedItemIndex();
//---
   CGraphic *graph2=m_graph2.GetGraphicPointer();
//--- Update all series of the chart
   int total=graph2.CurvesTotal();
   for(int i=0; i<total; i++)
     {
      CCurve *curve=graph2.CurveGetByIndex(i);
      //--- Set the data arrays
      if(i<1)
         curve.Update(data3);
      else
         curve.Update(data4);
      //--- Set the properties
      curve.PointsType(point_type);
      curve.Type(curve_type);
     }
//--- Apply 
   graph2.Redraw(true);
   graph2.Update();
  }
//+------------------------------------------------------------------+
//| Recalculate the series on the chart                              |
//+------------------------------------------------------------------+
void CProgram::RecalculatingSeries(void)
  {
//--- Calculate the values and initialize the arrays
   InitGraph1Arrays();
   InitGraph2Arrays();
//--- Update the series
   UpdateGraph();
  }
//+------------------------------------------------------------------+
//| Add an element with a random value to the end of arrays          |
//+------------------------------------------------------------------+
void CProgram::AddValue(void)
  {
   int array_size =::ArraySize(data1);
   int new_size   =array_size+1;
//---
   ResizeGraph1Arrays(new_size);
   ResizeGraph2Arrays(new_size);
//---
   SetGraph1Value(array_size);
   SetGraph2Value(array_size);
  }
//+------------------------------------------------------------------+
//| Remove the last element of arrays                                |
//+------------------------------------------------------------------+
void CProgram::DeleteValue(void)
  {
   int array_size =::ArraySize(data1);
   int new_size   =array_size-1;
//---
   if(new_size<2)
      return;
//---
   ResizeGraph1Arrays(new_size);
   ResizeGraph2Arrays(new_size);
  }
//+------------------------------------------------------------------+
//| Set random value at the specified index                          |
//+------------------------------------------------------------------+
void CProgram::SetGraph1Value(const int index)
  {
   if(index==0)
     {
      int start_value=1000;
      data1[index]=start_value;
      data2[index]=start_value;
      return;
     }
//---
   int rand_value =::rand()%10*::rand()%10;
   int direction  =(bool(::rand()%2))? rand_value : -rand_value;
   data1[index]   =data1[index-1]+direction;
//---
   rand_value   =::rand()%10*::rand()%10;
   direction    =(bool(::rand()%2))? rand_value : -rand_value;
   data2[index] =data2[index-1]+direction;
  }
//+------------------------------------------------------------------+
//| Setting the value by the specified index                         |
//+------------------------------------------------------------------+
void CProgram::SetGraph2Value(const int index)
  {
   int period=(int)m_ind_period.GetValue();
//---
   if(index-period<1)
      return;
//---
   int    d=100.0;
   double divider1 =(data1[index-period]!=0)? data1[index-period] : 1;
   double divider2 =(data2[index-period]!=0)? data2[index-period] : 1;
   //---
   data3[index] =data1[index]*(d/divider1)-d;
   data4[index] =data2[index]*(d/divider2)-d;
  }
//+------------------------------------------------------------------+
//| Update the chart by timer                                        |
//+------------------------------------------------------------------+
void CProgram::UpdateGraphByTimer(void)
  {
//--- Leave, if (1) the form is minimized or (2) animation is disabled
   if(m_window.IsMinimized() || !m_animate.IsPressed())
      return;
//--- Animate the chart series
   AnimateGraphSeries();
  }
//+------------------------------------------------------------------+
//| Animate the chart series                                         |
//+------------------------------------------------------------------+
void CProgram::AnimateGraphSeries(void)
  {
//--- Switch the direction if the maximum has been reached
   if((double)m_array_size.GetValue()>=m_array_size.MaxValue())
     {
      //--- Set the new value and update the text box
      m_array_size.SetValue((string)m_array_size.MinValue(),false);
      m_array_size.GetTextBoxPointer().Update(true);
      RecalculatingSeries();
      return;
     }
//--- Resize the array in the specified direction
   string value=string((double)m_array_size.GetValue()+m_array_size.StepValue());
//--- Set the new value and update the text box
   m_array_size.SetValue(value,false);
   m_array_size.GetTextBoxPointer().Update(true);
//--- Add an element with a random value
   AddValue();
   UpdateGraph();
  }
//+------------------------------------------------------------------+
