#ifndef __SEMO_GROUPING_HEADER__
#define __SEMO_GROUPING_HEADER__
#include "semo_common.h"
typedef struct _SEMO_GROUP
{
    semo_int32 id;
    semo_int32 min;
} SEMO_GROUP;
typedef struct _SEMO_GROUPING_SHARED
{
    semo_int32 robot_id;
    semo_int32 count;
} SEMO_GROUPING_SHARED;
typedef enum _SEMO_GROUP_SELECTION_STATE
{
    SEMO_GROUP_SELECTION_INITIALIZE,
    SEMO_GROUP_SELECTION_PAUSE,
    SEMO_GROUP_SELECTION_RUN,
    SEMO_GROUP_SELECTION_STOP,
    SEMO_GROUP_SELECTION_WRAPUP
} SEMO_GROUP_SELECTION_STATE;
#endif