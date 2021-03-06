//+------------------------------------------------------------------+
//|                                         GridTrendBaseOperate.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Arrays\ArrayLong.mqh>
#include <strategy_czj\common\strategy_common.mqh>

class CGridTrendBaseOperate:public CStrategy
  {
private:
   MqlTick latest_price;
   double base_price;
   ENUM_POSITION_TYPE last_pos_type;
   CArrayLong pos_id;
public:
   PositionInfor pos_state;
public:
                     CGridTrendBaseOperate(void){};
                    ~CGridTrendBaseOperate(void){};
                    void BuildLongPosition(double l);   // 多头建仓
                    void BuildShortPosition(double l);  // 空头建仓
                    void CloseAllPosition(); // 平仓
                    double UpWithBasePrice(){return (latest_price.bid-base_price)*MathPow(10,Digits());};  // 同基础价格上涨的距离
                    double DownWithBasePrice(){return (base_price-latest_price.ask)*MathPow(10,Digits());}; // 同基础价格下跌的距离
                    void   RefreshBasePrice(){base_price=latest_price.ask;};
                    void   RefreshPositionState(); // 刷新仓位信息
                    void   RefreshTickPrice(){SymbolInfoTick(ExpertSymbol(),latest_price);}; // 刷新tick报价
                    double GetProfitsPerLots(){return (pos_state.profits_buy+pos_state.profits_sell)/(pos_state.lots_buy+pos_state.lots_sell);}; // 获取每手获利
                    double GetProfitsTotal(){return pos_state.profits_buy+pos_state.profits_sell;};
                    ENUM_POSITION_TYPE GetLastPositionType(){return last_pos_type;};
                    int GetGridLevel(){return pos_state.num_buy+pos_state.num_sell;};
  };
void CGridTrendBaseOperate::BuildLongPosition(double l)
   {
    if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l,latest_price.ask,0,0,"long"))
      {
       last_pos_type=POSITION_TYPE_BUY;
       pos_id.Add(Trade.ResultOrder());   
      }
   }
void CGridTrendBaseOperate::BuildShortPosition(double l)
   {
    if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l,latest_price.bid,0,0,"short"))
      {
       last_pos_type=POSITION_TYPE_SELL; 
       pos_id.Add(Trade.ResultOrder());  
      }
   }
void CGridTrendBaseOperate::CloseAllPosition(void)
   {
    for(int i=0;i<pos_id.Total();i++)
      {
       Trade.PositionClose(pos_id.At(i),"close");
      }
    pos_id.Clear();
   }
void CGridTrendBaseOperate::RefreshPositionState(void)
   {
    pos_state.Init();
    for(int i=0;i<pos_id.Total();i++)
      {
       PositionSelectByTicket(pos_id.At(i));
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
          pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
          pos_state.num_buy++;
          pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
         }
       else
         {
          pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
          pos_state.num_sell++;
          pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
         }
      }
   }

