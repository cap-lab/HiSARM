#include "semo_transition.h"
#include "semo_port.h"
#include "semo_logger.h"
#include "semo_mode.h"

// DEFINE static FUNCTION
static void init_explore_result(TRANSITION_CLASS *transition_class)
{
    transition_class->event_explore_result->next_mode = -1;
    transition_class->event_explore_result->transition_depth = transition_class->transition_list_size;
    transition_class->event_explore_result->event_priority = transition_class->event_class->event_list_size;
}

static void run_transition(semo_int32 transition_id, TRANSITION_CLASS *transition_class)
{
    SEMO_LOG_INFO("run transition %d", transition_id);
    transition_class->transition_list[transition_id].state = SEMO_RUN;
    transition_class->transition_list[transition_id].mode_point = 0;
    run_mode(transition_class->transition_list[transition_id].mode_list[0].mode_id, transition_class->mode_class);
}

static void stop_transition(semo_int32 transition_id, TRANSITION_CLASS *transition_class)
{
    SEMO_LOG_INFO("stop transition %d", transition_id);
    transition_class->transition_list[transition_id].state = SEMO_STOP;
}

static void explore_transition(semo_int32 transition_id, semo_int32 event, TRANSITION_CLASS *transition_class) 
{
    semo_int32 transition_depth = transition_class->transition_list[transition_id].transition_depth;
    semo_int32 previous_mode_point = transition_class->transition_list[transition_id].mode_point;
    MODE_EVENT_MAP *mode_map_list = transition_class->transition_list[transition_id].mode_list;
    EVENT_MODE_MAP *event_map_list = mode_map_list[previous_mode_point].event_mode_map;
    SEMO_LOG_DEBUG("current mode state %d(point %d)", mode_map_list[previous_mode_point].mode_id, previous_mode_point);
    for (int i = 0 ; i < mode_map_list[previous_mode_point].event_mode_map_size ; i++)
    {
        if (event_map_list[i].eventId == event)
        {
            if ((transition_depth < transition_class->event_explore_result->transition_depth) ||
                (transition_depth == transition_class->event_explore_result->transition_depth && i <= transition_class->event_explore_result->event_priority))
            {
                transition_class->event_explore_result->previous_mode = mode_map_list[previous_mode_point].mode_id;
                transition_class->transition_list[transition_id].mode_point = event_map_list[i].next_mode_point;
                transition_class->event_explore_result->next_mode = event_map_list[i].next_mode;
                transition_class->event_explore_result->variable_map_list_size = event_map_list[i].variable_map_list_size;
                transition_class->event_explore_result->variable_map_list = event_map_list[i].variable_map_list;
                transition_class->event_explore_result->transition_depth = transition_depth;
                transition_class->event_explore_result->event_priority = i;
                return;
            }
        }
    }
}

static void explore_to_find_next_mode(semo_int32 event, TRANSITION_CLASS *transition_class)
{
    for (int i = 0 ; i < transition_class->transition_list_size ; i++)
    {
        if (transition_class->transition_list[i].state == SEMO_RUN && 
            transition_class->transition_list[i].transition_depth <= transition_class->event_explore_result->transition_depth)
        {
            SEMO_LOG_DEBUG("explore transition %d", transition_class->transition_list[i].transition_id);
            explore_transition(transition_class->transition_list[i].transition_id, event, transition_class);
            SEMO_LOG_DEBUG("next mode selected %d(point %d)", transition_class->event_explore_result->next_mode, transition_class->transition_list[i].mode_point);
        }
    }
}

static void stop_previous_mode(TRANSITION_CLASS *transition_class)
{
    stop_mode(transition_class->event_explore_result->previous_mode, transition_class->mode_class);
    for (int i = 0 ; i < transition_class->transition_list_size ; i++)
    {
        if (transition_class->transition_list[i].state == SEMO_RUN && 
            transition_class->transition_list[i].transition_depth > transition_class->event_explore_result->transition_depth)
        {
            MODE_EVENT_MAP *mode_map_list = transition_class->transition_list[i].mode_list;
            for (int j = 0 ; j <transition_class-> transition_list[i].mode_list_size ; j++)
            {
                if(transition_class->mode_class->mode_list[mode_map_list[j].mode_id].state == SEMO_RUN)
                {
                    stop_mode(mode_map_list[j].mode_id, transition_class->mode_class);
                }
            }
            stop_transition(i, transition_class);
        }
    }
}

static void deal_with_result(TRANSITION_CLASS *transition_class)
{
    stop_previous_mode(transition_class);
    for (int i = 0 ; i < transition_class->event_explore_result->variable_map_list_size ; i++)
    {
        copy_variable(transition_class->event_explore_result->variable_map_list[i].src, transition_class->event_explore_result->variable_map_list[i].dst);
    }
    run_mode(transition_class->event_explore_result->next_mode, transition_class->mode_class);
}

// DEFINE EXTERN FUNCTION
void manage_event(TRANSITION_CLASS *transition_class) 
{
    init_explore_result(transition_class);

    for (int i = 0 ; i < transition_class->event_class->event_list_size ; i++)
    {
        if (transition_class->event_class->event_list[i] == TRUE)
        {   
            SEMO_LOG_INFO("explore event for %d", i);
            explore_to_find_next_mode(i, transition_class);
        }
    }

    if (transition_class->event_explore_result->next_mode != -1)
    {
        SEMO_LOG_INFO("next mode selected %d", transition_class->event_explore_result->next_mode);
        deal_with_result(transition_class);
    }
}



void check_group_allocation_and_run_transition(TRANSITION_CLASS *transition_class)
{
    check_group_selection_state(transition_class->group_class);
    for(int i = 0 ; i < transition_class->group_class->group_list_size ; i++)
    {
        if (get_group_state(get_group_id(i, transition_class->group_class), transition_class->group_class) == TRUE)
        {
            for (int transition_count = 0 ; transition_count < transition_class->transition_list_size ; transition_count++)
            {
                if (transition_class->transition_list[transition_count].group_id == get_group_id(i, transition_class->group_class)
                    && transition_class->transition_list[transition_count].state == SEMO_STOP)
                {
                    run_transition(transition_count, transition_class);
                }
            }
        }
    }
}