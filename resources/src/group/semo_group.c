#include "semo_group.h"
#include "semo_port.h"
#include "semo_logger.h"

static semo_int32 get_group_index(semo_int32 group_id, GROUP_CLASS *group_class)
{
    for (int i = 0 ; i < group_class->group_list_size ; i++)
    {
        if (group_class->group_list[i] == group_id)
        {
            return i;
        }
    }
    return -1;
}

void group_init(GROUP_CLASS *group_class,  semo_int32 initial_team)
{
    SEMO_LOG_INFO("group init");
    group_class->selecting_mode = (semo_int32 *) NULL;
    group_class->group_state_list[get_group_index(initial_team, group_class)] = TRUE;
}

void set_group_state(semo_int32 group_id, semo_int32 refer_count, GROUP_CLASS *group_class)
{
    group_class->group_state_list[get_group_index(group_id, group_class)] += refer_count;
}

semo_int8 get_group_state(semo_int32 group_id, GROUP_CLASS *group_class)
{
    return group_class->group_state_list[get_group_index(group_id, group_class)];
}

void register_group_selection(semo_int32 mode_id, semo_int32 *field_of_mode, GROUP_CLASS *group_class) {
    int dataLen = 0;
    UFPort_GetNumOfAvailableData(group_class->port_of_grouping_result->port_id, 0, &dataLen);
    if (dataLen > 0) {
        UFPort_ReadFromQueue(group_class->port_of_grouping_result->port_id, (semo_uint8*)group_class->selecting_mode, sizeof(semo_int32), 0, &dataLen);
    }
    UFPort_WriteToBuffer(group_class->port_of_grouping_mode->port_id, (semo_uint8*)&mode_id, sizeof(semo_int32), 0, &dataLen);
    group_class->selecting_mode = field_of_mode;
    group_class->current_selecting_mode = mode_id;
}

void check_group_selection_state(GROUP_CLASS *group_class) {
    int dataLen = 0;
    UFPort_GetNumOfAvailableData(group_class->port_of_grouping_result->port_id, 0, &dataLen);
    if (dataLen > 0) {
        UFPort_ReadFromQueue(group_class->port_of_grouping_result->port_id, (semo_uint8*)group_class->selecting_mode, sizeof(semo_int32), 0, &dataLen);
        if (group_class->current_selecting_mode != -1) {
            set_group_state(*group_class->selecting_mode, SEMO_INCREASE, group_class);
            register_leader_selection(group_class->leader_class, *group_class->selecting_mode);
            group_class->selecting_mode = (semo_int32*) NULL;
            group_class->current_selecting_mode = -1;
        }
    }
}

void stop_selecting_group(semo_int32 mode_id, semo_int32 *field_of_mode, GROUP_CLASS *group_class) {
    if (group_class->current_selecting_mode == mode_id) {
        group_class->selecting_mode = (semo_int32*) NULL;
        group_class->current_selecting_mode = -1;
    } 
    if (*field_of_mode != -1) {
        set_group_state(*field_of_mode, SEMO_DECREASE, group_class);
        *field_of_mode = -1;
    }
}

semo_int32 get_group_id(semo_int32 index, GROUP_CLASS *group_class){
    return group_class->group_list[index];
}