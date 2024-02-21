#ifndef __SEMO_RESOURCE_HEADER__
#define __SEMO_RESOURCE_HEADER__

#include "semo_common.h"

typedef struct _RESOURCE {
    semo_int32 resource_id;
    semo_int32 reference_count;
    semo_int32 *action_id_list;
    semo_int8 conflict;
} RESOURCE;

typedef struct _RESOURCE_CLASS {
    RESOURCE *resource_list;
    semo_int32 resource_list_size;
} RESOURCE_CLASS;

#endif