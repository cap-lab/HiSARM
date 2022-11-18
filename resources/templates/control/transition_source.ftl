#include "${robotId}_transition.h"
#include "${robotId}_event.h"

// DEFINE EVENT MODE MAP
<#list transitionList as transition>
    <#list transition.modeList as mode>
EVENT_MODE_MAP ${transition.transitionId}_${mode.modeId}_event_mode_map[${transition.getTransitionMapOfMode(mode)?size}] = {
        <#list transition.getTransitionMapOfMode(mode) as event, mode>
    {ID_EVENT_${event}, ${transition.getModeIndex(mode)}, ID_MODE_${mode.modeId}},
        </#list>
};
    </#list>
</#list>

// DEFINE MODE EVENT MAP
<#list transitionList as transition>
MODE_EVENT_MAP ${transition.transitionId}_mode_event_map[${transition.modeList?size}] = {
    <#list transition.modeList as mode>
    {ID_MODE_${mode.modeId}, ${transition.getTransitionMapOfMode(mode)?size}, ${transition.transitionId}_${mode.modeId}_event_mode_map},
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

static void explore_transition(TRANSITION_ID transition_id, semo_int32 event) 
{
    semo_int32 transition_depth = transition_list[transition_id].transition_depth;
    semo_int32 previous_mode_point = transition_list[transition_id].mode_point;
    MODE_EVENT_MAP *mode_map_list = transition_list[transition_id].mode_list;
    EVENT_MODE_MAP *event_map_list = mode_map_list[previous_mode_point].event_mode_map;
    for (int i = 0 ; i < mode_map_list[previous_mode_point].event_mode_map_size ; i++)
    {
        if (event_map_list[i].eventId == event)
        {
            if ((transition_depth < EVENT_EXPLORE_RESULT.transition_depth) ||
                (transition_depth == EVENT_EXPLORE_RESULT.transition_depth && i < EVENT_EXPLORE_RESULT.event_priority))
            {
                EVENT_EXPLORE_RESULT.previous_mode = mode_map_list[previous_mode_point].mode_id;
                transition_list[i].mode_point = event_map_list[i].next_mode_point;
                EVENT_EXPLORE_RESULT.next_mode = event_map_list[i].next_mode;
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
            explore_transition(transition_list[i].transition_id, event);
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
            transition_list[i].state = SEMO_STOP;
        }
    }
}

static void deal_with_result()
{
    stop_previous_mode();
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
            explore_to_find_next_mode(i);
        }
    }

    if (EVENT_EXPLORE_RESULT.next_mode != -1)
    {
        deal_with_result();
    }
}

void run_transition(TRANSITION_ID transition_id)
{
    transition_list[transition_id].state = SEMO_RUN;
    transition_list[transition_id].mode_point = 0;
    run_mode(transition_list[transition_id].mode_list[0].mode_id);
}

void check_group_allocation_and_run_transition()
{
    for(int i = 0 ; i < group_num ; i++)
    {
        GROUP_ID group_id = group_list[i];
        if (group_state_list[i] == TRUE)
        {
            for (int transition_count = 0 ; transition_count < ${transitionList?size} ; transition_count++)
            {
                if (transition_list[transition_count].group_id == group_id
                    && transition_list[transition_count].state == SEMO_STOP)
                {
                    run_transition(transition_count);
                }
            }
        }
    }
}