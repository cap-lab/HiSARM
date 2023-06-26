#include "${robotId}_group.h"
#include "${robotId}_port.h"

GROUP_ID group_list[${groupMap?size}] = {
    <#list groupMap as group, index>
    ID_GROUP_${group},
    </#list>
};
static semo_int32 group_state_list[${groupMap?size}];
semo_int32 group_num = ${groupMap?size};
semo_int32 *selecting_mode;
semo_int32 current_selecting_mode;

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
    int dataLen;
    for (int i = 0; i < group_num; i++)
    {
        group_state_list[i] = FALSE;
    }
    group_state_list[get_group_index(ID_GROUP_${team})] = TRUE;
    ((semo_int32 *)port_of_leader.variable->buffer)[0] = ID_GROUP_${team};
    ((semo_int32 *)port_of_leader.variable->buffer)[1] = TRUE;
    UFPort_WriteToQueue(port_of_leader.port_id, (unsigned char *) port_of_leader.variable->buffer, port_of_leader.variable->size, 0, &dataLen);
    selecting_mode = (semo_int32 *) NULL;
}

void set_group_state(GROUP_ID group_id, semo_int32 refer_count)
{
    group_state_list[get_group_index(group_id)] += refer_count;
}

semo_int8 get_group_state(GROUP_ID group_id)
{
    return group_state_list[get_group_index(group_id)];
}

void register_group_selection(semo_int32 mode_id, GROUP_ID *field_of_mode) {
    int dataLen = 0;
    UFPort_GetNumOfAvailableData(port_of_grouping_result.port_id, 0, &dataLen);
    if (dataLen > 0) {
        UFPort_ReadFromQueue(port_of_grouping_result.port_id, (semo_uint8*)selecting_mode, sizeof(GROUP_ID), 0, &dataLen);
    }
    UFPort_WriteToBuffer(port_of_grouping_mode.port_id, (semo_uint8*)&mode_id, sizeof(semo_int32), 0, &dataLen);
    selecting_mode = field_of_mode;
    current_selecting_mode = mode_id;
}

void check_group_selection_state() {
    int dataLen = 0;
    UFPort_GetNumOfAvailableData(port_of_grouping_result.port_id, 0, &dataLen);
    if (dataLen > 0) {
        UFPort_ReadFromQueue(port_of_grouping_result.port_id, (semo_uint8*)selecting_mode, sizeof(GROUP_ID), 0, &dataLen);
        if (current_selecting_mode != -1) {
            ((semo_int32 *)port_of_leader.variable->buffer)[0] = *selecting_mode;
            ((semo_int32 *)port_of_leader.variable->buffer)[1] = TRUE;
            UFPort_WriteToQueue(port_of_leader.port_id, (unsigned char *) port_of_leader.variable->buffer, port_of_leader.variable->size, 0, &dataLen);
            set_group_state(*selecting_mode, SEMO_INCREASE);
            selecting_mode = (semo_int32*) NULL;
            current_selecting_mode = -1;
        }
    }
}

void stop_selecting_group(semo_int32 mode_id, GROUP_ID *field_of_mode) {
    if (current_selecting_mode == mode_id) {
        selecting_mode = (semo_int32*) NULL;
        current_selecting_mode = -1;
    } 
    if (*field_of_mode != -1) {
        set_group_state(*field_of_mode, SEMO_DECREASE);
        *field_of_mode = -1;
    }
}
