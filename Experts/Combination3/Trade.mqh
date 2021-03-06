//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright  "Copyright 2017, Alexander Fedosov"
#property link       "https://www.mql5.com/en/users/alex2356"
#property version    "2.0"
//--- Enumeration for lot calculation options
enum MarginMode
  {
   FREEMARGIN=0,     //MM Free Margin
   BALANCE,          //MM Balance
   LOT               //Constant Lot
  };
//--- Enumeration of basic lot options
enum LotType
  {
   MINLOT=0,
   BASELOT
  };
//+------------------------------------------------------------------+
//| The library of trading operations                                |
//+------------------------------------------------------------------+
class CTradeBase
  {
private:
   //--- Selection of basic lot calculation options
   MarginMode        m_mm_lot;
   LotType           m_type_lot;
   double            m_base_lot;
   //--- Slippage
   uint              m_deviation;
   ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
   //-- Expert Advisor name
   string            m_ea_name;
   //-- Language for error messages
   string            m_lang;
   //--- Lot calculation for positions opened with lot_margin
   double            GetLotForOpeningPos(string symbol,ENUM_POSITION_TYPE direction,double lot_margin);
   //--- Return the fill type
   ENUM_ORDER_TYPE_FILLING GetFilling(void);
   //---
   int               GetDig(string symbol);
   //--- Correction of a lot size to the nearest acceptable value
   bool              LotCorrect(string symbol,ENUM_POSITION_TYPE trade_operation);
   //--- Limitation of a lot size by a deposit capacity
   bool              LotFreeMarginCorrect(string symbol,ENUM_POSITION_TYPE trade_operation);
   //--- Lot calculation
   double            LotCount(string symbol,ENUM_POSITION_TYPE directon,double base_lot);
   //--- Correction of a pending order size to an acceptable value
   int               StopCorrect(string symbol,int Stop);
   bool              dStopCorrect(string symbol,double &dStopLoss,double &dTakeprofit,ENUM_POSITION_TYPE trade_operation);
   //--- Returning a trade operation string result by its code
   string            ResultRetcodeDescription(int retcode);
   //--- Selecting a position with the specified index
   bool              SelectByIndex(const int index);
   //--- position select depending on netting or hedging
   bool              SelectPosition(const string symbol,int MagicNumber);
   //---
   bool              IsHedging(void) const { return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING); }
public:
                     CTradeBase(void);
                    ~CTradeBase(void);
   //--- Setting lot calculation option
   void              SetMM(const MarginMode MM) { m_mm_lot=MM;             }
   //--- Setting lot option
   void              SetLotType(const LotType Lot) { m_type_lot=Lot;          }
   //--- Setting Expert Advisor name
   void              SetNameEA(const string NameEA) { m_ea_name=NameEA;        }
   //--- Setting language for the errors
   void              SetLanguage(const string Lang) { m_lang=Lang;             }
   //--- Setting slippage
   void              SetDeviation(const uint Dev) { m_deviation=Dev;      }
   //--- Opening a long position, stop levels in points
   bool              BuyPositionOpen(const string symbol,double Lot,int StopLoss,int Takeprofit,int MagicNumber,string  TradeComm);
   //--- Opening a long position, stop levels in price units
   bool              BuyPositionOpen(const string symbol,double Lot,double dStopLoss,double dTakeprofit,int MagicNumber,string  TradeComm);
   //--- Opening a short position, stop levels in points
   bool              SellPositionOpen(const string symbol,double Lot,int StopLoss,int Takeprofit,int MagicNumber,string  TradeComm);
   //--- Opening a short position, stop levels in price units
   bool              SellPositionOpen(const string symbol,double Lot,double dStopLoss,double dTakeprofit,int MagicNumber,string  TradeComm);
   //--- Modification of a long position in points
   bool              BuyPositionModify(const string symbol,int StopLoss,int Takeprofit);
   //--- Modification of a long position in price units
   bool              BuyPositionModify(const string symbol,double dStopLoss,double dTakeprofit);
   //--- Modification of a short position in points
   bool              SellPositionModify(const string symbol,int StopLoss,int Takeprofit);
   //--- Modification of a short position in price units
   bool              SellPositionModify(const string symbol,double dStopLoss,double dTakeprofit);
   //--- Closing a position by type
   bool              ClosePositionByType(const string symbol,ENUM_POSITION_TYPE PosType,int MagicNumber);
   //--- Checking open positions with the magic number 
   bool              IsOpenedByMagic(int MagicNumber);
   //--- Checking open position types with the magic number
   bool              IsOpenedByType(ENUM_POSITION_TYPE PosType,int MagicNumber);
   //--- Checking open positions on the symbol with the magic number
   bool              IsOpenedBySymbol(string symbol,int MagicNumber);
   //--- Checking allowable symbol spread
   bool              MaxSpread(string symbol,int MaxLevelSpread);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeBase::CTradeBase(void): m_mm_lot(LOT),
                              m_type_lot(MINLOT),
                              m_ea_name("EA"),
                              m_lang("en"),
                              m_deviation(20)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeBase::~CTradeBase(void)
  {
  }
