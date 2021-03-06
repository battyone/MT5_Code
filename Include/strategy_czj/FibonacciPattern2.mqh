//+------------------------------------------------------------------+
//|                                            FibonacciPattern2.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <strategy_czj\FibonacciBase.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_PATTERN
  {
   PATTERN_1,
   PATTERN_2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFibonacciPattern2:public CFibonacciBaseStrategy
  {
private:
   int               handle_zigzag;
   double            position_lots;
   int               position_max;
   int               num_zigzag;
   double            extreme_value[];
   int               point_range_min;
   double            pre_max;
   double            pre_min;
   int choose_mode;
   double p_ratio;
protected:
   virtual void      PatternRecognize(void);
   virtual void      GetZigZagValue(void);
   void              Pattern1(void);
   void              Pattern2(void);
public:
   void              InitStrategy(const double ratio_open,const double ratio_tp,const double ratio_sl,const double p_lots,const int p_max,const int point_min,const int n_zigzag,const int depth_zigzag, const int mode, const double zz_ratio=1.0);
   virtual void      OnEvent(const MarketEvent &event);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciPattern2::InitStrategy(const double ratio_open,const double ratio_tp,const double ratio_sl,const double p_lots,const int p_max,const int point_min,const int n_zigzag,const int depth_zigzag,const int mode,const double zz_ratio=1.0)
  {
   open_ratio=ratio_open;
   tp_ratio=ratio_tp;
   sl_ratio=ratio_sl;
   position_lots=p_lots;
   position_max=p_max;
   num_zigzag=n_zigzag;
   point_range_min=point_min;
   handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag",depth_zigzag,5,3);
   choose_mode = mode;
   p_ratio=zz_ratio;
   //handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"ZigZags\\iHighLowZigZag",depth_zigzag);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciPattern2::GetZigZagValue(void)
  {
   double zigzag_value[1000];
   int counter=0;
   CopyBuffer(handle_zigzag,0,0,1000,zigzag_value);
   for(int i=ArraySize(zigzag_value)-2;i>=0;i--)
     {
      if(zigzag_value[i]==0) continue;//过滤为0的值
      if(counter==num_zigzag) break;//极值数量达到给定的值不再取值
      counter++;
      ArrayResize(extreme_value,counter);
      extreme_value[counter-1]=zigzag_value[i];
     }
  }
//+------------------------------------------------------------------+
void CFibonacciPattern2::OnEvent(const MarketEvent &event)
  {
//监控品种的BAR事件发生时的相关处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      PatternRecognize();//进行模式识别
     }
//监控品种tick事件发生时的相关处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      GetPositionStates();//刷新仓位信息
      bool basic_buy_open_condition=pattern_valid && p_state.open_buy<position_max && signal==up;
      bool basic_sell_open_condition=pattern_valid && p_state.open_sell<position_max && signal==down;
      if(basic_buy_open_condition || basic_sell_open_condition)
         if(OpenPosition(position_lots))//进行开仓操作
           {
            pre_max=max_price;
            pre_min=min_price;
            pattern_valid=false;
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciPattern2::PatternRecognize(void)
  {
   GetZigZagValue();
   switch(choose_mode)
      {
         case 1:
            Pattern1();
            break;
         case 2:
            Pattern2();
            break;
         default:
            break;      
      }
  }
//+------------------------------------------------------------------+
//|   取zigzag序列的最大最小值，点差满足要求                         |
//+------------------------------------------------------------------+
void CFibonacciPattern2::Pattern1(void)
  {
   if(ArraySize(extreme_value)<num_zigzag)
     {
      Print("ZIGZAG VALUE NUM NOT ENOUGH");
      pattern_valid=false;
      return;
     }
   int maxloc=ArrayMaximum(extreme_value);
   int minloc=ArrayMinimum(extreme_value);
   max_price=extreme_value[maxloc];
   min_price=extreme_value[minloc];
   signal=maxloc<minloc?up:down;
   if(extreme_value[maxloc]-extreme_value[minloc]>point_range_min*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
      pattern_valid=true;

//如果前面判断的模式存在，还需要判断是否之前已经使用过该模式
   if(max_price==pre_max || min_price==pre_min)
     {
      pattern_valid=false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciPattern2::Pattern2(void)
  {
   if(ArraySize(extreme_value)<num_zigzag)
     {
      Print("ZIGZAG VALUE NUM NOT ENOUGH");
      pattern_valid=false;
      return;
     }
   double range_current=extreme_value[0]-extreme_value[1];
   
   for(int i=1;i<ArraySize(extreme_value)-1;i++)
     {
      if(MathAbs(extreme_value[i]-extreme_value[i+1])>p_ratio*MathAbs(range_current))
        {
         pattern_valid=false;
         return;
        }
     }
   if(range_current>point_range_min*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
     {
      pattern_valid=true;
      signal=up;
      max_price=extreme_value[0];
      min_price=extreme_value[1];
     }
   else if(range_current<-point_range_min*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
     {
      pattern_valid=true;
      signal=down;
      max_price=extreme_value[1];
      min_price=extreme_value[0];
     }
//如果前面判断的模式存在，还需要判断是否之前已经使用过该模式
   if(max_price==pre_max || min_price==pre_min)
     {
      pattern_valid=false;
     }
  }
//+------------------------------------------------------------------+
