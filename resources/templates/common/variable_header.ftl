#ifndef __${robotId}_VARIABLE_HEADER__
#define __${robotId}_VARIABLE_HEADER__

#include "semo_variable.h"

<#list variableTypeList as variableType>
    <#if variableType.variableType.type.getValue() == "enum">
typedef enum _VARIABLE_TYPE_${variableType.variableType.name} {
        <#list variableType.variableType.candidate.candidates as candidate>
        SEMO_ENUM_${candidate},
        </#list>
} VARIABLE_TYPE_${variableType.variableType.name};
    </#if>
</#list>

<#list variableList as variable>
extern VARIABLE variable_${variable.id};
</#list>
extern VARIABLE variable_leader;
extern VARIABLE variable_group;
extern VARIABLE variable_grouping_mode;
extern VARIABLE variable_grouping_result;

#endif