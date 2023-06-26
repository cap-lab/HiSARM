/////////////////////////////////////
// include header section
/////////////////////////////////////

// ##DEFINE_SECTION::START
#include "UFTimer.h"
// ##DEFINE_SECTION::END

TASK_CODE_BEGIN

/////////////////////////////////////
// global definition
/////////////////////////////////////
<#if channelPortMap?size gt 0>
// CHANNEL VARIABLE DEFINE
<#list channelPortMap as outPort, inPort>
    <#if outPort.variableType.variableType.type.getValue() == "enum">
STATIC VARIABLE_TYPE_${outPort.variableType.variableType.name} ${outPort.getVariableName()}[${outPort.variableType.variableType.count}];
    <#else>
STATIC ${outPort.variableType.variableType.type.getValue()} ${outPort.getVariableName()}[${outPort.variableType.variableType.count}];
    </#if>
</#list>

</#if>
<#if multicastPortMap?size gt 0>
// MULTICAST VARIABLE DEFINE
<#list multicastPortMap as channelPort, multicastPort>
#pragma pack(push, 1)
STATIC struct _${multicastPort.getVariableName()} {
    MULTICAST_PACKET_HEADER header;
    <#if multicastPort.variableType.variableType.type.getValue() == "enum">
    VARIABLE_TYPE_${multicastPort.variableType.variableType.name} body[${multicastPort.variableType.variableType.count}];
    <#else>
    ${multicastPort.variableType.variableType.type.getValue()} body[${multicastPort.variableType.variableType.count}];
    </#if>
} ${multicastPort.getVariableName()} = {{-1, THIS_ROBOT_ID}, {0,}};
#pragma pack(pop)
STATIC MULTICAST_PACKET packet_${multicastPort.getVariableName()} = {&${multicastPort.getVariableName()}.header, ${multicastPort.getVariableName()}.body};
</#list>

</#if>
<#if sharedDataPortMap?size gt 0>
// SHARED DATA VARIABLE DEFINE
<#list sharedDataPortMap as libPort, multicastPort>
#pragma pack(push, 1)
STATIC struct _${libPort.library.name} {
    MULTICAST_PACKET_HEADER header;
    <#if libPort.library.variableType.variableType.type.getValue() == "enum">
    VARIABLE_TYPE_${libPort.variableType.variableType.name} body[${libPort.variableType.variableType.count}];
    <#else>
    ${libPort.variableType.variableType.type.getValue()} body[${libPort.variableType.variableType.count}];
    </#if>
} ${libPort.library.name} = {{-1, THIS_ROBOT_ID}, {0,}};
#pragma pack(pop)
STATIC MULTICAST_PACKET packet_${libPort.library.name} = {&${libPort.library.name}.header, ${libPort.library.name}.body};
</#list>

</#if>
<#if groupActionPortList?size gt 0>
// GROUP ACTION VARIABLE DEFINE
<#list groupActionPortList as multicastPort>
#pragma pack(push, 1)
STATIC struct _group_action_${multicastPort.message} {
    MULTICAST_PACKET_HEADER header;
    semo_int32 body[1];
} group_action_${multicastPort.message} = {{-1, THIS_ROBOT_ID}, {${multicastPort.message}}};
#pragma pack(pop)
STATIC MULTICAST_PACKET packet_group_action_${multicastPort.message} = {&group_action_${multicastPort.message}.header, group_action_${multicastPort.message}.body};
</#list>

</#if>
// LEADER VARIABLE DEFINE
<#list leaderPortMap as robotIdPort, heartbeatPort>
#pragma pack(push, 1)
STATIC struct _${robotIdPort.getVariableName()} {
    MULTICAST_PACKET_HEADER header;
    semo_int32 body[1];
} ${robotIdPort.getVariableName()} = {{-1, THIS_ROBOT_ID}, {0}};
#pragma pack(pop)
STATIC MULTICAST_PACKET packet_${robotIdPort.getVariableName()} = {&${robotIdPort.getVariableName()}.header, ${robotIdPort.getVariableName()}.body};
#pragma pack(push, 1)
STATIC struct _${heartbeatPort.getVariableName()} {
    MULTICAST_PACKET_HEADER header;
    semo_int32 body[1];
} ${heartbeatPort.getVariableName()} = {{-1, THIS_ROBOT_ID}, {0}};
#pragma pack(pop)
STATIC MULTICAST_PACKET packet_${heartbeatPort.getVariableName()} = {&${heartbeatPort.getVariableName()}.header, ${heartbeatPort.getVariableName()}.body};
</#list>

