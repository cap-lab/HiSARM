#define GROUP_ACTION_INITIAL_THRESHOLD 3000
#define GROUP_ACTION_REFRESHED_THRESHOLD 1000

typedef struct _SEMO_GROUP_ACTION {
    semo_int32 action_id;
    semo_int8 sync_state;
    semo_int64 last_time;
    semo_int32 *robot_list;
    semo_int32 robot_list_index;
    semo_int8 refreshed;
    semo_int32 threshold;
    HThreadMutex mutex;
    HThreadMutex report_mutex;
} SEMO_GROUP_ACTION;

<#list groupActionList as ga>
semo_int32 robot_list_${ga.groupActionIndex}[${NumOfRobot}];
</#list>

static SEMO_GROUP_ACTION group_action_list[${groupActionList?size}] = {
<#list groupActionList as ga>
    {${ga.groupActionIndex}, FALSE, -1, robot_list_${ga.groupActionIndex}, 0, FALSE, GROUP_ACTION_INITIAL_THRESHOLD,},
</#list>
};

LIBFUNC(void, init, void) {
    for (int i = 0 ; i < ${groupActionList?size} ; i++) {
        UCThreadMutex_Create(&group_action_list[i].mutex);
        UCThreadMutex_Create(&group_action_list[i].report_mutex);
    }
}

LIBFUNC(void, wrapup, void) {
    for (int i = 0 ; i < ${groupActionList?size} ; i++) {
        UCThreadMutex_Destroy(&group_action_list[i].mutex);
        UCThreadMutex_Destroy(&group_action_list[i].report_mutex);
    }
}

static SEMO_GROUP_ACTION* find_group_action_struct(semo_int32 action_id) {
    semo_int32 i;
    for (i = 0; i < ${groupActionList?size}; i++) {
        if (group_action_list[i].action_id == action_id) {
            return &group_action_list[i];
        }
    }
    SEMO_LOG_ERROR("Not Found Group Action Struct (Action Id %d)", action_id);
    return NULL;
}

LIBFUNC(void, set_group_action_listen, semo_int32 action_id, semo_int32 robot_id, semo_int64 time) {
    SEMO_GROUP_ACTION* group_action = find_group_action_struct(action_id);
    if (group_action != NULL) {
        if (group_action->sync_state == TRUE) {
            semo_int8 refreshed = TRUE;
            for (int index = 0 ; index < group_action->robot_list_index ; index++) {
                if (group_action->robot_list[index] == robot_id) {
                    refreshed = FALSE;
                    break;
                }
            }
            if (refreshed == TRUE) {
                UCThreadMutex_Lock(group_action->mutex);
                group_action->robot_list[group_action->robot_list_index] = robot_id;
                group_action->robot_list_index++;
                if (time - group_action->last_time < GROUP_ACTION_REFRESHED_THRESHOLD){
                    group_action->threshold = GROUP_ACTION_REFRESHED_THRESHOLD;
                }
                group_action->last_time = time;
                UCThreadMutex_Unlock(group_action->mutex);
                SEMO_LOG_INFO("New Robot (Action Id %d, Robot Id %d, Time %lld)", action_id, robot_id, time);
            }
        }
    }
}

LIBFUNC(void, set_group_action_control, semo_int32 action_id, semo_int8 sync_state, semo_int64 time) {
    SEMO_GROUP_ACTION* group_action = find_group_action_struct(action_id);
    if (group_action != NULL) {
        group_action->sync_state = sync_state;
        UCThreadMutex_Lock(group_action->mutex);
        group_action->robot_list_index = 0;
        group_action->last_time = time;
        group_action->threshold = GROUP_ACTION_INITIAL_THRESHOLD;
        UCThreadMutex_Unlock(group_action->mutex);
        SEMO_LOG_INFO("Set Group Action State (Action Id %d, State %d, Time %lld)", action_id, sync_state, time);
    }
}

LIBFUNC(void, set_robot_id_control, semo_int32 action_id) {
    SEMO_GROUP_ACTION* group_action = find_group_action_struct(action_id);
    if (group_action != NULL) {
        if (group_action->sync_state == FALSE) {
            SEMO_LOG_ERROR("Group Action Sync State is False (Action Id %d)", action_id);
            return FALSE;
        }
        UCThreadMutex_Lock(group_action->report_mutex);
        group_action->refreshed = TRUE;
        UCThreadMutex_Unlock(group_action->report_mutex);
    }
}

LIBFUNC(semo_int8, get_group_action_control, semo_int32 action_id, semo_int64 time) {
    SEMO_GROUP_ACTION* group_action = find_group_action_struct(action_id);
    if (group_action != NULL) {
        if (group_action->sync_state == FALSE) {
            SEMO_LOG_ERROR("Group Action Sync State is False (Action Id %d)", action_id);
            return FALSE;
        }
        if (time - group_action->last_time > group_action->threshold) {
            SEMO_LOG_INFO("Group Action Sync Finished (Action Id %d, Time %lld)", action_id, time);
            return TRUE;
        }
    }
    return FALSE;
}

LIBFUNC(semo_int8, avail_group_action_report, semo_int32 action_id) {
    SEMO_GROUP_ACTION* group_action = find_group_action_struct(action_id);
    if (group_action != NULL) {
        if (group_action->sync_state == FALSE) {
            return FALSE;
        }
        if (group_action->refreshed == TRUE) {
            UCThreadMutex_Lock(group_action->report_mutex);
            group_action->refreshed = FALSE;
            UCThreadMutex_Unlock(group_action->report_mutex);
            return TRUE;
        }
    }
    return FALSE;
}