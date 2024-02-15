#include "${robotId}_variable.h"
#include "${robotId}_team.h"
#include "semo_common.h"

// VARIABLE BUFFER DEFINE
<#list variableList as variable>
    <#if variable.type.variableType.type.getValue() == "enum">
${robotId}_VARIABLE_TYPE_${variable.type.variableType.name} ${robotId}_variable_buffer_of_${variable.id}[${variable.type.variableType.count}]<#if variable.defaultValue?has_content> = {SEMO_ENUM_${robotId}_${variable.defaultValue}}</#if>;
    <#else>
${variable.type.variableType.type.getValue()} ${robotId}_variable_buffer_of_${variable.id}[${variable.type.variableType.count}]<#if variable.defaultValue?has_content> = {${variable.defaultValue}}</#if>;
    </#if>
</#list>
semo_int32 ${robotId}_variable_buffer_of_leader[2];
semo_int32 ${robotId}_variable_buffer_of_group[1];
semo_int32 ${robotId}_variable_buffer_of_grouping_mode[1];
semo_int32 ${robotId}_variable_buffer_of_grouping_result[1];

// VARIABLE RELATION DEFINE
<#list variableList as variable>
    <#if variable.childVariableList?size gt 0>
void *${robotId}_variable_relation_of_${variable.id}[${variable.type.variableType.count}] = {
        <#list variable.childVariableList as childVariable>
    ${robotId}_variable_buffer_of_${childVariable.id},
        </#list>
};
    </#if>
</#list>

// VARIABLE DEFINE
<#list variableList as variable>
VARIABLE ${robotId}_variable_${variable.id} = {
    ${variable.type.variableType.size}, ${robotId}_variable_buffer_of_${variable.id}, ${variable.getChildVariableType().getVariableType().getSize()}, ${variable.childVariableList?size}, <#if variable.childVariableList?size gt 0>${robotId}_variable_relation_of_${variable.id}<#else>NULL</#if>
};
</#list>
VARIABLE ${robotId}_variable_leader = {
    8, ${robotId}_variable_buffer_of_leader, 0, 0, NULL
};
VARIABLE ${robotId}_variable_group = {
    4, ${robotId}_variable_buffer_of_group, 0, 0, NULL
};
VARIABLE ${robotId}_variable_grouping_mode = {
    4, ${robotId}_variable_buffer_of_grouping_mode, 0, 0, NULL
};
VARIABLE ${robotId}_variable_grouping_result = {
    4, ${robotId}_variable_buffer_of_grouping_result, 0, 0, NULL
};
