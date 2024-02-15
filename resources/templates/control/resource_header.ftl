#ifndef __${robotId}_RESOURCE_HEADER__
#define __${robotId}_RESOURCE_HEADER__

#include "semo_resource.h"

typedef enum _${robotId}_RESOURCE_ID {
<#list resourceList as resource>
    ID_RESOURCE_${robotId}_${resource.getResourceId()},
</#list>
    ID_RESOURCE_${robotId}_LAST
} ${robotId}_RESOURCE_ID;

void ${robotId}_resource_init(RESOURCE_CLASS *resource_class);

#endif