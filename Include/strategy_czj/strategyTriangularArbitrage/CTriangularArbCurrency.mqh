//+------------------------------------------------------------------+
//|                                            ArbitrageStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Trade\Trade.mqh>

enum TypeCurrency
  {
   ENUM_TYPE_CURRENCY_XUSD_XUSD,
   ENUM_TYPE_CURRENCY_XUSD_USDX,
   ENUM_TYPE_CURRENCY_USDX_USDX
  };
//+------------------------------------------------------------------+
//|       套利仓位信息                                               |
//+------------------------------------------------------------------+
struct ArbitragePosition
  {
   int               pair_open_buy;
   int               pair_open_sell;
   int               pair_open_total;
   double            pair_buy_profit;
   double            pair_sell_profit;
   void              Init();
  };
//+------------------------------------------------------------------+
//|         初始化套利仓位信息                                       |
//+------------------------------------------------------------------+
void ArbitragePosition::Init(void)
  {
   pair_open_buy=0;
   pair_open_sell=0;
   pair_open_total=0;
   pair_buy_profit=0.0;
   pair_sell_profit=0.0;
  }
//+------------------------------------------------------------------+
//|               套利策略类                                         |
//+------------------------------------------------------------------+
class CTriangularArbCurrency:public CStrategy
  {
private:
   MqlTick           latest_price_x; //最新的x-usd tick报价
   MqlTick           latest_price_y; //最新的y-usd tick报价
   MqlTick           latest_price_xy;//最新的交叉货币对x-y
   TypeCurrency      cross_type;
   ArbitragePosition arb_position_states; // 套利仓位信息
   int dev_points;
   double per_lots_win;
   int out_points_dev;
   //套利仓位的开仓的成交价格
   double deal_buy_xy;
   double deal_buy_x;
   double deal_buy_y;
   double deal_sell_xy;
   double deal_sell_x;
   double deal_sell_y;
   //套利仓位的平仓的当前价格
   double close_buy_xy;
   double close_buy_x;
   double close_buy_y;
   double close_sell_xy;
   double close_sell_x;
   double close_sell_y;
   //套利开仓价格的潜在赢利点
   int buy_arb_open_points;
   int sell_arb_open_points;
   //套利当前平仓的赢利点
   int buy_arb_close_points;
   int sell_arb_close_points;
   
protected:
   string            symbol_x;   // 品种x
   string            symbol_y; // 品种y
   string            symbol_xy;
   ENUM_TIMEFRAMES   period; // 周期
   int               num; // 序列的长度
   double            lots_base; // 品种x的手数  
public:
                     CTriangularArbCurrency(void);
                    ~CTriangularArbCurrency(void){};
   //---参数设置
   void              SetSymbolsInfor(string currency_1="EUR", string currency_2="GBP",double open_lots=0.1,int points_dev=50,double win_per_lots=50,int points_dev_out=80);//设置品种基本信息
   virtual void      OnEvent(const MarketEvent &event);//事件处理
   void              RefreshPosition(void);//刷新仓位信息
   void              RefreshPositionXUSDXUSD(void);
   void              RefreshPositionXUSDUSDX(void);
   void              RefreshPositionUSDXUSDX(void);
   void CloseArbitrageBuyPosition(void);
   void CloseArbitrageBuyPositionXUSDXUSD(void);
   void CloseArbitrageBuyPositionXUSDUSDX(void);
   void CloseArbitrageBuyPositionUSDXUSDX(void);
   void CloseArbitrageSellPosition(void);
   void CloseArbitrageSellPositionXUSDXUSD(void);
   void CloseArbitrageSellPositionXUSDUSDX(void);
   void CloseArbitrageSellPositionUSDXUSDX(void);
  };
//+------------------------------------------------------------------+
//|               默认构造函数                                       |
//+------------------------------------------------------------------+
CTriangularArbCurrency::CTriangularArbCurrency(void)
  {
   //symbol_x="EURUSD";
   //symbol_y="GBPUSD";
   //symbol_xy="EURGBP";
   //AddTickEvent(symbol_x);
   //AddTickEvent(symbol_y);
   //AddTickEvent(symbol_xy);
   //lots_base=0.1;
   //dev_points=50;
   //per_lots_win=50;
  }
