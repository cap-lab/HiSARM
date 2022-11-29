#include "${robotId}_transition.h"
#include "${robotId}_event.h"
#include "semo_logger.h"

// DEFINE VARIABLE MAP LIST
<#list transitionList as transition>
    <#list transition.getTransitionElementList() as transitionElement>
        <#if transition.getArgumentMap(transitionElement)?size gt 0>
VARIABLE_MAP variable_map_of_${transition.transitionId}_<#if transitionElement.srcMode?has_content>${transitionElement.srcMode.modeId}_${transitionElement.event}<#else>default_mode</#if>_${transitionElement.dstMode.modeId}[${transition.getArgumentMap(transitionElement)?size}] = {
            <#list transition.getArgumentMap(transitionElement) as argument, parameter>
    {&variable_${argument.id}, &variable_${parameter.id}},
            </#list>
};
        </#if>
    </#list>
</#list>

// DEFINE EVENT MODE MAP
<#list transitionList as transition>
    <#list transition.modeList as srcMode>
        <#if transition.getTransitionElementList(srcMode)?size gt 0>
EVENT_MODE_MAP event_mode_map_of_${transition.transitionId}_${srcMode.modeId}[${transition.getTransitionElementList(srcMode)?size}] = {
            <#list transition.getTransitionElementList(srcMode) as transitionElement>
    {ID_EVENT_${transitionElement.event}, ${transition.getModeIndex(transitionElement.dstMode)}, ${transition.getArgumentMap(transitionElement)?size}, <#if transition.getArgumentMap(transitionElement)?size gt 0>variable_map_of_${transition.transitionId}_<#if testElement.srcMode?has_content>${testElement.srcMode.modeId}_${transitionElement.event}<#else>default_mode</#if>_${transitionElement.dstMode.modeId}<#else>NULL</#if>, ID_MODE_${transitionElement.dstMode.modeId}},
            </#list>
};
        </#if>
    </#list>
</#list>

// DEFINE MODE EVENT MAP
<#list transitionList as transition>
MODE_EVENT_MAP ${transition.transitionId}_mode_event_map[${transition.modeList?size}] = {
    <#list transition.modeList as mode>
    {ID_MODE_${mode.modeId}, ${transition.getTransitionElementList(mode)?size}, <#if transition.getTransitionElementList(mode)?size gt 0>event_mode_map_of_${transition.transitionId}_${mode.modeId}<#else>NULL</#if>},
    </#list>
};
</#list>

// DEFINE TRANSITION
TRANSITION transition_list[${transitionList?size}] = {
    <#list transitionList as transition>
    {SEMO_STOP, ID_TRANSITION_${transition.transitionId}, ID_GROUP_${transition.groupId}, ${transition.depth}, ${transition.modeList?size}, 0, ${transition.transitionId}_mode_event_map},
    </#list>
};

static struct _EVENT_EXPLORE_RESULT {
    semo_int32 next_mode;
    semo_int32 previous_mode;
    semo_int32 variable_map_list_size;
    VARIABLE_MAP *variable_map_list;
    semo_int32 transition_depth;
    semo_int32 event_priority;
} EVENT_EXPLORE_RESULT;

// DEFINE static FUNCTION
static void init_explore_result()
{
    EVENT_EXPLORE_RESULT.next_mode = -1;
    EVENT_EXPLORE_RESULT.transition_depth = ${transitionList?size};
    EVENT_EXPLORE_RESULT.event_priority = ${eventList?size};
}

void run_transition(TRANSITION_ID transition_id)
{
    SEMO_LOG_INFO("run transition %d", transition_id);
    transition_list[transition_id].state = SEMO_RUN;
    transition_list[transition_id].mode_point = 0;
    run_mode(transition_list[transition_id].mode_list[0].mode_id);
}

void stop_transition(TRANSITION_ID transition_id)
{
    SEMO_LOG_INFO("stop transition %d", transition_id);
    transition_list[transition_id].state = SEMO_STOP;
}

static void explore_transition(TRANSITION_ID transition_id, semo_int32 event) 
{
    semo_int32 transition_depth = transition_list[transition_id].transition_depth;
    semo_int32 previous_mode_point = transition_list[transition_id].mode_point;
    MODE_EVENT_MAP *mode_map_list = transition_list[transition_id].mode_list;
    EVENT_MODE_MAP *event_map_list = mode_map_list[previous_mode_point].event_mode_map;
    SEMO_LOG_INFO("current mode state %d(point %d)", mode_map_list[previous_mode_point].mode_id, previous_mode_point);
    for (int i = 0 ; i < mode_map_list[previous_mode_point].event_mode_map_size ; i++)
    {
        if (event_map_list[i].eventId == event)
        {
            if ((transition_depth < EVENT_EXPLORE_RESULT.transition_depth) ||
                (transition_depth == EVENT_EXPLORE_RESULT.transition_depth && i <= EVENT_EXPLORE_RESULT.event_priority))
            {
                EVENT_EXPLORE_RESULT.previous_mode = mode_map_list[previous_mode_point].mode_id;
                transition_list[transition_id].mode_point = event_map_list[i].next_mode_point;
                EVENT_EXPLORE_RESULT.next_mode = event_map_list[i].next_mode;
                EVENT_EXPLORE_RESULT.variable_map_list_size = event_map_list[i].variable_map_list_size;
                EVENT_EXPLORE_RESULT.variable_map_list = event_map_list[i].variable_map_list;
                EVENT_EXPLORE_RESULT.transition_depth = transition_depth;
                EVENT_EXPLORE_RESULT.event_priority = i;
                return;
            }
        }
    }
}

static void explore_to_find_next_mode(semo_int32 event)
{
    for (int i = 0 ; i < ${transitionList?size} ; i++)
    {
        if (transition_list[i].state == SEMO_RUN && transition_list[i].transition_depth <= EVENT_EXPLORE_RESULT.transition_depth)
        {
            SEMO_LOG_INFO("explore transition %d", transition_list[i].transition_id);
            explore_transition(transition_list[i].transition_id, event);
            SEMO_LOG_INFO("next mode selected %d(point %d)", EVENT_EXPLORE_RESULT.next_mode, transition_list[i].mode_point);
        }
    }
}

static void stop_previous_mode()
{
    stop_mode(EVENT_EXPLORE_RESULT.previous_mode);
    for (int i = 0 ; i < ${transitionList?size} ; i++)
    {
        if (transition_list[i].state == SEMO_RUN && transition_list[i].transition_depth > EVENT_EXPLORE_RESULT.transition_depth)
        {
            MODE_EVENT_MAP *mode_map_list = transition_list[i].mode_list;
            for (int j = 0 ; j < transition_list[i].mode_list_size ; j++)
            {
                if(mode_list[mode_map_list[j].mode_id].state == SEMO_RUN)
                {
                    stop_mode(mode_map_list[j].mode_id);
                }
            }
            stop_transition(i);
        }
    }
}

static void deal_with_result()
{
    stop_previous_mode();
    for (int i = 0 ; i < EVENT_EXPLORE_RESULT.variable_map_list_size ; i++)
    {
        copy_variable(EVENT_EXPLORE_RESULT.variable_map_list[i].src, EVENT_EXPLORE_RESULT.variable_map_list[i].dst);
    }
    run_mode(EVENT_EXPLORE_RESULT.next_mode);
}

// DEFINE EXTERN FUNCTION
void manage_event() 
{
    init_explore_result();

    for (int i = 0 ; i < ${eventList?size} ; i++)
    {
        if (event_list[i] == TRUE)
        {   
            SEMO_LOG_INFO("explore event for %d", i);
            explore_to_find_next_mode(i);
        }
    }

    if (EVENT_EXPLORE_RESULT.next_mode != -1)
    {
        SEMO_LOG_INFO("next mode selected %d", EVENT_EXPLORE_RESULT.next_mode);
        deal_with_result();
    }
}



void check_group_allocation_and_run_transition()
{
    for(int i = 0 ; i < group_num ; i++)
    {
        if (get_group_state(group_list[i]) == TRUE)
        {
            for (int transition_count = 0 ; transition_count < ${transitionList?size} ; transition_count++)
            {
                if (transition_list[transition_count].group_id == group_list[i]
                    && transition_list[transition_count].state == SEMO_STOP)
                {
                    run_transition(transition_count);
                }
            }
        }
    }
}