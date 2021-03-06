#include <Math\Alglib\statistics.mqh>

#property script_show_inputs

input int  backpoints = 600;        // 设置最大回调point 
input int  symbol_index_start = 0;  // 为了防止卡死，建议分段运行脚本
input int  symbol_index_end = 28;    // start为1,end为8; start为8,end为15; start为15,end为22; start为22, end为29
input int  back_type = 1;           // 0：上升回调, sell进场用；1：下降回调, buy进场用；
input datetime d1 = D'2016.01.01 00:00';
input datetime d2 = D'2018.10.01 00:00';

int rand_s1;
double percentile_arr[10] = {0.9999,0.999,0.99,0.97,0.95,0.93,0.9,0.87,0.84,0.8};   // 分位数 10档
double out[10];         //分位数输出结果
//int rand_s2 = rand();
//int rand_s3 = rand();
//int rand_s4 = rand();
//int rand_s5 = rand();
CBaseStat Stat;
string filepath = "statistics";
string filename;

struct Record{
   double   StartPrice;
   double   HighPrice;
   double   LowPrice;
   double   DeltaPrice;
   int      DeltaPoint;
   datetime StartTime;
   datetime HighTime;
   datetime LowTime;
   datetime EndTime;
   uint     HoldingTime;
};

struct Controller{
   int      Start_j1_Mem;
   bool     Existing;
   double   TempBack1;
   double   TempHigh1;
   double   TempLow1;
   datetime TempHightime1;
   datetime TempLowtime1;
};

double TransPoint( string symbol, int point)
{
   return SymbolInfoDouble(symbol, SYMBOL_POINT)*point;
}

int TranDeltaprice( string symbol, double deltaprice )
{
   return deltaprice/SymbolInfoDouble(symbol, SYMBOL_POINT);
}

MqlRates r[];                       // 存储d1-d2之间的所有bar数据
Record record_arr1[];               // 记录backmax达到的点的全部信息
Controller ctrl_arr[10000];              // 采样控制器(MAX)
double deltapoint_arr[];            // 记录backmax达到的点之前的最大点差

double backmax1;         //最大回调point-->delta price
int n;
string sym;

