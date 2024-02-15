#ifndef __${robotId}_LEADER_DATA_HEADER__
#define __${robotId}_LEADER_DATA_HEADER__

#include "semo_leader.h"

extern semo_int32 ${robotId}_leader_selection_info_size;
extern semo_int32 ${robotId}_leader_list_size;
extern SEMO_LEADER ${robotId}_leader_list[${groupList?size}];

#endif