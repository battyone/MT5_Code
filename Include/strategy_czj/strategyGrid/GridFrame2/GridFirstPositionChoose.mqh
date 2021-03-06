//+------------------------------------------------------------------+
//|                                      GridFirstPositionChoose.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseStrategy.mqh"

class CGridFirstPositionChoose:public CGridBaseStrategyOneSymbol
  {
private:
   int ma24;
   int ma48;
   int ma96;
   int ma200;
   double ma24_value[2];
   double ma48_value[2];
   double ma96_value[2];
   double ma200_value[2];
   double            tp_total;
   double            tp_per_lots;
   int grid_gap;
public:
                     CGridFirstPositionChoose(void){};
                    ~CGridFirstPositionChoose(void){};
                    void Init();
                    void SetParameters(int gap=300,int total_tp=200,int per_tp=200);
protected:
   virtual void      CheckPositionOpen(const MarketEvent &event); // 开仓检测
   virtual void      CheckPositionClose(const MarketEvent &event);   // 平仓检测   
   bool              IsLongTrend();
   bool              IsShortTrend();
                    
  };
void CGridFirstPositionChoose::Init(void)
   {
    ma24=iMA(ExpertSymbol(),Timeframe(),24,0,MODE_EMA,PRICE_CLOSE);
    ma48=iMA(ExpertSymbol(),Timeframe(),48,0,MODE_EMA,PRICE_CLOSE);
    ma96=iMA(ExpertSymbol(),Timeframe(),96,0,MODE_EMA,PRICE_CLOSE);
    ma200=iMA(ExpertSymbol(),Timeframe(),200,0,MODE_EMA,PRICE_CLOSE);
    SetParameters();
   }
void CGridFirstPositionChoose::SetParameters(int gap=300,int total_tp=200,int per_tp=200)
   {
    grid_gap=gap;
    tp_total=total_tp;
    tp_per_lots=per_tp;
   }
bool CGridFirstPositionChoose::IsLongTrend(void)
   {
    CopyBuffer(ma24,0,0,2,ma24_value);
    CopyBuffer(ma48,0,0,2,ma48_value);
    CopyBuffer(ma96,0,0,2,ma96_value);
    CopyBuffer(ma200,0,0,2,ma200_value);
    if(ma24_value[0]>ma48_value[0]&&ma48_value[0]>ma96_value[0]&&ma96_value[0]>ma200_value[0])
       return true;
    return false;
   }
bool CGridFirstPositionChoose::IsShortTrend(void)
   {
    CopyBuffer(ma24,0,0,2,ma24_value);
    CopyBuffer(ma48,0,0,2,ma48_value);
    CopyBuffer(ma96,0,0,2,ma96_value);
    CopyBuffer(ma200,0,0,2,ma200_value);
    if(ma24_value[0]<ma48_value[0]&&ma48_value[0]<ma96_value[0]&&ma96_value[0]<ma200_value[0])
       return true;
    return false;
   }
void CGridFirstPositionChoose::CheckPositionOpen(const MarketEvent &event)
   {
    if(event.type!=MARKET_EVENT_BAR_OPEN) return;
    if(pos.TotalLong()==0) 
      {
       if(IsLongTrend())  OpenLongPosition("first long");
      }
    else 
      {
       if(DistToLastLongPrice()>grid_gap) OpenLongPosition("add long");
      }
    if(pos.TotalShort()==0 )
      {
       if(IsShortTrend()) OpenShortPosition("first short");
      }
    else
      {
       if(DistToLastShortPrice()>grid_gap) OpenShortPosition("add short");
      }
   }
void CGridFirstPositionChoose::CheckPositionClose(const MarketEvent &event)
   {
    if(event.type==MARKET_EVENT_TICK)
      {
       CArrayInt p_ids;
       double p_total,l_total;
       
       if(pos.TotalLong()>0)
        {
         pos.GetPartialLongPosition(p_ids,p_total,l_total);
         if(p_total>tp_total || p_total/l_total>tp_per_lots) CloseLongPosition(p_ids);
        } 
       if(pos.TotalShort()>0)
        {
         pos.GetPartialShortPosition(p_ids,p_total,l_total);
         if(p_total>tp_total || p_total/l_total>tp_per_lots) CloseShortPosition(p_ids);
        }  
      }
    if(event.type==MARKET_EVENT_BAR_OPEN)
      {
       if(pos.TotalLong()>0 && IsShortTrend()) CloseLongPosition();
       if(pos.TotalShort()>0 && IsLongTrend()) CloseShortPosition();
         {
          
         }
      }
   }