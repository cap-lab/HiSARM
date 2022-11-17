#include <${robotId}_resource.h>

// DEFINE RESOURCE
RESOURCE resource_list[${resourceList?size}] = {
<#list resourceList as resource>
    {ID_RESOURCE_${resource}, NOT_OCCUPIED, -1},
</#list>
};