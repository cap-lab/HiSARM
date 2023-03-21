#include "${robotId}_action.h"

extern LIBFUNC(void, set_group_action_listen, semo_int32 action_id, semo_int32 robot_id, semo_int64 time);
extern LIBFUNC(void, set_group_action_control, semo_int32 action_id, semo_int8 sync_state, semo_int64 time);
extern LIBFUNC(void, set_robot_id_control, semo_int32 action_id);
extern LIBFUNC(semo_int8, get_group_action_control, semo_int32 action_id, semo_int64 time);
extern LIBFUNC(semo_int8, avail_group_action_report, semo_int32 action_id);