#ifndef __${robotId}_COMMON_HEADER__
#define __${robotId}_COMMON_HEADER__

#include "semo_common.h"

typedef struct TIMER {
    semo_int32 service_id;
    semo_int32 statement_id;
    int timer_id;
    int alarmed;
} TIMER;

TIMER* get_timer(semo_int32 service_id, semo_int32 statement_id);
TIMER* new_timer(int time, char *unit, semo_int32 service_id, semo_int32 statement_id);
void remove_timer(TIMER* timer);
void remove_all_service_timer(semo_int32 service_id);
void remove_all_timer();
int timer_check(TIMER *timer);

#endif