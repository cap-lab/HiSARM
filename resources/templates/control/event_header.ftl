#ifndef __${robotId}_EVENT_HEADER__
#define __${robotId}_EVENT_HEADER__

#include "semo_event.h"
#include "semo_group.h"

// EVENT DEFINE
typedef enum _${robotId}_EVENT_ID {
<#list eventList as event>
    ID_EVENT_${robotId}_${event},
</#list>
    ID_EVENT_LAST
} ${robotId}_EVENT_ID;

void ${robotId}_event_init(EVENT_CLASS *event_class, GROUP_CLASS *group_class);

#endif
