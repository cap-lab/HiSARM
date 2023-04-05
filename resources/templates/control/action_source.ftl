#include "${robotId}_action.h"
#include "${robotId}_common.h"
#include "${robotId}_port.h"
#include "UFTask.h"
#include "UFTimer.h"
#include "UFControl.h"
#include "semo_logger.h"

#define LIBCALL(x, ...) LIBCALL_##x(__VA_ARGS__)
#define LIBCALL_group_action(f, ...) l_${robotId}_group_action_##f(__VA_ARGS__)                                                                                                                                     
#include "${robotId}_group_action.cicl.h"

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
    {ID_ACTION_TASK_${actionTask.name}, // ACTION_TASK_ID action_task_id
     ID_ACTION_TYPE_${actionTask.actionImpl.actionType.action.name}, // ACTION_TYPE_ID action_type_id
     ${actionTask.id}, // semo_int32 task_id
     "${actionTask.taskName}", // char *task_name
     SEMO_RUN, // SEMO_STATE state
     <#if actionTask.actionImpl.actionImpl.getReturnImmediate()>TRUE<#else>FALSE</#if>, // semo_int8 return_immediate
     <#if actionTask.actionImpl.actionImpl.needdedResource?has_content>${actionTask.actionImpl.actionImpl.needdedResource?size}<#else>0</#if>, // semo_int32 resource_list_size 
     <#if actionTask.actionImpl.actionImpl.needdedResource?has_content>resource_list_of_${actionTask.name}<#else>NULL</#if>, // RESOURCE_ID *resource_list
     ${actionTask.inputPortList?size}, // semo_int32 input_list_size
     <#if actionTask.inputPortList?size gt 0>input_port_of_${actionTask.name}<#else>NULL</#if>, // PORT *input_port_list
     ${actionTask.outputPortList?size}, // semo_int32 output_list_size
     <#if actionTask.outputPortList?size gt 0>output_port_of_${actionTask.name}<#else>NULL</#if>, // PORT *output_port_list
     <#if actionTask.actionImpl.actionType.isGroupAction()>TRUE<#else>FALSE</#if>, // semo_int8 is_group_action,
     ${actionTask.groupActionIndex}, // semo_int32 group_action_id,
     <#if actionTask.groupPort?has_content>&group_port_of_${actionTask.name}<#else>NULL</#if>}, // PORT *group_port
</#list>
};

semo_int8 check_group_action_task(ACTION_TASK *action)
{
    semo_int64 cur_time = 0;
    UFTimer_GetCurrentTime(CONTROL_TASK_ID, &cur_time);
    if (action->state == SEMO_STOP)
    {
        LIBCALL(group_action, set_group_action_control, action->group_action_id, TRUE, cur_time);
        action->state = SEMO_READY;
    } 
    else if (action->state == SEMO_READY) 
    {
        LIBCALL(group_action, set_robot_id_control, action->group_action_id);
        return LIBCALL(group_action, get_group_action_control, action->group_action_id, cur_time);
    }
    return FALSE;
}

void run_action_task(semo_int32 action_task_id)
{
    if (action_task_list[action_task_id].state != SEMO_RUN)
    {
        int dataLen = 0;
        ACTION_TASK *action = action_task_list + action_task_id;
        int run = TRUE;
        if (action->state == SEMO_STOP)
        {
            SEMO_LOG_INFO("run action task id %d name %s", action_task_id, action->task_name);
        }
        for (int port_index = 0 ; port_index < action->input_list_size ; port_index++)
        {
            fill_buffer_from_elements(action->input_port_list[port_index].variable);
            UFPort_WriteToBuffer(action->input_port_list[port_index].port_id, (unsigned char*) action->input_port_list[port_index].variable->buffer, action->input_port_list[port_index].variable->size, 0, &dataLen);
        }
        for (int resource_index = 0 ; resource_index < action->resource_list_size ; resource_index++)
        {
            resource_list[action->resource_list[resource_index]].action_id_list[resource_list[action->resource_list[resource_index]].reference_count] = action->action_task_id;
            resource_list[action->resource_list[resource_index]].reference_count += 1;
        } 
        if (action->is_group_action == TRUE)
        {
            run = check_group_action_task(action);
        }
        if (run == TRUE)
        {
            action->state = SEMO_RUN;
            UFControl_RunTask(CONTROL_TASK_ID, action->task_name);
        }
    }
}

void wrapup_group_action(ACTION_TASK *action)
{
    semo_int64 cur_time = 0;
    LIBCALL(group_action, set_group_action_control, action->group_action_id, FALSE, cur_time);
}

void stop_action_task(semo_int32 action_task_id)
{
    if (action_task_list[action_task_id].state != SEMO_STOP)
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
            int removed = FALSE;
            for (int resource_action_index = 0 ; resource_action_index < resource_list[action->resource_list[resource_index]].reference_count ; resource_action_index++) 
            {
                if (removed == TRUE) 
                {
                    resource_list[action->resource_list[resource_index]].action_id_list[resource_action_index-1] = resource_list[action->resource_list[resource_index]].action_id_list[resource_action_index];
                }
                if (resource_list[action->resource_list[resource_index]].action_id_list[resource_action_index] == action->action_task_id)
                {
                    removed = TRUE;
                }
            }
            resource_list[action->resource_list[resource_index]].reference_count -= 1;
        } 
        if (action->is_group_action == TRUE)
        {
            wrapup_group_action(action);
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