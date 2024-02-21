#ifndef __SEMO_TIMER_HEADER__
#define __SEMO_TIMER_HEADER__

#include "semo_common.h"

typedef struct TIMER {
    semo_int32 service_id;
    semo_int32 statement_id;
    int timer_id;
    int alarmed;
} TIMER;

typedef struct TIMER_CLASS {
    semo_int32 timer_list_size;
    TIMER *timer_list;
    semo_int32 control_task_id;
} TIMER_CLASS;

TIMER* get_timer(semo_int32 service_id, semo_int32 statement_id, TIMER_CLASS *timer_class);
TIMER* new_timer(int time, char *unit, semo_int32 service_id, semo_int32 statement_id, TIMER_CLASS *timer_class);
void remove_timer(TIMER* timer, TIMER_CLASS *timer_class);
void remove_all_service_timer(semo_int32 service_id, TIMER_CLASS *timer_class);
void remove_all_timer(TIMER_CLASS *timer_class);
int timer_check(TIMER *timer, TIMER_CLASS *timer_class);

#endif