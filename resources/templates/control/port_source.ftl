#include "${robotId}_port.h"
#include "${robotId}_variable.h"

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
    <#if action.actionTask.actionImpl.actionType.isGroupAction()>
PORT group_port_of_${action.actionTask.name} = {
    "${action.group.port.name}", -1, &variable_group
};
    </#if>
</#list>

<#list commPortList as commPort>
STATIC PORT port_of_${commPort.name} = {"${commPort.name}", -1, NULL};
</#list>

<#list commStatementList as commStatement>
COMM_PORT comm_port_of_${commStatement.statementId} = {&port_of_${commStatement.port.name}, &variable_${commStatement.comm.variable.id}};
</#list>

<#list throwStatementList as throwStatement>
COMM_PORT throw_out_port_of_${throwStatement.statementId} = {&port_of_${throwStatement.th.outPort.port.name}, NULL};
</#list>

COMM_PORT throw_in_port_list[${throwStatementList?size}] = {
    <#list throwStatementList as throwStatement>
    {port_of_${throwStatement.th.inPort.port.name}, NULL},
    </#list>
};
semo_int32 throw_in_port_list_size = ${throwStatementList?size};

PORT leader_task_port = {"${leaderPort.name}", -1, &variable_leader};

STATIC void action_port_init() {
<#list actionList as action>
    <#if action.inputList?size gt 0 >
    for (int i = 0 ; i < ${action.inputList?size} ; i++)
    {
        UFPort_Initialize(CONTROL_TASK_ID, input_port_of_${action.actionTask.name}[i].portName, &(input_port_of_${action.actionTask.name}[i].portId));
    }
    </#if>
    <#if action.outputList?size gt 0 >
    for (int i = 0 ; i < ${action.outputList?size} ; i++)
    {
        UFPort_Initialize(CONTROL_TASK_ID, output_port_of_${action.actionTask.name}[i].portName, &(output_port_of_${action.actionTask.name}[i].portId));
    }
    </#if>
</#list>
}

STATIC void comm_port_init() {
<#list commPortList as commPort>
    UFPort_Initialize(CONTROL_TASK_ID, port_of_${commPort.name}.portName, &(port_of_${commPort.name}.portId));
</#list>
}

STATIC void additional_port_init() {
    UFPort_Initialize(CONTROL_TASK_ID, leader_task_port.portName, &(leader_task_port.portId));
}

void port_init() {
    action_port_init();
    comm_port_init();
    additional_port_init();
}