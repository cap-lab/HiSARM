#ifndef __${robotId}_PORT_HEADER__
#define __${robotId}_PORT_HEADER__

#include "semo_common.h"
#include "semo_port.h"

<#list actionList as action>
    <#if action.inputList?size gt 0>
extern PORT input_port_of_${action.actionTask.name}[${action.inputList?size}];
    </#if>
    <#if action.outputList?size gt 0>
extern PORT output_port_of_${action.actionTask.name}[${action.outputList?size}];
    </#if>
    <#if action.actionTask.actionImpl.actionType.isGroupAction()>
extern PORT group_port_of_${action.actionTask.name};
    </#if>
</#list>

<#list commStatementList as commStatement>
extern COMM_PORT comm_port_of_${commStatement.statementId}[${commStatement.comm.portList?size}];
extern semo_int32 comm_port_of_${commStatement.statementId}_size;
</#list>

<#list throwStatementList as throwStatement>
extern COMM_PORT throw_out_port_of_${throwStatement.statementId};
</#list>

COMM_PORT* get_team_port(COMM_PORT* port_list, semo_int32 port_list_size, semo_int32 team_id);
extern COMM_PORT throw_in_port_list[${throwStatementList?size}];
extern semo_int32 throw_in_port_list_size;

extern PORT port_of_leader;

void port_init();
#endif