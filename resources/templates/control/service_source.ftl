#include "semo_service.h"
#include "semo_logger.h"
#include "${robotId}_common.h"
#include "${robotId}_service.h"
#include "${robotId}_action.h"
#include "${robotId}_port.h"
#include "${robotId}_event.h"
#include "${robotId}_variable.h"
#include "${robotId}_timer.h"

// DEFINE ACTION TASK LIST FOR EACH SERVICE ACTION TYPE
<#list serviceList as service>
    <#list service.getActionMap() as actionType, actionList>
static semo_int32 ${robotId}_action_task_list_${service.serviceId}_${actionType.action.name}[] = {
        <#list actionList as action>
    ID_ACTION_TASK_${robotId}_${action.actionTask.name},
        </#list>
};
    </#list>
</#list>

// DEFINE SERVICE ACTION LIST
<#list serviceList as service>
    <#if service.getActionMap()?size gt 0>
static ACTION_MAP ${robotId}_action_list_of_${service.serviceId}[${service.getActionMap()?size}] = {
        <#list service.getActionMap() as actionType, actionTaksList>
    {
        ID_ACTION_TYPE_${robotId}_${actionType.action.name}, // semo_int32 action_type_id
        ${actionTaksList?size}, // semo_int32 action_task_list_size
        ${robotId}_action_task_list_${service.serviceId}_${actionType.action.name} // semo_int32 *action_task_list
    },
        </#list>
};
    </#if>
</#list>

// STATEMENT ID DEFINE
<#list serviceList as service>
typedef enum _${robotId}_STATEMENT_${service.serviceId} {
    <#list service.statementList as statement>
    ID_STATEMENT_${robotId}_${service.serviceId}_${statement.statementId},
    </#list>
} ${robotId}_STATEMENT_${service.serviceId};
</#list>

// SERVICE STATEMENT INFO
<#list serviceList as service>
    <#list service.statementList as statement>
        <#switch statement.statement.statement.getStatementType().getValue()>
            <#case "action">
static STATEMENT_ACTION_INFO ${robotId}_statement_info_${service.serviceId}_${statement.statementId} = {
    ID_ACTION_TYPE_${robotId}_${statement.statement.statement.actionName} // semo_int32 action_type_id
};
                <#break>
            <#case "receive">
            <#case "subscribe">
            <#case "send">
            <#case "publish">
static STATEMENT_COMMUNICATION_INFO ${robotId}_statement_info_${service.serviceId}_${statement.statementId} = {
    &${robotId}_comm_port_of_${statement.statementId}_${statement.statementId} // COMM_PORT *port
};
                <#break>
            <#case "if">
            <#case "loop">
            <#case "repeat">
                <#if statement.condition??>
static STATEMENT_CONDITION_INFO ${robotId}_statement_info_${service.serviceId}_${statement.statementId} = {
    <#if statement.condition.leftVariable??>
    &${robotId}_variable_${statement.condition.leftVariable.id}, // VARIABLE *left_variable
    &${robotId}_variable_${statement.condition.rightVariable.id}, // VARIABLE *right_variable
    <#else>
    NULL, // VARIABLE *left_variable
    NULL, // VARIABLE *right_variable
    </#if>
    <#if statement.condition.period??>
    TRUE, // semo_int8 has_timer
    ${statement.condition.period.getConvertedTime()}, // semo_int32 timer_time
    "${statement.condition.period.getConvertedTimeUnit().getValue()}" // char* timer_unit
    <#else>
    FALSE, // semo_int8 has_timer
    -1, // semo_int32 timer_time
    NULL // char* timer_unit
    </#if>
};
                </#if>
                <#break>
            <#case "throw">
static STATEMENT_THROW_INFO ${robotId}_statement_info_${service.serviceId}_${statement.statementId} = {
    ID_EVENT_${robotId}_${statement.statement.statement.event.name}, // semo_int32 event_id
    <#if statement.statement.statement.isBroadcast() == true>TRUE<#else>FALSE</#if>, // semo_int8 is_broadcast
    <#if statement.statement.statement.isBroadcast() == true>&${robotId}_throw_out_port_of_${service.serviceId}_${statement.statementId}<#else>NULL</#if> // COMM_PORT *port
};
                <#break>
        </#switch>
    </#list>
</#list>

// STATEMENT LIST
<#list serviceList as service>
    <#list service.statementList as statement>
