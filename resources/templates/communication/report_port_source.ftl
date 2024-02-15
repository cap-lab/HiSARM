#include "${robotId}_common.h"
#include "${robotId}_report.h"
#include "${robotId}_variable.h"
#include "${robotId}_group.h"
<#list sharedDataPortMap as libPort, multicastPort>
#include "${libPort.library.name}.cicl.h"
</#list>
<#if groupActionPortList?size gt 0>
#include "${robotId}_group_action.cicl.h"
</#if>
#include "${robotId}_leader_lib.cicl.h"
<#if groupingPortList?size gt 0>
#include "${robotId}_grouping.cicl.h"
</#if>

<#if channelPortMap?size gt 0>
// CHANNEL VARIABLE DEFINE
<#list channelPortMap as outPort, inPort>
    <#if outPort.variableType.variableType.type.getValue() == "enum">
static ${robotId}_VARIABLE_TYPE_${outPort.variableType.variableType.name} ${outPort.getVariableName()}[${outPort.variableType.variableType.count?c}];
    <#else>
static ${outPort.variableType.variableType.type.getValue()} ${outPort.getVariableName()}[${outPort.variableType.variableType.count?c}];
    </#if>
</#list>

</#if>
<#if multicastPortMap?size gt 0>
// MULTICAST VARIABLE DEFINE
<#list multicastPortMap as channelPort, multicastPort>
#pragma pack(push, 1)
static struct _${multicastPort.getVariableName()} {
    MULTICAST_PACKET_HEADER header;
    <#if multicastPort.variableType.variableType.type.getValue() == "enum">
    ${robotId}_VARIABLE_TYPE_${multicastPort.variableType.variableType.name} body[${multicastPort.variableType.variableType.count?c}];
    <#else>
    ${multicastPort.variableType.variableType.type.getValue()} body[${multicastPort.variableType.variableType.count?c}];
    </#if>
} ${multicastPort.getVariableName()} = {{-1, THIS_ROBOT_ID}, {0,}};
#pragma pack(pop)
static MULTICAST_PACKET packet_${multicastPort.getVariableName()} = {
    -1, // semo_int64 before_time
    &${multicastPort.getVariableName()}.header, // MULTICAST_PACKET_HEADER *header
    ${multicastPort.getVariableName()}.body // void *body
};
</#list>

</#if>
<#if sharedDataPortMap?size gt 0>
// SHARED DATA VARIABLE DEFINE
<#list sharedDataPortMap as libPort, multicastPort>
#pragma pack(push, 1)
static struct _${libPort.library.name} {
    MULTICAST_PACKET_HEADER header;
    semo_int8 data[${(libPort.variableType.variableType.count*libPort.variableType.variableType.size)?c}];
} ${libPort.library.name} = {{-1, THIS_ROBOT_ID}, {0,}};
#pragma pack(pop)
static SHARED_DATA_PACKET packet_${libPort.library.name} = {
    -1, // semo_int64 before_time
    &${libPort.library.name}.header, // MULTICAST_PACKET_HEADER *header
    ${libPort.library.name}.data // semo_int8 *data
};
</#list>

</#if>
<#if groupActionPortList?size gt 0>
// GROUP ACTION VARIABLE DEFINE
<#list groupActionPortList as multicastPort>
#pragma pack(push, 1)
static struct _group_action_${multicastPort.message} {
    MULTICAST_PACKET_HEADER header;
    semo_int32 body;
} group_action_${multicastPort.message} = {{-1, THIS_ROBOT_ID}, ${multicastPort.message}};
#pragma pack(pop)
static MULTICAST_PACKET packet_group_action_${multicastPort.message} = {
    -1, // semo_int64 before_time
    &group_action_${multicastPort.message}.header, // MULTICAST_PACKET_HEADER *header
    &group_action_${multicastPort.message}.body // void *body
};
</#list>