//+------------------------------------------------------------------+
//| Opening a long position, stop levels in points                   |
//+------------------------------------------------------------------+
bool CTradeBase::BuyPositionOpen
(
 const string  symbol,                 // deal trading pair
 double        Lot,                    // MM
 int           StopLoss,               // stop loss in points
 int           Takeprofit,             // take profit in points
 int           MagicNumber,            // magic number
 string        TradeComm=""            // comments
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;
//----
   double volume=LotCount(symbol,PosType,Lot);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Declaration of the structure of a trade request checking result 
   MqlTradeCheckResult check;

//---- nulling the structures
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Ask;
//----   
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask))
      return(true);

//---- Initializing structure of the MqlTradeRequest to open BUY position

   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.magic  = MagicNumber;
   request.comment= TradeComm;
   request.deviation=m_deviation;
   request.type_filling=GetFilling();
//---- Determine distance to Stop Loss (in price chart units)

   if(StopLoss!=0)
     {
      StopLoss=StopCorrect(symbol,StopLoss);
      if(StopLoss==0)
         return(false);
      double dStopLoss=StopLoss*point*GetDig(symbol);
      request.sl=NormalizeDouble(request.price-dStopLoss,int(digit));
     }
   else
      request.sl=0.0;
//---- Determine distance to Take Profit (in price chart units)

   if(Takeprofit!=0)
     {
      Takeprofit=StopCorrect(symbol,Takeprofit);
      if(Takeprofit==0)
         return(false);
      double dTakeprofit=Takeprofit*point*GetDig(symbol);
      request.tp=NormalizeDouble(request.price+dTakeprofit,int(digit));
     }
   else
      request.tp=0.0;

//---- Checking correctness of a trade request
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,m_ea_name,": Opening Buy position to ",symbol,"");
   Print(comment);

//---- Open BUY position and check the result of trade request
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,m_ea_name,": Buy position to ",symbol," opened.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Opening a long position, stop levels in price units              |
//+------------------------------------------------------------------+
bool CTradeBase::BuyPositionOpen
(
 const string  symbol,                 // deal trading pair
 double        Lot,                    // MM
 double        dStopLoss,              // stop loss in price chart units
 double        dTakeprofit,            // take profit in price chart units
 int           MagicNumber,            //magic number
 string        TradeComm=""            // comments 
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;

//---- Declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Declaration of the structure of a trade request checking result 
   MqlTradeCheckResult check;

//---- nulling the structures
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Ask;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask))
      return(true);

//---- correcting the distances for stop loss and take profit (in price chart units)
   if(!dStopCorrect(symbol,dStopLoss,dTakeprofit,PosType))
      return(false);
//----
   double volume=LotCount(symbol,PosType,Lot);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Initializing structure of the MqlTradeRequest to open BUY position
   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.sl=dStopLoss;
   request.tp=dTakeprofit;
   request.deviation=m_deviation;
   request.magic=MagicNumber;
   request.comment=TradeComm;
   request.type_filling=GetFilling();
//---- Checking correctness of a trade request
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"Open Buy position to ",symbol);
   Print(comment);

