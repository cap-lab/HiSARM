static semo_int8 shared_data[${(maxRobotNum * variableType.variableType.count * variableType.variableType.size)?c}];
static semo_int64 shared_data_updated_time[${maxRobotNum?c}];
static semo_int32 shared_data_robot_list[${maxRobotNum?c}];
static semo_int32 shared_data_robot_num;
static semo_int32 shared_data_size = ${(variableType.variableType.count * variableType.variableType.size)?c};
static semo_int8 shared_data_updated;
static HThreadMutex shared_data_mutex;

LIBFUNC(void, init, void) {
    shared_data_updated = FALSE;
    shared_data_robot_num = 1;
    UCThreadMutex_Create(&shared_data_mutex);
}

LIBFUNC(void, wrapup, void) {
    UCThreadMutex_Destroy(&shared_data_mutex);
}

static int get_shared_data_robot_index(semo_int32 robot_id) {
    for (int i = 0 ; i < shared_data_robot_num ; i++) {
        if (shared_data_robot_list[i] == robot_id) {
            return i;
        }
    }
    return -1;
}

LIBFUNC(void, set_shared_data_listen, semo_int32 robot_id, semo_int64 updated_time, semo_int8 *buffer) {
    UCThreadMutex_Lock(shared_data_mutex);
    semo_int32 robotIndex = get_shared_data_robot_index(robot_id);
    if (robotIndex < 0) {
        shared_data_robot_list[shared_data_robot_num] = robot_id;
        shared_data_updated_time[shared_data_robot_num] = updated_time;
        memcpy(&shared_data[shared_data_robot_num * shared_data_size], buffer, shared_data_size);
        shared_data_robot_num++;
    } else {
        if (shared_data_updated_time[robotIndex] < updated_time) {
            shared_data_updated_time[robotIndex] = updated_time;
            memcpy(&shared_data[robotIndex * shared_data_size], buffer, shared_data_size);
        }
    }
    UCThreadMutex_Unlock(shared_data_mutex);
}

LIBFUNC(void, get_shared_data_action, semo_int32 *robot_num, semo_int32 *robot_list, void *buffer) {
    UCThreadMutex_Lock(shared_data_mutex);
    *robot_num = shared_data_robot_num;
    memcpy(robot_list, shared_data_robot_list, shared_data_robot_num * sizeof(semo_int32));
    memcpy(buffer, shared_data, shared_data_robot_num * shared_data_size);
    UCThreadMutex_Unlock(shared_data_mutex);
}

LIBFUNC(semo_int8, get_specific_shared_data_action, semo_int32 robot_id, void *buffer) {
    UCThreadMutex_Lock(shared_data_mutex);
    semo_int32 robot_index = get_shared_data_robot_index(robot_id);
    if (robot_index < 0) {
        UCThreadMutex_Unlock(shared_data_mutex);
        return FALSE;
    }
    memcpy(buffer, &shared_data[robot_index * shared_data_size], shared_data_size);
    UCThreadMutex_Unlock(shared_data_mutex);
    return TRUE;
}

LIBFUNC(void, set_shared_data_action, void *buffer) {
    UCThreadMutex_Lock(shared_data_mutex);
    shared_data_updated = TRUE;
    memcpy(shared_data, buffer, shared_data_size);
    UCThreadMutex_Unlock(shared_data_mutex);
    SEMO_LOG_DEBUG("Set from action");
}

LIBFUNC(void, get_shared_data_report, semo_int8 *buffer) {
    UCThreadMutex_Lock(shared_data_mutex);
    shared_data_updated = FALSE;
    memcpy(buffer, shared_data, shared_data_size);
    UCThreadMutex_Unlock(shared_data_mutex);
}

LIBFUNC(semo_int8, avail_shared_data_report) {
    return  shared_data_updated;
}