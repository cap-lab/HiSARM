<#macro INDENT indentNum><#if indentNum gt 0><#list 1..indentNum as i>    </#list></#if></#macro>

<#macro TRANSITION statement condition service indentNum>
            <@INDENT indentNum/>service_list[ID_SERVICE_${service.serviceId}].current_statement_id = ID_SERVICE_${statement.getNextStatement(service.getStatementList(), condition).getStatementId()};
</#macro>

<#macro ACTION statement service>
            ACTION_TASK *action = get_action_task(ID_ACTION_TYPE_${statement.statement.statement.actionName});
            int dataLen;
            
            if (action->state == STOP) 
            {
                semo_int8 resource_conflict = FALSE;
                for(int resource_index = 0 ; resource_index < action->resource_list_size ; resource_index++)
                {
                    RESOURCE *resource = resource_list + action->resource_list[resource_index];
                    if (resource->state == OCCUPIED)
                    {
                        action_list[resource->action_id].state = WRAPUP
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
                    UFPort_WriteToBuffer(action->input_port_list[port_index].portId, (unsigned char*) action->input_port_list[port_index].variable->buffer, action->input_port_list[port_index].variable->size, 0, &dataLen);
                }
                if (action->group != NULL) 
                {
                    UFPort_WriteToBuffer(action->groupPort.portId, (unsigned char*) service_list[service_index].group, sizeof(semo_int32), 0, &dataLen);
                }

                UFControl_RunTask(CONTROL_TASK_ID, action->action_task_id);
                action->state = RUN;
                SEMO_LOG_DEBUG("New action (task %s)", , action->task_name);
            }
            if (action->return_immediate == TRUE || action->state == WRAPUP)
            {
                <@TRANSITION statement "TRUE" service 1/>
                for (int port_index = 0 ; port_index < action->output_list_size ; port_index++)
                {
                    UFPort_ReadFromBuffer(action->output_port_list[port_index].portId, (unsigned char*) action->output_port_list[port_index].variable->buffer, action->output_port_list[port_index].variable->size, 0, &dataLen);
                    fill_elements_from_buffer(action->output_port_list[port_index].variable);
                }
            }
</#macro>

<#macro RECEIVE statement service>
            int dataLen;
            int dataNum;
        	dataNum = 0;
        	UFPort_GetNumOfAvailableData(comm_port_of_${statement.commStatement.id}.port->portId, 0, &dataNum);
        	if (dataNum >= ${statement.commStatement.port.variable..variableType.size})
        	{
                UFPort_ReadFromQueue(comm_port_of_${statement.commStatement.id}.port->portId, (unsigned char*) comm_port_of_${statement.commStatement.id}.variable->buffer, comm_port_of_${statement.commStatement.id}.variable->size, 0, &dataLen);
                fill_elements_from_buffer(action->output_port_list[port_index].variable);
            }
            <@TRANSITION statement "TRUE" service 0/>
</#macro>

<#macro SEND action csName>
            int dataLen;
            int dataNum = 0;
            int channelSize = 0;
            UFPort_GetNumOfAvailableData(comm_port_of_${statement.commStatement.id}.port->portId, 0, &dataNum);
            channelSize = UFPort_GetChannelSize(comm_port_of_${statement.commStatement.id}.port->portId);
            if (channelSize - dataNum >= ${input.variableBase.size})
            {
                fill_buffer_from_elements(action->input_port_list[port_index].variable);
                UFPort_WriteToQueue(comm_port_of_${statement.commStatement.id}.port->portId, (unsigned char*) comm_port_of_${statement.commStatement.id}.variable->buffer, comm_port_of_${statement.commStatement.id}.variable->size, 0, &dataLen);
            }
            <@TRANSITION statement "TRUE" service 0/>
</#macro>

<#macro IF statement service>
            VARIABLE *leftVariable = &variable_${statement.condition.leftVariable};
            VARIABLE *rightVariable = &variable_${statement.condition.rightVariable};
            fill_buffer_from_elements(leftVariable);
            fill_buffer_from_elements(rightVariable);
	        if (compare_variable(leftVariable, rightVariable) == TRUE)
	        {
	        <#if statement.period?exists>
	        	TIMER *timer = get_timer(ID_SERVICE_${service.serviceId}, ID_STATEMENT_${statement.statementId});
	            if(timer == NULL || timer_check(timer) == TRUE) 
                {
                    remove_timer(timer);
                    new_timer(${action.period.timeValue}, TIMER_UNIT_${action.period.timeUnit}, ID_SERVICE_${service.serviceId}, ID_STATEMENT_${statement.statementId});
                    <@TRANSITION statement "TRUE" service 2/>
                }
            <#else>
                <@TRANSITION statement "TRUE" service 1/>
            </#if>
            }
            else
            {
            <#if statement.period?exists>
                remove_timer(get_timer(timerList, timerNum, service_list[ID_SERVICE_${service.name}]));
            </#if>
                <@TRANSITION statement "FALSE" service 1/>
            }
</#macro>

<#macro THROW statement service>
            semo_int32 event = ID_EVENT_${statement.statement.statement.event.name};
            event_list[event] = TRUE;
            <#if statement.statement.statement.isBroadcast() == true>
            UFPort_WriteToQueue(throw_out_port_of_${statement.statementId}.port->portId, (unsigned char*) &event, sizeof(semo_int32), 0, &dataLen);
            </#if>
</#macro>