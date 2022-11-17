#include "${robotId}_mode.h"

// DEFINE MODE SERVICE LIST
<#list modeList as mode>
SERVICE_ID service_list_of_${mode.modeId}[${mode.serviceList?size}] = {
    <#list mode.serviceList as service>
    ID_SERVICE_${service.serviceId},
    </#list>
};
</#list>

// DEFINE MODE
MODE_INFO mode_list[${modeList?size}] = {
<#list modeList as mode>
    {ID_MODE_${mode.modeId}, STOP, ${mode.serviceList?size}, service_list_of_${mode.modeId}, ID_GROUP_${mode.groupId}},
</#list>
};

void stop_mode(MODE_ID mode_id)
{
    mode_list[mode_id].state = STOP;
    for (int i = 0 ; i < mode_list[mode_id].service_list_size; i++)
    {
        stop_service(mode_list[mode_id].service_list[i]);
    }
    group_state_list[group_list[0]] = group_state_list[group_list[0]] - 1;
    if (group_state_list[mode_list[mode_id].group] == 0) 
    {
        int dataLen;
        ((semo_int32 *)port_of_leader.variable->buffer)[0] = group_list[0];
        ((semo_int32 *)port_of_leader.variable->buffer)[1] = FALSE;
        UFPort_WriteToQueue(port_of_leader.portId, (unsigend char *) port_of_leader.variable->buffer, port_of_leader.variable->size, 0, &dataLen);
    }
}

void run_mode(MODE_ID mode_id)
{
    mode_list[mode_id].state = RUN;
    for (int i = 0 ; i < mode_list[mode_id].service_list_size; i++)
    {
        run_service(mode_list[mode_id].service_list[i], group_scope);
    }
    if (group_state_list[mode_list[mode_id].group] == 0) 
    {
        int dataLen;
        ((semo_int32 *)port_of_leader.variable->buffer)[0] = group_list[0];
        ((semo_int32 *)port_of_leader.variable->buffer)[1] = TRUE;
        UFPort_WriteToQueue(port_of_leader.portId, (unsigend char *) port_of_leader.variable->buffer, port_of_leader.variable->size, 0, &dataLen);
    }
    group_state_list[group_list[0]] = group_state_list[group_list[0]] + 1;
}