//+------------------------------------------------------------------+
//|                                                   EA_Reverse.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRobot\Frame1\Reverse.mqh>
#include <strategy_czj\common\strategy_common.mqh>

sinput string InpStr1="*****品种选择*****"; // 标题  ——————>
input int InpSym=2;     // 0->Symbol,1->Symbol7,2->Symbol28

sinput string InpStr2="*****基本参数设定*****"; // 标题  ——————>
input int InpTpPoints=300; // 止盈点数
input int InpSlPoints=300; // 止损点数
input int InpSearchBar=20; // 模式识别Bar数
input int InpAdjBar=5; // 相邻Bar数
input int InpSepTime=24; // 相邻两单隔开的时间(小时)

sinput string InpStr3="*****MaFilter映射关系*****"; // 标题  ——————>
input bool InpUseMap1=false;   // 是否使用该映射关系
input int InpMap1=0;
input int InpMap2=0;
input int InpMap3=0;
input int InpMap4=0;
input int InpMap5=0;
input int InpMap6=0;

sinput string InpStr4="*****PriceFilter映射关系*****"; // 标题  ——————>
input bool InpUseMap2=false;   // 是否使用该映射关系
input int InpMap21=0;
input int InpMap22=0;
input int InpMap23=0;
input int InpMap24=0;
input int InpMap25=0;
input int InpMap26=0;
input int InpMap27=0;
input int InpMap28=0;
input int InpMap29=0;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int maps[6];
   maps[0]=InpMap1;
   maps[1]=InpMap2;
   maps[2]=InpMap3;
   maps[3]=InpMap4;
   maps[4]=InpMap5;
   maps[5]=InpMap6;
   
   int maps2[9];
   maps2[0]=InpMap21;
   maps2[1]=InpMap22;
   maps2[2]=InpMap23;
   maps2[3]=InpMap24;
   maps2[4]=InpMap25;
   maps2[5]=InpMap26;
   maps2[6]=InpMap27; 
   maps2[7]=InpMap28;
   maps2[8]=InpMap29;

   string syms[];
   switch(InpSym)
     {
      case 0 :
        ArrayResize(syms,1);
        syms[0]=_Symbol;
        break;
      case 1:
         ArrayCopy(syms,SYMBOLS_7);
         break;
      case 2:
         ArrayCopy(syms,SYMBOLS_28);
         break;   
      default:
        break;
     }
   for(int i=0;i<ArraySize(syms);i++)
     {
      CReverseStrategy *s=new CReverseStrategy();
      s.ExpertMagic(10+i);
      s.ExpertName("CReverseStrategy"+i);
      s.ExpertSymbol(syms[i]);
      s.Timeframe(_Period);
      s.Init();
      s.SetParameters(InpTpPoints,InpSlPoints,InpSearchBar,InpAdjBar,InpSepTime);
      if(InpUseMap1) // 使用MaFilter
        {
         s.SetMaFilterMode(InpUseMap1);
         s.SetMaFilterMapping(maps);
         s.InitMaFilter();
        }
      if(InpUseMap2)
        {
         s.SetPriceFilterMode(InpUseMap2);
         s.SetPriceFilterMapping(maps2);
         s.InitPriceFilter();
        }
      Manager.AddStrategy(s);
     }
   

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
