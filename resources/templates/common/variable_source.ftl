#include "${robotId}_variable.h"
#include "${robotId}_team.h"
#include "semo_common.h"

// VARIABLE BUFFER DEFINE
<#list variableList as variable>
    <#if variable.type.variableType.type.getValue() == "enum">
VARIABLE_TYPE_${variable.type.variableType.name} variable_buffer_of_${variable.id}[${variable.type.variableType.count}]<#if variable.defaultValue?has_content> = {SEMO_ENUM_${variable.defaultValue}}</#if>;
    <#else>
${variable.type.variableType.type.getValue()} variable_buffer_of_${variable.id}[${variable.type.variableType.count}]<#if variable.defaultValue?has_content> = {${variable.defaultValue}}</#if>;
    </#if>
</#list>
semo_int32 variable_buffer_of_leader[2];
semo_int32 variable_buffer_of_group[1];
semo_int32 variable_buffer_of_grouping_mode[1];
semo_int32 variable_buffer_of_grouping_result[1];

// VARIABLE RELATION DEFINE
<#list variableList as variable>
    <#if variable.childVariableList?size gt 0>
void *variable_relation_of_${variable.id}[${variable.type.variableType.count}] = {
        <#list variable.childVariableList as childVariable>
    variable_buffer_of_${childVariable.id},
        </#list>
};
    </#if>
</#list>

// VARIABLE DEFINE
<#list variableList as variable>
VARIABLE variable_${variable.id} = {
    ${variable.type.variableType.size}, variable_buffer_of_${variable.id}, ${variable.getChildVariableType().getVariableType().getSize()}, ${variable.childVariableList?size}, <#if variable.childVariableList?size gt 0>variable_relation_of_${variable.id}<#else>NULL</#if>
};
</#list>
VARIABLE variable_leader = {
    8, variable_buffer_of_leader, 0, 0, NULL
};
VARIABLE variable_group = {
    4, variable_buffer_of_group, 0, 0, NULL
};
VARIABLE variable_grouping_mode = {
    4, variable_buffer_of_grouping_mode, 0, 0, NULL
};
VARIABLE variable_grouping_result = {
    4, variable_buffer_of_grouping_result, 0, 0, NULL
};
