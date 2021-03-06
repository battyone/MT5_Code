//+------------------------------------------------------------------+
//|                                                 BaseClassify.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Object.mqh>
//+------------------------------------------------------------------+
//|                 分类器更新分类的触发事件                         |
//+------------------------------------------------------------------+
enum ClassifyRefreshEventType
  {
   ENUM_CLASSIFY_REFRESH_BAR, // BAR上更新分类结果
   ENUM_CLASSIFY_REFRESH_TICK // tick事件上更新分类结果
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBaseClassify:public CObject
  {
protected:
   string            c_name;  // 分类器名称
   int               total_class;  // 类别总数
   int               class_result;  // 当前的分类结果
   ClassifyRefreshEventType cret; // 分类器更新方式(tick触发还是bar触发)
   string            symbol;
   ENUM_TIMEFRAMES   period;
   MqlTick           latest_tick;   // 最新的tick
   MqlRates          rates[]; // bar数据
   string            class_comment[];  // 类别注释
public:
                     CBaseClassify(void){};
                    ~CBaseClassify(void){};
   virtual void      SetTotal(int total);
   int               GetTotal();
   ClassifyRefreshEventType GetClasssifyRefreshType();   // 获取分类器的更新方式
   virtual void      CalClassifyResult(){};  // 计算当前的分类器的分类结果
   int               GetClassifyResult(); // 返回当前的分类器的分类结果
   string            GetClassComment();   // 获取当前分类器分类结果指定索引的注释
   string            GetClassComment(int index);   // 获取分类器指定索引的注释
   void              SetClassifyName(string name);
   string            GetClassifyName();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseClassify::SetTotal(int total)
  {
   total_class=total;
   ArrayResize(class_comment,total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBaseClassify::GetTotal(void)
  {
   return total_class;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ClassifyRefreshEventType CBaseClassify::GetClasssifyRefreshType(void)
  {
   return cret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBaseClassify::GetClassifyResult(void)
  {
   return class_result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CBaseClassify::GetClassComment(void)
  {
   return class_comment[class_result];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CBaseClassify::GetClassComment(int index)
  {
   return class_comment[index];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseClassify::SetClassifyName(string name)
  {
   c_name=name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CBaseClassify::GetClassifyName(void)
  {
   return c_name;
  }
//+------------------------------------------------------------------+
