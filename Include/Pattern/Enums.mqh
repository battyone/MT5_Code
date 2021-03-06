//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Candlestick type                                                 |
//+------------------------------------------------------------------+
enum TYPE_CANDLESTICK
  {
   CAND_NONE,           // Undefined
   CAND_MARIBOZU,       // Marubozu
   CAND_DOJI,           // Doji
   CAND_SPIN_TOP,       // Spinning tops
   CAND_HAMMER,         // Hammer
   CAND_INVERT_HAMMER,  // Inverted Hammer
   CAND_LONG,           // Long
   CAND_SHORT           // Short
  };
//+------------------------------------------------------------------+
//| Pattern type                                                     |
//+------------------------------------------------------------------+
enum TYPE_PATTERN
  {
   NONE,
   HUMMER,
   INVERT_HUMMER,
   HANDING_MAN,
   SHOOTING_STAR,
   ENGULFING_BULL,
   ENGULFING_BEAR,
   HARAMI_BULL,
   HARAMI_BEAR,
   HARAMI_CROSS_BULL,
   HARAMI_CROSS_BEAR,
   DOJI_STAR_BULL,
   DOJI_STAR_BEAR,
   PIERCING_LINE,
   DARK_CLOUD_COVER
  };
//+------------------------------------------------------------------+
//| Trend type                                                       |
//+------------------------------------------------------------------+
enum TYPE_TREND
  {
   UPPER,               //Uptrend
   DOWN,                //Downtrend
   FLAT                 //Flat
  };
//+------------------------------------------------------------------+
