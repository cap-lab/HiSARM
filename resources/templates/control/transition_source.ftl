#include "semo_transition.h"
#include "${robotId}_transition.h"
#include "semo_variable.h"
#include "${robotId}_variable.h"
#include "${robotId}_event.h"
#include "${robotId}_group.h"
#include "${robotId}_mode.h"
#include "semo_logger.h"

static EVENT_EXPLORE_RESULT ${robotId}_event_explore_result;

// DEFINE VARIABLE MAP LIST
<#list transitionList as transition>
    <#list transition.getTransitionElementList() as transitionElement>
        <#if transition.getArgumentMap(transitionElement)?size gt 0>
VARIABLE_MAP ${robotId}_variable_map_of_${transition.transitionId}_<#if transitionElement.srcModeScopeId?has_content>${transitionElement.srcModeScopeId}_${transitionElement.event}<#else>default_mode</#if>_${transitionElement.dstMode.modeId}[${transition.getArgumentMap(transitionElement)?size}] = {
            <#list transition.getArgumentMap(transitionElement) as argument, parameter>
    {
        &${robotId}_variable_${argument.id}, // VARIABLE *src
        &${robotId}_variable_${parameter.id} // VARIABLE *dst
    },
            </#list>
};
        </#if>
    </#list>
</#list>

// DEFINE EVENT MODE MAP
<#list transitionList as transition>
    <#list transition.getSourceModeScopeIdList() as srcMode>
        <#if transition.getTransitionElementList(srcMode)?size gt 0>
EVENT_MODE_MAP ${robotId}_event_mode_map_of_${transition.transitionId}_${srcMode}[${transition.getTransitionElementList(srcMode)?size}] = {
            <#list transition.getTransitionElementList(srcMode) as transitionElement>
    {
        ID_EVENT_${robotId}_${transitionElement.event}, // semo_int32 eventId
        ${transition.getModeIndex(transitionElement.dstMode)}, // semo_int32 next_mode_point
        ${transition.getArgumentMap(transitionElement)?size}, // semo_int32 variable_map_list_size
        <#if transition.getArgumentMap(transitionElement)?size gt 0>${robotId}_variable_map_of_${transition.transitionId}_<#if transitionElement.srcModeScopeId?has_content>${transitionElement.srcModeScopeId}_${transitionElement.event}<#else>default_mode</#if>_${transitionElement.dstMode.modeId}<#else>NULL</#if>, // VARIABLE_MAP *variable_map_list
        ID_MODE_${robotId}_${transitionElement.dstMode.modeId} // semo_int32 next_mode
    },
            </#list>
};
        </#if>
    </#list>
</#list>

// DEFINE MODE EVENT MAP
<#list transitionList as transition>
MODE_EVENT_MAP ${robotId}_${transition.transitionId}_mode_event_map[${transition.modeList?size}] = {
    <#list transition.modeList as mode>
    {
        ID_MODE_${robotId}_${mode.modeId}, // semo_int32 mode_id
        ${transition.getTransitionElementList(mode.scopeId)?size}, // semo_int32 event_mode_map_size
        <#if transition.getTransitionElementList(mode.scopeId)?size gt 0>${robotId}_event_mode_map_of_${transition.transitionId}_${mode.scopeId}<#else>NULL</#if> // EVENT_MODE_MAP *event_mode_map
    },
    </#list>
};
</#list>

// DEFINE TRANSITION
TRANSITION ${robotId}_transition_list[${transitionList?size}] = {
    <#list transitionList as transition>
    {
        SEMO_STOP, // SEMO_STATE state
        ID_TRANSITION_${robotId}_${transition.transitionId}, // semo_int32 transition_id
        ID_GROUP_${robotId}_${transition.groupId}, // semo_int32 group_id
        ${transition.depth}, // semo_int32 transition_depth
        ${transition.modeList?size}, // semo_int32 mode_list_size
        0, // semo_int32 mode_point
        ${robotId}_${transition.transitionId}_mode_event_map // MODE_EVENT_MAP* mode_list
    },
    </#list>
};

void ${robotId}_transition_init(TRANSITION_CLASS* transition, EVENT_CLASS* event, MODE_CLASS* mode, GROUP_CLASS* group)
{
    SEMO_LOG_INFO("transition init");
    transition->transition_list = ${robotId}_transition_list;
    transition->transition_list_size = ${transitionList?size};
    transition->event_class = event;
    transition->mode_class = mode;
    transition->group_class = group;
    transition->event_explore_result = &${robotId}_event_explore_result;
}