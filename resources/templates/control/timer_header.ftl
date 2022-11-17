#ifndef __${robotId}_COMMON_HEADER__
#define __${robotId}_COMMON_HEADER__

#include "semo_common.h"

typedef struct TIMER {
    semo_int32 serviceId;
    semo_int32 statementId;
    semo_int32 timerId;
    int alarmed;
} TIMER;

TIMER* get_timer(semo_int32 serviceId, semo_int32 statementId);
TIMER* new_timer(int time, char *unit, semo_int32 serviceId, semo_int32 statementId);
void remove_timer(TIMER* timer);
void remove_all_timer();
int timer_check(TIMER *timer);

#endif