//---- Open BUY position and check the result of trade request
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,m_ea_name,": Buy position to ",symbol," opened.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Opening a short position, stop levels in points                  |
//+------------------------------------------------------------------+
bool CTradeBase::SellPositionOpen
(
 const string  symbol,                 // deal trading pair
 double        Lot,                    // MM
 int           StopLoss,               // stop loss in points
 int           Takeprofit,             // take profit in points
 int           MagicNumber,            // magic number
 string        TradeComm=""            // comments
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//----
   double volume=LotCount(symbol,PosType,Lot);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Declaration of the structure of a trade request checking result 
   MqlTradeCheckResult check;

//---- nulling the structures
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Bid;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid)) return(true);

//---- Initializing structure of the MqlTradeRequest to open SELL position
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.magic=MagicNumber;
   request.comment=TradeComm;
   request.deviation=m_deviation;
   request.type_filling=GetFilling();
//---- Determine distance to Stop Loss (in price chart units)

   if(StopLoss!=0)
     {
      StopLoss=StopCorrect(symbol,StopLoss);
      if(StopLoss==0)
         return(false);
      double dStopLoss=StopLoss*point*GetDig(symbol);
      request.sl=NormalizeDouble(request.price+dStopLoss,int(digit));
     }
   else
      request.sl=0.0;

//---- Determine distance to Take Profit (in price chart units)
   if(Takeprofit!=0)
     {
      Takeprofit=StopCorrect(symbol,Takeprofit);
      if(Takeprofit==0)
         return(false);
      double dTakeprofit=Takeprofit*point*GetDig(symbol);
      request.tp=NormalizeDouble(request.price-dTakeprofit,int(digit));
     }
   else
      request.tp=0.0;
//---- Checking correctness of a trade request
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,m_ea_name,": Opening Sell position to ",symbol,"");
   Print(comment);

//---- Open SELL position and check the result of trade request
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,m_ea_name,": Sell position to ",symbol," opened.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Open a short position                                            |
//+------------------------------------------------------------------+
bool CTradeBase:: SellPositionOpen
(
 const string  symbol,                 // deal trading pair
 double        Lot,                    // MM
 double        dStopLoss,              // stop loss in price chart units
 double        dTakeprofit,            // take profit in price chart units
 int           MagicNumber,            //magic number
 string        TradeComm=""            // comments 
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//---- Declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Declaration of the structure of a trade request checking result 
   MqlTradeCheckResult check;

//---- nulling the structures
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Bid;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid))
      return(true);

//---- correcting the distances for stop loss and take profit (in price chart units)
   if(!dStopCorrect(symbol,dStopLoss,dTakeprofit,PosType))
      return(false);

//----
   double volume=LotCount(symbol,PosType,Lot);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Initializing structure of the MqlTradeRequest to open SELL position
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.sl=dStopLoss;
   request.tp=dTakeprofit;
   request.deviation=m_deviation;
   request.magic=MagicNumber;
   request.comment=TradeComm;
   request.type_filling=GetFilling();
//---- Checking correctness of a trade request
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,m_ea_name,": Opening Sell position to ",symbol);
   Print(comment);

//---- Open SELL position and check the result of trade request
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,m_ea_name,": Sell position to ",symbol," opened.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Modifying a long position                                        |
//+------------------------------------------------------------------+
bool CTradeBase::BuyPositionModify(const string symbol,int StopLoss,int Takeprofit)
  {
//---

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;

//---- Checking, if there is an open position
   if(!PositionSelect(symbol))
      return(true);

//---- Declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Declaration of the structure of a trade request checking result 
   MqlTradeCheckResult check;

//---- nulling the structures
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Ask;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask))
      return(true);

//---- Initializing structure of the MqlTradeRequest to open BUY position

   request.type   = ORDER_TYPE_BUY;
   request.action = TRADE_ACTION_SLTP;
   request.symbol = symbol;
   request.type_filling=GetFilling();
   request.deviation=m_deviation;
//---- Determine distance to Stop Loss (in price chart units)

   if(StopLoss)
     {
      StopLoss=StopCorrect(symbol,StopLoss);
      double dStopLoss=StopLoss*point*GetDig(symbol);
      request.sl=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-dStopLoss,int(digit));
     }
   else
      request.sl=PositionGetDouble(POSITION_SL);

