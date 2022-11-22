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
<#list channelPortMap as inPort, outPort>
    <#if inPort.variableType.variableType.type.getValue() == "enum">
STATIC VARIABLE_${inPort.variableType.variableType.name} ${inPort.getVariableName()}[${inPort.variableType.variableType.count}];
    <#else>
STATIC ${inPort.variableType.variableType.type.getValue()} ${inPort.getVariableName()}[${inPort.variableType.variableType.count}];
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
} ${multicastPort.getVariableName()} = {{-1, -1}, {0,}};
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
} ${libPort.library.name} = {{-1, -1}, {0,}};
#pragma pack(pop)
STATIC MULTICAST_PACKET packet_${libPort.library.name} = {&${libPort.library.name}.header, ${libPort.library.name}.body};
</#list>

</#if>
<#if channelPortMap?size gt 0>
// CHANNEL PORT SECTION
STATIC CHANNEL_PORT channel_port_list[${channelPortMap?size}] = {
<#list channelPortMap as inPort, outPort>
    {"${inPort.name}", -1, "${outPort.name}", -1, ${inPort.getVariableName()}, ${inPort.sampleSize}, FALSE}, 
</#list>
};

</#if>
<#if multicastPortMap?size gt 0>
// MULTICAST PORT SECTION
STATIC MULTICAST_PORT multicast_port_list[${multicastPortMap?size}] = {
<#list multicastPortMap as channelPort, multicastPort>
    {"${multicastPort.name}", -1, -1, "${channelPort.name}", -1, &${multicastPort.getVariableName()}, &packet_${multicastPort.getVariableName()}, ${multicastPort.variableType.getSize()}, -1},
</#list>
};

</#if>
<#if sharedDataPortMap?size gt 0>
// SHARED DATA PORT SECTION
STATIC SHARED_DATA_PORT shared_data_port_list[${sharedDataPortMap?size}] = {
<#list sharedDataPortMap as libPort, multicastPort>
    {"${multicastPort.name}", -1, -1, NULL, NULL, l_${libPort.library.name}_set_${libPort.variableType.variableType.name}_listen, &${libPort.library.name}, &packet_${libPort.library.name}, ${libPort.variableType.getSize()}, -1},
</#list>
};

</#if>
// LEADER PORT SECTION
STATIC LEADER_PORT leader_port_list[${leaderPortMap?size}] = {
<#list leaderPortMap as robotIdPort, heartbeatPort>
    {"${robotIdPort.name}", -1, -1, {{-1, -1}, -1}, -1, NULL, NULL, l_${robotId}leader_set_robot_id_listen, 
    "${heartbeatPort.name}", -1, -1, {{-1, -1}, -1}, -1, NULL, NULL, l_${robotId}leader_set_heartbeat_listen, ID_GROUP_${robotIdPort.message}},
</#list>
};

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
STATIC void leader_port_init() {
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
    channel_port_init();
</#if>
<#if multicastPortMap?size gt 0>
    multicast_port_init();
</#if>
<#if sharedDataPortMap?size gt 0>
    shared_data_port_init();
</#if>
    leader_port_init();
}