<#if groupingPortList?size gt 0>
// GROUPING VARIABLE DEFINE
#pragma pack(push, 1)
STATIC struct _grouping {
    GROUPING_PACKET_HEADER header;
    semo_int32 robot_num;
    SEMO_GROUPING_SHARED robot_info_list[${maxRobotNum}];
    semo_uint8 body[${groupingLibPort.library.sharedDataSize*maxRobotNum}];
} grouping = {{-1, THIS_ROBOT_ID, -1}, 0,};
#pragma pack(pop)
STATIC GROUPING_PACKET packet_grouping = {&grouping.header, &grouping.robot_num, grouping.robot_info_list, grouping.body};

</#if>
<#if channelPortMap?size gt 0>
// CHANNEL_PORT_SECTION
STATIC CHANNEL_PORT channel_port_list[${channelPortMap?size}] = {
<#list channelPortMap as inPort, outPort>
    {"${inPort.name}", -1, "${outPort.name}", -1, ${outPort.getVariableName()}, ${outPort.sampleSize}, FALSE}, 
</#list>
};

</#if>
<#if multicastPortMap?size gt 0>
// MULTICAST PORT SECTION
STATIC MULTICAST_PORT multicast_port_list[${multicastPortMap?size}] = {
<#list multicastPortMap as channelPort, multicastPort>
    {"${multicastPort.name}", -1, -1, "${channelPort.name}", -1,  &${multicastPort.getVariableName()}, &packet_${multicastPort.getVariableName()}, ${multicastPort.variableType.getSize()}, -1},
</#list>
};

</#if>
<#if sharedDataPortMap?size gt 0>
// GROUP SERVICE PORT SECTION
STATIC SHARED_DATA_PORT shared_data_port_list[${sharedDataPortMap?size}] = {
<#list sharedDataPortMap as libPort, multicastPort>
    {"${multicastPort.name}", -1, -1, l_${libPort.library.name}_avail_${libPort.variableType.variableType.name}_report, l_${libPort.library.name}_get_${libPort.variableType.variableType.name}_report, NULL, &${libPort.library.name}, &packet_${libPort.library.name}, ${libPort.variableType.getSize()}, -1},
</#list>
};

</#if>
<#if groupActionPortList?size gt 0>
// GROUP ACTION PORT SECTION
STATIC GROUP_ACTION_PORT group_action_port_list[${groupActionPortList?size}] = {
<#list groupActionPortList as multicastPort>
    {"${multicastPort.name}", -1, -1, l_${robotId}_group_action_avail_group_action_report, NULL, &group_action_${multicastPort.message}, &packet_group_action_${multicastPort.message}, 4, -1},
</#list>
};

</#if>
// LEADER PORT SECTION
STATIC LEADER_PORT leader_port_list[${leaderPortMap?size}] = {
    <#list leaderPortMap as robotIdPort, heartbeatPort>
    {"${robotIdPort.name}", -1, -1, &${robotIdPort.getVariableName()}, &packet_${robotIdPort.getVariableName()}, -1, l_${robotId}_leader_avail_robot_id_report, l_${robotId}_leader_get_robot_id_report, NULL,
    "${heartbeatPort.name}", -1, -1, &${heartbeatPort.getVariableName()}, &packet_${heartbeatPort.getVariableName()}, -1, l_${robotId}_leader_avail_heartbeat_report, l_${robotId}_leader_get_heartbeat_report, NULL, ID_GROUP_${robotIdPort.message}, 16},
    </#list>
};

<#if groupingPortList?size gt 0>
// GROUP SERVICE PORT SECTION
STATIC GROUPING_PORT grouping_port_list[${groupingPortList?size}] = {
<#list groupingPortList as multicastPort>
    {"${multicastPort.name}", -1, -1, l_${robotId}_grouping_avail_shared_data_report, l_${robotId}_grouping_get_shared_data_report, NULL, &grouping, &packet_grouping, ${groupingLibPort.library.sharedDataSize}, -1},
</#list>
};

</#if>
/////////////////////////////////////
// init code
/////////////////////////////////////
<#if channelPortMap?size gt 0>
STATIC void channel_port_init() {
    for (int i = 0 ; i<sizeof(channel_port_list)/sizeof(CHANNEL_PORT) ; i++)
    {
        UFPort_Initialize(THIS_TASK_ID, channel_port_list[i].in_port_name, &(channel_port_list[i].in_port_id));
        UFPort_Initialize(THIS_TASK_ID, channel_port_list[i].out_port_name, &(channel_port_list[i].out_port_id));
    }
}

