#include "${robotId}_common.h"
#include "${robotId}_action.h"
#include "${robotId}_resource.h"
#include "${robotId}_port.h"
#include "${robotId}_group_action.cicl.h"
#include "semo_logger.h"
#include "semo_action.h"

// DEFINE ACTION RESOURCE LIST
<#list actionTaskList as actionTask>
    <#if actionTask.actionImpl.actionImpl.neededResource?has_content>
RESOURCE_ID ${robotId}_resource_list_of_${actionTask.name}[${actionTask.actionImpl.actionImpl.neededResource?size}] = {
        <#list actionTask.actionImpl.actionImpl.neededResource as resource>
    ID_RESORUCE_${robotId}_${resource},
        </#list>
};
    </#if>
</#list>

// DEFINE ACTION TASK
ACTION_TASK ${robotId}_action_task_list[${actionTaskList?size}] = {
<#list actionTaskList as actionTask>
    {
        ID_ACTION_TASK_${robotId}_${actionTask.name}, // ACTION_TASK_ID action_task_id
        ID_ACTION_TYPE_${robotId}_${actionTask.actionImpl.actionType.action.name}, // ACTION_TYPE_ID action_type_id
        ${actionTask.id}, // semo_int32 task_id
        "${actionTask.taskName}", // char *task_name
        SEMO_RUN, // SEMO_STATE state
        <#if actionTask.actionImpl.actionImpl.getReturnImmediate()>TRUE<#else>FALSE</#if>, // semo_int8 return_immediate
        <#if actionTask.actionImpl.actionImpl.needdedResource?has_content>${actionTask.actionImpl.actionImpl.needdedResource?size}<#else>0</#if>, // semo_int32 resource_list_size 
        <#if actionTask.actionImpl.actionImpl.needdedResource?has_content>${robot_id}_resource_list_of_${actionTask.name}<#else>NULL</#if>, // RESOURCE_ID *resource_list
        ${actionTask.inputPortList?size}, // semo_int32 input_list_size
        <#if actionTask.inputPortList?size gt 0>${robotId}_input_port_of_${actionTask.name}<#else>NULL</#if>, // PORT *input_port_list
        ${actionTask.outputPortList?size}, // semo_int32 output_list_size
        <#if actionTask.outputPortList?size gt 0>${robotId}_output_port_of_${actionTask.name}<#else>NULL</#if>, // PORT *output_port_list
        <#if actionTask.actionImpl.actionType.isGroupAction()>TRUE<#else>FALSE</#if>, // semo_int8 is_group_action,
        <#if actionTask.actionImpl.actionType.action.groupAction??><#if actionTask.actionImpl.actionType.action.groupAction.synchronization == true>TRUE<#else>FALSE</#if><#else>FALSE</#if>, // semo_int8 is_group_action_synchronization,
        ${actionTask.groupActionIndex}, // semo_int32 group_action_id,
        <#if actionTask.groupPort?has_content>&${robotId}_group_port_of_${actionTask.name}<#else>NULL</#if> // PORT *group_port
     },
</#list>
};

void ${robotId}_action_init(ACTION_CLASS *action_class, RESOURCE_CLASS *resource_class)
{
    SEMO_LOG_INFO("action init");
    action_class->action_task_list = ${robotId}_action_task_list;
    action_class->action_task_list_size = ${actionTaskList?size};
    action_class->control_task_id = CONTROL_TASK_ID;
    action_class->resource_class = resource_class;
    action_class->set_group_action_control = l_${robotId}_group_action_set_group_action_control;
    action_class->get_group_action_control = l_${robotId}_group_action_get_group_action_control;
    action_class->set_robot_id_control = l_${robotId}_group_action_set_robot_id_control;
    action_init(action_class);
}