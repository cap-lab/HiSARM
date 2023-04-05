#include "${robotId}_resource.h"

// DEFINE ACTION ID LIST
<#list resourceList as resource>
semo_int32 action_id_list_${resource.getResourceId()}[${resource.getRelatedActionList()?size}];
</#list>

// DEFINE RESOURCE
RESOURCE resource_list[${resourceList?size}] = {
<#list resourceList as resource>
    {ID_RESOURCE_${resource.getResourceId()}, 0, action_id_list_${resource.getResourceId()}, <#if resource.isConflict()>TRUE<#else>FALSE</#if>},
</#list>
};