//---- Determine distance to Take Profit (in price chart units)
   if(Takeprofit)
     {
      Takeprofit=StopCorrect(symbol,Takeprofit);
      double dTakeprofit=Takeprofit*point*GetDig(symbol);
      request.tp=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+dTakeprofit,int(digit));
     }
   else
      request.tp=PositionGetDouble(POSITION_TP);

//----   
   if(request.tp==PositionGetDouble(POSITION_TP) && request.sl==PositionGetDouble(POSITION_SL))
      return(true);
//---- Checking correctness of a trade request

   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"Modify Buy position to ",symbol);
   Print(comment);

//---- Modifying SELL position and checking the result of a trade request
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not modify a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,"Buy position to ",symbol," modified.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not modify a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Close specified opened position                                  |
//+------------------------------------------------------------------+
bool CTradeBase::ClosePositionByType(const string symbol,ENUM_POSITION_TYPE PosType,int MagicNumber)
  {
//---- Declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Declaration of the structure of a trade request checking result 
   MqlTradeCheckResult check;
   bool partial_close=false;
   int  retry_count=10;
   uint retcode=TRADE_RETCODE_REJECT;
//---- nulling the structures
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
   do
     {
      if(SelectPosition(symbol,MagicNumber))
        {
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && 
            PosType==POSITION_TYPE_BUY
            )
           {
            request.type =ORDER_TYPE_SELL;
            request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
           }
         else if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && 
            PosType==POSITION_TYPE_SELL
            )
              {
               request.type =ORDER_TYPE_BUY;
               request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
              }
           }
         else
           {
            //--- position not found
            result.retcode=retcode;
            Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(result.retcode));
            return(false);
           }
         //--- setting request
         request.action   =TRADE_ACTION_DEAL;
         request.symbol   =symbol;
         request.volume   =PositionGetDouble(POSITION_VOLUME);
         request.magic    =MagicNumber;
         request.deviation=m_deviation;
         request.type_filling=GetFilling();
         //--- hedging? just send order
         if(IsHedging())
           {
            request.position=PositionGetInteger(POSITION_TICKET);
            return(OrderSend(request,result));
           }

         //--- check volume
         double max_volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
         if(request.volume>max_volume)
           {
            request.volume=max_volume;
            partial_close=true;
           }
         else
            partial_close=false;
         //--- order send
         if(!OrderSend(request,result))
           {
            if(--retry_count!=0) continue;
            if(retcode==TRADE_RETCODE_DONE_PARTIAL)
               result.retcode=retcode;
            Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
            return(false);
           }

         retcode=TRADE_RETCODE_DONE_PARTIAL;
         if(partial_close)
            Sleep(1000);
        }
   while(partial_close);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Modifying a short position in points                             |
//+------------------------------------------------------------------+
bool CTradeBase::SellPositionModify
(
 const string symbol,        // deal trading pair
 int StopLoss,               // Stop loss in points
 int Takeprofit              // Take profit in points
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//---- Checking, if there is an open position
   if(!PositionSelect(symbol))
      return(true);
//---- Declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;

//---- Declaration of the structure of a trade request checking result 
   MqlTradeCheckResult check;

//---- nulling the structures
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
//----
   long digit;
   double point,Bid;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid))
      return(true);

//---- Initializing structure of the MqlTradeRequest to open BUY position

   request.position=PositionGetInteger(POSITION_TICKET);
   request.type   = ORDER_TYPE_SELL;
   request.action = TRADE_ACTION_SLTP;
   request.symbol = symbol;
   request.deviation=m_deviation;
   request.type_filling=GetFilling();
//---- Determine distance to Stop Loss (in price chart units)

   if(StopLoss!=0)
     {
      StopLoss=StopCorrect(symbol,StopLoss);
      double dStopLoss=StopLoss*point*GetDig(symbol);
      request.sl=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+dStopLoss,int(digit));
     }
   else
      request.sl=PositionGetDouble(POSITION_SL);

//---- Determine distance to Take Profit (in price chart units)
   if(Takeprofit!=0)
     {
      Takeprofit=StopCorrect(symbol,Takeprofit);
      double dTakeprofit=Takeprofit*point*GetDig(symbol);
      request.tp=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-dTakeprofit,int(digit));
     }
   else
      request.tp=PositionGetDouble(POSITION_TP);

