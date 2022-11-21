#ifndef __${robotId}_TEAM_HEADER__
#define __${robotId}_TEAM_HEADER__

#include "semo_common.h"

// GROUP DEFINE
typedef enum _TEAM_ID {
<#list teamList as team>
    ID_TEAM_${team},
</#list>
} TEAM_ID;

#endif