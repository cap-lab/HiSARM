#ifndef __${robotId}_TRANSITION_HEADER__
#define __${robotId}_TRANSITION_HEADER__

#include "semo_common.h"
#include "${robotId}_mode.h"
#include "${robotId}_event.h"

typdef enum _TRANSITION_ID {
<#list transitionList as transition>
    ID_TRANSITION_${transition.transitionId},
</#list>
} TRANSITION_ID;

typedef structn _EVENT_MODE_MAP {
    EVENT_ID eventId;
    semo_int32 next_mode_point;
    MODE_ID next_mode;
} EVENT_MODE_MAP;

typedef struct _MODE_EVENT_MAP {
    MODE_ID mode_id;
    EVENT_MODE_MAP *eventModeMap;
} MODE_EVENT_MAP;

typedef struct _TRANSITION {
    STATE state;
    TRANSITION_ID transition_id;
    semo_int32 transition_depth;
    semo_int32 mode_list_size;
    semo_int32 mode_point;
    MODE_EVENT_MAP* mode_list;
} TRANSITION;

extern TRANSITION transition_list[${transitionList?size}];

void manage_event();
void run_transition(semo_int32 transition_id);

#endif