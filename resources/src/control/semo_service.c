#include "semo_service.h"
#include "UFControl.h"
#include "semo_logger.h"

static ACTION_MAP* get_action_map(SERVICE *service, semo_int32 action_type_id)
{
    for (int i = 0 ; i < service->action_list_size ; i++)
    {
        if (service->action_list[i].action_type_id == action_type_id)
        {
            return &service->action_list[i];
        }
    }
    return NULL;
}

void service_init(SERVICE_CLASS *service_class) 
{
    SEMO_LOG_INFO("service init");
    for(int i = 0 ; i < service_class->service_list_size ; i++)
    {
        service_class->service_list[i].state = SEMO_STOP;
        service_class->service_list[i].current_statement_id = 0;
    }
}

void execute_service(SERVICE_CLASS *service_class) 
{
    for(int i = 0 ; i < service_class->service_list_size ; i++)
    {
        if (service_class->service_list[i].state == SEMO_RUN)
        {
            if (service_class->service_list[i].statement_transition_list[service_class->service_list[i].current_statement_id].statement->execution_func != NULL){
                semo_int32 result = service_class->service_list[i].statement_transition_list[service_class->service_list[i].current_statement_id].statement->
                    execution_func(i, 
                                   service_class->service_list[i].current_statement_id, 
                                   service_class->service_list[i].statement_transition_list[service_class->service_list[i].current_statement_id].statement->statement_info,
                                   service_class);
                if (result == 1)
                {
                    service_class->service_list[i].current_statement_id = service_class->service_list[i].statement_transition_list[service_class->service_list[i].current_statement_id].next_true_statement_id;
                } 
                else if (result == 2) 
                {
                    service_class->service_list[i].current_statement_id = service_class->service_list[i].statement_transition_list[service_class->service_list[i].current_statement_id].next_false_statement_id;
                }
            }
        }
    }
}

void stop_service(semo_int32 service_id, SERVICE_CLASS *service_class)
{
    SEMO_LOG_INFO("stop service %d", service_id);
    service_class->service_list[service_id].state = SEMO_STOP;
    for (int i = 0 ; i < service_class->service_list[service_id].action_list_size ; i++)
    {
        for (int j = 0 ; j < service_class->service_list[service_id].action_list[i].action_task_list_size ; j++)
        {
            semo_int32 action_task_id = service_class->service_list[service_id].action_list[i].action_task_list[j];
            if (service_class->action_class->action_task_list[action_task_id].state == SEMO_RUN)
            {
                stop_action_task(action_task_id, service_class->action_class);
            }
        }
    }
    remove_all_service_timer(service_id, service_class->timer_class);
}

void run_service(semo_int32 service_id, semo_int32 group, SERVICE_CLASS *service_class)
{
    SEMO_LOG_INFO("run service %d", service_id);
    service_class->service_list[service_id].state = SEMO_RUN;
    service_class->service_list[service_id].current_statement_id = 0;
    service_class->service_list[service_id].group = group;
}

semo_int8 execute_action(semo_int32 service_id, semo_int32 statement, void *info, void *service)
{
    SERVICE_CLASS *service_class = (SERVICE_CLASS *) service;
    STATEMENT_ACTION_INFO *action_info = (STATEMENT_ACTION_INFO *) info;
    ACTION_MAP *action_map = get_action_map(&service_class->service_list[service_id], action_info->action_type_id);
    ACTION_TASK *action = get_action_task(action_map->action_task_list_size, action_map->action_task_list, service_class->action_class);
    uem_result result = ERR_UEM_NOERROR;
    semo_int8 ret = 0;
    int dataLen;
    int dataNum = 0;
    
    if (action->state == SEMO_STOP || action->state == SEMO_READY) 
    {
        if (action->state == SEMO_STOP)
        {
            semo_int8 resource_conflict = FALSE;
            for(int resource_index = 0 ; resource_index < action->resource_list_size ; resource_index++)
            {
                RESOURCE *resource = service_class->resource_class->resource_list + action->resource_list[resource_index];
                if (resource->reference_count > 0 && resource->conflict == TRUE)
                {
                    service_class->action_class->action_task_list[resource->action_id_list[0]].state = SEMO_WRAPUP;
                    resource_conflict = TRUE;
                }
            }
    	    if (resource_conflict == TRUE)
            {
                return ret;
            }
            if (action->group_port != NULL) 
            {
                result = UFPort_WriteToBuffer(action->group_port->port_id, (unsigned char*) &service_class->service_list[service_id].group, sizeof(semo_int32), 0, &dataLen);
                ERRIFGOTO(result, _EXIT);
            }
        }
        run_action_task(action->action_task_id, service_class->action_class);
    }
    dataNum = 0;
    if (action->output_list_size > 0){
	    result = UFPort_GetNumOfAvailableData(action->output_port_list[0].port_id, 0, &dataNum);
        ERRIFGOTO(result, _EXIT);
    }
    if (action->return_immediate == TRUE || action->state == SEMO_WRAPUP || action->state == SEMO_STOP || dataNum > 0)
    {
        if(action->return_immediate != TRUE)
        {
            stop_action_task(action->action_task_id, service_class->action_class);
            ret = 1;
        }
    }
_EXIT:
    if (result != ERR_UEM_NOERROR){
        SEMO_LOG_ERROR("action %d error", action->action_task_id);
    }
    return ret;
}

