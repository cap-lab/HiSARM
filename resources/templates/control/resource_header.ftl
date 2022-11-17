#ifndef __${robotId}_RESOURCE_HEADER__
#define __${robotId}_RESOURCE_HEADER__

#include "semo_common.h"

typedef enum _RESOURCE {
<#list resourceList as resource>
    ID_RESOURCE_${resource},
</#list>
} RESOURCE_ID;

typedef enum _RESOURCE_STATE {
    OCCUPIED,
    NOT_OCCUPIED
} RESOURCE_STATE;

typedef struct _RESOURCE {
    RESOURCE_ID resource_id;
    RESOURCE_STATE state;
    semo_int32 action_id;
} RESOURCE;

extern RESOURCE resource_list[${resourceList?size}];

#endif