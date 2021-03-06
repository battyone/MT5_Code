//+------------------------------------------------------------------+
//|                                                   BaseFilter.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//|         当前市场状态不同的映射结果枚举                           |
//+------------------------------------------------------------------+
enum ENUM_MAPPING_TYPE
  {
   MAPPING_NULL,// 不需要映射
   MAPPING_NO_OPERATE,// 映射不操作
   MAPPING_LONG_OPERATE,   // 映射做多
   MAPPING_SHORT_OPERATE,  // 映射做空
  }; 
//+------------------------------------------------------------------+
//|               基础过滤器                                         |
//+------------------------------------------------------------------+
class CBaseFilter
  {
protected:
   string            symbol;  // 品种
   int               total_filter;  // filter产生的类别总数
   ENUM_MAPPING_TYPE m_type[];   // filter不同类别对应不同Mapping的映射关系
   string            m_comment[];   // 每种映射的注释
public:
                     CBaseFilter(void){};
                    ~CBaseFilter(void){};
   void              SetSymbol(string sym); // 设置分类器的品种
   void              SetTotalFilterNum(int total); // 设置filter类别总数
   int               GetTotalFilterNum(); // 获取filter类别总数
   void              InitTypeValue(ENUM_MAPPING_TYPE mt=MAPPING_NO_OPERATE);  // 使用指定值初始化类别映射关系
   void              SetMappingTypeAt(int index,ENUM_MAPPING_TYPE type_m);  // 对指定索引做映射
  };
void CBaseFilter::SetSymbol(string sym)
   {
    symbol=sym;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseFilter::SetTotalFilterNum(int total)
  {
   total_filter=total;
   ArrayResize(m_type,total_filter);
   ArrayResize(m_comment,total_filter);
  }
int CBaseFilter::GetTotalFilterNum(void)
   {
    return total_filter;
   } 
void CBaseFilter::InitTypeValue(ENUM_MAPPING_TYPE mt=MAPPING_NO_OPERATE)
   {
    ArrayInitialize(m_type,mt);
   }    
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseFilter::SetMappingTypeAt(int index,ENUM_MAPPING_TYPE type_m)
  {
   m_type[index]=type_m;
  }
//+------------------------------------------------------------------+
