#include "${robotId}_port.h"
#include "${robotId}_common.h"
#include "${robotId}_variable.h"
#include "${robotId}_group.h"
#include "${robotId}_team.h"
#include "semo_logger.h"

// ACTION TASK PORT DEFINE

<#list actionList as action>
    <#if action.inputList?size gt 0 >
PORT ${robotId}_input_port_of_${action.actionTask.name}[${action.inputList?size}] = {
        <#list action.inputList as input>
    {
        "${input.port.name}", // char *port_name 
        -1, // int port_id
        &${robotId}_variable_${input.variable.id} // void *variable
    },
        </#list>
};
    </#if>
    <#if action.outputList?size gt 0 >
PORT ${robotId}_output_port_of_${action.actionTask.name}[${action.outputList?size}] = {
        <#list action.outputList as output>
    {
        "${output.port.name}", // char *port_name
        -1, // int port_id
        &${robotId}_variable_${output.variable.id} // void *variable
    },
        </#list>
};
    </#if>
    <#if action.actionTask.groupPort?has_content>
PORT ${robotId}_group_port_of_${action.actionTask.name} = {
    "${action.group.port.name}", // char *port_name
    -1, // int port_id
    &${robotId}_variable_group // void *variable
};
    </#if>
</#list>

<#list commPortList as commPort>
static PORT ${robotId}_port_of_${commPort.name} = {
    "${commPort.name}", // char *port_name
    -1, // int port_id
    NULL // void *variable
};
</#list>

<#list commStatementList as commStatement>
COMM_PORT ${robotId}_comm_port_of_${commStatement.statementId} = {
    <#list commStatement.comm.portList as commPort>
    &${robotId}_port_of_${commPort.port.name}, // PORT *port
    &${robotId}_variable_${commPort.variable.id}, // void *variable
    ID_TEAM_${robotId}_${commPort.port.counterTeam}, // int team_id 
    </#list>
};
</#list>

<#list throwStatementList as throwStatement>
    <#if throwStatement.statement.statement.isBroadcast() == true>
COMM_PORT ${robotId}_throw_out_port_of_${throwStatement.service.serviceId}_${throwStatement.statementId} = {
    &${robotId}_port_of_${throwStatement.th.outPort.port.name}, // PORT *port
    NULL, // void *variable
    0 // int team_id
};
    </#if>
</#list>

<#assign thInPortNameList = []>
<#assign thInPortList = []>
<#list throwStatementList as throwStatement>
    <#if throwStatement.statement.statement.isBroadcast() == true>
        <#if thInPortNameList?seq_contains(throwStatement.th.inPort.port.name)>
        <#else>
        <#assign thInPortList = thInPortList + [throwStatement.th.inPort]>
        <#assign thInPortNameList = thInPortNameList + [throwStatement.th.inPort.port.name]>
        </#if>
    </#if>
</#list>
COMM_PORT ${robotId}_throw_in_port_list[${thInPortList?size}] = {
<#list thInPortList as thInPort>
    {
        &${robotId}_port_of_${thInPort.port.name}, // PORT *port
        NULL, // void *variable
        ID_GROUP_${robotId}_${thInPort.groupId} // int team_id
    },
</#list>
};
semo_int32 ${robotId}_throw_in_port_list_size = ${thInPortList?size};

PORT ${robotId}_port_of_leader = {
    "${leaderPort.name}", // char *port_name
    -1, // int port_id
    &${robotId}_variable_leader // void *variable
};

PORT ${robotId}_port_of_grouping_mode = {
    "${groupingModePort.name}", // char *port_name
    -1, // int port_id
    &${robotId}_variable_grouping_mode // void *variable
};
PORT ${robotId}_port_of_grouping_result = {
    "${groupingResultPort.name}", // char *port_name
    -1, // int port_id
    &${robotId}_variable_grouping_result // void *variable
};

static void ${robotId}_action_port_init(int control_task_id) {
<#list actionList as action>
    <#if action.inputList?size gt 0 >
    for (int i = 0 ; i < ${action.inputList?size} ; i++)
    {
        UFPort_Initialize(control_task_id, ${robotId}_input_port_of_${action.actionTask.name}[i].port_name, &(${robotId}_input_port_of_${action.actionTask.name}[i].port_id));
    }
    </#if>
    <#if action.outputList?size gt 0 >
    for (int i = 0 ; i < ${action.outputList?size} ; i++)
    {
        UFPort_Initialize(control_task_id, ${robotId}_output_port_of_${action.actionTask.name}[i].port_name, &(${robotId}_output_port_of_${action.actionTask.name}[i].port_id));
    }
    </#if>
    <#if action.actionTask.groupPort?has_content>
    UFPort_Initialize(control_task_id, ${robotId}_group_port_of_${action.actionTask.name}.port_name, &(${robotId}_group_port_of_${action.actionTask.name}.port_id));
    </#if>
</#list>
}

static void ${robotId}_comm_port_init(int control_task_id) {
<#list commPortList as commPort>
    UFPort_Initialize(control_task_id, ${robotId}_port_of_${commPort.name}.port_name, &(${robotId}_port_of_${commPort.name}.port_id));
</#list>
}

static void ${robotId}_additional_port_init(int control_task_id) {
    UFPort_Initialize(control_task_id, ${robotId}_port_of_leader.port_name, &(${robotId}_port_of_leader.port_id));
    UFPort_Initialize(control_task_id, ${robotId}_port_of_grouping_mode.port_name, &(${robotId}_port_of_grouping_mode.port_id));
    UFPort_Initialize(control_task_id, ${robotId}_port_of_grouping_result.port_name, &(${robotId}_port_of_grouping_result.port_id));
}

void ${robotId}_port_init(int control_task_id) {
    SEMO_LOG_INFO("port init");
    ${robotId}_action_port_init(control_task_id);
    ${robotId}_comm_port_init(control_task_id);
    ${robotId}_additional_port_init(control_task_id);
}