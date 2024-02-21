#ifndef __SEMO_GROUP_HEADER__
#define __SEMO_GROUP_HEADER__

#include "semo_common.h"
#include "semo_port.h"
#include "semo_leader.h"

typedef struct _SEMO_GROUP
{
    semo_int32 id;
    semo_int32 min;
} SEMO_GROUP;

typedef enum _SEMO_GROUP_SELECTION_STATE
{
    SEMO_GROUP_SELECTION_INITIALIZE,
    SEMO_GROUP_SELECTION_PAUSE,
    SEMO_GROUP_SELECTION_RUN,
    SEMO_GROUP_SELECTION_STOP,
    SEMO_GROUP_SELECTION_WRAPUP
} SEMO_GROUP_SELECTION_STATE;

typedef struct _GROUP_CLASS {
    semo_int32 *group_list;
    semo_int32 group_list_size;
    semo_int32 *group_state_list;
    semo_int32 *selecting_mode;
    semo_int32 current_selecting_mode;
    PORT *port_of_grouping_mode;
    PORT *port_of_grouping_result;
    PORT *port_of_leader;
    LEADER_CLASS *leader_class;
} GROUP_CLASS;

void group_init(GROUP_CLASS *group_class,  semo_int32 initial_team);
void set_group_state(semo_int32 group, semo_int32 refer_count, GROUP_CLASS *group_class);
semo_int8 get_group_state(semo_int32 group, GROUP_CLASS *group_class);
void register_group_selection(semo_int32 mode_id, semo_int32 *field_of_mode, GROUP_CLASS *group_class);
void check_group_selection_state(GROUP_CLASS *group_class);
void stop_selecting_group(semo_int32 mode_id, semo_int32 *field_of_mode, GROUP_CLASS *group_class);
semo_int32 get_group_id(semo_int32 index, GROUP_CLASS *group_class);
#endif