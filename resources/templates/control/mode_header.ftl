#ifndef __${robotId}_MODE_HEADER__
#define __${robotId}_MODE_HEADER__

#include "semo_common.h"
#include "${robotId}_service.h"
#include "${robotId}_group.h"

// MODE STATE DEFINE
typedef enum _MODE {
<#list modeList as mode>
    ID_MODE_${mode.modeId},
</#list>
} MODE_ID;

typedef struct _MODE_INFO {
    MODE_ID mode_id
    STATE state;
    semo_int32 service_list_size;
    SERVICE_ID *service_list;
    GROUP_ID group;
} MODE;

extern MODE mode_list[${modeList?size}];

void run_mode(semo_int32 mode_id);
void stop_mode(semo_int32 mode_id);
#endif