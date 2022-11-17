#ifndef __${robotId}_EVENT_HEADER__
#define __${robotId}_EVENT_HEADER__

#include "semo_common.h"

// EVENT DEFINE
typedef enum _EVENT_ID {
<#list eventList as event>
    ID_EVENT_${event},
</#list>
} EVENT_ID;

extern semo_int8 event_list[${eventList?size}];
extern semo_int8 event_occured;

void event_list_init();

#endif