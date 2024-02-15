#include "semo_logger.h"
#include "${robotId}_mode.h"
#include "${robotId}_variable.h"
#include "${robotId}_service.h"
#include "${robotId}_group.h"
#include "${robotId}_port.h"

<#list modeList as mode>
    <#if mode.getArgumentMap()?size gt 0>
static VARIABLE_MAP ${robotId}_variable_map_of_${mode.modeId}[] = {
        <#list mode.getArgumentMap() as argument, parameterList>
            <#list parameterList as parameter>
    {&${robotId}_variable_${argument.id}, &${robotId}_variable_${parameter.id}},
            </#list>
        </#list>
};
    </#if>
</#list>

// DEFINE MODE SERVICE LIST
<#list modeList as mode>
    <#if mode.serviceList?size gt 0>
static semo_int32 ${robotId}_service_list_of_${mode.modeId}[${mode.serviceList?size}] = {
        <#list mode.serviceList as service>
    ID_SERVICE_${robotId}_${service.serviceId},
        </#list>
};
    </#if>
</#list>

// DEFINE MODE
MODE ${robotId}_mode_list[${modeList?size}] = {
<#list modeList as mode>
    {
        ID_MODE_${robotId}_${mode.modeId}, // MODE_ID mode_id
        SEMO_STOP, // SEMO_STATE state
        <#if mode.getGroupCandidateList()?size gt 0>TRUE<#else>FALSE</#if>, // semo_int8 need_select_group
        -1, // GROUP_ID selected_group
        ${mode.getArgumentMap()?size}, // semo_int32 variable_map_list_size
        <#if mode.getArgumentMap()?size gt 0>${robotId}_variable_map_of_${mode.modeId}<#else>NULL</#if>, // VARIABLE_MAP *variable_map_list
        ${mode.serviceList?size}, // semo_int32 service_list_size
        <#if mode.serviceList?size gt 0>${robotId}_service_list_of_${mode.modeId}<#else>NULL</#if>, // SERVICE_ID *service_list
        ID_GROUP_${robotId}_${mode.groupId} // GROUP_ID group
    },
</#list>
};

void ${robotId}_mode_init(MODE_CLASS *mode_class, SERVICE_CLASS *service_class, LEADER_CLASS *leader_class, GROUP_CLASS *group_class) {
    SEMO_LOG_INFO("mode init");
    mode_class->mode_list = ${robotId}_mode_list;
    mode_class->mode_list_size = ${modeList?size};
    mode_class->port_of_leader = &${robotId}_port_of_leader;
    mode_class->service_class = service_class;
    mode_class->leader_class = leader_class;
    mode_class->group_class = group_class;
}