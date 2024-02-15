#ifndef __${robotId}_SERVICE_HEADER__
#define __${robotId}_SERVICE_HEADER__

#include "semo_service.h"
#include "semo_action.h"
#include "semo_event.h"
#include "semo_resource.h"
#include "semo_timer.h"

typedef enum _${robotId}_SERVICE_ID {
<#list serviceList as service>
    ID_SERVICE_${robotId}_${service.serviceId},
</#list>
} ${robotId}_SERVICE_ID;

// DECLARE EXTERN FUNCTION
void ${robotId}_service_init(SERVICE_CLASS* service, ACTION_CLASS* action, EVENT_CLASS* event, RESOURCE_CLASS* resource, TIMER_CLASS* timer);

#endif