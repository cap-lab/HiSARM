#ifndef __${robotId}_TRANSITION_HEADER__
#define __${robotId}_TRANSITION_HEADER__

#include "semo_transition.h"
#include "semo_event.h"
#include "semo_mode.h"
#include "semo_group.h"

typedef enum _${robotId}_TRANSITION_ID {
<#list transitionList as transition>
    ID_TRANSITION_${robotId}_${transition.transitionId},
</#list>
} ${robotId}_TRANSITION_ID;

void ${robotId}_transition_init(TRANSITION_CLASS* transition, EVENT_CLASS* event, MODE_CLASS* mode, GROUP_CLASS* group);

#endif