/////////////////////////////////////
// go code
/////////////////////////////////////
<#if channelPortMap?size gt 0>
STATIC void channel_port_receive() {
    int data_len;
    for (int i = 0 ; i<sizeof(channel_port_list)/sizeof(CHANNEL_PORT) ; i++)
    {
    	if (channelPortRead(channel_port_list[i].in_port_id, channel_port_list[i].buffer, channel_port_list[i].size, FALSE) > 0) 
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
STATIC void multicast_port_receive() {
    int data_len;
    for (int i = 0 ; i<sizeof(multicast_port_list)/sizeof(MULTICAST_PORT) ; i++)
    {
        UFMulticastPort_ReadFromBuffer(multicast_port_list[i].multicast_group_id, multicast_port_list[i].multicast_port_id, (unsigned char*) multicast_port_list[i].buffer, multicast_port_list[i].size + sizeof(MULTICAST_PACKET_HEADER), &data_len);
        if (data_len > 0) 
        {
            if (multicast_port_list[i].before_time < multicast_port_list[i].packet->header->time
                 && multicast_port_list[i].packet->header->sender_robot_id != THIS_ROBOT_ID) 
            {
                if (channel_port_write(multicast_port_list[i].channel_port_id, multicast_port_list[i].packet->data, multicast_port_list[i].size, FALSE) > 0) 
                {
                	    multicast_port_list[i].before_time = multicast_port_list[i].packet->header->time;
                }
            }
        }
    }
}

</#if>
<#if sharedDataPortMap?size gt 0>
STATIC void shared_data_port_receive() {
    int data_len;
    for (int i = 0 ; i<sizeof(shared_data_port_list)/sizeof(SHARED_DATA_PORT) ; i++)
    {
        UFMulticastPort_ReadFromBuffer(shared_data_port_list[i].multicast_group_id, shared_data_port_list[i].multicast_port_id, (unsigned char*) shared_data_port_list[i].buffer, shared_data_port_list[i].size + sizeof(MULTICAST_PACKET_HEADER), &data_len);
        if (data_len > 0) 
        {
	         if (shared_data_port_list[i].before_time < shared_data_port_list[i].packet->header->time 
                 && shared_data_port_list[i].packet->header->sender_robot_id != THIS_ROBOT_ID) 
	         {
        		    shared_data_port_list[i].lib_set_func(shared_data_port_list[i].packet->data);
        		    shared_data_port_list[i].before_time = shared_data_port_list[i].packet->header->time;
         	 }
        }
    }
}

</#if>
STATIC void leader_port_receive() {
    int data_len;
    for (int i = 0 ; i < sizeof(leader_port_list)/sizeof(LEADER_PORT) ; i++)
    {
        UFMulticastPort_ReadFromBuffer(leader_port_list[i].robot_id_group_id, leader_port_list[i].robot_id_port_id, (unsigned char*) &(leader_port_list[i].robot_id_buffer), sizeof(LEADER_PACKET), &data_len);
        if (data_len > 0) 
        {
	         if (leader_port_list[i].robot_id_before_time < leader_port_list[i].robot_id_buffer.header.time
                 && leader_port_list[i].robot_id_buffer.header.sender_robot_id != THIS_ROBOT_ID) 
             {
        		    leader_port_list[i].robot_id_set_func(leader_port_list[i].group_id, leader_port_list[i].robot_id_buffer.body);
        		    leader_port_list[i].robot_id_before_time = leader_port_list[i].robot_id_buffer.header.time;
             }
        }
        UFMulticastPort_ReadFromBuffer(leader_port_list[i].heartbeat_group_id, leader_port_list[i].heartbeat_port_id, (unsigned char*) &(leader_port_list[i].heartbeat_buffer), sizeof(LEADER_PACKET), &data_len);
        if (data_len > 0) 
        {
	         if (leader_port_list[i].heartbeat_before_time < leader_port_list[i].heartbeat_buffer.header.time
                 && leader_port_list[i].heartbeat_buffer.header.sender_robot_id != THIS_ROBOT_ID) 
             {
        		    leader_port_list[i].heartbeat_set_func(leader_port_list[i].group_id, leader_port_list[i].heartbeat_buffer.body);
        		    leader_port_list[i].heartbeat_before_time = leader_port_list[i].heartbeat_buffer.header.time;
             }
        }
    }
}

TASK_GO
{
<#if channelPortMap?size gt 0>
    channel_port_receive();
</#if>
<#if multicastPortMap?size gt 0>
    multicast_port_receive();
</#if>
<#if sharedDataPortMap?size gt 0>
    shared_data_port_receive();
</#if>
    leader_port_receive();
}

/////////////////////////////////////
// wrapup code
/////////////////////////////////////

TASK_WRAPUP
{

}

TASK_CODE_END