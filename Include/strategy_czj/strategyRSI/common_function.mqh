//+------------------------------------------------------------------+
//|                                              common_function.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|     定义RSI类型                                        |
//+------------------------------------------------------------------+
enum RSI_type
  {
   ENUM_RSI_TYPE_1,
   ENUM_RSI_TYPE_2,
   ENUM_RSI_TYPE_3,
   ENUM_RSI_TYPE_4,
   ENUM_RSI_TYPE_5,
   ENUM_RSI_TYPE_6,
   ENUM_RSI_TYPE_7,
   ENUM_RSI_TYPE_0
  };
//+------------------------------------------------------------------+
//|       计算RSI序列的类型                         |
//+------------------------------------------------------------------+
void CalTypeRSI(const double &buffer[],const RSI_type rsi_cal,const double rsi_up,const double rsi_down,bool &is_long,bool &is_short)
  {
   switch(rsi_cal)
     {
      case ENUM_RSI_TYPE_1:
         // 最早的RSI的偏离大于rsi_up或小于rsi_down,且之前是递增/递减的
         is_short=buffer[0]>rsi_up && buffer[0]>buffer[1] && buffer[1]>buffer[2];
         is_long=buffer[0]<rsi_down && buffer[0]<buffer[1] && buffer[1]<buffer[2];
         break;
      case ENUM_RSI_TYPE_2:
         // 最新RSI的偏离大于rsi_up或小于rsi_down且前一个点时拐点(极大值/极小值)
         is_short=buffer[0]>rsi_up && buffer[1]>buffer[0] && buffer[1]>buffer[2];
         is_long=buffer[0]<rsi_down && buffer[1]<buffer[0] && buffer[1]<buffer[2];
         break;
      case ENUM_RSI_TYPE_3:
         ////rsi高位不断递减，最新点大于临界值，低点不断递增，最新点小于临界值
         is_short=buffer[2]>rsi_up && buffer[1]>buffer[2] && buffer[0]>buffer[1];
         is_long=buffer[2]<rsi_down && buffer[1]<buffer[2] && buffer[0]<buffer[1];
      case ENUM_RSI_TYPE_4://rsi高位不断递增最早点上穿，低点不断递减最早点上穿
         //
         is_short=buffer[0]>rsi_up && buffer[1]>buffer[0] && buffer[2]>buffer[1];
         is_long=buffer[0]<rsi_down && buffer[1]<buffer[0] && buffer[2]<buffer[1];
         break;
      case ENUM_RSI_TYPE_5://rsi高位不断递增最近点上穿，低点不断递减最近点下穿(good)
         //
         is_short=buffer[2]>rsi_up && buffer[1]>buffer[0] && buffer[2]>buffer[1];
         is_long=buffer[2]<rsi_down && buffer[1]<buffer[0] && buffer[2]<buffer[1];
         break;
      case ENUM_RSI_TYPE_6://rsi高点下穿，低点上穿
         is_short=buffer[2]<rsi_up && buffer[1]>rsi_up && buffer[0]>rsi_up;
         is_long=buffer[2]>rsi_down && buffer[1]<rsi_down && buffer[0]<rsi_down;
         break;
      case ENUM_RSI_TYPE_7://rsi高点下穿，低点上穿
         is_short=buffer[2]<rsi_up && buffer[1]>rsi_up;
         is_long=buffer[2]>rsi_down && buffer[1]<rsi_down;
         break;
      case ENUM_RSI_TYPE_0://rsi高点下穿，低点上穿
         is_short=buffer[2]>rsi_up;
         is_long=buffer[2]<rsi_down;
         break;
      default:
         is_short=buffer[2]<rsi_up && buffer[1]>rsi_up;
         is_long=buffer[2]>rsi_down && buffer[1]<rsi_down;
         break;
     }
  }
//+------------------------------------------------------------------+
