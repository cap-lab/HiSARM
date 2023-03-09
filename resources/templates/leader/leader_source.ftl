typedef struct _SEMO_LEADER {
    GROUP_ID group_id;
    LEADER_SELECTION_STATE leader_selection_state;
    semo_int32 leader_id;
    semo_int64 last_time;

    semo_int32 listen_robot_id;
    semo_int8 listen_robot_id_refreshed;
    HThreadMutex listen_robot_id_mutex;
    semo_int32 listen_heartbeat;
    semo_int8 listen_heartbeat_refreshed;
    HThreadMutex listen_heartbeat_mutex;

    semo_int32 leader_robot_id;
    semo_int8 leader_robot_id_refreshed;
    HThreadMutex leader_robot_id_mutex;
    semo_int32 leader_heartbeat;
    semo_int8 leader_heartbeat_refreshed;
    HThreadMutex leader_heartbeat_mutex;

} SEMO_LEADER;

static SEMO_LEADER leader_list[${groupList?size}] = {
<#list groupList as group>
    {ID_GROUP_${group}, LEADER_SELECTION_STOP, -1},
</#list>
};

LIBFUNC(void, init, void) {
    semo_int32 i;
    for (i = 0; i < ${groupList?size}; i++) {
        UCThreadMutex_Create(&leader_list[i].listen_robot_id_mutex);
        UCThreadMutex_Create(&leader_list[i].listen_heartbeat_mutex);
        UCThreadMutex_Create(&leader_list[i].leader_robot_id_mutex);
        UCThreadMutex_Create(&leader_list[i].leader_heartbeat_mutex);
    }
}

LIBFUNC(void, wrapup, void) {
    semo_int32 i;
    for (i = 0; i < ${groupList?size}; i++) {
        UCThreadMutex_Destroy(&leader_list[i].listen_robot_id_mutex);
        UCThreadMutex_Destroy(&leader_list[i].listen_heartbeat_mutex);
        UCThreadMutex_Destroy(&leader_list[i].leader_robot_id_mutex);
        UCThreadMutex_Destroy(&leader_list[i].leader_heartbeat_mutex);
    }
}
static SEMO_LEADER* find_leader_struct(semo_int32 group_id) {
    semo_int32 i;
    for (i = 0; i < ${groupList?size}; i++) {
        if (leader_list[i].group_id == group_id) {
            return &leader_list[i];
        }
    }
    SEMO_LOG_ERROR("Not Found Leader Struct (Group Id %d)", group_id);
    return NULL;
}

LIBFUNC(void, set_robot_id_listen, semo_int32 group_id, semo_int32 robot_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        UCThreadMutex_Lock(leader->listen_robot_id_mutex);
        if (leader->listen_robot_id_refreshed == FALSE) {
            leader->listen_robot_id = robot_id;
            leader->listen_robot_id_refreshed = TRUE;
        } else {
            if (leader->listen_robot_id > robot_id) {
                leader->listen_robot_id = robot_id;
            }
        }
        UCThreadMutex_Unlock(leader->listen_robot_id_mutex);
    }
}
LIBFUNC(semo_int8, avail_robot_id_leader, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        return leader->listen_robot_id_refreshed;
    }
    return FALSE;
}
LIBFUNC(semo_int32, get_robot_id_leader, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    semo_int32 robot_id = -1;
    if (leader != NULL) {
        UCThreadMutex_Lock(leader->leader_robot_id_mutex);
        robot_id = leader->leader_robot_id;
        leader->listen_robot_id_refreshed = FALSE;
        UCThreadMutex_Unlock(leader->leader_robot_id_mutex);
    }
    return robot_id;
}
LIBFUNC(void, set_robot_id_leader, semo_int32 group_id, semo_int32 robot_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        SEMO_LOG_INFO("Set Leader (Group Id %d, Leader %d)", group_id, robot_id);
        UCThreadMutex_Lock(leader->leader_robot_id_mutex);
        leader->leader_robot_id = robot_id;
        leader->leader_robot_id_refreshed = TRUE;
        UCThreadMutex_Unlock(leader->leader_robot_id_mutex);
    }
}
LIBFUNC(semo_int8, avail_robot_id_report, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        return leader->leader_robot_id_refreshed;
    }
    return FALSE;
}
LIBFUNC(semo_int32, get_robot_id_report, semo_int32 group_id){
    SEMO_LEADER* leader = find_leader_struct(group_id);
    semo_int32 robot_id = -1;
    if (leader != NULL) {
        UCThreadMutex_Lock(leader->leader_robot_id_mutex);
        robot_id = leader->leader_robot_id;
        leader->leader_robot_id_refreshed = FALSE;
        UCThreadMutex_Unlock(leader->leader_robot_id_mutex);
    }
    return robot_id;
}

