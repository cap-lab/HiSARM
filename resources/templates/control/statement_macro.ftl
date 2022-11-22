<#macro INDENT indentNum><#if indentNum gt 0><#list 1..indentNum as i>    </#list></#if></#macro>

<#macro TRANSITION statement condition service indentNum>
            <@INDENT indentNum/>service_list[ID_SERVICE_${service.serviceId}].current_statement_id = ID_STATEMENT_${statement.getNextStatement(service.getStatementList(), condition).getStatementId()};
</#macro>

<#macro ACTION statement service>
            ACTION_MAP *action_map = get_action_map(&service_list[service_index], ID_ACTION_TYPE_${statement.statement.statement.actionName});
            ACTION_TASK *action = get_action_task(action_map->action_task_list_size, action_map->action_task_list);
            uem_result result;  
            int dataLen;
            int dataNum = 0;
            
            if (action->state == SEMO_STOP) 
            {
                semo_int8 resource_conflict = FALSE;
                for(int resource_index = 0 ; resource_index < action->resource_list_size ; resource_index++)
                {
                    RESOURCE *resource = resource_list + action->resource_list[resource_index];
                    if (resource->state == OCCUPIED)
                    {
                        action_task_list[resource->action_id].state = SEMO_WRAPUP;
                        resource_conflict = TRUE;
                    }
                }
            	if (resource_conflict == TRUE)
                {
                	break;
                }

                for (int port_index = 0 ; port_index < action->input_list_size ; port_index++)
                {
                    fill_buffer_from_elements(action->input_port_list[port_index].variable);
                    UFPort_WriteToBuffer(action->input_port_list[port_index].port_id, (unsigned char*) action->input_port_list[port_index].variable->buffer, action->input_port_list[port_index].variable->size, 0, &dataLen);
                }
                if (action->group_port != NULL) 
                {
                    UFPort_WriteToBuffer(action->group_port->port_id, (unsigned char*) service_list[service_index].group, sizeof(GROUP_ID), 0, &dataLen);
                }
                run_action_task(action->action_task_id);
            }
            <#if statement.statement.statement.outputList?size gt 0>
        	result = UFPort_GetNumOfAvailableData(action->output_port_list[0].port_id, 0, &dataNum);
            ERRIFGOTO(result, _EXIT);
            </#if>
            if (action->return_immediate == TRUE || action->state == SEMO_WRAPUP || action->state == SEMO_STOP<#if statement.statement.statement.outputList?size gt 0> || dataNum > 0</#if>)
            {
                <@TRANSITION statement "TRUE" service 1/>
                stop_action_task(action->action_task_id);
                for (int port_index = 0 ; port_index < action->output_list_size ; port_index++)
                {
                    UFPort_ReadFromBuffer(action->output_port_list[port_index].port_id, (unsigned char*) action->output_port_list[port_index].variable->buffer, action->output_port_list[port_index].variable->size, 0, &dataLen);
                    fill_elements_from_buffer(action->output_port_list[port_index].variable);
                }
            }
</#macro>

<#macro RECEIVE statement service>
            int dataLen;
            uem_result result;
            int dataNum = 0;
            COMM_PORT *port = get_team_port(comm_port_of_${statement.statementId}, comm_port_of_${statement.statementId}_size, *((int*)variable_${statement.comm.team.id}.buffer));
        	result = UFPort_GetNumOfAvailableData(port->port->port_id, 0, &dataNum);
            ERRIFGOTO(result, _EXIT);
        	if (dataNum >= ${statement.comm.message.type.variableType.size})
        	{
                UFPort_ReadFromQueue(port->port->port_id, (unsigned char*) port->variable->buffer, port->variable->size, 0, &dataLen);
                fill_elements_from_buffer(port->variable);
                <@TRANSITION statement "TRUE" service 1/>
            }
</#macro>

<#macro SEND statement service>
            int dataLen;
            uem_result result;
            int dataNum = 0;
            int channelSize = 0;
            COMM_PORT *port = get_team_port(comm_port_of_${statement.statementId}, comm_port_of_${statement.statementId}_size, *((int*)variable_${statement.comm.team.id}.buffer));
            result = UFPort_GetNumOfAvailableData(port->port->port_id, 0, &dataNum);
            ERRIFGOTO(result, _EXIT);
            channelSize = UFPort_GetChannelSize(port->port->port_id);
            if (channelSize - dataNum >= ${statement.comm.message.type.variableType.size})
            {
                fill_buffer_from_elements(port->variable);
                UFPort_WriteToQueue(port->port->port_id, (unsigned char*) port->variable->buffer, port->variable->size, 0, &dataLen);
                <@TRANSITION statement "TRUE" service 1/>
            }
</#macro>

<#macro IF statement service>
            <#if statement.condition.leftVariable?has_content>
            VARIABLE *leftVariable = &variable_${statement.condition.leftVariable.id};
            VARIABLE *rightVariable = &variable_${statement.condition.rightVariable.id};
            fill_buffer_from_elements(leftVariable);
            fill_buffer_from_elements(rightVariable);
	        if (compare_variable(leftVariable, rightVariable) == TRUE)
	        {
            </#if>
	        <#if statement.condition.period?has_content>
	        	TIMER *timer = get_timer(ID_SERVICE_${service.serviceId}, ID_STATEMENT_${statement.statementId});
	            if(timer == NULL || timer_check(timer) == TRUE) 
                {
                    remove_timer(timer);
                    new_timer(${statement.condition.period.getConvertedTime()}, "${statement.condition.period.getConvertedTimeUnit().getValue()}", ID_SERVICE_${service.serviceId}, ID_STATEMENT_${statement.statementId});
                    <@TRANSITION statement "TRUE" service 2/>
                }
            <#else>
                <@TRANSITION statement "TRUE" service 1/>
            </#if>
            <#if statement.condition.leftVariable?has_content>
            }
            else
            {
            </#if>
            <#if statement.period?exists>
                remove_timer(get_timer(timerList, timerNum, service_list[ID_SERVICE_${service.name}]));
            </#if>
            <#if statement.condition.leftVariable?has_content>
                <@TRANSITION statement "FALSE" service 1/>
            }
            </#if>
</#macro>

<#macro THROW statement service>
            int dataLen;
            semo_int32 event = ID_EVENT_${statement.statement.statement.event.name};
            event_list[event] = TRUE;
            event_occured = TRUE;
            SEMO_LOG_INFO("Event %d occured", event);
            <#if statement.statement.statement.isBroadcast() == true>
            UFPort_WriteToQueue(throw_out_port_of_${statement.statementId}.port->port_id, (unsigned char*) &event, sizeof(semo_int32), 0, &dataLen);
            </#if>
</#macro>