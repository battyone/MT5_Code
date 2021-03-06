//---------------------------------------------------------------------
#property copyright 	"Dima S., 2010 �"
#property link      	"dimascub@mail.com"
#property version   	"1.01"
#property description "Market Watch"
//---------------------------------------------------------------------
#property indicator_chart_window
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//	版本历史:
//---------------------------------------------------------------------
//	11.10.2010. - V1.00
//	 - 首次发布;
//
//	20.10.2010. - V1.01
//	 - 增加 - 表格垂直和水平转换参数;
//
//---------------------------------------------------------------------


//---------------------------------------------------------------------
//	包含函数库:
//---------------------------------------------------------------------
#include	<MarketWatch.mqh>
//---------------------------------------------------------------------

//=====================================================================
//	外部输入参数:
//=====================================================================
input string   CurrencylList = "EURUSD; GBPUSD; EURGBP; AUDUSD; NZDUSD; AUDNZD; USDJPY; USDCHF; USDCAD; EURJPY; GBPJPY; AUDJPY; NZDJPY; CHFJPY; CADJPY; XAUUSD;";
input string   TimeFrameList = "H1; H4; D1; MN";
input int      UpDownBorderShift=1;
input int      LeftRightBorderShift=1;
input color    TitlesColor=LightCyan;
//---------------------------------------------------------------------

//---------------------------------------------------------------------
string   Symbol_Array[ ];                 // 交易品种列表
string   TimeFrame_Array[ ];              // 时段列表
ENUM_TIMEFRAMES   TFs[];
string   Titles_Array[]={ "Bid:","Spread:","StopLev:","ToOpen:","Hi-Lo:","DailyAv:" };
//---------------------------------------------------------------------

//---------------------------------------------------------------------
SymbolWatchDisplay   *Watches[];
TableDisplay         TitlesDisplay;
//---------------------------------------------------------------------

//---------------------------------------------------------------------
int            currencies_count;
int            timeframes_count;
bool         is_first_init=true;
//---------------------------------------------------------------------
#define		WIDTH			128
#define		HEIGHT		128
#define		FONTSIZE	10
//---------------------------------------------------------------------
//	OnInit 事件处理函数
//---------------------------------------------------------------------
int OnInit()
  {
//	交易品种列表:
   currencies_count=StringToArrayString(CurrencylList,Symbol_Array);
   if(currencies_count>16)
     {
      currencies_count=16;
     }
//	时段列表:
   timeframes_count=StringToArrayString(TimeFrameList,TimeFrame_Array);
   ArrayResize(TFs,timeframes_count);
   for(int k=0; k<timeframes_count; k++)
     {
      TFs[k]=get_timeframe_from_string(TimeFrame_Array[k]);
     }

   if(is_first_init!=true)
     {
      DeleteGraphObjects();
     }
   InitGraphObjects();
   is_first_init=false;

   RefreshInfo();
   EventSetTimer(1);

   ChartRedraw(0);

   return(0);
  }
//---------------------------------------------------------------------
//	OnCalculate 事件处理函数
//---------------------------------------------------------------------
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
   return(rates_total);
  }
//---------------------------------------------------------------------
//	OnTimer 事件处理函数
//---------------------------------------------------------------------
void OnTimer()
  {
   RefreshInfo();
   ChartRedraw(0);
  }
//---------------------------------------------------------------------
//	OnDeinit 事件处理函数
//---------------------------------------------------------------------
void OnDeinit(const int _reason)
  {
   EventKillTimer();
   DeleteGraphObjects();
  }
//---------------------------------------------------------------------
//	初始化图形对象
//---------------------------------------------------------------------
void InitGraphObjects()
  {
//Print( "创建..." );

//	标题
   TitlesDisplay.SetParams(0,0,CORNER_LEFT_UPPER);
   for(int k=0; k<3; k++)
     {
      TitlesDisplay.AddTitleObject( WIDTH, HEIGHT, LeftRightBorderShift + 5, UpDownBorderShift + k * 2 + 5, Titles_Array[ k ], TitlesColor, "Arial", FONTSIZE );
      TitlesDisplay.SetAnchor( k, ANCHOR_RIGHT );
     }
   TitlesDisplay.AddTitleObject( WIDTH, HEIGHT, LeftRightBorderShift + 5, UpDownBorderShift + 12, Titles_Array[ 3 ], TitlesColor, "Arial", 10 );
   TitlesDisplay.SetAnchor( 3, ANCHOR_RIGHT );
   for(int k=4; k<6; k++)
     {
      TitlesDisplay.AddTitleObject( WIDTH, HEIGHT, LeftRightBorderShift + 5, UpDownBorderShift + 2 * k + 7, Titles_Array[ k ], TitlesColor, "Arial", FONTSIZE );
      TitlesDisplay.SetAnchor( k, ANCHOR_RIGHT );
     }

//	时段
   for(int k=0; k<timeframes_count; k++)
     {
      TitlesDisplay.AddTitleObject( WIDTH, HEIGHT, LeftRightBorderShift + 5, UpDownBorderShift + k * 2 + 20, TimeFrame_Array[ k ] + "%:", TitlesColor, "Arial", FONTSIZE );
      TitlesDisplay.SetAnchor( 6 + k, ANCHOR_RIGHT );
     }

   ArrayResize(Watches,currencies_count);
   for(int i=0; i<currencies_count; i++)
     {
      //	为每个交易品种创建交易品种观察:
      Watches[i]=new SymbolWatchDisplay();
      Watches[i].Create(Symbol_Array[i],0,0,WIDTH,HEIGHT,UpDownBorderShift,LeftRightBorderShift+6+i*7,get_currency_color(Symbol_Array[i]),TFs);
     }
  }
