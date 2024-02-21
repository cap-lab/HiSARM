#include "semo_action.h"
#include "UFTask.h"
#include "UFTimer.h"
#include "UFControl.h"
#include "semo_logger.h"

static semo_int8 check_group_action_task(ACTION_TASK *action, ACTION_CLASS *action_class)
{
    semo_int64 cur_time = 0;
    UFTimer_GetCurrentTime(action_class->control_task_id, &cur_time);
    if (action->state == SEMO_STOP)
    {
        action_class->set_group_action_control(action->group_action_id, TRUE, cur_time);
        action->state = SEMO_READY;
    } 
    else if (action->state == SEMO_READY) 
    {
        action_class->set_robot_id_control(action->group_action_id);
        return action_class->get_group_action_control(action->group_action_id, cur_time);
    }
    return FALSE;
}

static void wrapup_group_action(ACTION_TASK *action, ACTION_CLASS *action_class)
{
    semo_int64 cur_time = 0;
    action_class->set_group_action_control(action->group_action_id, FALSE, cur_time);
}

void run_action_task(semo_int32 action_task_id, ACTION_CLASS *action_class)
{
    if (action_class->action_task_list[action_task_id].state != SEMO_RUN)
    {
        int dataLen = 0;
        ACTION_TASK *action = action_class->action_task_list + action_task_id;
        int run = TRUE;
        if (action->state == SEMO_STOP)
        {
            SEMO_LOG_DEBUG("run action task id %d name %s", action_task_id, action->task_name);
        }
        for (int port_index = 0 ; port_index < action->input_list_size ; port_index++)
        {
            fill_buffer_from_elements(action->input_port_list[port_index].variable);
            UFPort_WriteToBuffer(action->input_port_list[port_index].port_id, (unsigned char*) action->input_port_list[port_index].variable->buffer, action->input_port_list[port_index].variable->size, 0, &dataLen);
        }
        for (int resource_index = 0 ; resource_index < action->resource_list_size ; resource_index++)
        {
            action_class->resource_class->resource_list[action->resource_list[resource_index]].action_id_list[action_class->resource_class->resource_list[action->resource_list[resource_index]].reference_count] = action->action_task_id;
            action_class->resource_class->resource_list[action->resource_list[resource_index]].reference_count += 1;
        } 
        if (action->is_group_action == TRUE && action->is_group_action_synchronization == TRUE)
        {
            run = check_group_action_task(action, action_class);
        }
        if (run == TRUE)
        {
            action->state = SEMO_RUN;
            UFControl_RunTask(action_class->control_task_id, action->task_name);
        }
    }
}


void stop_action_task(semo_int32 action_task_id, ACTION_CLASS *action_class)
{
    if (action_class->action_task_list[action_task_id].state != SEMO_STOP)
    {
        int dataLen = 0;
        ACTION_TASK *action = action_class->action_task_list + action_task_id;
        SEMO_LOG_DEBUG("stop action task %d name %s", action_task_id, action->task_name);
        UFControl_StopTask(action_class->control_task_id, action->task_name, FALSE);
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
            for (int resource_action_index = 0 ; resource_action_index < action_class->resource_class->resource_list[action->resource_list[resource_index]].reference_count ; resource_action_index++) 
            {
                if (removed == TRUE) 
                {
                    action_class->resource_class->resource_list[action->resource_list[resource_index]].action_id_list[resource_action_index-1] = action_class->resource_class->resource_list[action->resource_list[resource_index]].action_id_list[resource_action_index];
                }
                if (action_class->resource_class->resource_list[action->resource_list[resource_index]].action_id_list[resource_action_index] == action->action_task_id)
                {
                    removed = TRUE;
                }
            }
            action_class->resource_class->resource_list[action->resource_list[resource_index]].reference_count -= 1;
        } 
        if (action->is_group_action == TRUE)
        {
            wrapup_group_action(action, action_class);
        }
        action->state = SEMO_STOP;
    }
_EXIT:
    return;
}

void action_init(ACTION_CLASS *action_class)
{
    SEMO_LOG_INFO("action init");
    for (int i = 0 ; i < action_class->action_task_list_size ; i++)
    {
        stop_action_task(i, action_class);
    }
}

ACTION_TASK* get_action_task(semo_int32 list_size, semo_int32 *candidate_task_list, ACTION_CLASS *action_class)
{
    return action_class->action_task_list + candidate_task_list[0];
}

void action_task_state_polling(ACTION_CLASS *action_class)
{
    for (int i = 0 ; i < action_class->action_task_list_size ; i++)
    {
        if (action_class->action_task_list[i].state == SEMO_WRAPUP)
        {
            stop_action_task(action_class->action_task_list[i].action_task_id, action_class);
        }
        else if (action_class->action_task_list[i].state == SEMO_RUN)
        {
            ETaskState state;
            UFTask_GetState(action_class->control_task_id, action_class->action_task_list[i].task_name, &state);
            if (state == STATE_END )
            {
                action_class->action_task_list[i].state = SEMO_WRAPUP;
            }
            else if (state == STATE_STOP)
            {
                action_class->action_task_list[i].state = SEMO_STOP;
            }
        }
    }
}