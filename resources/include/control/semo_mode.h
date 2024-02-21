#ifndef __SEMO_MODE_HEADER__
#define __SEMO_MODE_HEADER__

#include "semo_common.h"
#include "semo_variable.h"
#include "semo_port.h"
#include "semo_service.h"
#include "semo_group.h"
#include "semo_leader.h"

// MODE STATE DEFINE
typedef struct _MODE {
    semo_int32 mode_id;
    SEMO_STATE state;
    semo_int8 need_select_group;
    semo_int32 selected_group;
    semo_int32 variable_map_list_size;
    VARIABLE_MAP *variable_map_list;
    semo_int32 service_list_size;
    semo_int32 *service_list;
    semo_int32 group;
} MODE;

typedef struct _MODE_CLASS {
    MODE *mode_list;
    semo_int32 mode_list_size;
    PORT *port_of_leader;
    SERVICE_CLASS *service_class;
    LEADER_CLASS *leader_class;
    GROUP_CLASS *group_class;
} MODE_CLASS;

void run_mode(semo_int32 mode_id, MODE_CLASS *mode_class);
void stop_mode(semo_int32 mode_id, MODE_CLASS *mode_class);
#endif