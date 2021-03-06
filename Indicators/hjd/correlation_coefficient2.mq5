//+------------------------------------------------------------------+
//|                                                         wave.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//结算两个品种的相关性系数

#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//*
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_label1  "cc"
/*
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_label2  "UP"//*/
/*
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_label3  "DOWN"

#property indicator_type4   DRAW_NONE
#property indicator_color4  clrGreen
#property indicator_label4  "slope"
/*
#property indicator_type5   DRAW_NONE
#property indicator_color5  clrGreen
#property indicator_label5  "slope1"

#property indicator_type6   DRAW_NONE
#property indicator_color6  clrGreen
#property indicator_label6  "slope2"

#property indicator_type7   DRAW_NONE
#property indicator_color7  clrGreen
#property indicator_label7  "slope3"//*/
//--- indicator buffers

double   cc[];

double price1[];
double price2[];
datetime pairtime[];
int hourstotal = 0;//price1和price2的时间数，

string   nextsymbol;
bool needfresh=true;
int win; //
int currentindex;
int isfull;  // 对price1/2，pairtime判断是否满了，满了才能计算相关性。
int calwin;  // 用于提速，最终只计算历史的buf数
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//斐波那契数列:1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,
//1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233,377,610,987,1597,2584,4181,6765,10946,17711,28657,46368
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//13天 = 78*4小时 = 312 小时 = 624 * 30min = 1248 * 15min = 3744 * 5min = 6240 * 3min =  9360 * 2min = 18720 min
//13     89         377        610           1597           4181          6765           10946         17711

//DAY			13			13			8			8			5		5			3		3
//4HOURS		78			89			48			55			30		34			18		21
//HOUR		312		377		192		233		120	144		72		89
//30MINS		624		610		384		377		240	233		144	144
//15MIN		1248		1597		768		610		480	377		288	233
//5Min		3744		4181		2304		2584		1440	1597		964	987
//1Min		18720		17711		11520		10946		7200	6765		4320	4181
//
enum CORRELATION{COR_POSITIVE,COR_NEGATIVE,COR_DIFF}; //正相关，价差使用对数差；负相关，价差使用对数和；价格差，价格直接求差
enum BAIS_MODE{BM_CLOSE,BM_EMA};
input double thewin = 7;//周期的天数
input string symbol1="XAUUSD" ; //品种1
input string symbol2="USDJPY";  //品种2
input double hourinday;	// 两个品种共同时间内

//double threshold;

//首先根据thewin来确定乖离线的周期，用固定时长来做，是为了确保数据周期的改变不会对策略产生明显的影响
//在此通过thewin来确定统计周期，并且画出上下轨出来。

//string symbol1 ="USDJPY";
//string symbol2 ="GBPUSD";
int OnInit()
  {
  //ArrayCopy(para,para4);
  	Print("helloadsfdads111");   
   hourstotal = 0;
   switch(Period())
   {
      case PERIOD_M1:win = int(thewin*hourinday*60); break;
      case PERIOD_M5:win = int(thewin*hourinday*12);break;
      case PERIOD_M15:win = int(thewin*hourinday*4);break;
      case PERIOD_M30:win = int(thewin*hourinday*2);break;
      case PERIOD_H1:win = int(thewin*hourinday);break;
      case PERIOD_H4:win = int(thewin*hourinday/4+0.5);break;
      case PERIOD_D1:win = int(thewin);break;
      default:Alert("不支持的周期：",Period());return (INIT_FAILED);
   }

   if(StringCompare(Symbol(),symbol1)==0)
   {
      nextsymbol=symbol2;
   }
   else if(StringCompare(Symbol(),symbol2)==0)
   {
      nextsymbol=symbol1;
   }
   else
  {
      Print("wrong symbol1:",Symbol());
      return(INIT_FAILED);
  }
  
	if(win <=1 ) // 统计窗口太小了
  	{
  		Print("win size is too small:",win);
      return(INIT_FAILED);
  	}
  	
  	ArrayResize(price1,win);
   ArrayResize(price2,win);
   ArrayResize(pairtime,win); // 确定
  	
   

   SetIndexBuffer(0,cc,INDICATOR_DATA);
   
	bool synchronized=false;
      //--- 循环计数器
   int attempts=0;
      // 进行5次尝试等候同步进行
   while(attempts<5)
   {
      if(SeriesInfoInteger(nextsymbol,Period(),SERIES_SYNCHRONIZED))
      {
            //--- 同步化完成，退出
         synchronized=true;
         break;
      }
         //--- 增加计数器
      attempts++;
         //--- 等候10毫秒直至嵌套反复
      Sleep(10);
   }
      //--- 同步化后退出循环
   if(synchronized)
   {
      
      Print("The first date in the terminal history for the symbol-period at the moment = ",
            (datetime)SeriesInfoInteger(nextsymbol,0,SERIES_FIRSTDATE));
      Print("The first date in the history for the symbol on the server = ",
            (datetime)SeriesInfoInteger(nextsymbol,0,SERIES_SERVER_FIRSTDATE));
   }
      //--- 不发生数据同步
   else
   {
      Print("Failed to get number of bars for ",nextsymbol);
      //如果这这里同步不了的话，那么就继续让程序跑，获不到bar的情况下，他会再做一次同步
      //return(INIT_FAILED);
   }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  	//PositionSelect("XAUUSD");
  	//Print(PositionGetDouble(POSITION_PROFIT));
   if(!needfresh) 
   {
   	//Print("sldkfj");
   	return rates_total;
   }
   static bool needadd = false;
   static datetime begintime;
   
   uint timestart;
   if(prev_calculated > rates_total)
   	return 0;
   if(prev_calculated == 0) 
   {
   	currentindex = 0;
   	isfull = false;
  		Print("begin",rates_total);
   	//nextpos = 0;//prev_calculated ==0 有三种情况，初次计算，出现错误需要重新计算，人工刷新导致重新计算
   	timestart = GetTickCount();
   	ArrayInitialize(cc,DBL_MAX); 
   	pairtime[0] = 0;  	
   	needadd = false;
   	hourstotal = 0;
   }  
   cc[rates_total-1] = DBL_MAX;
   
   int nextbars=Bars(nextsymbol,Period());
   if(nextbars<1)
   {
   	if(!SeriesInfoInteger(nextsymbol,Period(),SERIES_SYNCHRONIZED))Sleep(1000);
   	return prev_calculated;
   }
   int start=MathMax(1,prev_calculated-1); //第一根不计算
   //start = MathMax(start,rates_total-calwin);
   MqlRates nextrates[];
   int datalen=CopyRates(nextsymbol,Period(),time[start],time[rates_total-1],nextrates);
   if(datalen<=0)
   {
   	return prev_calculated;
   }
   
   int i = start, j = 0;
   while(i < rates_total && j < datalen)
   {
   	if(time[i]< nextrates[j].time) 
   	{
   		cc[i] = cc[i-1];
   		i++;   		
   	}
   	else if(time[i] > nextrates[j].time) j++;
   	else
   	{	//time[i] == nextrates[j].time)
   		double cor;
   		if(Adddata_And_Cal_Corr(time[i],MathLog(close[i]),MathLog(nextrates[j].close),cor))
   			cc[i] = cor;
   		else
   			cc[i] = cc[i-1];
   		i++;
   		j++;
   	}
   
	}
	if(prev_calculated ==0)
	{
		Print("Time: ",GetTickCount()-timestart);
	}
	//Print("corr=",cc[rates_total-1]);
//---

//--- return value of prev_calculated for next call
   return(rates_total);
}