</#if>
<#if multicastPortMap?size gt 0>
STATIC void multicast_port_init() {
    for (int i = 0 ; i<sizeof(multicast_port_list)/sizeof(MULTICAST_PORT) ; i++)
    {
        UFPort_Initialize(THIS_TASK_ID, multicast_port_list[i].channel_port_name, &(multicast_port_list[i].channel_port_id));
        UFMulticastPort_Initialize(THIS_TASK_ID, multicast_port_list[i].multicast_port_name, &(multicast_port_list[i].multicast_group_id), &(multicast_port_list[i].multicast_port_id));
    }
}

</#if>
<#if sharedDataPortMap?size gt 0>
STATIC void shared_data_port_init() {
    for (int i = 0 ; i<sizeof(shared_data_port_list)/sizeof(SHARED_DATA_PORT) ; i++)
    {
        UFMulticastPort_Initialize(THIS_TASK_ID, shared_data_port_list[i].multicast_port_name, &(shared_data_port_list[i].multicast_group_id), &(shared_data_port_list[i].multicast_port_id));
    }
}

</#if>
<#if groupActionPortList?size gt 0>
STATIC void group_action_port_init() {
    for (int i = 0 ; i<sizeof(group_action_port_list)/sizeof(GROUP_ACTION_PORT) ; i++)
    {
        UFMulticastPort_Initialize(THIS_TASK_ID, group_action_port_list[i].multicast_port_name, &(group_action_port_list[i].multicast_group_id), &(group_action_port_list[i].multicast_port_id));
    }
}

</#if>
STATIC void leader_port_init() {
    for (int i = 0 ; i < sizeof(leader_port_list)/sizeof(LEADER_PORT) ; i++)
    {
        UFMulticastPort_Initialize(THIS_TASK_ID, leader_port_list[i].robot_id_port_name, &(leader_port_list[i].robot_id_group_id), &(leader_port_list[i].robot_id_port_id));
        UFMulticastPort_Initialize(THIS_TASK_ID, leader_port_list[i].heartbeat_port_name, &(leader_port_list[i].heartbeat_group_id), &(leader_port_list[i].heartbeat_port_id));
    }
}
<#if groupingPortList?size gt 0>
STATIC void grouping_port_init() {
    for (int i = 0 ; i<sizeof(grouping_port_list)/sizeof(GROUPING_PORT) ; i++)
    {
        UFMulticastPort_Initialize(THIS_TASK_ID, grouping_port_list[i].multicast_port_name, &(grouping_port_list[i].multicast_group_id), &(grouping_port_list[i].multicast_port_id));
    }
}

</#if>
TASK_INIT
{
	SEMO_LOG_INFO("INIT");
<#if channelPortMap?size gt 0>
    channel_port_init(); 
</#if>
<#if multicastPortMap?size gt 0>
    multicast_port_init();
</#if>
<#if sharedDataPortMap?size gt 0>
    shared_data_port_init();
</#if>
<#if groupActionPortList?size gt 0>
    group_action_port_init();
</#if>
    leader_port_init();
<#if groupingPortList?size gt 0>
    grouping_port_init();
</#if>
}

/////////////////////////////////////
// go code
/////////////////////////////////////
<#if channelPortMap?size gt 0>
STATIC void channel_port_send() {
    int data_len = 0;
    
    for (int i = 0 ; i<sizeof(channel_port_list)/sizeof(CHANNEL_PORT) ; i++)
    {
    	if (channel_port_read(channel_port_list[i].in_port_id, channel_port_list[i].buffer, channel_port_list[i].size, FALSE) > 0) 
    	{
    	    channel_port_list[i].refreshed = TRUE;
    	}
    	if (channel_port_list[i].refreshed == TRUE) 
    	{
    	    if (channel_port_write(channel_port_list[i].out_port_id, channel_port_list[i].buffer, channel_port_list[i].size, FALSE) > 0) 
    	    {
    	        channel_port_list[i].refreshed = FALSE;
    	    }
    	}    	    
    }
}

</#if>
<#if multicastPortMap?size gt 0>
STATIC void multicast_port_send() {
    for (int i = 0 ; i<sizeof(multicast_port_list)/sizeof(MULTICAST_PORT) ; i++)
    {
        if (channel_port_read(multicast_port_list[i].channel_port_id, multicast_port_list[i].packet->data, multicast_port_list[i].size, FALSE) > 0) 
        {
            int data_len;
        	UFTimer_GetCurrentTime(THIS_TASK_ID, &(multicast_port_list[i].packet->header->time));
        	UFMulticastPort_WriteToBuffer(multicast_port_list[i].multicast_group_id, multicast_port_list[i].multicast_port_id, (unsigned char * ) multicast_port_list[i].buffer, multicast_port_list[i].size + sizeof(MULTICAST_PACKET_HEADER), &data_len);
        }
    }
}