//+------------------------------------------------------------------+
//|              设置品种对的基本信息                                |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::SetSymbolsInfor(string currency_1="EUR", string currency_2="GBP",double open_lots=0.1,int points_dev=50,double win_per_lots=50,int points_dev_out=80)
  {
   //确保品种对形式为XY，symbol_x对应XUSD OR USDX , SYMBOL_Y 对应为YUSD OR USDY
   int index_currency_1=-1;
   int index_currency_2=-1;
   string currency_arr[]={"EUR","GBP","AUD","NZD","CAD","CHF","JPY"};
   for(int i=0;i<ArraySize(currency_arr);i++)
     {
      if(currency_1==currency_arr[i])
         index_currency_1=i;
      if(currency_2==currency_arr[i])
         index_currency_2=i;
     }
   if(index_currency_1==-1 ||index_currency_2==-1) return;
   if(index_currency_1<index_currency_2)
      {
         if(index_currency_1>=4)
            {
             cross_type=ENUM_TYPE_CURRENCY_USDX_USDX;
             symbol_x="USD"+currency_1;
             symbol_y="USD"+currency_2;
             symbol_xy=currency_1+currency_2;
            }
         else if(index_currency_2<4)
            {
             cross_type=ENUM_TYPE_CURRENCY_XUSD_XUSD;
             symbol_x=currency_1+"USD";
             symbol_y=currency_2+"USD";
             symbol_xy=currency_1+currency_2;
            }
         else
            {
             cross_type=ENUM_TYPE_CURRENCY_XUSD_USDX;
             symbol_x=currency_1+"USD";
             symbol_y="USD"+currency_2;
             symbol_xy=currency_1+currency_2;
            }
      }
   else
     {
      if(index_currency_2>=4) 
         {
          cross_type=ENUM_TYPE_CURRENCY_USDX_USDX;
          symbol_x="USD"+currency_2;
          symbol_y="USD"+currency_1;
          symbol_xy=currency_2+currency_1;
         }
      else if(index_currency_1<4) 
         {
          cross_type=ENUM_TYPE_CURRENCY_XUSD_XUSD;
          symbol_x=currency_2+"USD";
          symbol_y=currency_1+"USD";
          symbol_xy=currency_2+currency_1;
         }
      else 
         {
          cross_type=ENUM_TYPE_CURRENCY_XUSD_USDX;
          symbol_x=currency_2+"USD";
          symbol_y="USD"+currency_1;
          symbol_xy=currency_2+currency_1;
         }
     }
   lots_base=open_lots;
   dev_points=points_dev;
   per_lots_win=win_per_lots;
   out_points_dev=points_dev_out;
   
   ExpertName(symbol_x);
   //AddTickEvent(symbol_x);
   //AddTickEvent(symbol_y);
   //AddTickEvent(symbol_xy);
   //if(iCustom(symbol_x,PERIOD_M1,"iSpy",ChartID(),0)==INVALID_HANDLE) 
   //   { Print("Error in setting of spy on ",symbol_x);}
   //if(iCustom(symbol_y,PERIOD_M1,"iSpy",ChartID(),1)==INVALID_HANDLE) 
   //   { Print("Error in setting of spy on ",symbol_y);}
   //if(iCustom(symbol_xy,PERIOD_M1,"iSpy",ChartID(),2)==INVALID_HANDLE) 
   //   { Print("Error in setting of spy on ", symbol_xy);}
  }
