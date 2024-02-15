#include "semo_logger.h"
#include "${robotId}_group.h"
#include "${robotId}_port.h"

semo_int32 ${robotId}_group_list[${groupMap?size}] = {
    <#list groupMap as group, index>
    ID_GROUP_${robotId}_${group},
    </#list>
};
static semo_int32 ${robotId}_group_state_list[${groupMap?size}];

void ${robotId}_group_init(GROUP_CLASS *group, LEADER_CLASS *leader)
{
    SEMO_LOG_INFO("group init");
    group->group_list = ${robotId}_group_list;
    group->group_state_list = ${robotId}_group_state_list;
    group->group_list_size = ${groupMap?size};
    group->selecting_mode = NULL;
    group->current_selecting_mode = -1;
    group->port_of_leader = &${robotId}_port_of_leader;
    group->port_of_grouping_mode = &${robotId}_port_of_grouping_mode;
    group->port_of_grouping_result = &${robotId}_port_of_grouping_result;
    group->leader_class = leader;
    group_init(group, ID_GROUP_${robotId}_${team});
}