</#if>
<#if sharedDataPortMap?size gt 0>
STATIC void shared_data_port_send() {
    for (int i = 0 ; i<sizeof(shared_data_port_list)/sizeof(SHARED_DATA_PORT) ; i++)
    {
        if (shared_data_port_list[i].lib_avail_func() == TRUE) 
        {
            int data_len;
            shared_data_port_list[i].lib_get_func(shared_data_port_list[i].packet->data);
            UFTimer_GetCurrentTime(THIS_TASK_ID, &(shared_data_port_list[i].packet->header->time));
            UFMulticastPort_WriteToBuffer(shared_data_port_list[i].multicast_group_id, shared_data_port_list[i].multicast_port_id, (unsigned char * ) shared_data_port_list[i].buffer, shared_data_port_list[i].size + sizeof(MULTICAST_PACKET_HEADER), &data_len);
        }
    }
}

</#if>
<#if groupActionPortList?size gt 0>
STATIC void group_action_port_send() {
    for (int i = 0 ; i<sizeof(group_action_port_list)/sizeof(GROUP_ACTION_PORT) ; i++)
    {
        if (group_action_port_list[i].lib_avail_func(*(int*)group_action_port_list[i].packet->data) == TRUE) 
        {
            int data_len;
            UFTimer_GetCurrentTime(THIS_TASK_ID, &(group_action_port_list[i].packet->header->time));
            UFMulticastPort_WriteToBuffer(group_action_port_list[i].multicast_group_id, group_action_port_list[i].multicast_port_id, (unsigned char * ) group_action_port_list[i].buffer, group_action_port_list[i].size + sizeof(MULTICAST_PACKET_HEADER), &data_len);
        }
    }
}

</#if>
STATIC void leader_port_send() {
    for (int i = 0 ; i < sizeof(leader_port_list)/sizeof(LEADER_PORT) ; i++)
    {
        if (leader_port_list[i].robot_id_avail_func(leader_port_list[i].group_id) == TRUE) 
        {
            int data_len;
            *(int*)leader_port_list[i].robot_id_packet->data = leader_port_list[i].robot_id_get_func(leader_port_list[i].group_id);
            UFTimer_GetCurrentTime(THIS_TASK_ID, &(leader_port_list[i].robot_id_packet->header->time));
            UFMulticastPort_WriteToBuffer(leader_port_list[i].robot_id_group_id, leader_port_list[i].robot_id_port_id, (unsigned char * ) leader_port_list[i].robot_id_buffer, leader_port_list[i].size, &data_len);
        }
        if (leader_port_list[i].heartbeat_avail_func(leader_port_list[i].group_id) == TRUE) 
        {
            int data_len;
            *(int*)leader_port_list[i].heartbeat_packet->data = leader_port_list[i].heartbeat_get_func(leader_port_list[i].group_id);
            UFTimer_GetCurrentTime(THIS_TASK_ID, &(leader_port_list[i].heartbeat_packet->header->time));
            UFMulticastPort_WriteToBuffer(leader_port_list[i].heartbeat_group_id, leader_port_list[i].heartbeat_port_id, (unsigned char * ) leader_port_list[i].heartbeat_buffer, leader_port_list[i].size, &data_len);
        }
    }
}

<#if groupingPortList?size gt 0>
STATIC void grouping_port_send() {
    for (int i = 0 ; i<sizeof(grouping_port_list)/sizeof(GROUPING_PORT) ; i++)
    {
        if (grouping_port_list[i].lib_avail_func() == TRUE) 
        {
            int data_len;
            grouping_port_list[i].lib_get_func(&grouping_port_list[i].packet->header->mode_id, grouping_port_list[i].packet->robot_info_list, grouping_port_list[i].packet->shared_robot_num, grouping_port_list[i].packet->data, grouping_port_list[i].size);
            UFTimer_GetCurrentTime(THIS_TASK_ID, &(grouping_port_list[i].packet->header->time));
            UFMulticastPort_WriteToBuffer(grouping_port_list[i].multicast_group_id, grouping_port_list[i].multicast_port_id, (unsigned char * ) grouping_port_list[i].buffer, sizeof(grouping), &data_len);
        }
    }
}

</#if>
TASK_GO
{
<#if channelPortMap?size gt 0>
    channel_port_send();
</#if>
<#if multicastPortMap?size gt 0>
    multicast_port_send();
</#if>
<#if sharedDataPortMap?size gt 0>
    shared_data_port_send();
</#if>
<#if groupActionPortList?size gt 0>
    group_action_port_send();
</#if>
    leader_port_send();
<#if groupingPortList?size gt 0>
    grouping_port_send();
</#if>
}

/////////////////////////////////////
// wrapup code
/////////////////////////////////////

TASK_WRAPUP
{

}

TASK_CODE_END