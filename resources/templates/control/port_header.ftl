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
extern COMM_PORT comm_port_of_${commStatement.statementId};
</#list>

<#list throwStatementList as throwStatement>
extern COMM_PORT throw_out_port_of_${throwStatement.statementId};
</#list>

extern COMM_PORT throw_in_port_list[${throwStatementList?size}];
extern semo_int32 throw_in_port_list_size;

extern PORT leader_task_port;

void port_init();
#endif