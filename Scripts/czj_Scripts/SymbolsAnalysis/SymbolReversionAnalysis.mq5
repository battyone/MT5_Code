//+------------------------------------------------------------------+
//|                                      SymbolReversionAnalysis.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs
input datetime begin_date=D'2018.01.01';
input datetime end_date=D'2018.10.01';

struct ReversionType
  {
   datetime begin_time;
   datetime end_high_time;
   datetime end_low_time;
   datetime high_time;
   datetime low_time;
   double begin_price;
   double end_high_price;
   double end_low_price;
   double high_price;
   double low_price;
   double up_points;
   double down_points;
  };
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   WriteSymbolDataRandMethod(_Symbol,600,10000);
   //WriteSymbolDataOrderMethod(_Symbol,600);
  }
void WriteSymbolDataOrderMethod(string sym, int bt_points)
   {
   MqlRates rates_copied[];
   int bar_num=Bars(sym,PERIOD_M1,begin_date,end_date);
   Print("bar number:",bar_num);
   int num_copy=CopyRates(sym,PERIOD_M1,end_date,bar_num,rates_copied);
   ReversionType rt_cal[];
   ArrayResize(rt_cal,num_copy);
   ResetLastError();
   FileDelete(sym+"_"+string(bt_points)+".csv");
   int file_handle = FileOpen(sym+"_"+string(bt_points)+".csv",FILE_READ|FILE_WRITE|FILE_CSV);
   if(file_handle!=INVALID_HANDLE)
     {
      Print("等待写数据...");
      FileWrite(file_handle,"起点时间","高点时间","高点回撤时间","低点时间","低点回撤时间",
                            "起点价格","高点价格","高点回撤价格","低点价格","低点回撤价格",
                            "UpPoints","DownPoints");
      bool res_find=false;
      for(int i=0;i<num_copy;i++)
        {
         GetReversionInfo(rates_copied,sym,i,bt_points,rt_cal[i],res_find);
         Print(res_find);
         if(res_find)
           {
            FileWrite(file_handle,rt_cal[i].begin_time,rt_cal[i].high_time,rt_cal[i].end_high_time,rt_cal[i].low_time,rt_cal[i].end_low_time,
                   rt_cal[i].begin_price,rt_cal[i].high_price,rt_cal[i].end_high_price,rt_cal[i].low_price,rt_cal[i].end_low_price,
                   rt_cal[i].up_points,rt_cal[i].down_points);
           }
         
        }
      Print("数据写入完毕，关闭文件！");
      FileClose(file_handle);
     }
   else
     {
      Print("文件打开错误！");
     }
   }
void WriteSymbolDataRandMethod(string sym, int bt_points, int rand_num)
   {
   MqlRates rates_copied[];
   int num_copy=CopyRates(sym,PERIOD_M1,begin_date,end_date,rates_copied);
   ReversionType rt_cal[];
   ArrayResize(rt_cal,rand_num);
   ResetLastError();
   FileDelete(sym+"_"+string(bt_points)+".csv");
   int file_handle = FileOpen(sym+"_"+string(bt_points)+".csv",FILE_READ|FILE_WRITE|FILE_CSV);
   if(file_handle!=INVALID_HANDLE)
     {
      Print("等待写数据...");
      FileWrite(file_handle,"起点时间","高点时间","高点回撤时间","低点时间","低点回撤时间",
                            "起点价格","高点价格","高点回撤价格","低点价格","低点回撤价格",
                            "UpPoints","DownPoints");
      int rand_index;
      int num_total=MathMin(rand_num,num_copy);
      bool res_find=false;
      for(int i=0;i<num_total;i++)
        {
         rand_index=int(rand()/32767.0*(num_total-1));
         GetReversionInfo(rates_copied,sym,rand_index,bt_points,rt_cal[i],res_find);
         if(res_find)
           {
            FileWrite(file_handle,rt_cal[i].begin_time,rt_cal[i].high_time,rt_cal[i].end_high_time,rt_cal[i].low_time,rt_cal[i].end_low_time,
                   rt_cal[i].begin_price,rt_cal[i].high_price,rt_cal[i].end_high_price,rt_cal[i].low_price,rt_cal[i].end_low_price,
                   rt_cal[i].up_points,rt_cal[i].down_points);
           }
        }
      Print("数据写入完毕，关闭文件！");
      FileClose(file_handle);
     }
   else
     {
      Print("文件打开错误！");
     }
   }
void GetReversionInfo(const MqlRates &rates[], string sym, int begin_num, int bt_points, ReversionType &rt, bool &res)
   {
    int num_rates=ArraySize(rates);
    if(begin_num>=num_rates) 
      {
       Print("begin num wrong*********");
       return;
      }
    rt.begin_time=rates[begin_num].time;
    rt.high_time=rt.begin_time;
    rt.low_time=rt.begin_time;
    rt.begin_price=rates[begin_num].open;
    
    double high_price=rt.begin_price;
    double low_price=rt.begin_price;
    bool high_find=false;
    bool low_find=false;
    
    for(int i=begin_num+1;i<num_rates;i++)
      {
       
       //if(MathAbs(rates[i].open-rates[i-1].open)>10000*SymbolInfoDouble(sym,SYMBOL_POINT)) continue;
       if(rates[i].high>high_price&&!high_find)
         {
          high_price=rates[i].high;
          rt.high_price=high_price;
          rt.high_time=rates[i].time;
         }
       if(rates[i].low<low_price && !low_find)
         {
          low_price=rates[i].low;
          rt.low_price=low_price;
          rt.low_time=rates[i].time;
         }
       if(rates[i].low<high_price-bt_points*SymbolInfoDouble(sym,SYMBOL_POINT)&&!high_find)
         {
          high_find=true;
          rt.end_high_time=rates[i].time;
          rt.end_high_price=rates[i].low;
          rt.up_points=((rt.high_price-rt.begin_price)/SymbolInfoDouble(sym,SYMBOL_POINT));
         }
       if(rates[i].high>low_price+bt_points*SymbolInfoDouble(sym,SYMBOL_POINT)&&!low_find)
         {
          low_find=true;
          rt.end_low_time=rates[i].time;
          rt.end_low_price=rates[i].high;
          rt.down_points=((rt.begin_price-rt.low_price)/SymbolInfoDouble(sym,SYMBOL_POINT));
         }
       if(low_find&&high_find) 
         {
          if(IsVaild(rt))
            {
             res=true;
             if(rt.begin_time>rt.low_time) Print(rt.begin_time," ", rt.low_time);
             return;
            }
          //Print(rt.begin_time,"/", rt.end_high_time,"/", rt.end_low_time,"/", rt.high_time,"/", rt.low_time);
          res=false;
          return;
         }
      }
     res=false;
   }
bool IsVaild(const ReversionType &rt_cal)
   {
    if(rt_cal.begin_time==D'1970.01.01'||rt_cal.end_high_time==D'1970.01.01'||rt_cal.end_low_time==D'1970.01.01'||rt_cal.high_time==D'1970.01.01'||rt_cal.low_time==D'1970.01.01')
      {
       Print("Error time");
       return false;
      }
    return true;
   }
//+------------------------------------------------------------------+
