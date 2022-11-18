#include "${robotId}_action.h"
#include "${robotId}_common.h"
#include "${robotId}_port.h"
#include "UFTask.h"

// DEFINE ACTION RESOURCE LIST
<#list actionTaskList as actionTask>
    <#if actionTask.actionImpl.actionImpl.neededResource?has_content>
RESOURCE_ID resource_list_of_${actionTask.name}[${actionTask.actionImpl.actionImpl.neededResource?size}] = {
        <#list actionTask.actionImpl.actionImpl.neededResource as resource>
    ID_RESORUCE_${resource},
        </#list>
};
    </#if>
</#list>

// DEFINE ACTION TASK
ACTION_TASK action_task_list[${actionTaskList?size}] = {
<#list actionTaskList as actionTask>
    {ID_ACTION_TASK_${actionTask.name}, ID_ACTION_TYPE_${actionTask.actionImpl.actionType.action.name}, ${actionTask.id}, "${actionTask.name}", 
     SEMO_STOP, <#if actionTask.actionImpl.actionImpl.getReturnImmediate()>TRUE<#else>FALSE</#if>, <#if actionTask.actionImpl.actionImpl.needdedResource?has_content>${actionTask.actionImpl.actionImpl.needdedResource?size}, resource_list_of_${actionTask.name}<#else>0, NULL</#if>, 
     ${actionTask.inputPortList?size}, <#if actionTask.inputPortList?size gt 0>input_port_of_${actionTask.name}<#else>NULL</#if>, ${actionTask.outputPortList?size}, <#if actionTask.outputPortList?size gt 0>output_port_of_${actionTask.name}<#else>NULL</#if>,
     <#if actionTask.groupPort?has_content>&group_port_of_${actionTask.name}<#else>NULL</#if>},
</#list>
};

ACTION_TASK* get_action_task(semo_int32 list_size, ACTION_TASK_ID *candidate_task_list)
{
    return action_task_list + candidate_task_list[0];
}

void stop_action_task(semo_int32 action_task_id)
{
    UFControl_StopTask(CONTROL_TASK_ID, action_task_list[action_task_id].task_name, TRUE);
    for (int i = 0 ; i < action_task_list[action_task_id].resource_list_size ; i++)
    {
        resource_list[action_task_list[action_task_id].resource_list[i]].state = NOT_OCCUPIED;
    } 
    action_task_list[action_task_id].state = SEMO_STOP;
}

void action_task_state_polling()
{
    for (int i = 0 ; i < ${actionTaskList?size} ; i++)
    {
        if (action_task_list[i].state == SEMO_WRAPUP)
        {
            stop_action_task(action_task_list[i].action_task_id);
        }
        else if (action_task_list[i].state == SEMO_RUN)
        {
            ETaskState state;
            UFTask_GetState(action_task_list[i].task_id, action_task_list[i].task_name, &state);
            if (state == STATE_END || state == STATE_STOP)
            {
                action_task_list[i].state = SEMO_STOP;
            }
        }
    }
}