#ifndef __${robotId}_ACTION_HEADER__
#define __${robotId}_ACTION_HEADER__

#include "semo_common.h"
#include "${robotId}_resource.h"

typedef enum _ACTION_TASK_ID {
<#list actionTaskList as actionTask>
    ID_ACTION_TASK_${actionTask.name},
</#list>
} ACTION_TASK_ID;

typedef enum _ACTION_TYPE_ID {
<#list actionTypeList as actionType>
    ID_ACTION_TYPE_${actionType.action.name},
</#list>
} ACTION_TYPE_ID;

typedef struct _ACTION_TASK {
    ACTION_TASK_ID action_task_id;
    ACTION_TYPE_ID action_type_id;
    semo_int32 task_id;
    char *task_name;
    STATE state;
    semo_int8 return_immediate;
    semo_int32 resource_list_size;
    RESOURCE_ID *resource_list;
    semo_int32 input_list_size;
    PORT *input_port_list;
    semo_int32 output_list_size;
    PORT *output_port_list;
    PORT groupPort;
} ACTION_TASK;

extern ACTION_TASK action_task_list[${actionTaskList?size}];

ACTION_TASK* get_action_task(semo_int32 list_size, ACTION_TASK_ID *candidiate_task_list);
void action_task_state_polling();
void stop_action(semo_int32 action_id);

#endif