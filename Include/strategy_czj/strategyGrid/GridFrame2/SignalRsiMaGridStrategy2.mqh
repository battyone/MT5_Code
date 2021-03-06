//+------------------------------------------------------------------+
//|                                     SignalRsiMaGridStrategy2.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "SignalRsiMaGridStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalRsiMaGridStrategy2:public CSignalRsiMaGridStrategy
  {
protected:
   virtual void      CheckPositionOpen(const MarketEvent &event); // 开仓检测
   virtual void      CheckPositionClose(const MarketEvent &event);   // 平仓检测
   void              CheckAllLongFirstShortClose();
   void              CheckAllShortFirstLongClose();
   void              CheckLongCloseForOpen();
   void              CheckShortCloseForOpen();
   
   void              OpenFirstLongOnShortRisk(string comment="comment");
   void              OpenFirstShortOnLongRisk(string comment="comment");
   void              CloseAllLongFirstShortPosition(string comment="comment");
   void              CloseAllShortFirstLongPosition(string comment="comment");
   int               CalHedgeLevel();
public:
                     CSignalRsiMaGridStrategy2(void){};
                    ~CSignalRsiMaGridStrategy2(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiMaGridStrategy2::CheckPositionOpen(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      RefreshSignal(event);
       if(v_ma_l[0]>v_ma_s[0]) // 均线下降=>主Short
        {
         if(pos.TotalLongLots()>pos.TotalShortLots()+0.1)   // 仓位多头风险
           {
//            空头仓位的处理
            if(pos.TotalShort()==0) OpenFirstShortOnLongRisk();
            else if(pos.TotalShort()<5 && DistToLastShortPrice()>grid_gap) OpenShortPosition("S_1");
            else if(v_rsi[0]>80 && DistToLastShortPrice()>grid_gap) OpenShortPosition("S_极端");
            else if(v_rsi[0]>70 && DistToLastShortPrice()>5*grid_gap) OpenShortPosition("S2");
            else if(DistToLastShortPrice()>10*grid_gap) OpenShortPosition("S3");
//            多头仓位的处理
            if(v_rsi[0]<30 && DistToLastLongPrice()>grid_gap) OpenLongPosition("L_极端");
           }
         else if(pos.TotalShortLots()>pos.TotalLongLots()+0.1) // 仓位空头风险
                {
//            空头仓位的处理
                  if(pos.TotalShort()<5 && DistToLastShortPrice()>grid_gap) OpenShortPosition("S_1");
                  else if(v_rsi[0]>80 && DistToLastShortPrice()>grid_gap) OpenShortPosition("S_极端");
                  else if(v_rsi[0]>70 && DistToLastShortPrice()>5*grid_gap) OpenShortPosition("S2");
                  else if(DistToLastShortPrice()>10*grid_gap) OpenShortPosition("S3");
//            多头仓位的处理
                  if(v_rsi[0]<30 && DistToLastLongPrice()>grid_gap) OpenLongPosition("L_极端");                 
                }
         else
           {
            if(pos.TotalShort()==0||DistToLastShortPrice()>grid_gap) OpenShortPosition();
            if(pos.TotalLong()==0||DistToLastLongPrice()>grid_gap) OpenLongPosition();
           }
        }
      else // 均线上升
        {
         if(pos.TotalLongLots()>pos.TotalShortLots()+0.1)   // 仓位多头风险
           {
//            多头头仓位的处理
         if(pos.TotalLong()<5 && DistToLastLongPrice()>grid_gap) OpenLongPosition();
         else if(v_rsi[0]<20 && DistToLastLongPrice()>grid_gap) OpenLongPosition("L_极端");
         else if(v_rsi[0]<30 && DistToLastLongPrice()>5*grid_gap) OpenLongPosition("L2");
         else if(DistToLastLongPrice()>10*grid_gap) OpenLongPosition("L3");
//            空头仓位的处理 
         if(pos.TotalShort()==0) OpenFirstShortOnLongRisk();       
         if(v_rsi[0]>70 && DistToLastShortPrice()>grid_gap) OpenShortPosition("S_极端");
         else if(v_rsi[0]>80 && DistToLastShortPrice()>5*grid_gap) OpenShortPosition("S2");
         else if(DistToLastShortPrice()>10*grid_gap) OpenShortPosition("S3");

           
           }
         else if(pos.TotalShortLots()>pos.TotalLongLots()+0.1) // 仓位空头风险
                {
//            空头仓位的处理
                  if(pos.TotalLong()==0)
                     {
                      if(pos.TotalShortLots()>pos.TotalLongLots()) OpenFirstLongOnShortRisk();
                      else OpenLongPosition();
                     }
                  else if(pos.TotalLong()<10 && DistToLastLongPrice()>grid_gap) OpenLongPosition();
                  if(v_rsi[0]<20 && DistToLastLongPrice()>grid_gap) OpenLongPosition("L_极端");
                  else if(v_rsi[0]<30 && DistToLastLongPrice()>5*grid_gap) OpenLongPosition("L2");
                  else if(DistToLastLongPrice()>10*grid_gap) OpenLongPosition("L3");
                  
                  if(v_rsi[0]>70 && DistToLastShortPrice()>grid_gap) OpenShortPosition("S_极端");
                  else if(v_rsi[0]>80 && DistToLastShortPrice()>5*grid_gap) OpenShortPosition("S2");
                  else if(DistToLastShortPrice()>10*grid_gap) OpenShortPosition("S3");
//            多头仓位的处理
            
                }
         else
           {
            if(pos.TotalShort()==0||DistToLastShortPrice()>grid_gap) OpenShortPosition();
            if(pos.TotalLong()==0||DistToLastLongPrice()>grid_gap) OpenLongPosition();
           }
         
        
        }
     }
  }
void CSignalRsiMaGridStrategy2::CheckPositionClose(const MarketEvent &event)
   {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      double lots_lts=pos.TotalLongLots()-pos.TotalShortLots();
      if(MathAbs(lots_lts)<0.1)
        {
         CSignalGridStrategy::CheckPositionClose(event);
        }
      else if(lots_lts<-0.1)
             {
              CheckPartialShortClose();
              CheckAllLongFirstShortClose();
              CheckLongCloseForOpen();
             }
      else if(lots_lts>0.1)
             {
              CheckPartialLongClose();
              CheckAllShortFirstLongClose();
              CheckShortCloseForOpen();
             }
     }    
   }
