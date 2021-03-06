//+------------------------------------------------------------------+
//|                                                MacdCondition.mqh |
//|                                      Copyright 2017,Daixiaorong. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,Daixiaorong."
#property link      "https://www.mql5.com"
#include "IndicatorCondition.mqh"
#include <Indicators\Oscilators.mqh>
#include <Indicators\Trend.mqh>
#include "..\Series.mqh"
//+------------------------------------------------------------------+
//| macd进出场模式管理类，可以在此基础之上进一步拓展和继承                                                          |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| MACD进场条件枚举型                                                                   |
//+------------------------------------------------------------------+
enum ENUM_MACD_POSITION_OPEN
  {
   NEAR_EXTREMUM_DEVIATION=1,
   MAX_EXTREMUM_DEVIATION=2,
   MAX_PRICE_DEVIATION=3,
  };
//+------------------------------------------------------------------+
//|MACD出场条件枚举型                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MACD_POSITION_CLOSE
  {
   BAND_CLOSE=1,
   FIBO_CLOSE=2,
   MA_CLOSE=3,
  };
//+------------------------------------------------------------------+
//| MACD条件类                                                                 |
//+------------------------------------------------------------------+
class CMacdCondition:public CIndicatorCondition
  {
private:
   CiMACD            m_macd;
   CiBands           m_band;
   CiMA              m_ma;
   CiZigZag          m_zigzag;
   CHigh             High;
   CLow              Low;
   int               count;          //用于计算极点的个数
   double            m_type;         //指标的方向，若指标值为负，则为-1.00，为正则为1.00，其他为0.0
   double            m_extr_osc[];   // array of values of extremums of the oscillator
   double            m_extr_pr[];    // array of values of the corresponding extremums of price
   int               m_extr_pos[];   // array of shifts of extremums (in bars)
protected:
   void              InitSeries(string symbol,ENUM_TIMEFRAMES period);
   int               StartIndex(void) {return m_every_tick?0:1;}
   void              CheckArray(int num);
   bool              SaveExtremums(int StartIndex);
   bool              CreateMACD(const string symbol,const ENUM_TIMEFRAMES period,
                                const int fast_ema_period,const int slow_ema_period,
                                const int signal_period,const int applied);
   bool              CreateBand(const string symbol,const ENUM_TIMEFRAMES period,
                                const int ma_period,const int ma_shift,
                                const double deviation,const int applied);
   bool              CreateZigZag(const string symbol,const ENUM_TIMEFRAMES period,
                                  const int depth,const int deviation,const int backstep);
   bool              Deviation_1();
   bool              Deviation_2();
   bool              Deviation_3();
   bool              BandClose(CPosition *pos);
   bool              FiboClose(CPosition *pos);
   bool              MaClose(CPosition *pos);
   int               StateMain(int ind);
public:
                     CMacdCondition(void);
                    ~CMacdCondition(void){}
   double            m_ind_precent;  //指标偏离的幅度
   double            m_pr_prencet;   //价格偏离的幅度
   bool              m_every_tick;
   void              CreateIndicator(const string symbol,const ENUM_TIMEFRAMES period);
   virtual void      RefreshState();
   virtual bool      LongInCondition();
   virtual bool      LongOutCondition(CPosition *pos);
   virtual bool      ShortInCondition();
   virtual bool      ShortOutCondition(CPosition *pos);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMacdCondition::CMacdCondition(void)
  {
   m_pr_prencet=0.005;
   m_ind_precent=0.005;
   m_every_tick=true;
  }
//+------------------------------------------------------------------+
//|创建进出场条件所需的指标                                                                  |
//+------------------------------------------------------------------+
void CMacdCondition::CreateIndicator(const string symbol,const ENUM_TIMEFRAMES period)
  {
   CreateMACD(symbol,period,12,26,9,PRICE_CLOSE);
   if(m_long_out_pattern==BAND_CLOSE || m_short_out_pattern==BAND_CLOSE)
      CreateBand(symbol,period,20,0,2.0,PRICE_CLOSE);
   if(m_long_out_pattern==FIBO_CLOSE || m_short_out_pattern==FIBO_CLOSE)
      CreateZigZag(symbol,period,12,5,3);
   if(m_long_out_pattern==MA_CLOSE || m_short_out_pattern==MA_CLOSE)
     {
      m_ma.Create(symbol,period,24,0,MODE_SMA,PRICE_CLOSE);
     }

  }
//+------------------------------------------------------------------+
//| 创建CiMacd指标对象                                                                 |
//+------------------------------------------------------------------+
bool CMacdCondition::CreateMACD(const string symbol,const ENUM_TIMEFRAMES period,
                                const int fast_ema_period,const int slow_ema_period,
                                const int signal_period,const int applied)
  {
   InitSeries(symbol,period);
   return m_macd.Create(symbol,period,fast_ema_period,slow_ema_period,signal_period,applied);
  }
//+------------------------------------------------------------------+
//|创建CiBand指标对象                                                                  |
//+------------------------------------------------------------------+
bool CMacdCondition::CreateBand(const string symbol,const ENUM_TIMEFRAMES period,
                                const int ma_period,const int ma_shift,
                                const double deviation,const int applied)
  {
   return m_band.Create(symbol,period,ma_period,ma_shift,deviation,applied);
  }
//+------------------------------------------------------------------+
//|创建CiZigzag指标对象                                                              |
//+------------------------------------------------------------------+
bool CMacdCondition::CreateZigZag(const string symbol,const ENUM_TIMEFRAMES period,
                                  const int depth,const int deviation,const int backstep)
  {
   return m_zigzag.Create(symbol,period,depth,deviation,backstep);
  }
//+------------------------------------------------------------------+
//|初始化价格数据                                                                  |
//+------------------------------------------------------------------+
void CMacdCondition::InitSeries(string symbol,ENUM_TIMEFRAMES period)
  {
   High.Symbol(symbol);
   High.Timeframe(period);
   Low.Symbol(symbol);
   Low.Timeframe(period);
  }
//+------------------------------------------------------------------+
//| 更新指标值和状态，若指标值为负，状态为-1.00，为正则为1.00，其他为0.0                                                                |
//+------------------------------------------------------------------+
void CMacdCondition::RefreshState(void)
  {
   m_macd.Refresh();
   if(m_long_out_pattern==BAND_CLOSE || m_short_out_pattern==BAND_CLOSE)
      m_band.Refresh();
   if(m_long_out_pattern==FIBO_CLOSE || m_short_out_pattern==FIBO_CLOSE)
      m_zigzag.Refresh();
   if(m_long_out_pattern==MA_CLOSE || m_short_out_pattern==MA_CLOSE)
      m_ma.Refresh();
   int idx=StartIndex();
   if(m_macd.Main(idx)==EMPTY_VALUE) m_type=0.0;
   if(m_macd.Main(idx)<0)
      m_type=-1.00;
   else
      m_type=1.00;
  }
//+------------------------------------------------------------------+
//| 检查存储数据长度                                                                 |
//+------------------------------------------------------------------+
void CMacdCondition::CheckArray(int num)
  {
   if(num>=ArraySize(m_extr_osc))
     {
      ArrayResize(m_extr_osc,num+10);
      ArrayResize(m_extr_pr,num+10);
      ArrayResize(m_extr_pos,num+10);
     }
  }
//+------------------------------------------------------------------+
//|寻找对应极点并保存                                                                  |
//+------------------------------------------------------------------+
bool CMacdCondition::SaveExtremums(int StartIndex)
  {
   count=0;
   for(int i=0;i<StartIndex-1;i++)
     {
      //---计算极大值
      if(m_type*(m_macd.Main(i+1)-m_macd.Main(i+2))>0 && m_type*(m_macd.Main(i)-m_macd.Main(i+1))<0)
        {
         CheckArray(count);
         m_extr_osc[count]=m_macd.Main(i+1);
         m_extr_pr[count]=(m_type==1.00)?Low[i+1]:High[i+1];
         m_extr_pos[count]=i+1;
         count++;
        }
     }
//---过滤只有一个极点的情况
   if(count<2) return false;
   return true;
  }
//+------------------------------------------------------------------+
//|多单进场条件                                                                  |
//+------------------------------------------------------------------+
bool CMacdCondition::LongInCondition(void)
  {
   if(m_type>=0) return false;
//---选择不同进场条件
   switch(m_long_in_pattern)
     {
      case NEAR_EXTREMUM_DEVIATION:
         return Deviation_1();
         break;
      case MAX_EXTREMUM_DEVIATION:
         return Deviation_2();
         break;
      case MAX_PRICE_DEVIATION:
         return Deviation_3();
         break;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| 多单出场条件                                                                   |
//+------------------------------------------------------------------+
bool CMacdCondition::LongOutCondition(CPosition *pos)
  {
   switch(m_long_out_pattern)
     {
      case BAND_CLOSE:
         return BandClose(pos);
         break;
      case FIBO_CLOSE:
         return FiboClose(pos);
         break;
      case MA_CLOSE:
         return MaClose(pos);
         break;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|   空单进场条件                                                               |
//+------------------------------------------------------------------+
bool CMacdCondition::ShortInCondition(void)
  {
   if(m_type<=0) return false;
//---选择不同进场条件
   switch(m_short_in_pattern)
     {
      case NEAR_EXTREMUM_DEVIATION:
         return Deviation_1();
         break;
      case MAX_EXTREMUM_DEVIATION:
         return Deviation_2();
         break;
      case MAX_PRICE_DEVIATION:
         return Deviation_3();
         break;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|  空单出场条件                                                                  |
//+------------------------------------------------------------------+
bool CMacdCondition::ShortOutCondition(CPosition *pos)
  {

   switch(m_short_out_pattern)
     {
      case BAND_CLOSE:
         return BandClose(pos);
         break;
      case FIBO_CLOSE:
         return FiboClose(pos);
         break;
      case MA_CLOSE:
         return MaClose(pos);
         break;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|背离模式一：临近的两个极点背离                                                                  |
//+------------------------------------------------------------------+
bool CMacdCondition::Deviation_1(void)
  {
   int idx=StartIndex();
//---寻找filed的起点位置
   while(m_type*m_macd.Main(idx+1)>=0)
     {
      idx++;
     }
//---每个Field的前5个Bar不考虑
   if(idx<5) return false;
   if(!SaveExtremums(idx)) return false;
   if(MathAbs((m_extr_osc[0]-m_extr_osc[1])/m_extr_osc[1])>m_ind_precent && MathAbs((m_extr_pr[0]-m_extr_pr[1])/m_extr_pr[1])>m_pr_prencet) return true;
   return false;
  }
//+------------------------------------------------------------------+
//| 背离模式二：当前极点与最大极点背离                                                                  |
//+------------------------------------------------------------------+
bool CMacdCondition::Deviation_2(void)
  {
   int idx=StartIndex();
//---寻找filed的起点位置
   while(m_type*m_macd.Main(idx+1)>=0)
     {
      idx++;
     }
//---每个Field的前5个Bar不考虑
   if(idx<5) return false;
   if(!SaveExtremums(idx)) return false;
   if(m_extr_pos[0]>1) return false;
   int max_id=(m_type==1.00)?ArrayMaximum(m_extr_osc,0,count):ArrayMinimum(m_extr_osc,0,count);
   if(max_id==0) return false;
   if(MathAbs((m_extr_osc[0]-m_extr_osc[max_id])/m_extr_osc[max_id])>m_ind_precent && MathAbs((m_extr_pr[0]-m_extr_pr[max_id])/m_extr_pr[max_id])>m_pr_prencet) return true;
   return false;
  }
//+------------------------------------------------------------------+
//| 背离模式三：与模式二类似，但是价格的背离采用两个极点中的极大值                                                                 |
//+------------------------------------------------------------------+
bool CMacdCondition::Deviation_3(void)
  {
   int idx=StartIndex();
//---寻找filed的起点位置
   while(m_type*m_macd.Main(idx+1)>=0)
     {
      idx++;
     }
//---每个Field的前5个Bar不考虑
   if(idx<5) return false;
   if(!SaveExtremums(idx)) return false;
   if(m_extr_pos[0]>1) return false;
   int max_id=(m_type==1.00)?ArrayMaximum(m_extr_osc,0,count):ArrayMinimum(m_extr_osc,0,count);
   if(max_id==0) return false;
//---保存极点间的最高价或者最低价   
   double extr_price[];
   ArrayResize(extr_price,m_extr_pos[max_id]);
   for(int i=0;i<m_extr_pos[max_id];i++)
     {
      extr_price[i]=(m_type==1.00)?Low[i]:High[i];
     }
   int max_pr_id=(m_type==1.00)?ArrayMinimum(extr_price):ArrayMaximum(extr_price);
   if(MathAbs((m_extr_osc[0]-m_extr_osc[max_id])/m_extr_osc[max_id])>m_ind_precent && MathAbs((extr_price[0]-extr_price[max_pr_id])/extr_price[max_pr_id])>m_pr_prencet) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|布林带出场条件                                                                  |
//+------------------------------------------------------------------+
bool CMacdCondition::BandClose(CPosition *pos)
  {
   int idx=StartIndex();
   if(pos.Direction()==POSITION_TYPE_BUY)
     {
      if(pos.CurrentPrice()>m_band.Upper(idx))
        {
         return true;
        }
     }
   else
     {
      if(pos.CurrentPrice()<m_band.Lower(idx))
        {
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| 斐波那契数出场                                                                 |
//+------------------------------------------------------------------+
bool CMacdCondition::FiboClose(CPosition *pos)
  {
   int      idx=StartIndex();
   int      fibo_count=0;
   double   fibo_extrumum[2]={0.0,0.0};
   if(pos.Direction()==POSITION_TYPE_BUY)
     {
      //---寻找临近的两个高低点
      while(fibo_count<2)
        {
         if(m_zigzag.Main(idx)!=0.0)
           {
            fibo_extrumum[fibo_count]=m_zigzag.Main(idx);
            fibo_count++;
           }
         idx++;
        }
      double tp=NormalizeDouble(pos.EntryPrice()+MathAbs(fibo_extrumum[0]-fibo_extrumum[1])*0.618,
                                (int)SymbolInfoInteger(pos.Symbol(),SYMBOL_DIGITS));
      double sl=NormalizeDouble(pos.EntryPrice()-MathAbs(fibo_extrumum[0]-fibo_extrumum[1])*0.618,
                                (int)SymbolInfoInteger(pos.Symbol(),SYMBOL_DIGITS));
      if(pos.CurrentPrice()>=tp || pos.CurrentPrice()<=sl)
         return true;
     }
   else
     {
      //---寻找临近的两个高低点
      while(fibo_count<2)
        {
         if(m_zigzag.Main(idx)!=0.0)
           {
            fibo_extrumum[fibo_count]=m_zigzag.Main(idx);
            fibo_count++;
           }
         idx++;
        }
      double tp=NormalizeDouble(pos.EntryPrice()-MathAbs(fibo_extrumum[0]-fibo_extrumum[1])*0.618,
                                (int)SymbolInfoInteger(pos.Symbol(),SYMBOL_DIGITS));
      double sl=NormalizeDouble(pos.EntryPrice()+MathAbs(fibo_extrumum[0]-fibo_extrumum[1])*0.618,
                                (int)SymbolInfoInteger(pos.Symbol(),SYMBOL_DIGITS));
      if(pos.CurrentPrice()<=tp || pos.CurrentPrice()>=sl)
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|均线拐点出场                                                                  |
//+------------------------------------------------------------------+
bool CMacdCondition::MaClose(CPosition *pos)
  {
   int idx=StartIndex();
   int off=StateMain(idx);
   if(pos.Direction()==POSITION_TYPE_BUY)
     {
      if(off<0)
        {
         ArrayResize(m_extr_pr,24,100);
         for(int i=0;i<24;i++)
           {
            m_extr_pr[i]=Low[i+1];
           }
         if(Low[idx]<=m_extr_pr[ArrayMinimum(m_extr_pr)])
           {
            return true;
           }

        }
     }
   else
     {
      if(off>0)
        {
         ArrayResize(m_extr_pr,24,100);
         for(int i=0;i<24;i++)
           {
            m_extr_pr[i]=High[i+1];
           }
         if(High[idx]>=m_extr_pr[ArrayMaximum(m_extr_pr)])
           {
            return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|计算指标从indx开始往前数最近的一个极点的位置，若返回正数，则是极小值，|
//|若是负数则为极大值                                                    |
//+------------------------------------------------------------------+
int CMacdCondition::StateMain(int ind)
  {
   int    res=0;
   double var;
//---
   for(int i=ind;;i++)
     {
      if(m_ma.Main(i+1)==EMPTY_VALUE)
         break;
      var=m_ma.Main(i)-m_ma.Main(i+1);
      if(res>0)
        {
         if(var<0)
            break;
         res++;
         continue;
        }
      if(res<0)
        {
         if(var>0)
            break;
         res--;
         continue;
        }
      if(var>0)
         res++;
      if(var<0)
         res--;
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
