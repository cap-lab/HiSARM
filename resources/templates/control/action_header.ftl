#ifndef __${robotId}_ACTION_HEADER__
#define __${robotId}_ACTION_HEADER__

#include "semo_action.h"
#include "semo_resource.h"

typedef enum _${robotId}_ACTION_TASK_ID {
<#list actionTaskList as actionTask>
    ID_ACTION_TASK_${robotId}_${actionTask.name},
</#list>
} ${robotId}_ACTION_TASK_ID;

typedef enum _ACTION_TYPE_ID {
<#list actionTypeList as actionType>
    ID_ACTION_TYPE_${robotId}_${actionType.action.name},
</#list>
} ${robotId}_ACTION_TYPE_ID;

void ${robotId}_action_init(int control_task_id, ACTION_CLASS *action_class, RESOURCE_CLASS *resource_class);

#endif