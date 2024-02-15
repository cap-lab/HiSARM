#ifndef __${robotId}_VARIABLE_HEADER__
#define __${robotId}_VARIABLE_HEADER__

#include "semo_variable.h"

<#list variableTypeList as variableType>
    <#if variableType.variableType.type.getValue() == "enum">
typedef enum _${robotId}_VARIABLE_TYPE_${variableType.variableType.name} {
        <#list variableType.variableType.candidate.candidates as candidate>
        SEMO_ENUM_${robotId}_${candidate},
        </#list>
} ${robotId}_VARIABLE_TYPE_${variableType.variableType.name};
    </#if>
</#list>

<#list variableList as variable>
extern VARIABLE ${robotId}_variable_${variable.id};
</#list>
extern VARIABLE ${robotId}_variable_leader;
extern VARIABLE ${robotId}_variable_group;
extern VARIABLE ${robotId}_variable_grouping_mode;
extern VARIABLE ${robotId}_variable_grouping_result;

#endif