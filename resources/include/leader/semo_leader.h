#ifndef __SEMO_LEADER_HEADER__
#define __SEMO_LEADER_HEADER__

#include "semo_common.h"
#include "semo_port.h"
#include "UCThreadMutex.h"

#define LEADER_SELECTION_PERIOD 100
#define LEADER_SELECTION_TIMEOUT 10000

typedef enum _LEADER_SELECTION_STATE
{
	LEADER_SELECTION_STOP,
	LEADER_SELECTION_NOT_SELECTED,
	LEADER_SELECTION_SELECTED,
	LEADER_SELECTION_COLLISION,
} LEADER_SELECTION_STATE;

typedef struct _SEMO_LEADER_SELECTION_INFO {
	semo_int32 robot_id;
	semo_int64 last_updated_time;
	semo_int8 *data;
} SEMO_LEADER_SELECTION_INFO;

typedef struct _SEMO_LEADER_HEARTBEAT {
	semo_int32 robot_id;
	semo_int64 last_heartbeat_time;
	semo_int8 leader_id;
} SEMO_LEADER_HEARTBEAT;

typedef struct _SEMO_LEADER {
    semo_int32 group_id;
    LEADER_SELECTION_STATE leader_selection_state;
    semo_int32 leader_id;

    semo_int8 selection_info_refreshed;
    SEMO_LEADER_SELECTION_INFO *selection_info_robot_list;
	semo_int32 selection_info_robot_num;

	SEMO_LEADER_HEARTBEAT *heartbeat_robot_list;
	semo_int32 heartbeat_robot_num;
	semo_int8 new_robot_added;
	semo_int8 duplicated_leader;

	HThreadMutex selection_info_mutex;
	HThreadMutex heartbeat_mutex;
} SEMO_LEADER;

typedef semo_int8 REMOVE_MALFUNCTIONED_ROBOT_FUNC(semo_int32 group_id);
typedef void SET_LEADER_SELECTION_STATE_FUNC(semo_int32 group_id, LEADER_SELECTION_STATE state);
typedef LEADER_SELECTION_STATE GET_LEADER_SELECTION_STATE_FUNC(semo_int32 group_id);

typedef struct _LEADER_CLASS {
	SEMO_LEADER *leader_list;
	semo_int32 leader_list_size;
	semo_int32 leader_selection_info_size;
	REMOVE_MALFUNCTIONED_ROBOT_FUNC *remove_malfunctioned_robot_func;
	SET_LEADER_SELECTION_STATE_FUNC *set_leader_selection_state_func;
	GET_LEADER_SELECTION_STATE_FUNC *get_leader_selection_state_func;
	PORT *port_of_leader;
} LEADER_CLASS;

void leader_init(LEADER_CLASS *leader_class, semo_int32 initial_team);
void register_leader_selection(LEADER_CLASS *leader_class, semo_int32 group_id);
void unregister_leader_selection(LEADER_CLASS *leader_class, semo_int32 group_id);
void check_leader_selection_state(LEADER_CLASS *leader_class);
#endif
