#include "${robotId}_group.h"

extern LIBFUNC(void, set_robot_id_listen, GROUP group_id, semo_int32 robot_id);
extern LIBFUNC(semo_int8, avail_robot_id_leader, GROUP group_id);
extern LIBFUNC(semo_int32, get_robot_id_leader, GROUP group_id);
extern LIBFUNC(void, set_robot_id_leader, GROUP group_id, semo_int32 robot_id);
extern LIBFUNC(semo_int8, avail_robot_id_report, GROUP group_id);
extern LIBFUNC(semo_int32, get_robot_id_report, GROUP group_id);

extern LIBFUNC(void, set_heartbeat_listen, GROUP group_id, semo_int32 robot_id);
extern LIBFUNC(semo_int8, avail_heartbeat_leader, GROUP group_id);
extern LIBFUNC(semo_int32, get_heartbeat_leader, GROUP group_id);
extern LIBFUNC(void, set_heartbeat_leader, GROUP group_id, semo_int32 robot_id);
extern LIBFUNC(semo_int8, avail_heartbeat_report, GROUP group_id);
extern LIBFUNC(semo_int32, get_heartbeat_report, GROUP group_id);

extern LIBFUNC(void, set_leader_selection_state, GROUP group_id, LEADER_SELECTION_STATE state);
extern LIBFUNC(LEADER_SELECTION_STATE, get_leader_selection_state, GROUP group_id);
extern LIBFUNC(semo_int64, get_last_time, GROUP group_id);
extern LIBFUNC(void, set_last_time, GROUP group_id, semo_int64 time);
extern LIBFUNC(semo_int32, get_leader, GROUP group_id);
extern LIBFUNC(void, set_leader, GROUP group_id, semo_int32 robot_id);