void CSignalRsiMaGridStrategy2::CheckAllLongFirstShortClose(void)
   {
     double sum_p=pos.TotalLongProfits()+pos.ShortProfitsAt(0);
     double sum_l=pos.TotalLongLots()+pos.ShortLotsAt(0);
     if(sum_p>tp_total||sum_p/sum_l>tp_per_lots) CloseAllLongFirstShortPosition();
   }
void CSignalRsiMaGridStrategy2::CheckAllShortFirstLongClose(void)
   {
    double sum_p=pos.TotalShortProfits()+pos.LongProfitsAt(0);
     double sum_l=pos.TotalShortLots()+pos.LongLotsAt(0);
     if(sum_p>tp_total||sum_p/sum_l>tp_per_lots) CloseAllShortFirstLongPosition();
   }
void CSignalRsiMaGridStrategy2::CheckLongCloseForOpen(void)
   {
    if(pos.TotalLong()==0) return;
    if(pos.TotalLongLots()<pos.TotalShortLots()*0.5&&pos.TotalLongProfits()/pos.TotalLongLots()>tp_per_lots)
      {
       CloseLongPosition();
      }
    
   }
void CSignalRsiMaGridStrategy2::CheckShortCloseForOpen(void)
   {
    if(pos.TotalShort()==0) return;
    if(pos.TotalShortLots()<pos.TotalLongLots()*0.5&&pos.TotalShortProfits()/pos.TotalShortLots()>tp_per_lots)
      {
       CloseShortPosition();
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalRsiMaGridStrategy2::OpenFirstLongOnShortRisk(string comment="comment")
  {
   int level=0;
   double l=0;
   //level=MathMax(pos.LastShortLevel(),pos.FirstShortLevel()*2);
   level=MathMax((int)(pos.TotalShortLots()/base_lots*0.5),1);
   l=CalGridLots(level,base_lots,l_type,pos_num);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l,latest_price.ask,0,0,comment);
   pos.AddLongPosId(Trade.ResultOrder(),level);
  }
void CSignalRsiMaGridStrategy2::OpenFirstShortOnLongRisk(string comment="comment")
   {
   int level=0;
   double l=0;
   level=MathMax(pos.LastLongLevel(),pos.FirstLongLevel()*2);
   level=MathMax((int)(pos.TotalLongLots()/base_lots*0.5),1);
   l=CalGridLots(level,base_lots,l_type,pos_num);
   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l,latest_price.bid,0,0,comment);
   pos.AddShortPosId(Trade.ResultOrder(),level);
   }
void CSignalRsiMaGridStrategy2::CloseAllLongFirstShortPosition(string comment="comment")
   {
    CloseLongPosition();
    CloseShortPosition(0);
   }
void CSignalRsiMaGridStrategy2::CloseAllShortFirstLongPosition(string comment="comment")
   {
    CloseShortPosition();
    CloseLongPosition(0);
   }
//+------------------------------------------------------------------+