static STATEMENT ${robotId}_statement_${service.serviceId}_${statement.statementId} = {
    ID_STATEMENT_${robotId}_${service.serviceId}_${statement.statementId}, // semo_int32 statement_id
        <#switch statement.statement.statement.getStatementType().getValue()>
            <#case "action">
    STATEMENT_TYPE_ACTION, // STATEMENT_TYPE statement_type
    &${robotId}_statement_info_${service.serviceId}_${statement.statementId}, // void *statement_info
    execute_action // SERVICE_STATEMENT_EXECUTION_FUNC execution_func
                <#break>
            <#case "receive">
            <#case "subscribe">
    STATEMENT_TYPE_RECEIVE, // STATEMENT_TYPE statement_type
    &${robotId}_statement_info_${service.serviceId}_${statement.statementId}, // void *statement_info
    execute_receive // SERVICE_STATEMENT_EXECUTION_FUNC execution_func
                <#break>
            <#case "send">
            <#case "publish">
    STATEMENT_TYPE_SEND, // STATEMENT_TYPE statement_type
    &${robotId}_statement_info_${service.serviceId}_${statement.statementId}, // void *statement_info
    execute_send // SERVICE_STATEMENT_EXECUTION_FUNC execution_func
                <#break>
            <#case "if">
            <#case "loop">
            <#case "repeat">
    STATEMENT_TYPE_IF, // STATEMENT_TYPE statement_type
    <#if statement.condition??>&${robotId}_statement_info_${service.serviceId}_${statement.statementId}<#else>NULL</#if>, // void *statement_info
    execute_if // SERVICE_STATEMENT_EXECUTION_FUNC execution_func
                <#break>
            <#case "throw">
    STATEMENT_TYPE_THROW, // STATEMENT_TYPE statement_type
    &${robotId}_statement_info_${service.serviceId}_${statement.statementId}, // void *statement_info
    execute_throw // SERVICE_STATEMENT_EXECUTION_FUNC execution_func
                <#break>
            <#default>
    STATEMENT_TYPE_NONE, // STATEMENT_TYPE statement_type
    NULL, // void *statement_info
    NULL // SERVICE_STATEMENT_EXECUTION_FUNC execution_func
            </#switch>
};
    </#list>
</#list>

// SERVICE STATEMENT TRANSITION LIST
<#list serviceList as service>
SERVICE_STATEMENT_TRANSITION ${robotId}_service_statement_transition_list_${service.serviceId}[] = {
    <#list service.statementList as statement>
    {
        &${robotId}_statement_${service.serviceId}_${statement.statementId}, // STATEMENT *statement
        <#if statement.getNextStatement(service.getStatementList(), "TRUE")??>
        ID_STATEMENT_${robotId}_${service.serviceId}_${statement.getNextStatement(service.getStatementList(), "TRUE").getStatementId()}, // semo_int32 next_true_statement_id
        <#else>
        -1, // semo_int32 next_true_statement_id
        </#if>
        <#if statement.getNextStatement(service.getStatementList(), "FALSE")??>
        ID_STATEMENT_${robotId}_${service.serviceId}_${statement.getNextStatement(service.getStatementList(), "FALSE").getStatementId()} // semo_int32 next_false_statement_id
        <#else>
        -1 // semo_int32 next_false_statement_id
        </#if>
    },
    </#list>
};
</#list>



// DEFINE SERVICE
static SERVICE ${robotId}_service_list[${serviceList?size}] = {
<#list serviceList as service>
    {
        ID_SERVICE_${robotId}_${service.serviceId}, // semo_int32 service_id
        SEMO_STOP, // SEMO_STATE state
         ${service.getActionList()?size}, // semo_int32 action_list_size
        <#if service.getActionMap()?size gt 0>${robotId}_action_list_of_${service.serviceId}<#else>NULL</#if>, // ACTION_MAP *action_list
        0, // semo_int32 current_statement_id
        ${robotId}_service_statement_transition_list_${service.serviceId}, // STATE_TRANSITION *statement_transition_list
        -1 // semo_int32 group
    },
</#list>
};

void ${robotId}_service_init(SERVICE_CLASS* service, ACTION_CLASS* action, EVENT_CLASS* event, RESOURCE_CLASS* resource, TIMER_CLASS* timer)
{
    SEMO_LOG_INFO("service init");
    service->service_list = ${robotId}_service_list;
    service->service_list_size = ${serviceList?size};
    service->action_class = action;
    service->event_class = event;
    service->resource_class = resource;
    service->timer_class = timer;
    service_init(service);
}