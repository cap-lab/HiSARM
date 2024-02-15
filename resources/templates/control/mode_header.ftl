#ifndef __${robotId}_MODE_HEADER__
#define __${robotId}_MODE_HEADER__

#include "semo_mode.h"
#include "semo_service.h"
#include "semo_group.h"

// MODE STATE DEFINE
typedef enum _${robotId}_MODE_ID {
<#list modeList as mode>
    ID_MODE_${robotId}_${mode.modeId},
</#list>
} ${robotId}_MODE_ID;

void ${robotId}_mode_init(MODE_CLASS *mode_class, SERVICE_CLASS *service_class, LEADER_CLASS *leader_class, GROUP_CLASS *group_class);

#endif