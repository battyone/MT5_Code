//+------------------------------------------------------------------+
//|                                                  ColorButton.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Button.mqh"
//+------------------------------------------------------------------+
//| Class for creating buttons to call the color picker              |
//+------------------------------------------------------------------+
class CColorButton : public CElement
  {
private:
   //--- Instances for creating a control
   CButton           m_button;
   //--- Selected color
   color             m_current_color;
   //--- Resource name for the image of the color market on the button
   string            m_resource_name;
   //---
public:
                     CColorButton(void);
                    ~CColorButton(void);
   //--- Methods for creating the control
   bool              CreateColorButton(const string text,const int x_gap,const int y_gap);
   //---
private:
   void              InitializeProperties(const string text,const int x_gap,const int y_gap);
   bool              CreateCanvas(void);
   bool              CreateButton(void);
   //---
public:
   //--- Returns pointers to the button
   CButton          *GetButtonPointer(void)                 { return(::GetPointer(m_button)); }
   color             CurrentColor(void)               const { return(m_current_color);        }
   void              CurrentColor(const color clr);
   //---
public:
   //--- Handler of chart events
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Draws the control
   virtual void      Draw(void);
   //---
private:
   //--- Draws the image
   virtual void      DrawImage(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CColorButton::CColorButton(void) : m_current_color(C'35,205,255'),
                                   m_resource_name("color_marker.bmp")
  {
//--- Save the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CColorButton::~CColorButton(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CColorButton::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handle the mouse move event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Redraw the control
      if(CheckCrossingBorder())
         Update(true);
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
//| Create Button object                                             |
//+------------------------------------------------------------------+
bool CColorButton::CreateColorButton(const string text,const int x_gap,const int y_gap)
  {
//--- Exit, if there is no pointer to the main control
   if(!CElement::CheckMainPointer())
      return(false);
//--- Initialization of the properties
   InitializeProperties(text,x_gap,y_gap);
//--- Create element
   if(!CreateCanvas())
      return(false);
   if(!CreateButton())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the properties                                 |
//+------------------------------------------------------------------+
void CColorButton::InitializeProperties(const string text,const int x_gap,const int y_gap)
  {
   m_x          =CElement::CalculateX(x_gap);
   m_y          =CElement::CalculateY(y_gap);
   m_x_size     =(m_x_size<1)? 100 : m_x_size;
   m_y_size     =(m_y_size<1)? 20 : m_y_size;
   m_label_text =text;
   m_back_color =(m_back_color!=clrNONE)? m_back_color : m_main.BackColor();
//--- Indents and color of the text label
   m_label_x_gap         =(m_label_x_gap!=WRONG_VALUE)? m_label_x_gap : 0;
   m_label_y_gap         =(m_label_y_gap!=WRONG_VALUE)? m_label_y_gap : 4;
   m_label_color         =(m_label_color!=clrNONE)? m_label_color : clrBlack;
   m_label_color_hover   =(m_label_color_hover!=clrNONE)? m_label_color_hover : C'0,120,215';
   m_label_color_locked  =(m_label_color_locked!=clrNONE)? m_label_color_locked : clrGray;
//--- Offsets from the extreme point
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
  }
//+------------------------------------------------------------------+
//| Creates the canvas for drawing                                   |
//+------------------------------------------------------------------+
bool CColorButton::CreateCanvas(void)
  {
//--- Forms the object name
   string name=CElementBase::ElementName("color_button");
//--- Creates an object
   if(!CElement::CreateCanvas(name,m_x,m_y,m_x_size,m_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates button                                                   |
//+------------------------------------------------------------------+
bool CColorButton::CreateButton(void)
  {
//--- Save the pointer to the main control
   m_button.MainPointer(this);
//--- Size
   int x_size=(m_button.XSize()<1)? 80 : m_button.XSize();
//--- Coordinates
   int x =(m_button.XGap()<1)? x_size : m_button.XGap();
   int y =0;
//--- Indents for the image
   int icon_x_gap =(m_button.IconXGap()<1)? 4 : m_button.IconXGap();
   int icon_y_gap =(m_button.IconYGap()<1)? 3 : m_button.IconYGap();
//--- Margins for the text
   int label_x_gap =(m_button.LabelXGap()<1)? 24 : m_button.LabelXGap();
   int label_y_gap =(m_button.LabelYGap()<1)? 4 : m_button.LabelYGap();
//--- Properties
   m_button.XSize(x_size);
   m_button.YSize(m_y_size);
   m_button.IconXGap(icon_x_gap);
   m_button.IconYGap(icon_y_gap);
   m_button.LabelXGap(label_x_gap);
   m_button.LabelYGap(label_y_gap);
//--- Setting the color for the button
   CurrentColor(m_current_color);
   m_button.IconFile(m_resource_name);
   m_button.IconFileLocked(m_resource_name);
//--- Creating a control
   if(!m_button.CreateButton(::ColorToString(m_current_color),x,y))
      return(false);
//--- Add the control to the array
   CElement::AddToArray(m_button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the current color of parameter                            |
//+------------------------------------------------------------------+
void CColorButton::CurrentColor(const color clr)
  {
//--- Save the color
   m_current_color=clr;
//--- Size of the image and array (image_size x image_size)
   uint image_size=14;
   uint image_data[196];
//--- Initialize the array with a color
   for(uint y=0,i=0; y<image_size; y++)
     {
      for(uint x=0; x<image_size; x++,i++)
        {
         if(y<1 || y==image_size-1 || x<1 || x==image_size-1)
            image_data[i]=::ColorToARGB(C'160,160,160');
         else
            image_data[i]=::ColorToARGB(m_current_color);
        }
     }
//--- Create a resource in the EX5 application
   ::ResetLastError();
   if(!::ResourceCreate(m_resource_name,image_data,image_size,image_size,0,0,0,COLOR_FORMAT_ARGB_NORMALIZE))
      ::Print(__FUNCTION__," > error: ",::GetLastError());
//---
   if(m_button.IconXGap()<1)
     {
      m_button.IconXGap(4);
      m_button.IconYGap(3);
     }
//--- Setting the path to the image in the button properties
   m_button.IconFile(m_resource_name);
   m_button.IconFileLocked(m_resource_name);
//--- Setting the text for the button
   m_button.LabelText(::ColorToString(m_current_color));
  }
//+------------------------------------------------------------------+
//| Draws the control                                                |
//+------------------------------------------------------------------+
void CColorButton::Draw(void)
  {
//--- Draw the background
   CElement::DrawBackground();
//--- Draw icon
   CColorButton::DrawImage();
//--- Draw text
   CElement::DrawText();
  }
//+------------------------------------------------------------------+
//| Draws the image                                                  |
//+------------------------------------------------------------------+
void CColorButton::DrawImage(void)
  {
//--- Exit, if (1) the checkbox is not required or (2) icon is not defined
   if(CElement::IconFile()=="")
      return;
//--- Determine the index
   uint image_index=(m_is_pressed)? 2 : 0;
//--- If the element is not blocked
   if(!CElementBase::IsLocked())
     {
      if(CElementBase::MouseFocus())
         image_index=(m_is_pressed)? 2 : 0;
     }
   else
      image_index=(m_is_pressed)? 3 : 1;
//--- Draw the image
   CElement::DrawImage();
  }
//+------------------------------------------------------------------+