//+------------------------------------------------------------------+
//|               事件处理                                           |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::OnEvent(const MarketEvent &event)
  {
   //if(event.type==MARKET_EVENT_TICK)
   //  {
   //    Print("OnEvent-Tick"," ", event.symbol, " ",symbol_x," ",symbol_y," ",symbol_xy);
   //  }
   if(event.type==MARKET_EVENT_TICK)
   //if((event.symbol==symbol_x || event.symbol==symbol_y||event.symbol==symbol_xy) && event.type==MARKET_EVENT_TICK)
     {
     
      SymbolInfoTick(symbol_x,latest_price_x);
      SymbolInfoTick(symbol_y,latest_price_y);
      SymbolInfoTick(symbol_xy,latest_price_xy);
      RefreshPosition();
      
      if(arb_position_states.pair_open_buy>0)
        {
         if(MathMod(arb_position_states.pair_open_buy,3)!=0)//只有部分仓位的情况，需要强平
         {
           CloseArbitrageBuyPosition();
           Print("策略",ExpertMagic(),"仓位不完整,对其进行强制平仓,套利买仓数",arb_position_states.pair_open_buy);
           ExpertRemove();
            }
         else if(arb_position_states.pair_buy_profit>per_lots_win*lots_base)  //盈利达到止盈要求的，进行平仓
            {
             CloseArbitrageBuyPosition();
             Print("策略",ExpertMagic(),"达到止盈条件进行平仓，获利",arb_position_states.pair_buy_profit);
            }
         else if(buy_arb_close_points>out_points_dev)  //平仓价格理想的情况(一般是开仓价格不理想达不到止盈条件的)
            {
             CloseArbitrageBuyPosition();
             Print("策略",ExpertMagic(),"买仓达到反向偏离出场条件,反向偏离点数",buy_arb_close_points);
            }
        }
      
      if(arb_position_states.pair_open_sell>0)
        {
         if(MathMod(arb_position_states.pair_open_sell,3)!=0)
         {
          CloseArbitrageSellPosition();
          Print("策略",ExpertMagic(),"仓位不完整,对其进行强制平仓,套利卖仓数",arb_position_states.pair_open_sell);
          ExpertRemove();
         }
         else if(arb_position_states.pair_sell_profit>per_lots_win*lots_base)
            {
             CloseArbitrageSellPosition();
              Print("策略",ExpertMagic(),"达到止盈条件进行平仓，获利",arb_position_states.pair_sell_profit);
            }
         else if(sell_arb_close_points>out_points_dev)  //平仓价格理想的情况(一般是开仓价格不理想达不到止盈条件的)
            {
             CloseArbitrageSellPosition();
             Print("策略",ExpertMagic(),"卖仓达到反向偏离出场条件,反向偏离点数",sell_arb_close_points);
            }
        }
      
      RefreshPosition();
      SymbolInfoTick(symbol_x,latest_price_x);
      SymbolInfoTick(symbol_y,latest_price_y);
      SymbolInfoTick(symbol_xy,latest_price_xy);
      double delta=SymbolInfoDouble(symbol_xy,SYMBOL_POINT)*dev_points;
      switch(cross_type)
        {
         case ENUM_TYPE_CURRENCY_XUSD_XUSD :
           if(arb_position_states.pair_open_buy==0&&latest_price_xy.ask+delta<latest_price_x.bid/latest_price_y.ask)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_BUY,lots_base,latest_price_xy.ask,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_SELL,lots_base,latest_price_x.bid,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_BUY,lots_base,latest_price_y.ask,0,0);
               
              }
           if(arb_position_states.pair_open_sell==0&&latest_price_xy.bid-delta>latest_price_x.ask/latest_price_y.bid)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_SELL,lots_base,latest_price_xy.bid,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_BUY,lots_base,latest_price_x.ask,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_SELL,lots_base,latest_price_y.bid,0,0);
              }
           break;
         case ENUM_TYPE_CURRENCY_USDX_USDX:
           if(arb_position_states.pair_open_buy==0&&latest_price_xy.ask+delta<latest_price_y.bid/latest_price_x.ask)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_BUY,lots_base,latest_price_xy.ask,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_BUY,lots_base,latest_price_x.ask,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_SELL,lots_base,latest_price_y.bid,0,0);
               
              }
           if(arb_position_states.pair_open_sell==0&&latest_price_xy.bid-delta>latest_price_y.ask/latest_price_x.bid)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_SELL,lots_base,latest_price_xy.bid,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_SELL,lots_base,latest_price_x.bid,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_BUY,lots_base,latest_price_y.ask,0,0);
              } 
           break;
         case ENUM_TYPE_CURRENCY_XUSD_USDX:
            if(arb_position_states.pair_open_buy==0&&latest_price_xy.ask+delta<latest_price_x.bid*latest_price_y.bid)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_BUY,lots_base,latest_price_xy.ask,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_SELL,lots_base,latest_price_x.bid,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_SELL,lots_base,latest_price_y.bid,0,0);
               
              }
           if(arb_position_states.pair_open_sell==0&&latest_price_xy.bid-delta>latest_price_x.ask*latest_price_y.ask)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_SELL,lots_base,latest_price_xy.bid,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_BUY,lots_base,latest_price_x.ask,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_BUY,lots_base,latest_price_y.ask,0,0);
              }
            break;
         default:
           break;
        }
      
     }
  }
