#include "${robotId}_mode.h"
#include "${robotId}_port.h"
#include "semo_logger.h"

<#list modeList as mode>
    <#if mode.getArgumentMap()?size gt 0>
static VARIABLE_MAP variable_map_of_${mode.modeId}[] = {
        <#list mode.getArgumentMap() as argument, parameterList>
            <#list parameterList as parameter>
    {&variable_${argument.id}, &variable_${parameter.id}},
            </#list>
        </#list>
};
    </#if>
</#list>

// DEFINE MODE SERVICE LIST
<#list modeList as mode>
    <#if mode.serviceList?size gt 0>
static SERVICE_ID service_list_of_${mode.modeId}[${mode.serviceList?size}] = {
        <#list mode.serviceList as service>
    ID_SERVICE_${service.serviceId},
        </#list>
};
    </#if>
</#list>

// DEFINE MODE
MODE mode_list[${modeList?size}] = {
<#list modeList as mode>
    {
        ID_MODE_${mode.modeId}, // MODE_ID mode_id
        SEMO_STOP, // SEMO_STATE state
        <#if mode.getGroupCandidateList()?size gt 0>TRUE<#else>FALSE</#if>, // semo_int8 need_select_group
        -1, // GROUP_ID selected_group
        ${mode.getArgumentMap()?size}, // semo_int32 variable_map_list_size
        <#if mode.getArgumentMap()?size gt 0>variable_map_of_${mode.modeId}<#else>NULL</#if>, // VARIABLE_MAP *variable_map_list
        ${mode.serviceList?size}, // semo_int32 service_list_size
        <#if mode.serviceList?size gt 0>service_list_of_${mode.modeId}<#else>NULL</#if>, // SERVICE_ID *service_list
        ID_GROUP_${mode.groupId} // GROUP_ID group
    },
</#list>
};

void stop_mode(MODE_ID mode_id)
{
    SEMO_LOG_INFO("stop mode %d", mode_id);
    mode_list[mode_id].state = SEMO_STOP;
    for (int i = 0 ; i < mode_list[mode_id].service_list_size; i++)
    {
        stop_service(mode_list[mode_id].service_list[i]);
    }
    if (mode_list[mode_id].need_select_group == TRUE) {
        stop_selecting_group(mode_id, &mode_list[mode_id].selected_group);
    }
    set_group_state(mode_list[mode_id].group, SEMO_DECREASE);
    if (get_group_state(mode_list[mode_id].group) == 0) 
    {
        int dataLen;
        ((semo_int32 *)port_of_leader.variable->buffer)[0] = mode_list[mode_id].group;
        ((semo_int32 *)port_of_leader.variable->buffer)[1] = FALSE;
        UFPort_WriteToQueue(port_of_leader.port_id, (unsigned char *) port_of_leader.variable->buffer, port_of_leader.variable->size, 0, &dataLen);
    }
}

void run_mode(MODE_ID mode_id)
{
    int dataLen;
    SEMO_LOG_INFO("run mode %d", mode_id);
    mode_list[mode_id].state = SEMO_RUN;
    for (int i = 0 ; i < mode_list[mode_id].variable_map_list_size ; i++)
    {
        copy_variable(mode_list[mode_id].variable_map_list[i].src, mode_list[mode_id].variable_map_list[i].dst);
    }
    for (int i = 0 ; i < mode_list[mode_id].service_list_size; i++)
    {
        run_service(mode_list[mode_id].service_list[i], mode_list[mode_id].group);
    }
    if (mode_list[mode_id].need_select_group == TRUE) {
        register_group_selection(mode_id, &mode_list[mode_id].selected_group);
    }
    set_group_state(mode_list[mode_id].group, SEMO_INCREASE);
}
