#include "${robotId}_variable.h"
#include "semo_common.h"

// VARIABLE BUFFER DEFINE
<#list variableList as variable>
    <#if variable.type.variableType.type.getValue() == "enum">
VARIABLE_TYPE_${variable.type.variableType.name} variable_buffer_of_${variable.id}[${variable.type.variableType.count}]<#if variable.defaultValue?has_content> = {<#list variable.defaultValue as value> ${value},</#list>}</#if>;
    <#else>
${variable.type.variableType.type.getValue()} variable_buffer_of_${variable.id}[${variable.type.variableType.count}]<#if variable.defaultValue?has_content> = {<#list variable.defaultValue as value> ${value},</#list>}</#if>;
    </#if>
</#list>
int32 variable_buffer_of_leader[2];
int32 variable_buffer_of_group[1];

// VARIABEL RELATION DEFINE
<#list variableList as variable>
    <#if variable.childVariableList?size gt 0>
void variable_relation_of_${variable.id}[${variable.type.variableType.count}] = {
        <#list variable.childVariableList as childVariable>
    variable_buffer_of_${childVariable.id}},
        </#list>
};
    </#if>
</#list>

// VARIABLE DEFINE
<#list variableList as variable>
VARIABLE variable_${variable.id} = {
    ${variable.type.variableType.size}, variable_buffer_of_${variable.id}, ${variable.getChildVariableType().getVariableType().getSize()}, ${variable.childVariableList?size}, variable_relation_of_${variable.id}
};
</#list>
VARIABLE variable_leader = {
    8, variable_buffer_of_leader, 0, 0, NULL
};
VARIABLE variable_group = {
    4, variable_buffer_of_group, 0, 0, NULL
};