//+------------------------------------------------------------------+
//|         刷新套利仓位信息                                         |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::RefreshPosition(void)
  {
   switch(cross_type)
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD :
        RefreshPositionXUSDXUSD();
        break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         RefreshPositionXUSDUSDX();
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         RefreshPositionUSDXUSDX();
         break;   
      default:
        break;
     }
  }
void CTriangularArbCurrency::RefreshPositionXUSDXUSD(void)
  {
   arb_position_states.Init();// 初始化仓位信息
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()==symbol_xy)
        {
         arb_position_states.pair_open_total++;
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
            deal_buy_xy=cpos.EntryPrice();
            close_buy_xy=cpos.CurrentPrice();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
            deal_sell_xy=cpos.EntryPrice();
            close_sell_xy=cpos.CurrentPrice();
           }

        }
      if(cpos.Symbol()==symbol_x)
        {
         if(cpos.Direction()==POSITION_TYPE_SELL)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
            deal_buy_x=cpos.EntryPrice();
            close_buy_x=cpos.CurrentPrice();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
            deal_sell_x=cpos.EntryPrice();
            close_sell_x=cpos.CurrentPrice();
           }
        }
      if(cpos.Symbol()==symbol_y)
        {
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
            deal_buy_y=cpos.EntryPrice();
            close_buy_y=cpos.CurrentPrice();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
            deal_sell_y=cpos.EntryPrice();
            close_sell_y=cpos.CurrentPrice();
           }
        }
     }
    if(arb_position_states.pair_open_buy>0)
      {
        buy_arb_open_points=(int)((deal_buy_x/deal_buy_y-deal_buy_xy)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
        buy_arb_close_points=(int)((close_buy_xy-close_buy_x/close_buy_y)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
      }
    if(arb_position_states.pair_open_sell>0)
      {
        sell_arb_open_points=(int)((deal_sell_xy-deal_sell_x/deal_sell_y)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
        sell_arb_close_points=(int)((close_sell_x/close_sell_y-close_sell_xy)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
      }
   
   
    
  }
void CTriangularArbCurrency::RefreshPositionXUSDUSDX(void)
  {
   arb_position_states.Init();// 初始化仓位信息
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()==symbol_xy)
        {
         arb_position_states.pair_open_total++;
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
            deal_buy_xy=cpos.EntryPrice();
            close_buy_xy=cpos.CurrentPrice();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
            deal_sell_xy=cpos.EntryPrice();
            close_sell_xy=cpos.CurrentPrice();
           }

        }
      if(cpos.Symbol()==symbol_x)
        {
         if(cpos.Direction()==POSITION_TYPE_SELL)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
            deal_buy_x=cpos.EntryPrice();
            close_buy_x=cpos.CurrentPrice();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
            deal_sell_x=cpos.EntryPrice();
            close_sell_x=cpos.CurrentPrice();
           }
        }
      if(cpos.Symbol()==symbol_y)
        {
         if(cpos.Direction()==POSITION_TYPE_SELL)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
            deal_buy_y=cpos.EntryPrice();
            close_buy_y=cpos.CurrentPrice();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
            deal_sell_y=cpos.EntryPrice();
            close_sell_y=cpos.CurrentPrice();
           }
        }
     }
     if(arb_position_states.pair_open_buy>0)
      {
       buy_arb_open_points=(int)((deal_buy_x*deal_buy_y-deal_buy_xy)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
       buy_arb_close_points=(int)((close_buy_xy-close_buy_x*close_buy_y)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
      }
    if(arb_position_states.pair_open_sell>0)
      {
       sell_arb_open_points=(int)((deal_sell_xy-deal_buy_x*deal_buy_y)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
       sell_arb_close_points=(int)((close_sell_x*close_sell_y-close_sell_xy)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
      }
  }
 void CTriangularArbCurrency::RefreshPositionUSDXUSDX(void)
  {
   arb_position_states.Init();// 初始化仓位信息
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()==symbol_xy)
        {
         arb_position_states.pair_open_total++;
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
            deal_buy_xy=cpos.EntryPrice();
            close_buy_xy=cpos.CurrentPrice();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
            deal_sell_xy=cpos.EntryPrice();
            close_sell_xy=cpos.CurrentPrice();
           }

        }
      if(cpos.Symbol()==symbol_x)
        {
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
            deal_buy_x=cpos.EntryPrice();
            close_buy_x=cpos.CurrentPrice();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
            deal_sell_x=cpos.EntryPrice();
            close_sell_x=cpos.CurrentPrice();
           }
        }
      if(cpos.Symbol()==symbol_y)
        {
         if(cpos.Direction()==POSITION_TYPE_SELL)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
            deal_buy_y=cpos.EntryPrice();
            close_buy_y=cpos.CurrentPrice();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
            deal_sell_y=cpos.EntryPrice();
            close_sell_y=cpos.CurrentPrice();
           }
        }
     }
    if(arb_position_states.pair_open_buy>0)
      {
         buy_arb_open_points=(int)((deal_buy_y/deal_buy_x-deal_buy_xy)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
         buy_arb_close_points=(int)((close_buy_xy-close_buy_y/close_buy_x)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
      }
    if(arb_position_states.pair_open_sell>0)
      {
       sell_arb_open_points=(int)((deal_sell_xy-deal_sell_y/deal_sell_x)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
       sell_arb_close_points=(int)((close_sell_y/close_sell_x-close_sell_xy)/SymbolInfoDouble(symbol_xy,SYMBOL_POINT));
      }

    
  }
//+------------------------------------------------------------------+
//|            平买仓操作                                            |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::CloseArbitrageBuyPosition(void)
  {
   switch(cross_type)
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD :
        CloseArbitrageBuyPositionXUSDXUSD();
        break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         CloseArbitrageBuyPositionXUSDUSDX();
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         CloseArbitrageBuyPositionUSDXUSDX();
         break;   
      default:
        break;
     }
  }
void CTriangularArbCurrency::CloseArbitrageBuyPositionXUSDXUSD(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());   
     }
   }
void CTriangularArbCurrency::CloseArbitrageBuyPositionXUSDUSDX(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());   
     }
   }
void CTriangularArbCurrency::CloseArbitrageBuyPositionUSDXUSDX(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());   
     }
   }
//+------------------------------------------------------------------+
//|                  平卖仓操作                                      |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::CloseArbitrageSellPosition(void)
  {
   switch(cross_type)
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD :
        CloseArbitrageSellPositionXUSDXUSD();
        break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         CloseArbitrageSellPositionXUSDUSDX();
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         CloseArbitrageSellPositionUSDXUSDX();
         break;   
      default:
        break;
     }
  }
void CTriangularArbCurrency::CloseArbitrageSellPositionXUSDXUSD(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());   
     }
   }
void CTriangularArbCurrency::CloseArbitrageSellPositionXUSDUSDX(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());   
     }
   }
void CTriangularArbCurrency::CloseArbitrageSellPositionUSDXUSDX(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());   
     }
   }
//+------------------------------------------------------------------+