</#if>
// LEADER VARIABLE DEFINE
<#list leaderPortMap as selectionInfoPort, heartbeatPort>
#pragma pack(push, 1)
static struct _${selectionInfoPort.getVariableName()} {
    MULTICAST_PACKET_HEADER header;
    semo_int8 data[${leaderSharedDataSize?c}];
} ${selectionInfoPort.getVariableName()} = {{-1, THIS_ROBOT_ID}, {0,}};
#pragma pack(pop)
static LEADER_SELECTION_INFO_PACKET packet_${selectionInfoPort.getVariableName()} = {
    -1, // semo_int64 before_time
    &${selectionInfoPort.getVariableName()}.header, // MULTICAST_PACKET_HEADER *header
    ${selectionInfoPort.getVariableName()}.data // semo_int8 *data
};
#pragma pack(push, 1)
static struct _${heartbeatPort.getVariableName()} {
    MULTICAST_PACKET_HEADER header;
    semo_int32 data;
} ${heartbeatPort.getVariableName()} = {{-1, THIS_ROBOT_ID}, 0};
#pragma pack(pop)
static LEADER_HEARTBEAT_PACKET packet_${heartbeatPort.getVariableName()} = {
    -1, // semo_int64 before_time
    &${heartbeatPort.getVariableName()}.header, // MULTICAST_PACKET_HEADER *header
    &${heartbeatPort.getVariableName()}.data // semo_int32 *leader_id
};
</#list>

<#if groupingPortList?size gt 0>
// GROUPING VARIABLE DEFINE
#pragma pack(push, 1)
static struct _grouping {
    GROUPING_PACKET_HEADER header;
    semo_uint8 body[${groupingLibPort.library.sharedDataSize?c}];
} grouping = {{-1, THIS_ROBOT_ID, -1}, {0,}};
#pragma pack(pop)
static GROUPING_PACKET packet_grouping = {
    -1, // semo_int64 before_time
    &grouping.header, // GROUPING_PACKET_HEADER *header
    grouping.body // void *data
};

</#if>
// CHANNEL_PORT_SECTION
semo_int32 ${robotId}_report_channel_port_num = ${channelPortMap?size};
<#if channelPortMap?size gt 0>
CHANNEL_PORT ${robotId}_report_channel_port_list[${channelPortMap?size}] = {
<#list channelPortMap as inPort, outPort>
    {
        "${inPort.name}", // char *in_port_name
        -1, // int in_port_id
        "${outPort.name}", // char *out_port_name
        -1, // int out_port_id
        ${outPort.getVariableName()}, // void *buffer
        ${outPort.sampleSize?c}, // semo_int32 size
        FALSE // semo_int8 refreshed
    }, 
</#list>
};
<#else>
CHANNEL_PORT *${robotId}_report_channel_port_list = NULL;
</#if>

// MULTICAST PORT SECTION
semo_int32 ${robotId}_report_multicast_port_num = ${multicastPortMap?size};
<#if multicastPortMap?size gt 0>
MULTICAST_PORT ${robotId}_report_multicast_port_list[${multicastPortMap?size}] = {
<#list multicastPortMap as channelPort, multicastPort>
    {
        "${multicastPort.name}", // char *multicast_port_name
        -1, // int multicast_group_id
        -1, // int multicast_port_id
        "${channelPort.name}", // char *channel_port_name
        -1, // int channel_port_id
        &packet_${multicastPort.getVariableName()}, // MULTICAST_PACKET *packet
        ${multicastPort.variableType.getSize()?c} // semo_int32 size
    },
</#list>
};
<#else>
MULTICAST_PORT *${robotId}_report_multicast_port_list = NULL;
</#if>

// SHARED DATA PORT SECTION
semo_int32 ${robotId}_report_shared_data_port_num = ${sharedDataPortMap?size};
<#if sharedDataPortMap?size gt 0>
SHARED_DATA_PORT ${robotId}_report_shared_data_port_list[${sharedDataPortMap?size}] = {
<#list sharedDataPortMap as libPort, multicastPort>
    {
        "${multicastPort.name}", // char *multicast_port_name
        -1, // int multicast_group_id
        -1, // int multicast_port_id
        l_${libPort.library.name}_avail_shared_data_report, // LIBRARY_AVAIL_FUNC *lib_avail_func
        l_${libPort.library.name}_get_shared_data_report, // LIBRARY_GET_FUNC *lib_get_func
        NULL, // LIBRARY_SET_FUNC *lib_set_func
        &packet_${libPort.library.name}, // SHARED_DATA_PACKET *packet
        ${libPort.variableType.getSize()?c} // semo_int32 size
    },
</#list>
};
<#else>
SHARED_DATA_PORT *${robotId}_report_shared_data_port_list = NULL;
</#if>

