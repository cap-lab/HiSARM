#ifndef __${robotId}_REPORT_PORT_HEADER__
#define __${robotId}_REPORT_PORT_HEADER__

#include "semo_port.h"

// CHANNEL_PORT_SECTION
extern semo_int32 ${robotId}_report_channel_port_num;
<#if channelPortMap?size gt 0>
extern CHANNEL_PORT ${robotId}_report_channel_port_list[${channelPortMap?size}];
<#else>
extern CHANNEL_PORT *${robotId}_report_channel_port_list;
</#if>

// MULTICAST PORT SECTION
extern semo_int32 ${robotId}_report_multicast_port_num;
<#if multicastPortMap?size gt 0>
extern MULTICAST_PORT ${robotId}_report_multicast_port_list[${multicastPortMap?size}];
<#else>
extern MULTICAST_PORT *${robotId}_report_multicast_port_list;
</#if>

// SHARED DATA PORT SECTION
extern semo_int32 ${robotId}_report_shared_data_port_num;
<#if sharedDataPortMap?size gt 0>
extern SHARED_DATA_PORT ${robotId}_report_shared_data_port_list[${sharedDataPortMap?size}];
<#else>
extern SHARED_DATA_PORT *${robotId}_report_shared_data_port_list;
</#if>

// GROUP ACTION PORT SECTION
extern semo_int32 ${robotId}_report_group_action_port_num;
<#if groupActionPortList?size gt 0>
extern GROUP_ACTION_PORT ${robotId}_report_group_action_port_list[${groupActionPortList?size}];
<#else>
extern GROUP_ACTION_PORT *${robotId}_report_group_action_port_list;
</#if>

// LEADER PORT SECTION
extern semo_int32 ${robotId}_report_leader_port_num;
extern LEADER_PORT ${robotId}_report_leader_port_list[${leaderPortMap?size}];

// GROUP SERVICE PORT SECTION
extern semo_int32 ${robotId}_report_grouping_port_num;
<#if groupingPortList?size gt 0>
extern GROUPING_PORT ${robotId}_report_grouping_port_list[${groupingPortList?size}];
<#else>
extern GROUPING_PORT *${robotId}_report_grouping_port_list;
</#if>

#endif