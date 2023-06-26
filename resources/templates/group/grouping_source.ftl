typedef struct _SEMO_GROUPING_DATA {
    semo_int32 mode_id;
    SEMO_GROUP_SELECTION_STATE state;
    SEMO_GROUP *candidate_group_list;
    semo_int32 candidate_group_list_length;
} SEMO_GROUPING_DATA;

static SEMO_GROUPING_SHARED shared_robot_list[${maxRobotNum}];
static semo_uint8 shared_data_buffer[${maxRobotNum*sharedDataSize}];
static semo_int32 shared_robot_num;
static HThreadMutex shared_data_mutex;
static semo_int8 shared_data_refreshed;

static SEMO_GROUPING_DATA *current_mode_grouping_data;

<#list groupingModeSet as mode>
SEMO_GROUP candidate_group_list_${mode}[${groupingLib.getGroupList(mode)?size}] = {
    <#list groupingLib.getGroupList(mode) as group>
    {ID_GROUP_${groupingLib.makeGroupId(mode, group.getGroup().getName())}, ${group.getGroup().getMin()}},
    </#list>
};

</#list>
SEMO_GROUPING_DATA grouping_data[${groupingModeSet?size}] = {
<#list groupingModeSet as mode>
    {
        ID_MODE_${mode}, // semo_int32 mode_id
        SEMO_GROUP_SELECTION_STOP, // SEMO_GROUP_SELECTION_STATE state
        candidate_group_list_${mode}, // SEMO_GROUP *candidate_group_list
        ${groupingLib.getGroupList(mode)?size}, // semo_int32 candidate_group_list_length
    },
</#list>
};

LIBFUNC(void, init, void) {
    UCThreadMutex_Create(&shared_data_mutex);
    current_mode_grouping_data = (SEMO_GROUPING_DATA*) NULL;
    shared_data_refreshed = FALSE;
}

LIBFUNC(void, wrapup, void) {
    UCThreadMutex_Destroy(&shared_data_mutex);
}

static SEMO_GROUPING_SHARED* find_shared_robot_info(semo_int32 robot) {
    for (int i = 0 ; i < shared_robot_num ; i++) {
        if (shared_robot_list[i].robot_id == robot) {
            return &shared_robot_list[i];
        }
    }
    return (SEMO_GROUPING_SHARED*) NULL;
}

static semo_uint8* find_shared_data_for_target_robot(semo_int32 robot, semo_int32 length) {
    for (int i = 0 ; i < shared_robot_num ; i++) {
        if (shared_robot_list[i].robot_id == robot) {
            return shared_data_buffer + i*length;
        }
    }
    SEMO_LOG_ERROR("Not Found Robot Data (robot %d)", robot);
    return (semo_uint8*) NULL;
}

static SEMO_GROUPING_DATA* find_data_for_target_mode(semo_int32 mode) {
    for (int i = 0 ; i < ${groupingModeSet?size} ; i++) {
        if (grouping_data[i].mode_id == mode) {
            return grouping_data + i;
        }
    }
    SEMO_LOG_ERROR("Not Found Grouping Data (mode %d)", mode);
    return (SEMO_GROUPING_DATA*) NULL;
}

static SEMO_GROUP* find_group_in_current_mode(semo_int32 group_id) {
    for (int i = 0 ; i < current_mode_grouping_data->candidate_group_list_length ; i++) {
        if (current_mode_grouping_data->candidate_group_list[i].id == group_id) {
            return current_mode_grouping_data->candidate_group_list + i;
        }
    }

    SEMO_LOG_ERROR("Not Found GROUP (group %d)", group_id);
    return (SEMO_GROUP*) NULL;
}

static void parameter_wrapup() {
    UCThreadMutex_Lock(shared_data_mutex);
    current_mode_grouping_data = (SEMO_GROUPING_DATA*) NULL;
    shared_robot_num = -1;
    shared_data_refreshed = FALSE;
    UCThreadMutex_Unlock(shared_data_mutex);
}

static void parameter_init(SEMO_GROUPING_DATA *mode_group) {
    UCThreadMutex_Lock(shared_data_mutex);
    current_mode_grouping_data = mode_group;
    shared_robot_list[0].robot_id = THIS_ROBOT_ID;
    shared_robot_list[0].count = 0;
    shared_robot_num = 1;
    shared_data_refreshed = FALSE;
    UCThreadMutex_Unlock(shared_data_mutex);
}

LIBFUNC(SEMO_GROUP*, get_grouping_candidate_list) {
    if (current_mode_grouping_data == (SEMO_GROUPING_DATA*) NULL) {
        SEMO_LOG_ERROR("Group Selection has not Initialized");
        return (SEMO_GROUP*) NULL;
    }
    return current_mode_grouping_data->candidate_group_list;
}

LIBFUNC(semo_int32, get_grouping_candidate_num) {
    if (current_mode_grouping_data == (SEMO_GROUPING_DATA*) NULL) {
        SEMO_LOG_ERROR("Group Selection has not been Initialized");
        return -1;
    }
    return current_mode_grouping_data->candidate_group_list_length;
}

LIBFUNC(void, get_group_info, semo_int32 group_id, SEMO_GROUP *group) {
    if (current_mode_grouping_data == (SEMO_GROUPING_DATA*)  NULL) {
        SEMO_LOG_ERROR("Group Selection has not been Initialized");
        return;
    }
    SEMO_GROUP *foundGroup = find_group_in_current_mode(group_id);
    if (foundGroup == (SEMO_GROUP*) NULL) {
        return;
    }
    memcpy(group, foundGroup, sizeof(SEMO_GROUP));
}