semo_int8 excute_receive(semo_int32 service_id, semo_int32 statement, void *info, void *service)
{
    SERVICE_CLASS *service_class = (SERVICE_CLASS *) service;
    STATEMENT_COMMUNICATION_INFO *comm_info = (STATEMENT_COMMUNICATION_INFO *) info;
    int dataLen;
    uem_result result;
    int dataNum = 0;
    semo_int8 ret = 0;
	result = UFPort_GetNumOfAvailableData(comm_info->port->port->port_id, 0, &dataNum);
    ERRIFGOTO(result, _EXIT);
	if (dataNum >= comm_info->port->variable->size)
	{
        UFPort_ReadFromQueue(comm_info->port->port->port_id, (unsigned char*) comm_info->port->variable->buffer, comm_info->port->variable->size, 0, &dataLen);
        fill_elements_from_buffer(comm_info->port->variable);
        ret = 1;
    }
_EXIT:
    if (result != ERR_UEM_NOERROR){
        SEMO_LOG_ERROR("receive %d error", comm_info->port->port->port_id);
    }
    return ret;
}

semo_int8 execute_send(semo_int32 service_id, semo_int32 statement, void *info, void *service)
{
    SERVICE_CLASS *service_class = (SERVICE_CLASS *) service;
    STATEMENT_COMMUNICATION_INFO *comm_info = (STATEMENT_COMMUNICATION_INFO *) info;
    int dataLen;
    uem_result result;
    int dataNum = 0;
    int channelSize = 0;
    semo_int8 ret = 0;
    result = UFPort_GetNumOfAvailableData(comm_info->port->port->port_id, 0, &dataNum);
    ERRIFGOTO(result, _EXIT);
    channelSize = UFPort_GetChannelSize(comm_info->port->port->port_id);
    if (channelSize - dataNum >= comm_info->port->variable->size)
    {
        fill_buffer_from_elements(comm_info->port->variable);
        UFPort_WriteToQueue(comm_info->port->port->port_id, (unsigned char*) comm_info->port->variable->buffer, comm_info->port->variable->size, 0, &dataLen);
        ret = 1;
    }
_EXIT:
    if (result != ERR_UEM_NOERROR){
        SEMO_LOG_ERROR("send %d error", comm_info->port->port->port_id);
    }
    return ret;
}

semo_int8 execute_if(semo_int32 service_id, semo_int32 statement_id, void *info, void *service)
{
    SERVICE_CLASS *service_class = (SERVICE_CLASS *) service;
    STATEMENT_CONDITION_INFO *condition_info = (STATEMENT_CONDITION_INFO *) info;
    semo_int8 ret = 0;
    if(condition_info->left_variable != NULL && condition_info->right_variable != NULL)
    {
        fill_buffer_from_elements(condition_info->left_variable);
        fill_buffer_from_elements(condition_info->right_variable);
	    if(compare_variable(condition_info->left_variable, condition_info->right_variable) == TRUE)
        {
            if(condition_info->has_timer == TRUE)
            {
	            TIMER *timer = get_timer(service_id, statement_id, service_class->timer_class);
	            if(timer == NULL || timer_check(timer, service_class->timer_class) == TRUE) 
                {
                    remove_timer(timer, service_class->timer_class);
                    new_timer(condition_info->timer_time, condition_info->timer_unit, service_id, statement_id, service_class->timer_class);
                    ret = 1;
                }
            } else {
                ret = 1;
            }
        } else {
            if(condition_info->has_timer == TRUE) {
                remove_timer(get_timer(service_id, statement_id, service_class->timer_class), service_class->timer_class);
            }
            ret = 2;
        }
    } else {
        if(condition_info->has_timer == TRUE)
        {
            TIMER *timer = get_timer(service_id, statement_id, service_class->timer_class);
	        if(timer == NULL || timer_check(timer, service_class->timer_class) == TRUE) 
            {
                remove_timer(timer, service_class->timer_class);
                new_timer(condition_info->timer_time, condition_info->timer_unit, service_id, statement_id, service_class->timer_class);
                ret = 1;
            }
        }
    }
    return ret;
}

semo_int8 execute_throw(semo_int32 service_id, semo_int32 statement_id, void *info, void *service)
{
    SERVICE_CLASS *service_class = (SERVICE_CLASS *) service;
    STATEMENT_THROW_INFO *throw_info = (STATEMENT_THROW_INFO *) info;
    int dataLen;
    semo_int32 event = throw_info->event_id;
    uem_result result = ERR_UEM_NOERROR;
    set_event(event, service_class->event_class);
    SEMO_LOG_INFO("Event %d occured", event);
    if (throw_info->is_broadcast == TRUE){
        result = UFPort_WriteToQueue(throw_info->port->port->port_id, (unsigned char*) &event, sizeof(semo_int32), 0, &dataLen);
    }
    if (result != ERR_UEM_NOERROR){
        SEMO_LOG_ERROR("throw broadcast %d error", throw_info->port->port->port_id);
    }
    return 1;
}