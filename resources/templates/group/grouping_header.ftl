#ifndef __${robotId}_GROUPING_HEADER__
#define __${robotId}_GROUPING_HEADER__

#include "semo_group.h"
#include "${robotId}_group.h"
#include "${robotId}_mode.h"

extern LIBFUNC(SEMO_GROUP*, get_grouping_candidate_list);
extern LIBFUNC(semo_int32, get_grouping_candidate_num);
extern LIBFUNC(void, get_group_info, semo_int32 group_id, SEMO_GROUP *group)
extern LIBFUNC(void, get_shared_data_grouping, semo_int32 index, semo_uint8 *data, semo_uint32 length);
extern LIBFUNC(void, get_shared_data_report, semo_int32 *mode_id, semo_uint8 *data, semo_int32 length);
extern LIBFUNC(semo_int8, avail_shared_data_report);
extern LIBFUNC(void, set_grouping_state, semo_int32 mode, SEMO_GROUP_SELECTION_STATE state);
extern LIBFUNC(SEMO_GROUP_SELECTION_STATE, get_grouping_state, semo_int32 mode);
extern LIBFUNC(void, set_shared_data_grouping, semo_uint8 *data, semo_int32 length);
extern LIBFUNC(void, set_shared_data_listen, semo_int32 robot_id, semo_int32 mode_id, semo_uint8 *data, semo_int32 length);
extern LIBFUNC(semo_int32, get_shared_robot_num);

#endif