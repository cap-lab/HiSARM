#ifndef __${robotId}_GROUP_HEADER__
#define __${robotId}_GROUP_HEADER__

#include "semo_common.h"

// GROUP DEFINE
typedef enum _GROUP_ID {
<#list groupMap as group, index>
    ID_GROUP_${group} = ${index},
</#list>
} GROUP_ID;

extern GROUP_ID group_list[${groupMap?size}];
extern semo_int32 group_num;

void group_init(void);
void set_group_state(GROUP_ID group, semo_int32 refer_count);
semo_int8 get_group_state(GROUP_ID group);
void register_group_selection(semo_int32 mode_id, GROUP_ID *field_of_mode);
void check_group_selection_state();
void stop_selecting_group(semo_int32 mode_id, GROUP_ID *field_of_mode);
#endif