//---------------------------------------------------------------------
//	删除图形对象
//---------------------------------------------------------------------
void DeleteGraphObjects()
  {
//Print( "删除..." );

   TitlesDisplay.Clear();
   for(int i=0; i<currencies_count; i++)
     {
      if(CheckPointer(Watches[i])!=POINTER_INVALID)
        {
         //	删除一个交易品种的元素:
         delete(Watches[i]);
        }
     }
  }
//---------------------------------------------------------------------
//	刷新交易品种信息:
//---------------------------------------------------------------------
void RefreshInfo()
  {
   for(int i=0; i<currencies_count; i++)
     {
      Watches[ i ].RefreshSymbolInfo( );
      Watches[ i ].RedrawSymbolInfo( );
     }
  }
//+----------------------------------------------------------------------------+
//|  作者   : Kim Igor aka KimIV,  http://www.kimiv.ru                       |
//!修改于 : Dima S., 2010 �                                               !
//+----------------------------------------------------------------------------+
//|  Version  : 10.10.2008                                                     |
//|  描述.   : 它分析字符串并把单词放入数组                 |
//+----------------------------------------------------------------------------+
//|  参数:                                                               |
//|    st - 含有单词的字符串, 使用指定分隔符分隔              |
//|    ad - 单词数组                                                     |
//+----------------------------------------------------------------------------+
//|  返回值:                                                           |
//|    数组中的元素个数                                             |
//+----------------------------------------------------------------------------+
int StringToArrayString(string st,string &ad[],string _delimiter=";")
  {
   int      i=0,np;
   string   stp;

   ArrayResize(ad,0);
   while(StringLen(st)>0)
     {
      np=StringFind(st,_delimiter);
      if(np<0)
        {
         stp= st;
         st = "";
        }
      else
        {
         stp= StringSubstr(st,0,np);
         st = StringSubstr(st,np+1);
        }
      i++;
      ArrayResize(ad,i);
      StringTrimLeft(stp);
      ad[i-1]=stp;
     }

   return(ArraySize(ad));
  }
//---------------------------------------------------------------------
//	根据交易品种取得颜色
//---------------------------------------------------------------------
color get_currency_color(string _currency)
  {
   int      i;
   for(i=0; i<currencies_count; i++)
     {
      if(StringFind(Symbol_Array[i],_currency)!=-1)
        {
         if(StringFind(_currency,"GOLD")!=-1)
           {
            return(Gold);
           }
         else if(StringFind(_currency,"XAU")!=-1)
           {
            return(Gold);
           }
         else if(StringFind(_currency,"JPY")!=-1)
           {
            return(NavajoWhite);
           }
         else if(StringFind(_currency,"EUR")!=-1)
           {
            return(DeepSkyBlue);
           }
         else if(StringFind(_currency,"GBP")!=-1)
           {
            return(DeepSkyBlue);
           }
         else if(StringFind(_currency,"QM")!=-1)
           {
            return(Brown);
           }
         else if(StringFind(_currency,"ES")!=-1)
           {
            return(LightSalmon);
           }
         else if(StringFind(_currency,"NQ")!=-1)
           {
            return(LightSalmon);
           }
         else if(StringFind(_currency,"CHF")!=-1)
           {
            return(SpringGreen);
           }
         else if(StringFind(_currency,"CAD")!=-1)
           {
            return(SpringGreen);
           }
         else if(StringFind(_currency,"AUD")!=-1)
           {
            return(GreenYellow);
           }
         else if(StringFind(_currency,"NZD")!=-1)
           {
            return(GreenYellow);
           }

         return(Silver);
        }
     }
   return(Silver);
  }
//---------------------------------------------------------------------
//	把含有时段信息的字符串转换为整数值
//---------------------------------------------------------------------
ENUM_TIMEFRAMES get_timeframe_from_string(string _str)
  {
   if(_str=="M1")
     {
      return(PERIOD_M1);
     }
   if(_str=="M2")
     {
      return(PERIOD_M2);
     }
   if(_str=="M3")
     {
      return(PERIOD_M3);
     }
   if(_str=="M4")
     {
      return(PERIOD_M4);
     }
   if(_str=="M5")
     {
      return(PERIOD_M5);
     }
   if(_str=="M6")
     {
      return(PERIOD_M6);
     }
   if(_str=="M10")
     {
      return(PERIOD_M10);
     }
   if(_str=="M12")
     {
      return(PERIOD_M12);
     }
   if(_str=="M15")
     {
      return(PERIOD_M15);
     }
   if(_str=="M20")
     {
      return(PERIOD_M20);
     }
   if(_str=="M30")
     {
      return(PERIOD_M30);
     }
   if(_str=="H1")
     {
      return(PERIOD_H1);
     }
   if(_str=="H2")
     {
      return(PERIOD_H2);
     }
   if(_str=="H3")
     {
      return(PERIOD_H3);
     }
   if(_str=="H4")
     {
      return(PERIOD_H4);
     }
   if(_str=="H6")
     {
      return(PERIOD_H6);
     }
   if(_str=="H8")
     {
      return(PERIOD_H8);
     }
   if(_str=="H12")
     {
      return(PERIOD_H12);
     }
   if(_str=="D1")
     {
      return(PERIOD_D1);
     }
   if(_str=="W1")
     {
      return(PERIOD_W1);
     }
   if(_str=="MN1")
     {
      return(PERIOD_MN1);
     }

   return(PERIOD_D1);
  }
//+------------------------------------------------------------------+
