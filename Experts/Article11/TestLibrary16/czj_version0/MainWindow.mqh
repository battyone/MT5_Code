//+------------------------------------------------------------------+
//|                                                   MainWindow.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "Program.mqh"
#include <Arrays\ArrayObj.mqh>
#define TABS1_TOTAL 5//TAB分类数量

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CProgram::CreateWindow(const string caption_text)
  {
   CWndContainer::AddWindow(m_window1);
   int x=(m_window1.X()>0) ? m_window1.X() : 1;
   int y=(m_window1.Y()>0) ? m_window1.Y() : 1;

   m_window1.XSize(950);
   m_window1.YSize(600);
   m_window1.Alpha(200);
   m_window1.IconXGap(3);
   m_window1.IconYGap(2);
   m_window1.IsMovable(true);
   m_window1.ResizeMode(true);
   m_window1.CloseButtonIsUsed(true);
   m_window1.FullscreenButtonIsUsed(true);
   m_window1.CollapseButtonIsUsed(true);
   m_window1.TooltipsButtonIsUsed(true);
   m_window1.RollUpSubwindowMode(true,true);
   m_window1.TransparentOnlyCaption(true);
////--- Set the tooltips
   m_window1.GetCloseButtonPointer().Tooltip("Close");
   m_window1.GetFullscreenButtonPointer().Tooltip("Fullscreen/Minimize");
   m_window1.GetCollapseButtonPointer().Tooltip("Collapse/Expand");
   m_window1.GetTooltipButtonPointer().Tooltip("Tooltips");
//--- Creating a form
   if(!m_window1.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);

   return(true);
  }
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_1.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_2.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_3.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\server_off_4.bmp"
//---
bool CProgram::CreateStatusBar(const int x_gap,const int y_gap)
  {
#define STATUS_LABELS_TOTAL 2
//--- Store the pointer to the main control
   m_status_bar.MainPointer(m_window1);
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
bool CProgram::CreateTabs1(const int x_gap,const int y_gap)
   {
    m_tabs1.MainPointer(m_window1);
    int tabs_width[TABS1_TOTAL];
    ::ArrayInitialize(tabs_width,100);
    string tabs_names[TABS1_TOTAL]={"货币篮子监控","货币强弱分析","相关性监控", "特征分析","走势模拟"};
    //--- Properties
    m_tabs1.XSize(400);
    m_tabs1.YSize(500);
    m_tabs1.TabsYSize(22);
    m_tabs1.IsCenterText(true);
    m_tabs1.PositionMode(TABS_TOP);
    m_tabs1.AutoXResizeMode(true);
    m_tabs1.AutoXResizeRightOffset(7);
    m_tabs1.AutoYResizeMode(true);
    m_tabs1.AutoYResizeBottomOffset(27);
    m_tabs1.SelectedTab((m_tabs1.SelectedTab()==WRONG_VALUE) ? 0 : m_tabs1.SelectedTab());
    //--- Add tabs with the specified properties
   for(int i=0; i<TABS1_TOTAL; i++)
      m_tabs1.AddTab((tabs_names[i]!="")? tabs_names[i] : "Tab "+string(i+1),tabs_width[i]);
//--- Create a control
   if(!m_tabs1.CreateTabs(x_gap,y_gap))
      return(false);
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_tabs1);
   return(true);
   }
   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