void OnStart()
{
     //double temp_back1 ;
     //double temp_high1 ;
     //double temp_low1;
     //datetime temp_lowtime1;
     //datetime temp_hightime1;
     //bool existing1;
     bool init_existing;
     int j1;
     int jj;
     int delta_jj;
     int rand_count;
     int handle;
     int handle1;
     
     handle1 = FileOpen(filepath+"\\"+ "AA_statistic_"+IntegerToString(backpoints)+"_"+IntegerToString(back_type)+".csv", FILE_READ|FILE_WRITE|FILE_CSV );
     if(handle1 == INVALID_HANDLE)
      {
         Print("Invalid handle1.");
      }
     else
      {
         if(FileSeek(handle1,0,SEEK_END))
         {
            FileWrite(handle1, "Symbols", percentile_arr[0], percentile_arr[1], percentile_arr[2], percentile_arr[3], percentile_arr[4],
                                          percentile_arr[5], percentile_arr[6], percentile_arr[7], percentile_arr[8], percentile_arr[9]);            
         }
      }     
     FileClose(handle1);
     
     for( int s = symbol_index_start ; s<symbol_index_end; s++)
     {
      //sym_arr[s] = SymbolName(s,true);
        rand_s1 = rand();
        rand_count = rand_s1;
        sym = SymbolName(s,true);
        //string sym = sym_arr[0];                    // 参数设置：选择symbol
        filename = sym;
        
        n = Bars(sym,PERIOD_M1,d1,d2);          //返回sym在d1-d2所有bar条目数
        
        backmax1 = TransPoint(sym, backpoints);      //最大回调
        
        if(ArraySize(r)!=0)
        {  
           ArrayFree(r);
           int counter=0;
           int res_copy=CopyRates(sym,PERIOD_M1,d2,n,r);
           while(res_copy==-1&&counter<100)
             {
              res_copy=CopyRates(sym,PERIOD_M1,d2,n,r);
              counter++;
             }
           
           
        }
        else
        {  
           int counter=0;
           int res_copy=CopyRates(sym,PERIOD_M1,d2,n,r);
           while(res_copy==-1&&counter<100)
             {
              res_copy=CopyRates(sym,PERIOD_M1,d2,n,r);
              counter++;
             }
        }
        
        if(ArraySize(record_arr1)!=0)
        {  
           ArrayFree(record_arr1);
           ArrayResize(record_arr1,2000);
        }
        else
        {  
           ArrayResize(record_arr1,2000);
        }
        
        if(ArraySize(deltapoint_arr)!=0)
        {  
           ArrayFree(deltapoint_arr);
           ArrayResize(deltapoint_arr,2000);
        }
        else
        {  
           ArrayResize(deltapoint_arr,2000);
        }
        
        // init ctrl_arr;
        for( int c=0; c<ArraySize(ctrl_arr); c++)
        {
           ctrl_arr[c].Existing = false;
           ctrl_arr[c].Start_j1_Mem = 0;
           ctrl_arr[c].TempBack1 = 0.0;
           ctrl_arr[c].TempHigh1 = 0.0;
           ctrl_arr[c].TempLow1 = 100000.0;
        }
        jj = 0;
               
        if( back_type == 0)
        {
           //temp_back1 = 0.0;
           //temp_high1 = 0.0;
           //existing1 = false;
           init_existing = false;
           j1 = 0;
           for( int i=0; i<n; i++)
           {
               if( i<rand_s1 )
               {
                  continue;
               }
               else
               {
                  if( j1 + 1000 > ArraySize(record_arr1) )
                  {
                     ArrayResize(record_arr1,j1+1999);
                     ArrayResize(deltapoint_arr,j1+1999);
                  }
                  
                  if( i > rand_count || !init_existing)
                  //判断是否抽样
                  {
                     init_existing = true;
                     rand_count = i + (rand()-16384)/(16384/50)+60;              //间隔至少10分钟进行一次随机抽样（10-110分钟之间）
                     if( jj < ArraySize(ctrl_arr) )
                     {
                        ctrl_arr[jj].Start_j1_Mem = j1;
                        ctrl_arr[jj].Existing = true;
                        ctrl_arr[jj].TempBack1 = 0.0;
                        ctrl_arr[jj].TempHigh1 = 0.0;
                        jj++;
                        
                        record_arr1[j1].StartPrice = r[i].low;
                        record_arr1[j1].StartTime = r[i].time;
                        j1++;
                     }
                     else
                     {
                        Print("ctrl_arr is full.");
                     }
                     
                  }
                  else
                  // 追踪记录
                  {
                     delta_jj = 0;            //表示需要减掉的ctrl
                     for(int p=0; p<jj; p++)
                     {
                        if( r[i].high > ctrl_arr[p].TempHigh1 )
                        {
                           ctrl_arr[p].TempHigh1 = r[i].high;
                           ctrl_arr[p].TempHightime1 = r[i].time;
                        }
                        else
                        {
                           ctrl_arr[p].TempBack1 = ctrl_arr[p].TempHigh1 - r[i].close;
                        }
                        
                        if( ctrl_arr[p].TempBack1 > backmax1 )
                        {
                           record_arr1[ctrl_arr[p].Start_j1_Mem].HighPrice = ctrl_arr[p].TempHigh1;
                           record_arr1[ctrl_arr[p].Start_j1_Mem].HighTime = ctrl_arr[p].TempHightime1;
                           record_arr1[ctrl_arr[p].Start_j1_Mem].DeltaPrice = ctrl_arr[p].TempHigh1 - record_arr1[ctrl_arr[p].Start_j1_Mem].StartPrice;
                           record_arr1[ctrl_arr[p].Start_j1_Mem].DeltaPoint = TranDeltaprice( sym, record_arr1[ctrl_arr[p].Start_j1_Mem].DeltaPrice);
                           record_arr1[ctrl_arr[p].Start_j1_Mem].EndTime = r[i].time;
                           record_arr1[ctrl_arr[p].Start_j1_Mem].HoldingTime = record_arr1[ctrl_arr[p].Start_j1_Mem].EndTime - record_arr1[ctrl_arr[p].Start_j1_Mem].StartTime;
                           deltapoint_arr[ctrl_arr[p].Start_j1_Mem] = record_arr1[ctrl_arr[p].Start_j1_Mem].DeltaPoint;
                           
                           ctrl_arr[p].Start_j1_Mem = 0;
                           ctrl_arr[p].Existing = false;
                           ctrl_arr[p].TempBack1 = 0.0;
                           ctrl_arr[p].TempHigh1 = 0.0;
                           
                           delta_jj++;     //ctrl序号前移的次数
                        }
                        
                        if( delta_jj > 0 && p > delta_jj-1)
                        {
                           ctrl_arr[p-delta_jj] = ctrl_arr[p];
                           ctrl_arr[p].Start_j1_Mem = 0;
                           ctrl_arr[p].Existing = false;
                           ctrl_arr[p].TempBack1 = 0.0;
                           ctrl_arr[p].TempHigh1 = 0.0;
                           init_existing = false;
                        }
                        
                     }
                     jj-= delta_jj; 
                  
                  }
                  
//                  if( !existing1 )
//                  {
//                     record_arr1[j1].StartPrice = r[i].low;
//                     record_arr1[j1].StartTime = r[i].time;
//                     temp_back1 = 0.0;
//                     temp_high1 = 0.0;
//                     existing1 = true;
//                  }
//                  if ( r[i].high > temp_high1 ) 
//                  {
//                     temp_high1 = r[i].high;
//                     temp_hightime1 = r[i].time;
//                  }
//                  else
//                  {
//                     temp_back1 = temp_high1 - r[i].close;
//                  }
//         
//                  if ( temp_back1 > backmax1 )
//                  {
//                     record_arr1[j1].HighPrice = temp_high1;
//                     record_arr1[j1].HighTime = temp_hightime1;
//                     record_arr1[j1].DeltaPrice = temp_high1 - record_arr1[j1].StartPrice;
//                     record_arr1[j1].DeltaPoint = TranDeltaprice( sym, record_arr1[j1].DeltaPrice );
//                     record_arr1[j1].EndTime = r[i].time;
//                     record_arr1[j1].HoldingTime = record_arr1[j1].EndTime - record_arr1[j1].StartTime;
//                     deltapoint_arr[j1] = record_arr1[j1].DeltaPoint;
//                     j1++;
//                     existing1 = false;
//                  }
               }
            }         
        }
        else if( back_type == 1 )
        {
           //temp_back1 = 0.0;
           //temp_low1 = 100000.0;    
           //existing1 = false;
           init_existing = false;
           j1 = 0;
           
           for( int i=0; i<n; i++)
           {
               if( i<rand_s1 )
               {
                  continue;
               }
               else
               {
                  if( j1 + 1000 > ArraySize(record_arr1) )
                  {
                     ArrayResize(record_arr1,j1+1999);
                     ArrayResize(deltapoint_arr,j1+1999);
                  }
                  
                  if( i > rand_count || !init_existing)
                  //判断是否抽样
                  {
                     init_existing = true;
                     rand_count = i + (rand()-16384)/(16384/50)+60;              //间隔至少10分钟进行一次随机抽样（10-110分钟之间）
                     if( jj < ArraySize(ctrl_arr) )
                     {
                        ctrl_arr[jj].Start_j1_Mem = j1;
                        ctrl_arr[jj].Existing = true;
                        ctrl_arr[jj].TempBack1 = 0.0;
                        ctrl_arr[jj].TempLow1 = 100000.0;
                        jj++;
                        
                        record_arr1[j1].StartPrice = r[i].high;
                        record_arr1[j1].StartTime = r[i].time;
                        j1++;
                     }
                     else
                     {
                        Print("ctrl_arr is full.");
                     }
                     
                  }
                  else
                  // 追踪记录
                  {
                     delta_jj = 0;            //表示需要减掉的ctrl
                     for(int p=0; p<jj; p++)
                     {
                        if( r[i].low < ctrl_arr[p].TempLow1 )
                        {
                           ctrl_arr[p].TempLow1 = r[i].low;
                           ctrl_arr[p].TempLowtime1 = r[i].time;
                        }
                        else
                        {
                           ctrl_arr[p].TempBack1 = r[i].close - ctrl_arr[p].TempLow1;
                        }
                        
                        if( ctrl_arr[p].TempBack1 > backmax1 )
                        {
                           record_arr1[ctrl_arr[p].Start_j1_Mem].LowPrice = ctrl_arr[p].TempLow1;
                           record_arr1[ctrl_arr[p].Start_j1_Mem].LowTime = ctrl_arr[p].TempLowtime1;
                           record_arr1[ctrl_arr[p].Start_j1_Mem].DeltaPrice = record_arr1[ctrl_arr[p].Start_j1_Mem].StartPrice - ctrl_arr[p].TempLow1;
                           record_arr1[ctrl_arr[p].Start_j1_Mem].DeltaPoint = TranDeltaprice( sym, record_arr1[ctrl_arr[p].Start_j1_Mem].DeltaPrice);
                           record_arr1[ctrl_arr[p].Start_j1_Mem].EndTime = r[i].time;
                           record_arr1[ctrl_arr[p].Start_j1_Mem].HoldingTime = record_arr1[ctrl_arr[p].Start_j1_Mem].EndTime - record_arr1[ctrl_arr[p].Start_j1_Mem].StartTime;
                           deltapoint_arr[ctrl_arr[p].Start_j1_Mem] = record_arr1[ctrl_arr[p].Start_j1_Mem].DeltaPoint;
                           
                           ctrl_arr[p].Start_j1_Mem = 0;
                           ctrl_arr[p].Existing = false;
                           ctrl_arr[p].TempBack1 = 0.0;
                           ctrl_arr[p].TempLow1 = 100000.0;
                           
                           delta_jj++;     //ctrl序号前移的次数
                        }
                        
                        if( delta_jj > 0 && p > delta_jj-1)
                        {
                           ctrl_arr[p-delta_jj] = ctrl_arr[p];
                           ctrl_arr[p].Start_j1_Mem = 0;
                           ctrl_arr[p].Existing = false;
                           ctrl_arr[p].TempBack1 = 0.0;
                           ctrl_arr[p].TempLow1 = 100000.0;
                        }
                        
                     }
                     jj-= delta_jj;                  
                  }
                  
//                  if( !existing1 )
//                  {
//                     record_arr1[j1].StartPrice = r[i].high;
//                     record_arr1[j1].StartTime = r[i].time;
//                     temp_back1 = 0.0;
//                     temp_low1 = 100000.0;
//                     existing1 = true;
//                  }
//                  if ( r[i].low < temp_low1 ) 
//                  {
//                     temp_low1 = r[i].low;
//                     temp_lowtime1 = r[i].time;
//                  }
//                  else
//                  {
//                     temp_back1 = r[i].close - temp_low1;
//                  }
//         
//                  if ( temp_back1 > backmax1 )
//                  {
//                     record_arr1[j1].LowPrice = temp_low1;
//                     record_arr1[j1].LowTime = temp_lowtime1;
//                     record_arr1[j1].DeltaPrice = record_arr1[j1].StartPrice - temp_low1;
//                     record_arr1[j1].DeltaPoint = TranDeltaprice( sym, record_arr1[j1].DeltaPrice );
//                     record_arr1[j1].EndTime = r[i].time;
//                     record_arr1[j1].HoldingTime = record_arr1[j1].EndTime - record_arr1[j1].StartTime;
//                     deltapoint_arr[j1] = record_arr1[j1].DeltaPoint;
//                     j1++;
//                     existing1 = false;
//                  }
               }
            }             
        }
        else
            Print("error back type.");

//---------------------------------------------------------------------------------------     
   //数据统计
          for( int t=0; t<10; t++)
          {
            Stat.SamplePercentile(deltapoint_arr, j1-jj, percentile_arr[t], out[t]);   
          } 
          
          handle1 = FileOpen(filepath+"\\"+ "AA_statistic_"+IntegerToString(backpoints)+"_"+IntegerToString(back_type)+".csv", FILE_READ|FILE_WRITE|FILE_CSV );
          if(handle1 == INVALID_HANDLE)
          {
            Print("Invalid handle1 in for loop.");
          }
          else
          {
            if(FileSeek(handle1,0,SEEK_END))
            {
               FileWrite(handle1, sym, out[0],out[1], out[2], out[3], out[4], out[5],out[6],out[7],out[8],out[9]);
            }
          }
          FileClose(handle1);    

//---------------------------------------------------------------------------------------
   //记录1     
           handle = FileOpen( filepath+"\\"+filename+"_"+IntegerToString(backpoints)+"_"+IntegerToString(back_type)+".csv", FILE_READ|FILE_WRITE|FILE_CSV );
           if(handle == INVALID_HANDLE)
           {
            Print("Invalid handle.");
           }
           else
           {
            if(back_type == 0)
            {
               FileWrite(handle, "StartTime","StartPrice","HighTime","HighPrice","EndTime","DeltaPoint","DeltaPrice","HoldingTime","deltapoint");
            }
            else
            {
               FileWrite(handle, "StartTime","StartPrice","LowTime","LowPrice","EndTime","DeltaPoint","DeltaPrice","HoldingTime","deltapoint");
            }
           }
           for( int i=0; i<j1-jj; i++)
           {
               FileWrite(handle, record_arr1[i].StartTime, record_arr1[i].StartPrice, record_arr1[i].HighTime, record_arr1[i].HighPrice, 
                                 record_arr1[i].EndTime, record_arr1[i].DeltaPoint, record_arr1[i].DeltaPrice, record_arr1[i].HoldingTime, deltapoint_arr[i]);
           }
           FileClose(handle);
      }
     
     int stop = 0;
     
}
