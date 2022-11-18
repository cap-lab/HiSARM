typedef struct _${variableType.name} {
    <#if variableType.type.getValue() == "enum">VARIABLE_${variableType.name}<#else>${variableType.type.value}</#if> buffer[${variableType.count}];
    semo_int32 size;
} SHARED_VARIABLE_${variableType.name};

static SHARED_VARIABLE_${variableType.name} listen_${variableType.name};
static semo_int8 listen_${variableType.name}_updated;
static HThreadMutex listen_${variableType.name}_mutex;

static SHARED_VARIABLE_${variableType.name} action_${variableType.name};
static semo_int8 action_${variableType.name}_updated;
static HThreadMutex action_${variableType.name}_mutex;


LIBFUNC(void, init, void) {
    listen_${variableType.name}_updated = FALSE;
    action_${variableType.name}_updated = FALSE;
    listen_${variableType.name}.size = ${variableType.getSize()};
    action_${variableType.name}.size = ${variableType.getSize()};
    UCThreadMutex_Create(&listen_${variableType.name}_mutex);
    UCThreadMutex_Create(&action_${variableType.name}_mutex);
}

LIBFUNC(void, wrapup, void) {
    UCThreadMutex_Destroy(&listen_${variableType.name}_mutex);
    UCThreadMutex_Destroy(&action_${variableType.name}_mutex);
}

LIBFUNC(void, set_${variableType.name}_listen, void *buffer) {
    UCThreadMutex_Lock(listen_${variableType.name}_mutex);
    listen_${variableType.name}_updated = TRUE;
    memcpy(listen_${variableType.name}.buffer, buffer, listen_${variableType.name}.size);
    UCThreadMutex_Unlock(listen_${variableType.name}_mutex);
}

LIBFUNC(void, get_${variableType.name}_action, void *buffer) {
    UCThreadMutex_Lock(listen_${variableType.name}_mutex);
    listen_${variableType.name}_updated = FALSE;
    memcpy(buffer, listen_${variableType.name}.buffer, listen_${variableType.name}.size);
    UCThreadMutex_Unlock(listen_${variableType.name}_mutex);
}

LIBFUNC(semo_int8, avail_${variableType.name}_action) {
    return listen_${variableType.name}_updated;
}

LIBFUNC(void, set_${variableType.name}_action, void *buffer) {
    UCThreadMutex_Lock(action_${variableType.name}_mutex);
    action_${variableType.name}_updated = TRUE;
    memcpy(action_${variableType.name}.buffer, buffer, action_${variableType.name}.size);
    UCThreadMutex_Unlock(action_${variableType.name}_mutex);
}

LIBFUNC(void, get_${variableType.name}_report, void *buffer) {
    UCThreadMutex_Lock(action_${variableType.name}_mutex);
    action_${variableType.name}_updated = FALSE;
    memcpy(buffer, action_${variableType.name}.buffer, action_${variableType.name}.size);
    UCThreadMutex_Unlock(action_${variableType.name}_mutex);
}

LIBFUNC(semo_int8, avail_${variableType.name}_report) {
    return  action_${variableType.name}_updated;
}