//----   

   if(request.tp==PositionGetDouble(POSITION_TP) && request.sl==PositionGetDouble(POSITION_SL))
      return(true);
//---- Checking correctness of a trade request

   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"Modify Sell position to ",symbol);
   Print(comment);

//---- Modifying SELL position and checking the result of a trade request
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not modify a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,"Sell position to ",symbol," modified.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not modify a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking open positions with the magic number                    |
//+------------------------------------------------------------------+
bool CTradeBase:: IsOpenedByMagic(int MagicNumber)
  {
   int pos=0;
   uint total=PositionsTotal();
//---
   for(uint i=0; i<total; i++)
     {
      if(SelectByIndex(i))
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber)
            pos++;
     }
   return((pos>0)?true:false);
  }
//+------------------------------------------------------------------+
//| Checking open position types with the magic number               |
//+------------------------------------------------------------------+
bool CTradeBase:: IsOpenedByType(ENUM_POSITION_TYPE PosType,int MagicNumber)
  {
   int pos=0;
   uint total=PositionsTotal();
//---
   for(uint i=0; i<total; i++)
     {
      if(SelectByIndex(i))
         if(PositionGetInteger(POSITION_TYPE)==PosType && PositionGetInteger(POSITION_MAGIC)==MagicNumber)
            pos++;
     }
   return((pos>0)?true:false);
  }
//+------------------------------------------------------------------+
//| Checking open positions on the symbol with the magic number      |
//+------------------------------------------------------------------+
bool CTradeBase::IsOpenedBySymbol(string symbol,int MagicNumber)
  {
   int pos=0;
   uint total=PositionsTotal();
//---
   for(uint i=0; i<total; i++)
     {
      if(SelectByIndex(i))
         if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_MAGIC)==MagicNumber)
            pos++;
     }
   return((pos>0)?true:false);
  }
//+------------------------------------------------------------------+
//| Checking spread                                                  |
//+------------------------------------------------------------------+
bool   CTradeBase::MaxSpread(string symbol,int MaxLevelSpread)
  {
   if(MaxLevelSpread>0)
     {
      return ((SymbolInfoInteger(symbol,SYMBOL_SPREAD)>MaxLevelSpread)?true:false);
     }
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CTradeBase::GetDig(string symbol)
  {
   long digits=SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   return((digits==5 || digits==3 || digits==1)?10:1);
  }
//+------------------------------------------------------------------+
//| lot calculation to open a position with the margin lot_margin    |
//+------------------------------------------------------------------+
double CTradeBase::GetLotForOpeningPos(string symbol,ENUM_POSITION_TYPE direction,double lot_margin)
  {
//----
   double price=0.0,n_margin;
   double LotStep,MaxLot,MinLot;
   if(direction==POSITION_TYPE_BUY)
      if(!SymbolInfoDouble(symbol,SYMBOL_ASK,price))
         return(0);
   if(direction==POSITION_TYPE_SELL)
      if(!SymbolInfoDouble(symbol,SYMBOL_BID,price))
         return(0);
   if(!price)
      return(NULL);

   if(!OrderCalcMargin(ENUM_ORDER_TYPE(direction),symbol,1,price,n_margin) || !n_margin)
      return(0);

   double lot=lot_margin/n_margin;

//---- getting trade constants   
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,LotStep))
      return(0);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot))
      return(0);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot))
      return(0);

//---- normalizing the lot size to the nearest standard value 
   lot=LotStep*MathFloor(lot/LotStep);

//---- checking the lot for the minimum allowable value
   if(lot<MinLot)
      lot=MinLot;
//---- checking the lot for the maximum allowable value       
   if(lot>MaxLot)
      lot=MaxLot;
//----
   return(lot);
  }
//+------------------------------------------------------------------+
//| Returns the fill type                                            |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING CTradeBase::GetFilling(void)
  {
   uint filling=(uint)SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);

   if(filling==1)
      return(ORDER_FILLING_FOK);
   else if(filling==2)
      return(ORDER_FILLING_IOC);
   return(false);
  }
