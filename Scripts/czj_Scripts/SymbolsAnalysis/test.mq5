#include <Math\Alglib\statistics.mqh>

#property script_show_inputs

input int  backpoints = 600;        // 设置最大回调point 
input int  symbol_index_start = 1;  // 为了防止卡死，建议分段运行脚本
input int  symbol_index_end = 8;    // start为1,end为8; start为8,end为15; start为15,end为22; start为22, end为29
input int  back_type = 0;           // 0：上升回调, sell进场用；1：下降回调, buy进场用；
input datetime d1 = D'2008.01.01 00:00';
input datetime d2 = D'2018.01.01 00:00';
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
double deltapoint_arr[];            // 记录backmax达到的点之前的最大点差

double backmax1;         //最大回调point-->delta price
int n;
string sym;

void OnStart()
{
     double temp_back1 ;
     double temp_high1 ;
     double temp_low1;
     datetime temp_lowtime1;
     datetime temp_hightime1;
     int j1;
     int handle;
     int handle1;
     bool existing1;
     int test11;
     
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
        sym = SymbolName(s,true);
        //string sym = sym_arr[0];                    // 参数设置：选择symbol
        filename = sym;
        
        n = Bars(sym,PERIOD_M15,d1,d2);          //返回sym在d1-d2所有bar条目数
        
        backmax1 = TransPoint(sym, backpoints);      //最大回调
        
        if(ArraySize(r)!=0)
        {  
           ArrayFree(r);
            
           test11=CopyRates(sym,PERIOD_M15,d2,n,r);
        }
        else
        {  
            
           test11=CopyRates(sym,PERIOD_M15,d2,n,r);
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
        
        if( back_type == 0)
        {
           temp_back1 = 0.0;
           temp_high1 = 0.0;
           j1 = 0;
           existing1 = false;
          
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
                  if( !existing1 )
                  {
                     record_arr1[j1].StartPrice = r[i].low;
                     record_arr1[j1].StartTime = r[i].time;
                     temp_back1 = 0.0;
                     temp_high1 = 0.0;
                     existing1 = true;
                  }
                  if ( r[i].high > temp_high1 ) 
                  {
                     temp_high1 = r[i].high;
                     temp_hightime1 = r[i].time;
                  }
                  else
                  {
                     temp_back1 = temp_high1 - r[i].close;
                  }
         
                  if ( temp_back1 > backmax1 )
                  {
                     record_arr1[j1].HighPrice = temp_high1;
                     record_arr1[j1].HighTime = temp_hightime1;
                     record_arr1[j1].DeltaPrice = temp_high1 - record_arr1[j1].StartPrice;
                     record_arr1[j1].DeltaPoint = TranDeltaprice( sym, record_arr1[j1].DeltaPrice );
                     record_arr1[j1].EndTime = r[i].time;
                     record_arr1[j1].HoldingTime = record_arr1[j1].EndTime - record_arr1[j1].StartTime;
                     deltapoint_arr[j1] = record_arr1[j1].DeltaPoint;
                     j1++;
                     existing1 = false;
                  }
               }
            }         
        }
        else if( back_type == 1 )
        {
           temp_back1 = 0.0;
           temp_low1 = 100000.0;    
           j1 = 0;
           existing1 = false;
           
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
                  if( !existing1 )
                  {
                     record_arr1[j1].StartPrice = r[i].high;
                     record_arr1[j1].StartTime = r[i].time;
                     temp_back1 = 0.0;
                     temp_low1 = 100000.0;
                     existing1 = true;
                  }
                  if ( r[i].low < temp_low1 ) 
                  {
                     temp_low1 = r[i].low;
                     temp_lowtime1 = r[i].time;
                  }
                  else
                  {
                     temp_back1 = r[i].close - temp_low1;
                  }
         
                  if ( temp_back1 > backmax1 )
                  {
                     record_arr1[j1].LowPrice = temp_low1;
                     record_arr1[j1].LowTime = temp_lowtime1;
                     record_arr1[j1].DeltaPrice = record_arr1[j1].StartPrice - temp_low1;
                     record_arr1[j1].DeltaPoint = TranDeltaprice( sym, record_arr1[j1].DeltaPrice );
                     record_arr1[j1].EndTime = r[i].time;
                     record_arr1[j1].HoldingTime = record_arr1[j1].EndTime - record_arr1[j1].StartTime;
                     deltapoint_arr[j1] = record_arr1[j1].DeltaPoint;
                     j1++;
                     existing1 = false;
                  }
               }
            }             
        }
        else
            Print("error back type.");

//---------------------------------------------------------------------------------------     
   //数据统计
          for( int t=0; t<10; t++)
          {
            Print("j1:",j1," ","size array:",ArraySize(deltapoint_arr));
            Stat.SamplePercentile(deltapoint_arr, j1 , percentile_arr[t], out[t]);   
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

        //FileClose(test_handle);
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
               FileWrite(handle, "StartTime","StartPrice","HighTime","HighPrice","EndTime","DeltaPoint","DeltaPrice","HoldingTime");
            }
            else
            {
               FileWrite(handle, "StartTime","StartPrice","LowTime","LowPrice","EndTime","DeltaPoint","DeltaPrice","HoldingTime");
            }
           }
           for( int i=0; i<j1; i++)
           {
               FileWrite(handle, record_arr1[i].StartTime, record_arr1[i].StartPrice, record_arr1[i].HighTime, record_arr1[i].HighPrice, 
                                 record_arr1[i].EndTime, record_arr1[i].DeltaPoint, record_arr1[i].DeltaPrice, record_arr1[i].HoldingTime);
           }
           FileClose(handle);
      }
     
     int stop = 0;
     
}
