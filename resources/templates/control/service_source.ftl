<#import "/control/statement_macro.ftl" as statement_macro>
#include "${robotId}_service.h"
#include "${robotId}_strategy.h"
#include "${robotId}_port.h"
#include "${robotId}_event.h"
#include "${robotId}_variable.h"
#include "${robotId}_timer.h"
#include "${robotId}_common.h"
#include "semo_logger.h"

typedef void SERVICE_EXECUTION_FUNC();

typedef struct _ACTION_MAP {
    ACTION_TYPE_ID action_type_id;
    semo_int32 action_task_list_size;
    ACTION_TASK_ID *action_task_list;
} ACTION_MAP;

typedef struct _SERVICE {
    SERVICE_ID service_id;
    STATE state;
    semo_int32 current_statement_id;
    semo_int32 action_list_size;
    ACTION_MAP *action_list;
    SERVICE_EXECUTION_FUNC execution_func;
    GROUP_ID group;
} SERVICE;

// DECLARE SERVICE EXECUTION FUNCTION
<#list serviceList as service>
STATIC void execute_service_${service.serviceId}();
</#list>

// DEFINE ACTION TASK LIST FOR EACH SERVICE ACTION TYPE
<#list serviceList as service>
    <#list service.getActionMap() as actionType, actionList>
STATIC ACTION_TASK_ID action_task_list_${service.serviceId}_${actionType.action.name}[] = {
        <#list actionList as action>
    ID_ACTION_${action.actionTask.name},
        </#list>
};
    </#list>
</#list>


// DEFINE SERVICE ACTION LIST
<#list serviceList as service>
    <#if service.getActionMap()?size gt 0>
STATIC ACTION_MAP action_list_of_${service.serviceId}[${service.getActionMap()?size}] = {
    <#list service.getActionMap() as actionType, actionTaksList>
    {ID_ACTION_TYPE_${actionType.action.name}, ${actionTaksList?size}, action_task_list_${service.serviceId}_${actionType.action.name}},
    </#list>
};
    </#if>
</#list>

// DEFINE SERVICE
STATIC SERVICE service_list[${serviceList?size}] = {
<#list serviceList as service>
    {ID_SERVICE_${service.serviceId}, STOP, 0, ${service.getActionList()?size}, 
    <#if service.getActionMap()?size gt 0>action_list_of_${service.serviceId}<#else>NULL</#if>, execute_service_${service.serviceId}, -1},
</#list>
};

// SERVICE STATE DEFINE
<#list serviceList as service>
typedef enum _SERVICE_${service.serviceId} {
	<#list service.statementList as statement>
    ID_STATEMENT_${statement.statementId},
	</#list> 
} SERVICE_${service.serviceId};
</#list>

void stop_service(semo_int32 service_id)
{
    ACTION *action_list = service
    service_list[service_id].state = STOP;
    for (int i = 0 ; i < service_list[service_id].action_list_size ; i++)
    {
        int action_id = service_list[service_id].action_list[i];
        if (action_list[action_id].state == RUN)
        {
            stop_action(action_id);
        }
    }
}

void run_service(semo_int32 service_id, GROUP_ID group)
{
    service_list[service_id].state = RUN;
    service_list[service_id].current_statement_id = 0;
    service_list[service_id].group = group;
}

void init_service() {
    for(int i = 0 ; i < ${serviceList?size} ; i++)
    {
        service_list[i].state = STOP;
        service_list[i].current_statement_id = 0;
    }
}

void execute_service() 
{
    for(int i = 0 ; i < ${serviceList?size} ; i++)
    {
        if (service_list[i].state == RUN)
        {
            service_list[i].execute_func(i);
        }
    }
}

<#list serviceList as service>
STATIC void execute_service_${service.serviceId}(int serviceIndex) {
	switch (serviceList[ID_SERVICE_${service.serviceId}].current_statement_id)
	{
	<#list service.statementList as statement>
        case ID_STATEMENT_${statement.statementId}: 
        {
        <#switch statement.statement.statement.getStatementType().getValue()>
        <#case "action">
            <@statement_macro.ACTION statement service/>
            <#break>
        <#case "receive">
        <#case "subscribe">
            <@statement_macro.RECEIVE statement service/>
            <#break>
        <#case "send">
        <#case "publish">
            <@statement_macro.SEND statement service/>
            <#break>
        <#case "if">
        <#case "loop">
        <#case "repeat">
            <@statement_macro.IF statement service/>
            <#break>
        <#case "throw">
            <@statement_macro.THROW statement service/>
            <#break>
        </#switch>

			break;
		}
	</#list>
	}
}

</#list>