#include "${robotId}_leader_data.h"
#include "${robotId}_group.h"

<#list groupList as group>
    <#list 0..maxRobotNum-1 as i>
static semo_int8 ${robotId}_${group}_selection_info_data_${i}[${sharedDataSize}];
    </#list>
</#list>

semo_int32 ${robotId}_leader_selection_info_size = ${sharedDataSize};

<#list groupList as group>
static SEMO_LEADER_SELECTION_INFO ${robotId}_${group}_selection_info[${maxRobotNum}] = {
    <#list 0..maxRobotNum-1 as i>
    {
        -1, // semo_int32 robot_id
        0, // semo_int64 last_updated_time
        ${robotId}_${group}_selection_info_data_${i}, // semo_int8 *data
    },
    </#list>
};
static SEMO_LEADER_HEARTBEAT ${robotId}_${group}_heartbeat[${maxRobotNum}] = {
    <#list 0..maxRobotNum-1 as i>
    {
        -1, // semo_int32 robot_id
        0, // semo_int64 last_heartbeat_time
        -1, // semo_int32 leader_id
    },
    </#list>
};
</#list>

SEMO_LEADER ${robotId}_leader_list[${groupList?size}] = {
<#list groupList as group>
    {
        ID_GROUP_${robotId}_${group}, // semo_int32 group_id
        LEADER_SELECTION_STOP, // LEADER_SELECTION_STATE leader_selection_state
        -1, // semo_int32 leader_id

        FALSE, // semo_int8 selection_info_refreshed
        ${robotId}_${group}_selection_info, // SEMO_LEADER_SELECTION_INFO *selection_info_list
        0, // semo_int32 selection_info_robot_num

        ${robotId}_${group}_heartbeat, // SEMO_LEADER_HEARTBEAT *heartbeat_robot_list
        0, // semo_int32 heartbeat_robot_num
        FALSE, // semo_int8 new_robot_added
        FALSE, // semo_int8 duplicated_leader
    },
</#list>
};

semo_int32 ${robotId}_leader_list_size = ${groupList?size};

