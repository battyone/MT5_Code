//+------------------------------------------------------------------+
//|                                     EA_GridLinearCombination.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridLinearCombination.mqh>

input int Inp_points_add=500; // 网格加仓点数
input int Inp_points_total=10000; // 网格设置总趋势点
input double Inp_base_lots=0.1; // 基础手数
input string Inp_symbols="AUDUSD,NZDUSD,USDCAD,USDCHF,USDJPY,EURUSD,GBPUSD";  // 品种组合
input string Inp_alphas="-0.8,0.9,-0.3,0.3,-0.1,1.1,-1.0";   // 系数
input uint Inp_magic=20181010;   // Magic ID
//input ENUM_ORDER_TYPE_FILLING Inp_order_type=ORDER_FILLING_FOK;//FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)

string lc_syms[];
string str_alpha[];
double lc_alpha[];

int num1=StringSplit(Inp_symbols,StringGetCharacter(",",0),lc_syms);
int num2=StringSplit(Inp_alphas,StringGetCharacter(",",0),str_alpha);

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(lc_alpha,ArraySize(lc_syms));
   for(int i=0;i<ArraySize(lc_syms);i++)
     {
      lc_alpha[i]=StringToDouble(str_alpha[i]);
     }
//---
//   根据趋势长度和网格大小确定仓位数，以及计算手数的指数函数对应的系数
   int pos_num=int(Inp_points_total/Inp_points_add);
   double alpha,beta;
   beta=MathLog(100)/(pos_num-1);
   alpha=1/MathExp(beta);
//   计算止盈出场点，满足在给定的趋势范围内，一定止盈出场；
   double sum_product=0;
   double sum_lots=0;
   for(int i=1;i<pos_num+1;i++)
     {
      sum_lots+=NormalizeDouble(0.01*alpha*exp(beta*i),2);
      sum_product+=NormalizeDouble(0.01*alpha*exp(beta*i),2)*i;
     }
   int points_win=int(Inp_points_add*(pos_num-sum_product/sum_lots));
   Print("计算出的止盈点位:", points_win); 
   
   CGridLinearCombination *strategy=new CGridLinearCombination();
   strategy.ExpertName("CGridLinearCombination");
   strategy.ExpertMagic(Inp_magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.SetLinearCombinationParameter(lc_syms,lc_alpha);
   strategy.SetGridParameters(Inp_points_add,points_win,pos_num,Inp_base_lots);
   
   Manager.AddStrategy(strategy);
//---
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