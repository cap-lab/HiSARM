#ifndef __SEMO_TRANSITION_HEADER__
#define __SEMO_TRANSITION_HEADER__

#include "semo_common.h"
#include "semo_variable.h"
#include "semo_event.h"
#include "semo_mode.h"
#include "semo_group.h"

typedef struct _EVENT_EXPLORE_RESULT {
    semo_int32 next_mode;
    semo_int32 previous_mode;
    semo_int32 variable_map_list_size;
    VARIABLE_MAP *variable_map_list;
    semo_int32 transition_depth;
    semo_int32 event_priority;
} EVENT_EXPLORE_RESULT;

typedef struct _EVENT_MODE_MAP {
    semo_int32 eventId;
    semo_int32 next_mode_point;
    semo_int32 variable_map_list_size;
    VARIABLE_MAP *variable_map_list;
    semo_int32 next_mode;
} EVENT_MODE_MAP;

typedef struct _MODE_EVENT_MAP {
    semo_int32 mode_id;
    semo_int32 event_mode_map_size;
    EVENT_MODE_MAP *event_mode_map;
} MODE_EVENT_MAP;

typedef struct _TRANSITION {
    SEMO_STATE state;
    semo_int32 transition_id;
    semo_int32 group_id;
    semo_int32 transition_depth;
    semo_int32 mode_list_size;
    semo_int32 mode_point;
    MODE_EVENT_MAP* mode_list;
} TRANSITION;

typedef struct _TRANSITION_CLASS {
    TRANSITION *transition_list;
    semo_int32 transition_list_size;
    EVENT_CLASS *event_class;
    MODE_CLASS *mode_class;
    GROUP_CLASS *group_class;
    EVENT_EXPLORE_RESULT *event_explore_result;
} TRANSITION_CLASS;

void manage_event(TRANSITION_CLASS *transition_class);
void check_group_allocation_and_run_transition(TRANSITION_CLASS *transition_class);

#endif