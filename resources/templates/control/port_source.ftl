#include "${robotId}_port.h"
#include "${robotId}_common.h"
#include "${robotId}_variable.h"
#include "${robotId}_team.h"
#include "semo_logger.h"

// ACTION TASK PORT DEFINE

<#list actionList as action>
    <#if action.inputList?size gt 0 >
PORT input_port_of_${action.actionTask.name}[${action.inputList?size}] = {
        <#list action.inputList as input>
    {"${input.port.name}", -1, &variable_${input.variable.id}},
        </#list>
};
    </#if>
    <#if action.outputList?size gt 0 >
PORT output_port_of_${action.actionTask.name}[${action.outputList?size}] = {
        <#list action.outputList as output>
    {"${output.port.name}", -1, &variable_${output.variable.id}},
        </#list>
};
    </#if>
    <#if action.actionTask.groupPort?has_content>
PORT group_port_of_${action.actionTask.name} = {
    "${action.group.port.name}", -1, &variable_group
};
    </#if>
</#list>

<#list commPortList as commPort>
static PORT port_of_${commPort.name} = {"${commPort.name}", -1, NULL};
</#list>

<#list commStatementList as commStatement>
COMM_PORT comm_port_of_${commStatement.statementId}[${commStatement.comm.portList?size}] = {
    <#list commStatement.comm.portList as commPort>
    {&port_of_${commPort.port.name}, &variable_${commPort.variable.id}, ID_TEAM_${commPort.port.counterTeam}},
    </#list>
};
semo_int32 comm_port_of_${commStatement.statementId}_size = ${commStatement.comm.portList?size};
</#list>

<#list throwStatementList as throwStatement>
    <#if throwStatement.statement.statement.isBroadcast() == true>
COMM_PORT throw_out_port_of_${throwStatement.statementId} = {&port_of_${throwStatement.th.outPort.port.name}, NULL, 0};
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
COMM_PORT throw_in_port_list[${thInPortList?size}] = {
<#list thInPortList as thInPort>
{&port_of_${thInPort}, NULL, 0},
</#list>
};
semo_int32 throw_in_port_list_size = ${thInPortList?size};

PORT port_of_leader = {"${leaderPort.name}", -1, &variable_leader};

COMM_PORT* get_team_port(COMM_PORT* port_list, semo_int32 port_list_size, semo_int32 team_id)
{
    for (semo_int32 i = 0; i < port_list_size; i++) 
    {
        if (port_list[i].team_id == team_id) 
        {
            return &port_list[i];
        }
    }
    return NULL;
}

static void action_port_init() {
<#list actionList as action>
    <#if action.inputList?size gt 0 >
    for (int i = 0 ; i < ${action.inputList?size} ; i++)
    {
        UFPort_Initialize(CONTROL_TASK_ID, input_port_of_${action.actionTask.name}[i].port_name, &(input_port_of_${action.actionTask.name}[i].port_id));
    }
    </#if>
    <#if action.outputList?size gt 0 >
    for (int i = 0 ; i < ${action.outputList?size} ; i++)
    {
        UFPort_Initialize(CONTROL_TASK_ID, output_port_of_${action.actionTask.name}[i].port_name, &(output_port_of_${action.actionTask.name}[i].port_id));
    }
    </#if>
</#list>
}

static void comm_port_init() {
<#list commPortList as commPort>
    UFPort_Initialize(CONTROL_TASK_ID, port_of_${commPort.name}.port_name, &(port_of_${commPort.name}.port_id));
</#list>
}

static void additional_port_init() {
    UFPort_Initialize(CONTROL_TASK_ID, port_of_leader.port_name, &(port_of_leader.port_id));
}

void port_init() {
    SEMO_LOG_INFO("port init");
    action_port_init();
    comm_port_init();
    additional_port_init();
}