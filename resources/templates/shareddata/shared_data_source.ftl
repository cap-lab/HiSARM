typedef struct _${variableType.name} {
    semo_int32 robot_id;
    <#if variableType.type.getValue() == "enum">VARIABLE_${variableType.name}<#else>${variableType.type.value}</#if> buffer[${variableType.count}];
    semo_int32 size;
} VARIABLE_${variableType.name};

VARIABLE_${variableType.name} listen_${variableType.name};
semo_int8 ${variableType.name}_listen_${variableType.name}_updated;
STreadMutex listen_${variableType.name}_mutex;

VARIABLE_${variableType.name} action_${variableType.name};
semo_int8 action_${variableType.name}_updated;
STreadMutex action_${variableType.name}_mutex;


LIBFUNC(void, init, void) {
    listen_${variableType.name}_updated = FALSE;
    action_${variableType.name}_updated = FALSE;
    listen_${variableType.name}.size = ${variableType.getSize()}
    action_${variableType.name}.size = ${variableType.getSize()}
    UCTreadMutex_Create(&listen_${variableType.name}_mutex);
    UCTreadMutex_Create(&action_${variableType.name}_mutex);
}

LIBFUNC(void, wrapup, void) {
    UCTreadMutex_Destroy(&listen_${variableType.name}_mutex);
    UCTreadMutex_Destroy(&action_${variableType.name}_mutex);
}

LIBFUNC(void, set_${variableType.name}_listen, semo_int32 sender_robot, void *buffer) {
    UCTreadMutex_Lock(listen_${variableType.name}_mutex);
    listen_${variableType.name}_updated = TRUE;
    listen_${variableType.name}.robot_id = sender_robot;
    memcpy(listen_${variableType.name}.buffer, buffer, listen_${variableType.name}.size);
    UCTreadMutex_UnLock(listen_${variableType.name}_mutex);
}

LIBFUNC(void, get_${variableType.name}_action, semo_int32 *sender_robot, void *buffer) {
    UCTreadMutex_Lock(listen_${variableType.name}_mutex);
    listen_${variableType.name}_updated = FALSE;
    *sender_robot = listen_${variableType.name}.robot_id;
    memcpy(buffer, listen_${variableType.name}.buffer, listen_${variableType.name}.size);
    UCTreadMutex_UnLock(listen_${variableType.name}_mutex);
}

LIBFUNC(semo_int8, avail_${variableType.name}_action) {
    return listen_${variableType.name}_updated;
}

LIBFUNC(void, set_${variableType.name}_action, void *buffer) {
    UCTreadMutex_Lock(action_${variableType.name}_mutex);
    action_${variableType.name}_updated = TRUE;
    memcpy(action_${variableType.name}.buffer, buffer, action_${variableType.name}.size);
    UCTreadMutex_UnLock(action_${variableType.name}_mutex);
}

LIBFUNC(void, get_${variableType.name}_report, void *buffer) {
    UCTreadMutex_Lock(action_${variableType.name}_mutex);
    action_${variableType.name}_updated = FALSE;
    memcpy(buffer, action_${variableType.name}.buffer, action_${variableType.name}.size);
    UCTreadMutex_UnLock(action_${variableType.name}_mutex);
}

LIBFUNC(semo_int8, avail_${variableType.name}_report) {
    return  action_${variableType.name}_updated;
}