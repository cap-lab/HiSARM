#ifndef __${robotId}_PORT_HEADER__
#define __${robotId}_PORT_HEADER__

#include "semo_common.h"
#include "semo_port.h"

<#list actionList as action>
    <#if action.inputList?size gt 0>
extern PORT ${robotId}_input_port_of_${action.actionTask.name}[${action.inputList?size}];
    </#if>
    <#if action.outputList?size gt 0>
extern PORT ${robotId}_output_port_of_${action.actionTask.name}[${action.outputList?size}];
    </#if>
    <#if action.actionTask.actionImpl.actionType.isGroupAction()>
extern PORT ${robotId}_group_port_of_${action.actionTask.name};
    </#if>
</#list>

<#list commStatementList as commStatement>
extern COMM_PORT ${robotId}_comm_port_of_${commStatement.statementId}_${commStatement.statementId};
</#list>

<#list throwStatementList as throwStatement>
    <#if throwStatement.statement.statement.isBroadcast() == true>
extern COMM_PORT ${robotId}_throw_out_port_of_${throwStatement.service.serviceId}_${throwStatement.statementId};
    </#if>
</#list>

<#assign thInPortList = []>
<#list throwStatementList as throwStatement>
    <#if throwStatement.statement.statement.isBroadcast() == true>
        <#if thInPortList?seq_contains(throwStatement.th.inPort.port.name)>
        <#else>
        <#assign thInPortList = thInPortList + [throwStatement.th.inPort.port.name]>
        </#if>
    </#if>
</#list>
extern COMM_PORT ${robotId}_throw_in_port_list[${thInPortList?size}];
extern semo_int32 ${robotId}_throw_in_port_list_size;

extern PORT ${robotId}_port_of_leader;

extern PORT ${robotId}_port_of_grouping_mode;
extern PORT ${robotId}_port_of_grouping_result;

void ${robotId}_port_init();
#endif