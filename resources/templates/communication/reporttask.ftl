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
STATIC VARIABLE_${outPort.variableType.variableType.name} ${outPort.getVariableName()}[${outPort.variableType.variableType.count}];
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
    VARIABLE_${multicastPort.variableType.variableType.name} body[${multicastPort.variableType.variableType.count}];
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
    VARIABLE_${libPort.variableType.variableType.name} body[${libPort.variableType.variableType.count}];
    <#else>
    ${libPort.variableType.variableType.type.getValue()} body[${libPort.variableType.variableType.count}];
    </#if>
} ${libPort.library.name} = {{-1, THIS_ROBOT_ID}, {0,}};
#pragma pack(pop)
STATIC MULTICAST_PACKET packet_${libPort.library.name} = {&${libPort.library.name}.header, ${libPort.library.name}.body};
</#list>

</#if>
<#if channelPortMap?size gt 0>
// CHANNEL_PORT_SECTION
STATIC CHANNEL_PORT channel_port_list[${channelPortMap?size}] = {
<#list channelPortMap as outPort, inPort>
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
// LEADER PORT SECTION
STATIC LEADER_PORT leader_port_list[${leaderPortMap?size}] = {
    <#list leaderPortMap as robotIdPort, heartbeatPort>
    {"${robotIdPort.name}", -1, -1, {{-1, THIS_ROBOT_ID}, -1}, -1, l_${robotId}leader_avail_robot_id_report, l_${robotId}leader_get_robot_id_report, NULL,
    "${heartbeatPort.name}", -1, -1, {{-1, THIS_ROBOT_ID}, -1}, -1, l_${robotId}leader_avail_heartbeat_report, l_${robotId}leader_get_heartbeat_report, NULL, ID_GROUP_${robotIdPort.message}},
    </#list>
};

/////////////////////////////////////
// init code
/////////////////////////////////////
<#if channelPortMap?size gt 0>
STATIC void channel_port_init_() {
    for (int i = 0 ; i<sizeof(channel_port_list)/sizeof(CHANNEL_PORT) ; i++)
    {
        UFPort_Initialize(THIS_TASK_ID, channel_port_list[i].in_port_name, &(channel_port_list[i].in_port_id));
        UFPort_Initialize(THIS_TASK_ID, channel_port_list[i].out_port_name, &(channel_port_list[i].out_port_id));
    }
}

</#if>
<#if multicastPortMap?size gt 0>
STATIC void multicast_port_init_() {
    for (int i = 0 ; i<sizeof(multicast_port_list)/sizeof(MULTICAST_PORT) ; i++)
    {
        UFPort_Initialize(THIS_TASK_ID, multicast_port_list[i].channel_port_name, &(multicast_port_list[i].channel_port_id));
        UFMulticastPort_Initialize(THIS_TASK_ID, multicast_port_list[i].multicast_port_name, &(multicast_port_list[i].multicast_group_id), &(multicast_port_list[i].multicast_port_id));
    }
}

</#if>
<#if sharedDataPortMap?size gt 0>
STATIC void shared_data_port_init_() {
    for (int i = 0 ; i<sizeof(shared_data_port_list)/sizeof(SHARED_DATA_PORT) ; i++)
    {
        UFMulticastPort_Initialize(THIS_TASK_ID, shared_data_port_list[i].multicast_port_name, &(shared_data_port_list[i].multicast_group_id), &(shared_data_port_list[i].multicast_port_id));
    }
}

</#if>
STATIC void leader_port_init_() {
    for (int i = 0 ; i < sizeof(leader_port_list)/sizeof(LEADER_PORT) ; i++)
    {
        UFMulticastPort_Initialize(THIS_TASK_ID, leader_port_list[i].robot_id_port_name, &(leader_port_list[i].robot_id_group_id), &(leader_port_list[i].robot_id_port_id));
        UFMulticastPort_Initialize(THIS_TASK_ID, leader_port_list[i].heartbeat_port_name, &(leader_port_list[i].heartbeat_group_id), &(leader_port_list[i].heartbeat_port_id));
    }
}

TASK_INIT
{
	SEMO_LOG_INFO("INIT");
<#if channelPortMap?size gt 0>
    channel_port_init_(); 
</#if>
<#if multicastPortMap?size gt 0>
    multicast_port_init_();
</#if>
<#if sharedDataPortMap?size gt 0>
    shared_data_port_init_();
</#if>
    leader_port_init_();
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
    	if (channel_port_list[i].refreshed = TRUE) 
    	{
    	    if (channelPortWrite(channel_port_list[i].out_port_id, channel_port_list[i].buffer, channel_port_list[i].size, FALSE) > 0) 
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
STATIC void leader_port_send() {
    for (int i = 0 ; i < sizeof(leader_port_list)/sizeof(LEADER_PORT) ; i++)
    {
        if (leader_port_list[i].robot_id_avail_func(leader_port_list[i].group_id) == TRUE) 
        {
            int data_len;
            leader_port_list[i].robot_id_buffer.body = leader_port_list[i].robot_id_get_func(leader_port_list[i].group_id);
            UFTimer_GetCurrentTime(THIS_TASK_ID, &(leader_port_list[i].robot_id_buffer.header.time));
            UFMulticastPort_WriteToBuffer(leader_port_list[i].robot_id_group_id, leader_port_list[i].robot_id_port_id, (unsigned char * ) &(leader_port_list[i].robot_id_buffer), sizeof(LEADER_PACKET), &data_len);
        }
        if (leader_port_list[i].heartbeat_avail_func(leader_port_list[i].group_id) == TRUE) 
        {
            int data_len;
            leader_port_list[i].heartbeat_buffer.body = leader_port_list[i].heartbeat_get_func(leader_port_list[i].group_id);
            UFTimer_GetCurrentTime(THIS_TASK_ID, &(leader_port_list[i].heartbeat_buffer.header.time));
            UFMulticastPort_WriteToBuffer(leader_port_list[i].heartbeat_group_id, leader_port_list[i].heartbeat_port_id, (unsigned char * ) &(leader_port_list[i].heartbeat_buffer), sizeof(LEADER_PACKET), &data_len);
        }
    }
}

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
    leader_port_send();
}

/////////////////////////////////////
// wrapup code
/////////////////////////////////////

TASK_WRAPUP
{

}

TASK_CODE_END