//+------------------------------------------------------------------+
//| Lot size calculation                                             |  
//+------------------------------------------------------------------+
double CTradeBase:: LotCount(string symbol,ENUM_POSITION_TYPE directon,double base_lot)
  {
//----
   double margin=0.0,Lot=0.0,MinLot=0.0;
   switch(m_type_lot)
     {
      case  0:
         if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot))
         return(false);
         Lot=MinLot;
         break;
      case  1:
         Lot=base_lot;
         break;
     }
//--- LOT SIZE CALCULATION FOR OPENING A POSITION
   if(base_lot<0)
      m_base_lot=MathAbs(base_lot);
   else
   switch(m_mm_lot)
     {
      //---- Lot calculation considering account free funds
      case  0:
         margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE)*Lot;
         m_base_lot=GetLotForOpeningPos(symbol,directon,margin);
         break;
         //---- Lot calculation considering account balance
      case  1:
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Lot;
         m_base_lot=GetLotForOpeningPos(symbol,directon,margin);
         break;
         //---- Lot calculation should be unchanged
      case  2:
        {
         m_base_lot=MathAbs(base_lot);
         break;
        }
      //---- Lot calculation considering account free funds by default
      default:
        {
         margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE)*Lot;
         m_base_lot=GetLotForOpeningPos(symbol,directon,margin);
        }
     }

//---- normalizing the lot size to the nearest standard value 
   if(!LotCorrect(symbol,directon)) return(-1);
//----
   return(m_base_lot);
  }
//+------------------------------------------------------------------+
//| Correction of a lot size to the nearest acceptable value         |
//+------------------------------------------------------------------+
bool CTradeBase::LotCorrect(string symbol,ENUM_POSITION_TYPE trade_operation)
  {
//---- getting calculation data   
   double Step,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,Step)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(false);

//---- normalizing the lot size to the nearest standard value 
   m_base_lot=Step*MathFloor(m_base_lot/Step);

//---- checking the lot for the minimum allowable value
   if(m_base_lot<MinLot)
      m_base_lot=MinLot;
//---- checking the lot for the maximum allowable value       
   if(m_base_lot>MaxLot)
      m_base_lot=MaxLot;

//---- checking the funds sufficiency
   if(!LotFreeMarginCorrect(symbol,trade_operation))return(false);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| limitation of a lot size by a deposit capacity                   |
//+------------------------------------------------------------------+
bool CTradeBase::LotFreeMarginCorrect(string symbol,ENUM_POSITION_TYPE trade_operation)
  {
//---- checking the funds sufficiency
   double freemargin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(freemargin<=0) return(false);

//---- getting calculation data   
   double Step,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,Step)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(false);

   double ExtremLot=GetLotForOpeningPos(symbol,trade_operation,freemargin);
//---- normalizing the lot size to the nearest standard value 
   ExtremLot=Step*MathFloor(ExtremLot/Step);

   if(ExtremLot<MinLot)
      return(false);                   // funds are insufficient even for a minimum lot!
   if(m_base_lot>ExtremLot)
      m_base_lot=ExtremLot;            // cutting the lot size down to the deposit capacity!
   if(m_base_lot>MaxLot)
      m_base_lot=MaxLot;               // cutting the lot size down to the maximum permissible one
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Correction of a pending order size to an acceptable value        |
//+------------------------------------------------------------------+
int CTradeBase::StopCorrect(string symbol,int Stop)
  {
//----
   long Extrem_Stop;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL,Extrem_Stop)) return(false);
   if(Stop<Extrem_Stop)
      Stop=int(Extrem_Stop);
//----
   return(Stop);
  }
//+------------------------------------------------------------------+
//| Correction of a pending order size to an acceptable value        |
//+------------------------------------------------------------------+
bool CTradeBase::dStopCorrect(string symbol,double &dStopLoss,double &dTakeprofit,ENUM_POSITION_TYPE trade_operation)
  {
//----
   if(!dStopLoss && !dTakeprofit)
      return(true);

   if(dStopLoss<0)
     {
      Print(__FUNCTION__,"(): A negative value stoploss!");
      return(false);
     }

   if(dTakeprofit<0)
     {
      Print(__FUNCTION__,"(): A negative value takeprofit!");
      return(false);
     }
//---- 
   int Stop=0;
   long digit;
   double point,dStop,ExtrStop,ExtrTake;

//---- getting the minimum distance to a pending order 
   Stop=StopCorrect(symbol,Stop);
//----   
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(false);
   dStop=Stop*point;

//---- correction of a pending order size for a long position
   if(trade_operation==POSITION_TYPE_BUY)
     {
      double Ask;
      if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask))
         return(false);

      ExtrStop=NormalizeDouble(Ask-dStop,int(digit));
      ExtrTake=NormalizeDouble(Ask+dStop,int(digit));

      if(dStopLoss>ExtrStop && dStopLoss)
         dStopLoss=ExtrStop;
      if(dTakeprofit<ExtrTake && dTakeprofit)
         dTakeprofit=ExtrTake;
     }