LIBFUNC(void, get_shared_data_grouping, semo_int32 index, semo_uint8 *data, semo_int32 length) {
    if (current_mode_grouping_data == (SEMO_GROUPING_DATA*) NULL) {
        SEMO_LOG_ERROR("Group Selection has not Initialized");
        return;
    }
    if (index >= shared_robot_num) {
        SEMO_LOG_ERROR("Out of index (shared robot %d, index %d)", shared_robot_num, index);
        return;
    }
    UCThreadMutex_Lock(shared_data_mutex);
    memcpy(data, shared_data_buffer + length*index, length);
    UCThreadMutex_Unlock(shared_data_mutex);
}

LIBFUNC(void, get_shared_data_report, semo_int32 *mode, SEMO_GROUPING_SHARED *robot_info_list, semo_int32 *robot_num, semo_uint8 *data, semo_int32 length) {
    if (current_mode_grouping_data == (SEMO_GROUPING_DATA*) NULL) {
        return;
    }
    UCThreadMutex_Lock(shared_data_mutex);
    *mode = current_mode_grouping_data->mode_id;
    *robot_num = shared_robot_num;
    memcpy(robot_info_list, shared_robot_list, shared_robot_num*sizeof(SEMO_GROUPING_SHARED));
    memcpy(data, shared_data_buffer, shared_robot_num*length);
    shared_data_refreshed = FALSE;
    UCThreadMutex_Unlock(shared_data_mutex);
    if (current_mode_grouping_data->state == SEMO_GROUP_SELECTION_WRAPUP) {
        current_mode_grouping_data->state = SEMO_GROUP_SELECTION_STOP;
        parameter_wrapup();
    }
}

LIBFUNC(semo_int8, avail_shared_data_report) {
    if (current_mode_grouping_data == (SEMO_GROUPING_DATA*) NULL) {
        return FALSE;
    }
    return shared_data_refreshed;
}

LIBFUNC(void, set_grouping_state, semo_int32 mode, SEMO_GROUP_SELECTION_STATE state) {
    SEMO_GROUPING_DATA *mode_group = find_data_for_target_mode(mode);
    if (mode_group == (SEMO_GROUPING_DATA*) NULL) {
        return;
    }
    mode_group->state = state;
    switch(state) {
        case SEMO_GROUP_SELECTION_INITIALIZE:
            parameter_init(mode_group);
            break;
        case SEMO_GROUP_SELECTION_STOP:
            parameter_wrapup();
            break;
        case SEMO_GROUP_SELECTION_WRAPUP:
        case SEMO_GROUP_SELECTION_PAUSE:
        case SEMO_GROUP_SELECTION_RUN:
            break;
        default:
            SEMO_LOG_ERROR("Wrong group selection state %d", state);
    }
}

LIBFUNC(SEMO_GROUP_SELECTION_STATE, get_grouping_state, semo_int32 mode) {
    return current_mode_grouping_data->state; 
}

LIBFUNC(void, set_shared_data_grouping, semo_uint8 *data, semo_int32 length) {
    if (current_mode_grouping_data == (SEMO_GROUPING_DATA*) NULL) {
        SEMO_LOG_ERROR("Group Selection has not Initialized");
        return;
    }
    UCThreadMutex_Lock(shared_data_mutex);
    shared_robot_list[0].count += 1;
    shared_data_refreshed = TRUE;
    memcpy(shared_data_buffer, data, length);
    UCThreadMutex_Unlock(shared_data_mutex);
}

LIBFUNC(void, set_shared_data_listen, semo_int32 mode_id, SEMO_GROUPING_SHARED *robot_info_list, semo_int32 robot_num, semo_uint8 *data, semo_int32 length) {
    if (current_mode_grouping_data == (SEMO_GROUPING_DATA*) NULL) {
        return;
    }

    if (current_mode_grouping_data->mode_id != mode_id) {
        return;
    }

    UCThreadMutex_Lock(shared_data_mutex);
    for (int i = 0 ; i < robot_num ; i++) {
        SEMO_GROUPING_SHARED *robot_info = find_shared_robot_info(robot_info_list[i].robot_id);
        if (robot_info == (SEMO_GROUPING_SHARED*) NULL) {
            memcpy(shared_data_buffer + length*shared_robot_num, data+i*length, length);
            shared_robot_list[shared_robot_num].robot_id = robot_info_list[i].robot_id;
            shared_robot_list[shared_robot_num].count = robot_info_list[i].count;
            shared_robot_num++;
        } else if (robot_info->count < robot_info_list[i].count) {
            semo_uint8 *shared_data = find_shared_data_for_target_robot(robot_info_list[i].robot_id, length);
            robot_info->count = robot_info_list[i].count;
            memcpy(shared_data, data+i*length, length);
        }
    }
    UCThreadMutex_Unlock(shared_data_mutex);
}

LIBFUNC(semo_int32, get_shared_robot_num) {
    if (current_mode_grouping_data == (SEMO_GROUPING_DATA*) NULL) {
        SEMO_LOG_ERROR("Group Selection has not Initialized");
        return -1;
    }

    return shared_robot_num;
}
