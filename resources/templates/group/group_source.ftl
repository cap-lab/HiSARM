#include "${robotId}_group.h"

GROUP_ID group_list[${groupMap?size}] = {
    <#list groupMap as group, index>
    ID_GROUP_${group},
    </#list>
};
static semo_int32 group_state_list[${groupMap?size}];
semo_int32 group_num = ${groupMap?size};

static semo_int32 get_group_index(GROUP_ID group_id)
{
    for (int i = 0 ; i < group_num ; i++)
    {
        if (group_list[i] == group_id)
        {
            return i;
        }
    }
}

void group_init(void)
{
    for (int i = 0; i < group_num; i++)
    {
        group_state_list[i] = FALSE;
    }
    group_state_list[get_group_index(ID_GROUP_${team})] = TRUE;
}

void set_group_state(GROUP_ID group_id, semo_int32 refer_count)
{
    group_state_list[get_group_index(group_id)] += refer_count;
}

semo_int8 get_group_state(GROUP_ID group_id)
{
    return group_state_list[get_group_index(group_id)];
}