// GROUP ACTION PORT SECTION
semo_int32 ${robotId}_report_group_action_port_num = ${groupActionPortList?size};
<#if groupActionPortList?size gt 0>
GROUP_ACTION_PORT ${robotId}_report_group_action_port_list[${groupActionPortList?size}] = {
<#list groupActionPortList as multicastPort>
    {
        "${multicastPort.name}", // char *multicast_port_name
        -1, // int multicast_group_id
        -1, // int multicast_port_id
        l_${robotId}_group_action_avail_group_action_report, // GROUP_ACTION_AVAIL_FUNC *lib_avail_func
        NULL, // GROUP_ACTION_SET_FUNC *lib_set_func
        &packet_group_action_${multicastPort.message}, // MULTICAST_PACKET *packet
        4 // semo_int32 size
    },
</#list>
};
<#else>
GROUP_ACTION_PORT *${robotId}_report_group_action_port_list = NULL;
</#if>

// LEADER PORT SECTION
semo_int32 ${robotId}_report_leader_port_num = ${leaderPortMap?size};
LEADER_PORT ${robotId}_report_leader_port_list[${leaderPortMap?size}] = {
    <#list leaderPortMap as selectionInfoPort, heartbeatPort>
    {
        "${selectionInfoPort.name}", // char *selection_info_port_name
        -1, // int selection_info_group_id
        -1, // int selection_info_port_id
        &packet_${selectionInfoPort.getVariableName()}, // LEADER_SELECTION_INFO_PACKET *selection_info_packet
        l_${robotId}_leader_lib_avail_selection_info_report, // LEADER_AVAIL_FUNC *selection_info_avail_func
        l_${robotId}_leader_lib_get_selection_info_report, // LEADER_SELECTION_INFO_GET_FUNC *selection_info_get_func
        NULL, // LEADER_SELECTION_INFO_SET_FUNC *selection_info_set_func
    
        "${heartbeatPort.name}", // char *heartbeat_port_name
        -1, // int heartbeat_group_id
        -1, // int heartbeat_port_id
        &packet_${heartbeatPort.getVariableName()}, // LEADER_HEARTBEAT_PACKET *heartbeat_packet
        l_${robotId}_leader_lib_avail_heartbeat_report, // LEADER_AVAIL_FUNC *heartbeat_avail_func
        l_${robotId}_leader_lib_get_heartbeat_report, // LEADER_HEARTBEAT_GET_FUNC *heartbeat_get_func
        NULL, // LEADER_HEARTBEAT_SET_FUNC *heartbeat_set_func
        
        ID_GROUP_${robotId}_${selectionInfoPort.message} // semo_int32 group_id
    },
    </#list>
};

// GROUP SERVICE PORT SECTION
semo_int32 ${robotId}_report_grouping_port_num = ${groupingPortList?size};
<#if groupingPortList?size gt 0>
GROUPING_PORT ${robotId}_report_grouping_port_list[${groupingPortList?size}] = {
<#list groupingPortList as multicastPort>
    {
        "${multicastPort.name}", // char *multicast_port_name
        -1, // int multicast_group_id
        -1, // int multicast_port_id
        l_${robotId}_grouping_avail_shared_data_report, // GROUPING_AVAIL_FUNC *lib_avail_func
        l_${robotId}_grouping_get_shared_data_report, // GROUPING_GET_FUNC *lib_get_func
        NULL, // GROUPING_SET_FUNC *lib_set_func
        &packet_grouping, // GROUPING_PACKET *packet
    },
</#list>
};
<#else>
GROUPING_PORT *${robotId}_report_grouping_port_list = NULL;
</#if>