bool Adddata_And_Cal_Corr(const datetime time, const double value1, const double value2, double &cor)
{//要对消除指数性的数进行计算相关性
	static double sumx = 0.0, sumx2 = 0.0, sumy = 0.0, sumy2 = 0.0, sumxy = 0.0;
	if(currentindex == 0 && pairtime[0] <= 0)
	{
		sumx = sumx2 = sumy = sumy2 = sumxy = 0.0;
	}
	if(time == pairtime[currentindex])
	{
		price1[currentindex] = value1;
		price2[currentindex] = value2;
		if(isfull)
		{
			double tempsumx = sumx + value1;
			double tempsumy = sumy + value2;
			double tempsumx2= sumx2 + value1 * value1;
			double tempsumy2= sumy2 + value2 * value2;
			double tempsumxy= sumxy + value1 * value2;
			cor = (tempsumxy - tempsumx*tempsumy/win) / sqrt((tempsumx2-tempsumx*tempsumx/win)*(tempsumy2-tempsumy*tempsumy/win));
			return true;
		}
		else
			return false;
	}
	else if (time > pairtime[currentindex])
	{
		if(currentindex > 0 || pairtime[0] > 0) // 非首次加入
		{
			int lastindex = currentindex;
			currentindex ++;		
			if(currentindex == win) currentindex = 0;
			if(isfull)
			{
				sumx += price1[lastindex] - price1[currentindex];
				sumy += price2[lastindex] - price2[currentindex];
				sumx2+= price1[lastindex] * price1[lastindex] - price1[currentindex] * price1[currentindex];
				sumy2+= price2[lastindex] * price2[lastindex] - price2[currentindex] * price2[currentindex];
				sumxy+= price1[lastindex] * price2[lastindex] - price1[currentindex] * price2[currentindex];
			}
			else
			{
				sumx += price1[lastindex] ;
				sumy += price2[lastindex] ;
				sumx2+= price1[lastindex] * price1[lastindex] ;
				sumy2+= price2[lastindex] * price2[lastindex] ;
				sumxy+= price1[lastindex] * price2[lastindex] ;
			}
		}
		price1[currentindex] = value1;
		price2[currentindex] = value2;
		pairtime[currentindex] = time;
		if(!isfull && currentindex == win - 1)
			isfull = true;
		if(isfull)
		{
			double tempsumx = sumx + value1;
			double tempsumy = sumy + value2;
			double tempsumx2= sumx2 + value1 * value1;
			double tempsumy2= sumy2 + value2 * value2;
			double tempsumxy= sumxy + value1 * value2;
			cor = (tempsumxy - tempsumx*tempsumy/win) / sqrt((tempsumx2-tempsumx*tempsumx/win)*(tempsumy2-tempsumy*tempsumy/win));
			return true;
		}
		return false;		
	}
	else
		return false;
	 
	//if(isfull
}
