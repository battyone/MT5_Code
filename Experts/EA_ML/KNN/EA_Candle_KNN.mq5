//+------------------------------------------------------------------+
//|                                                EA_Candle_KNN.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade/Trade.mqh>
input int InpNeighbor=10;
enum KNN_RESULT
  {
   ENUM_KNN_NO=0,
   ENUM_KNN_UP=1,
   ENUM_KNN_DOWN=2,
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ModelData
  {
   double            r_c;
   double            r_h;
   double            r_l;
   int               label;
  };
ModelData md[];
double    dist[][2];

MqlRates rates[];
datetime last_bar_time;
CTrade trade;
MqlTick tick;
double tp_price;
double sl_price;
string str_comment;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!ReadModelData())
     {
      Print("读取模型数据失败");
      return INIT_FAILED;
     }
   Print("模型库中的数据条数",ArraySize(md));
   CopyRates(_Symbol,_Period,0,1,rates);
   last_bar_time=rates[0].time;
   Print(last_bar_time);
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
   CopyRates(_Symbol,_Period,0,2,rates);
   if(rates[1].time>last_bar_time)
     {
      last_bar_time=rates[1].time;
      //Print("new bar:",last_bar_time);
      switch(GetKnnResult(rates[0]))
        {
         case ENUM_KNN_DOWN :
            //Print("-1:Short");
            OpenShortPosition(0.01,str_comment);
            break;
         case ENUM_KNN_UP:
            //Print("1-Long");
            OpenLongPosition(0.01,str_comment);
            break;
         default:
            //Print("0:不操作");
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ReadModelData()
  {
//---读取模型数据
   string str_period="bar_h1";
   int file_handle=FileOpen("KnnModels\\knn_model_"+_Symbol+"_"+str_period+".csv",FILE_READ|FILE_CSV|FILE_ANSI|FILE_COMMON);
   int default_size=5;
   int size=0;
   string str;
   string str_arr[];
   ArrayResize(md,default_size);
   if(file_handle!=INVALID_HANDLE)
     {
      while(!FileIsEnding(file_handle))
        {
         str=FileReadString(file_handle);
         StringSplit(str,',',str_arr);
         md[size].r_c=StringToDouble(str_arr[0]);
         md[size].r_h=StringToDouble(str_arr[1]);
         md[size].r_l=StringToDouble(str_arr[2]);
         md[size].label=int(StringToInteger(str_arr[3]));
         //Print(md[size].r_c," ",md[size].r_h," ",md[size].r_l," ",md[size].label);
         size++;
         if(size==default_size)
           {
            default_size+=100;
            ArrayResize(md,default_size);
           }
        }
      ArrayResize(dist,ArraySize(md));
      FileClose(file_handle);
      int up_n=0,down_n=0,no_n=0;
      for(int i=0;i<ArraySize(md);i++)
        {
         if(md[i].label==1) up_n++;
         else if(md[i].label==-1) down_n++;
         else no_n++;
        }
      Print("Up:",up_n," Down:",down_n," No:",no_n);
      return true;
     }
   else
     {
      Print("数据模型读取错误");
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
KNN_RESULT GetKnnResult(MqlRates &rate)
  {
   double rc=rate.close/rate.open;
   double rh=rate.high/rate.open;
   double rl=rate.low/rate.open;
   //Print("bar mode:" ,rc, " ",rh," ", rl);
   for(int i=0;i<ArraySize(md);i++)
     {
      dist[i][1]=i;
      dist[i][0]=MathPow((md[i].r_c-rc),2)+MathPow((md[i].r_h-rh),2)+MathPow((md[i].r_l-rl),2);
     }
   ArraySort(dist);
   int n_up=0,n_down=0,n_no=0;
   for(int i=0;i<InpNeighbor;i++)
     {
      if(md[(int)dist[i][1]].label==1) n_up++;
      else if(md[(int)dist[i][1]].label==2) n_down++;
      else n_no++;
      //Print("min dist:",i," ",dist[i][0]," index-",dist[i][1]," class-",md[(int)dist[i][1]].label);
     }
   //Print("knn results:", n_up, " ", n_down, " ",n_no, " ",dist[99][0]," ",dist[99][1]," ",md[(int)dist[99][1]].label);
   str_comment=IntegerToString(n_up)+"|"+IntegerToString(n_down)+"|"+IntegerToString(n_no);
   if(n_no>=n_up&&n_no>=n_down) return ENUM_KNN_NO;
   if(n_up>n_down) 
      {
      Print("knn up:", n_up, " ", n_down, " ",n_no, " ",dist[99][0]," ",dist[99][1]," ",md[(int)dist[99][1]].label);
       return ENUM_KNN_UP;
      }
   else
      {
       Print("knn down:", n_up, " ", n_down, " ",n_no, " ",dist[99][0]," ",dist[99][1]," ",md[(int)dist[99][1]].label);
      return ENUM_KNN_DOWN;   
      }
    
  }
void OpenLongPosition(double l=0.01,string comment="")
   {
    SymbolInfoTick(_Symbol,tick);
    tp_price=tick.ask+500*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
    sl_price=tick.ask-500*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
    trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,l,tick.ask,sl_price,tp_price,comment);
   }
void OpenShortPosition(double l=0.01,string comment="")
   {
    SymbolInfoTick(_Symbol,tick);
    tp_price=tick.bid-500*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
    sl_price=tick.bid+500*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
    trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,l,tick.bid,sl_price,tp_price,comment);
   }
//+------------------------------------------------------------------+
