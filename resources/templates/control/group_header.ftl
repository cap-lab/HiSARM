#ifndef __${robotId}_GROUP_HEADER__
#define __${robotId}_GROUP_HEADER__

#include "semo_group.h"

// GROUP DEFINE
typedef enum _${robotId}_GROUP_ID {
<#list groupMap as group, index>
    ID_GROUP_${robotId}_${group} = ${index},
</#list>
} ${robotId}_GROUP_ID;

void ${robotId}_group_init(GROUP_CLASS *group, LEADER_CLASS *leader);
#endif