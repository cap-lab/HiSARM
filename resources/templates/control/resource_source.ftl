#include "${robotId}_resource.h"
#include "semo_resource.h"
#include "semo_logger.h"

// DEFINE ACTION ID LIST
<#list resourceList as resource>
semo_int32 ${robotId}_action_id_list_${resource.getResourceId()}[${resource.getRelatedActionList()?size}];
</#list>

// DEFINE RESOURCE
RESOURCE ${robotId}_resource_list[${resourceList?size}] = {
<#list resourceList as resource>
    {
        ID_RESOURCE_${robotId}_${resource.getResourceId()}, // semo_int32 resource_id
        0, // semo_int32 reference_count
        ${robotId}_action_id_list_${resource.getResourceId()}, // semo_int32 *action_id_list
        <#if resource.isConflict()>TRUE<#else>FALSE</#if> // semo_int8 conflict
    },
</#list>
};

void ${robotId}_resource_init(RESOURCE_CLASS *resource_class) {
    SEMO_LOG_INFO("resource init");
    resource_class->resource_list = ${robotId}_resource_list;
    resource_class->resource_list_size = ${resourceList?size};
}