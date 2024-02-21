#ifndef __SEMO_SERVICE_HEADER__
#define __SEMO_SERVICE_HEADER__

#include "semo_common.h"
#include "semo_action.h"
#include "semo_timer.h"
#include "semo_resource.h"
#include "semo_event.h"
#include "semo_port.h"

typedef struct _ACTION_MAP {
    semo_int32 action_type_id;
    semo_int32 action_task_list_size;
    semo_int32 *action_task_list;
} ACTION_MAP;

typedef enum _STATEMENT_TYPE {
    STATEMENT_TYPE_ACTION,
    STATEMENT_TYPE_RECEIVE,
    STATEMENT_TYPE_SEND,
    STATEMENT_TYPE_IF,
    STATEMENT_TYPE_THROW,
    STATEMENT_TYPE_NONE
} STATEMENT_TYPE;

typedef struct _STATEMENT_ACTION_INFO {
    semo_int32 action_type_id;
} STATEMENT_ACTION_INFO;

typedef struct _STATEMENT_COMMUNICATION_INFO {
    COMM_PORT *port;
} STATEMENT_COMMUNICATION_INFO;

typedef struct _STATEMENT_CONDITION_INFO {
    VARIABLE *left_variable;
    VARIABLE *right_variable;
    semo_int8 has_timer;
    semo_int32 timer_time;
    char* timer_unit;
} STATEMENT_CONDITION_INFO;

typedef struct _STATEMENT_THROW_INFO {
    semo_int32 event_id;
    semo_int8 is_broadcast;
    COMM_PORT *port;
} STATEMENT_THROW_INFO;

typedef semo_int8 (*SERVICE_STATEMENT_EXECUTION_FUNC)(semo_int32 service_id, semo_int32 statement, void *info, void *service_class);

typedef struct _STATEMENT {
    semo_int32 statement_id;
    STATEMENT_TYPE statement_type;
    void *statement_info;
    SERVICE_STATEMENT_EXECUTION_FUNC execution_func;
} STATEMENT;

typedef struct _SERVICE_STATEMENT_TRANSITION {
    STATEMENT *statement;
    semo_int32 next_true_statement_id;
    semo_int32 next_false_statement_id;
} SERVICE_STATEMENT_TRANSITION;

typedef struct _SERVICE {
    semo_int32 service_id;
    SEMO_STATE state;
    semo_int32 action_list_size;
    ACTION_MAP *action_list;
    semo_int32 current_statement_id;
    SERVICE_STATEMENT_TRANSITION *statement_transition_list;
    semo_int32 group;
} SERVICE;

typedef struct _SERVICE_CLASS {
    SERVICE *service_list;
    semo_int32 service_list_size;
    ACTION_CLASS *action_class;
    TIMER_CLASS *timer_class;
    RESOURCE_CLASS *resource_class;
    EVENT_CLASS *event_class;
} SERVICE_CLASS;

// DECLARE EXTERN FUNCTION
void service_init(SERVICE_CLASS *service_class);
void execute_service(SERVICE_CLASS *service_class);
void run_service(semo_int32 service_id, semo_int32 group, SERVICE_CLASS *service_class);
void stop_service(semo_int32 service_id, SERVICE_CLASS *service_class);
semo_int8 execute_action(semo_int32 service_id, semo_int32 statement, void *info, void *service_class);
semo_int8 execute_receive(semo_int32 service_id, semo_int32 statement, void *info, void *service_class);
semo_int8 execute_send(semo_int32 service_id, semo_int32 statement, void *info, void *service_class);
semo_int8 execute_if(semo_int32 service_id, semo_int32 statement, void *info, void *service_class);
semo_int8 execute_throw(semo_int32 service_id, semo_int32 statement, void *info, void *service_class);


#endif