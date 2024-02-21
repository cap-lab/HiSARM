#ifndef __SEMO_ACTION_HEADER__
#define __SEMO_ACTION_HEADER__

#include "semo_common.h"
#include "semo_resource.h"
#include "semo_port.h"

typedef struct _ACTION_TASK {
    semo_int32 action_task_id;
    semo_int32 action_type_id;
    semo_int32 task_id;
    char *task_name;
    SEMO_STATE state;
    semo_int8 return_immediate;
    semo_int32 resource_list_size;
    semo_int32 *resource_list;
    semo_int32 input_list_size;
    PORT *input_port_list;
    semo_int32 output_list_size;
    PORT *output_port_list;
    semo_int8 is_group_action;
    semo_int8 is_group_action_synchronization;
    semo_int32 group_action_id;
    PORT *group_port;
} ACTION_TASK;

typedef struct _ACTION_CLASS {
    ACTION_TASK *action_task_list;
    semo_int32 action_task_list_size;
    semo_int32 control_task_id;
    RESOURCE_CLASS *resource_class;
    void (*set_group_action_control)(semo_int32, semo_int8, semo_int64);
    semo_int8 (*get_group_action_control)(semo_int32, semo_int64);
    void (*set_robot_id_control)(semo_int32);
} ACTION_CLASS;

void action_init(ACTION_CLASS *action_class);
void run_action_task(semo_int32 action_task_id, ACTION_CLASS *action_class);
void stop_action_task(semo_int32 action_task_id, ACTION_CLASS *action_class);
void action_task_state_polling(ACTION_CLASS *action_class);
ACTION_TASK* get_action_task(semo_int32 list_size, semo_int32 *candidate_task_list, ACTION_CLASS *action_class);


#endif