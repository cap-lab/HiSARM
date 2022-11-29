#include "${robotId}_action.h"
#include "${robotId}_common.h"
#include "${robotId}_port.h"
#include "UFTask.h"
#include "UFControl.h"
#include "semo_logger.h"

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
    {ID_ACTION_TASK_${actionTask.name}, ID_ACTION_TYPE_${actionTask.actionImpl.actionType.action.name}, ${actionTask.id}, "${actionTask.taskName}", 
     SEMO_RUN, <#if actionTask.actionImpl.actionImpl.getReturnImmediate()>TRUE<#else>FALSE</#if>, <#if actionTask.actionImpl.actionImpl.needdedResource?has_content>${actionTask.actionImpl.actionImpl.needdedResource?size}, resource_list_of_${actionTask.name}<#else>0, NULL</#if>, 
     ${actionTask.inputPortList?size}, <#if actionTask.inputPortList?size gt 0>input_port_of_${actionTask.name}<#else>NULL</#if>, ${actionTask.outputPortList?size}, <#if actionTask.outputPortList?size gt 0>output_port_of_${actionTask.name}<#else>NULL</#if>,
     <#if actionTask.groupPort?has_content>&group_port_of_${actionTask.name}<#else>NULL</#if>},
</#list>
};

void run_action_task(semo_int32 action_task_id)
{
    if(action_task_list[action_task_id].state != SEMO_RUN)
    {
        int dataLen = 0;
        ACTION_TASK *action = action_task_list + action_task_id;
        SEMO_LOG_INFO("run action task id %d name %s", action_task_id, action->task_name);
        for (int port_index = 0 ; port_index < action->input_list_size ; port_index++)
        {
            fill_buffer_from_elements(action->input_port_list[port_index].variable);
            UFPort_WriteToBuffer(action->input_port_list[port_index].port_id, (unsigned char*) action->input_port_list[port_index].variable->buffer, action->input_port_list[port_index].variable->size, 0, &dataLen);
        }
        for (int resource_index = 0 ; resource_index < action->resource_list_size ; resource_index++)
        {
            resource_list[action->resource_list[resource_index]].state = OCCUPIED;
        } 
        action->state = SEMO_RUN;
        UFControl_RunTask(CONTROL_TASK_ID, action->task_name);
    }
}
void stop_action_task(semo_int32 action_task_id)
{
    if(action_task_list[action_task_id].state != SEMO_STOP)
    {
        int dataLen = 0;
        ACTION_TASK *action = action_task_list + action_task_id;
        SEMO_LOG_INFO("stop action task %d name %s", action_task_id, action->task_name);
        UFControl_StopTask(CONTROL_TASK_ID, action->task_name, FALSE);
        for (int port_index = 0 ; port_index < action->output_list_size ; port_index++)
        {
            uem_result result = UFPort_GetNumOfAvailableData(action->output_port_list[port_index].port_id, 0, &dataLen);
            ERRIFGOTO(result, _EXIT);
            if (dataLen > 0)
            {
                UFPort_ReadFromQueue(action->output_port_list[port_index].port_id, (unsigned char*) action->output_port_list[port_index].variable->buffer, action->output_port_list[port_index].variable->size, 0, &dataLen);
                fill_elements_from_buffer(action->output_port_list[port_index].variable);
            }
        }
        for (int resource_index = 0 ; resource_index < action->resource_list_size ; resource_index++)
        {
            resource_list[action->resource_list[resource_index]].state = NOT_OCCUPIED;
        } 
        action->state = SEMO_STOP;
    }
_EXIT:
    return;
}

void action_init()
{
    SEMO_LOG_INFO("action init");
    for (int i = 0 ; i < ${actionTaskList?size} ; i++)
    {
        stop_action_task(i);
    }
}

ACTION_TASK* get_action_task(semo_int32 list_size, ACTION_TASK_ID *candidate_task_list)
{
    return action_task_list + candidate_task_list[0];
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
            UFTask_GetState(CONTROL_TASK_ID, action_task_list[i].task_name, &state);
            if (state == STATE_END )
            {
                action_task_list[i].state = SEMO_WRAPUP;
            }
            else if (state == STATE_STOP)
            {
                action_task_list[i].state = SEMO_STOP;
            }
        }
    }
}