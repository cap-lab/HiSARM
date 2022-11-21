#ifndef __${robotId}_TRANSITION_HEADER__
#define __${robotId}_TRANSITION_HEADER__

#include "semo_common.h"
#include "${robotId}_mode.h"
#include "${robotId}_event.h"
#include "${robotId}_group.h"

typedef enum _TRANSITION_ID {
<#list transitionList as transition>
    ID_TRANSITION_${transition.transitionId},
</#list>
} TRANSITION_ID;

typedef struct _EVENT_MODE_MAP {
    EVENT_ID eventId;
    semo_int32 next_mode_point;
    semo_int32 variable_map_list_size;
    VARIABLE_MAP *variable_map_list;
    MODE_ID next_mode;
} EVENT_MODE_MAP;

typedef struct _MODE_EVENT_MAP {
    MODE_ID mode_id;
    semo_int32 event_mode_map_size;
    EVENT_MODE_MAP *event_mode_map;
} MODE_EVENT_MAP;

typedef struct _TRANSITION {
    SEMO_STATE state;
    TRANSITION_ID transition_id;
    GROUP_ID group_id;

    semo_int32 transition_depth;

    semo_int32 mode_list_size;
    semo_int32 mode_point;
    MODE_EVENT_MAP* mode_list;
} TRANSITION;

extern TRANSITION transition_list[${transitionList?size}];

void manage_event();
void run_transition(TRANSITION_ID transition_id);
void check_group_allocation_and_run_transition();

#endif