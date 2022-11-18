#ifndef __${robotId}_SERVICE_HEADER__
#define __${robotId}_SERVICE_HEADER__

#include "semo_common.h"
#include "${robotId}_group.h"

typedef enum _SERVICE_ID {
<#list serviceList as service>
    ID_SERVICE_${service.serviceId},
</#list>
} SERVICE_ID;

// DECLARE EXTERN FUNCTION
void service_init();
void execute_service();
void run_service(SERVICE_ID service_id, GROUP_ID group);
void stop_service(SERVICE_ID service_id);

#endif