//---- correction of a pending order size for a short position
   if(trade_operation==POSITION_TYPE_SELL)
     {
      double Bid;
      if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid))
         return(false);

      ExtrStop=NormalizeDouble(Bid+dStop,int(digit));
      ExtrTake=NormalizeDouble(Bid-dStop,int(digit));

      if(dStopLoss<ExtrStop && dStopLoss)
         dStopLoss=ExtrStop;
      if(dTakeprofit>ExtrTake && dTakeprofit)
         dTakeprofit=ExtrTake;
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Returning a trade operation string result by its code            |
//+------------------------------------------------------------------+
string CTradeBase::ResultRetcodeDescription(int retcode)
  {
   string str;
//----
   if(m_lang=="en")
     {
      switch(retcode)
        {
         case TRADE_RETCODE_REQUOTE: str="Requote"; break;
         case TRADE_RETCODE_REJECT: str="Request rejected"; break;
         case TRADE_RETCODE_CANCEL: str="Request canceled by trader"; break;
         case TRADE_RETCODE_PLACED: str="Order placed"; break;
         case TRADE_RETCODE_DONE: str="Request completed"; break;
         case TRADE_RETCODE_DONE_PARTIAL: str="Only part of the request was completed"; break;
         case TRADE_RETCODE_ERROR: str="Request processing error"; break;
         case TRADE_RETCODE_TIMEOUT: str="Request canceled by timeout";break;
         case TRADE_RETCODE_INVALID: str="Invalid request"; break;
         case TRADE_RETCODE_INVALID_VOLUME: str="Invalid volume in the request"; break;
         case TRADE_RETCODE_INVALID_PRICE: str="Invalid price in the request"; break;
         case TRADE_RETCODE_INVALID_STOPS: str="Invalid stops in the request"; break;
         case TRADE_RETCODE_TRADE_DISABLED: str="Trade is disabled"; break;
         case TRADE_RETCODE_MARKET_CLOSED: str="Market is closed"; break;
         case TRADE_RETCODE_NO_MONEY: str="There is not enough money to complete the request"; break;
         case TRADE_RETCODE_PRICE_CHANGED: str="Prices changed"; break;
         case TRADE_RETCODE_PRICE_OFF: str="There are no quotes to process the request"; break;
         case TRADE_RETCODE_INVALID_EXPIRATION: str="Invalid order expiration date in the request"; break;
         case TRADE_RETCODE_ORDER_CHANGED: str="Order state changed"; break;
         case TRADE_RETCODE_TOO_MANY_REQUESTS: str="Too frequent requests"; break;
         case TRADE_RETCODE_NO_CHANGES: str="No changes in request"; break;
         case TRADE_RETCODE_SERVER_DISABLES_AT: str="Autotrading disabled by server"; break;
         case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Autotrading disabled by client terminal"; break;
         case TRADE_RETCODE_LOCKED: str="Request locked for processing"; break;
         case TRADE_RETCODE_FROZEN: str="Order or position frozen"; break;
         case TRADE_RETCODE_INVALID_FILL: str="Invalid order filling type"; break;
         case TRADE_RETCODE_CONNECTION: str="No connection with the trade server"; break;
         case TRADE_RETCODE_ONLY_REAL: str="Operation is allowed only for live accounts"; break;
         case TRADE_RETCODE_LIMIT_ORDERS: str="The number of pending orders has reached the limit"; break;
         case TRADE_RETCODE_LIMIT_VOLUME: str="The volume of orders and positions for the symbol has reached the limit"; break;
         default: str="Unknown result";
        }
     }
   else if(m_lang=="ru")
     {
      switch(retcode)
        {
         case TRADE_RETCODE_REQUOTE: str="Реквота"; break;
         case TRADE_RETCODE_REJECT: str="Запрос отвергнут"; break;
         case TRADE_RETCODE_CANCEL: str="Запрос отменен трейдером"; break;
         case TRADE_RETCODE_PLACED: str="Ордер размещен"; break;
         case TRADE_RETCODE_DONE: str="Заявка выполнена"; break;
         case TRADE_RETCODE_DONE_PARTIAL: str="Заявка выполнена частично"; break;
         case TRADE_RETCODE_ERROR: str="Ошибка обработки запроса"; break;
         case TRADE_RETCODE_TIMEOUT: str="Запрос отменен по истечению времени";break;
         case TRADE_RETCODE_INVALID: str="Неправильный запрос"; break;
         case TRADE_RETCODE_INVALID_VOLUME: str="Неправильный объем в запросе"; break;
         case TRADE_RETCODE_INVALID_PRICE: str="Неправильная цена в запросе"; break;
         case TRADE_RETCODE_INVALID_STOPS: str="Неправильные стопы в запросе"; break;
         case TRADE_RETCODE_TRADE_DISABLED: str="Торговля запрещена"; break;
         case TRADE_RETCODE_MARKET_CLOSED: str="Рынок закрыт"; break;
         case TRADE_RETCODE_NO_MONEY: str="Нет достаточных денежных средств для выполнения запроса"; break;
         case TRADE_RETCODE_PRICE_CHANGED: str="Цены изменились"; break;
         case TRADE_RETCODE_PRICE_OFF: str="Отсутствуют котировки для обработки запроса"; break;
         case TRADE_RETCODE_INVALID_EXPIRATION: str="Неверная дата истечения ордера в запросе"; break;
         case TRADE_RETCODE_ORDER_CHANGED: str="Состояние ордера изменилось"; break;
         case TRADE_RETCODE_TOO_MANY_REQUESTS: str="Слишком частые запросы"; break;
         case TRADE_RETCODE_NO_CHANGES: str="В запросе нет изменений"; break;
         case TRADE_RETCODE_SERVER_DISABLES_AT: str="Автотрейдинг запрещен сервером"; break;
         case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Автотрейдинг запрещен клиентским терминалом"; break;
         case TRADE_RETCODE_LOCKED: str="Запрос заблокирован для обработки"; break;
         case TRADE_RETCODE_FROZEN: str="Ордер или позиция заморожены"; break;
         case TRADE_RETCODE_INVALID_FILL: str="Указан неподдерживаемый тип исполнения ордера по остатку "; break;
         case TRADE_RETCODE_CONNECTION: str="Нет соединения с торговым сервером"; break;
         case TRADE_RETCODE_ONLY_REAL: str="Операция разрешена только для реальных счетов"; break;
         case TRADE_RETCODE_LIMIT_ORDERS: str="Достигнут лимит на количество отложенных ордеров"; break;
         case TRADE_RETCODE_LIMIT_VOLUME: str="Достигнут лимит на объем ордеров и позиций для данного символа"; break;
         default: str="Неизвестный результат";
        }
     }
//----
   return(str);
  }
//+------------------------------------------------------------------+
//| Select a position on the index                                   |
//+------------------------------------------------------------------+
bool CTradeBase::SelectByIndex(const int index)
  {
   ENUM_ACCOUNT_MARGIN_MODE margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
//---
   if(margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      ulong ticket=PositionGetTicket(index);
      if(ticket==0)
         return(false);
     }
   else
     {
      string name=PositionGetSymbol(index);
      if(name=="")
         return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Position select depending on netting or hedging                  |
//+------------------------------------------------------------------+
bool CTradeBase::SelectPosition(const string symbol,int MagicNumber)
  {
   bool res=false;
//---
   if(IsHedging())
     {
      uint total=PositionsTotal();
      for(uint i=0; i<total; i++)
        {
         string position_symbol=PositionGetSymbol(i);
         if(position_symbol==symbol && MagicNumber==PositionGetInteger(POSITION_MAGIC))
           {
            res=true;
            break;
           }
        }
     }
   else
      res=PositionSelect(symbol);
//---
   return(res);
  }
//+------------------------------------------------------------------+