LIBFUNC(void, set_heartbeat_listen, semo_int32 group_id, semo_int32 robot_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        UCThreadMutex_Lock(leader->listen_heartbeat_mutex);
        if (leader->listen_heartbeat_refreshed == FALSE) {
            leader->listen_heartbeat = robot_id;
            leader->listen_heartbeat_refreshed = TRUE;
        } else {
            if (leader->listen_heartbeat > robot_id) {
                leader->listen_heartbeat = robot_id;
            }
        }
        UCThreadMutex_Unlock(leader->listen_heartbeat_mutex);
    }
}
LIBFUNC(semo_int8, avail_heartbeat_leader, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        return leader->listen_heartbeat_refreshed;
    }
    return FALSE;
}
LIBFUNC(semo_int32, get_heartbeat_leader, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    semo_int32 heartbeat = -1;
    if (leader != NULL) {
        UCThreadMutex_Lock(leader->leader_heartbeat_mutex);
        heartbeat = leader->leader_heartbeat;
        leader->listen_heartbeat_refreshed = FALSE;
        UCThreadMutex_Unlock(leader->leader_heartbeat_mutex);
    }
    return heartbeat;
}
LIBFUNC(void, set_heartbeat_leader, semo_int32 group_id, semo_int32 robot_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        UCThreadMutex_Lock(leader->leader_heartbeat_mutex);
        leader->leader_heartbeat = robot_id;
        leader->leader_heartbeat_refreshed = TRUE;
        UCThreadMutex_Unlock(leader->leader_heartbeat_mutex);
    }
}
LIBFUNC(semo_int8, avail_heartbeat_report, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        return leader->leader_heartbeat_refreshed;
    }
    return FALSE;
}
LIBFUNC(semo_int32, get_heartbeat_report, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    semo_int32 heartbeat = -1;
    if (leader != NULL) {
        UCThreadMutex_Lock(leader->leader_heartbeat_mutex);
        heartbeat = leader->leader_heartbeat;
        leader->leader_heartbeat_refreshed = FALSE;
        UCThreadMutex_Unlock(leader->leader_heartbeat_mutex);
    }
    return heartbeat;
}

LIBFUNC(void, set_leader_selection_state, semo_int32 group_id, LEADER_SELECTION_STATE state) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        SEMO_LOG_INFO("Set Leader Selection State (Group Id %d, State %d)", group_id, state);
        leader->leader_selection_state = state;
    }
}
LIBFUNC(LEADER_SELECTION_STATE, get_leader_selection_state, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        return leader->leader_selection_state;
    }
    return -1;
}

LIBFUNC(semo_int32, get_leader, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        return leader->leader_id;
    }
    return -1;
}
LIBFUNC(void, set_leader, semo_int32 group_id, semo_int32 robot_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        SEMO_LOG_INFO("Set Leader (Group Id %d, Leader %d)", group_id, robot_id);
        leader->leader_id = robot_id;
    }
}

LIBFUNC(semo_int64, get_last_time, semo_int32 group_id) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        return leader->last_time;
    }
    return -1;
}
LIBFUNC(void, set_last_time, semo_int32 group_id, semo_int64 time) {
    SEMO_LEADER* leader = find_leader_struct(group_id);
    if (leader != NULL) {
        leader->last_time = time;
    }
}