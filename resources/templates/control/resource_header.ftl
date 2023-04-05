#ifndef __${robotId}_RESOURCE_HEADER__
#define __${robotId}_RESOURCE_HEADER__

#include "semo_common.h"

typedef enum _RESOURCE_ID {
<#list resourceList as resource>
    ID_RESOURCE_${resource.getResourceId()},
</#list>
    ID_RESOURCE_LAST
} RESOURCE_ID;

typedef struct _RESOURCE {
    RESOURCE_ID resource_id;
    semo_int32 reference_count;
    semo_int32 *action_id_list;
    semo_int8 conflict;
} RESOURCE;

extern RESOURCE resource_list[${resourceList?size}];

#endif