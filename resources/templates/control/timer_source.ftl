#include "${robotId}_timer.h"
#include "${robotId}_common.h"
#include "UFTimer.h"

const semo_int32 timerNum = ${timerCount+1};

TIMER timerList[${timerCount+1}] = {
<#list 0..timerCount as timerIndex>
    {-1, -1, -1, FALSE},
</#list>
};

TIMER* get_timer(semo_int32 service_id, semo_int32 statement_id) {
    for (int i = 0 ; i < timerNum ; i++)
    {
        if(timerList[i].service_id == service_id && timerList[i].statement_id == statement_id)
        {
            return &(timerList[i]);
        }
    }
    return NULL;
}

TIMER* new_timer(int time, char *unit, semo_int32 service_id, semo_int32 statement_id) {
    for (int i = 0 ; i < timerNum ; i++)
    {
        if(timerList[i].timer_id == -1)
        {
            timerList[i].service_id = service_id;
            timerList[i].statement_id = statement_id;
            timerList[i].alarmed = FALSE;
            UFTimer_SetAlarm(CONTROL_TASK_ID, time, unit, &(timerList[i].timer_id));
            return &(timerList[i]);
        }
    }
    return NULL;
}

void remove_timer(TIMER* timer) {
    if(timer != NULL)
    {
        UFTimer_Reset(CONTROL_TASK_ID, timer->timer_id);
        timer->timer_id = -1;
        timer->service_id = -1;
        timer->statement_id = -1;
        timer->alarmed = FALSE;
    }
}

void remove_all_timer() {
	for (int i = 0 ; i < timerNum ; i++)
	{
		if (timerList[i].timer_id != -1)
		{
            remove_timer(&(timerList[i]));
		}
    }
}

int timer_check(TIMER *timer) {
    if(timer != NULL)
    {
        UFTimer_GetAlarmed(CONTROL_TASK_ID, timer->timer_id, &(timer->alarmed));
        return timer->alarmed;
    }
    return FALSE;
}
