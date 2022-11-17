#include "${robotId}_timer.h"
#include "UFTimre.h"

const semo_int32 timerNum = ${timerCount};

TIMER timerList[${timerCount}] = {
<#list 1..timerCount as timerIndex>
    {-1, -1, -1, -1, FALSE},
</#list>
};

TIMER* get_timer(semo_int32 serviceId, semo_int32 statementId) {
    for (int i = 0 ; i < timerNum ; i++)
    {
        if(timerList[i].serviceId == serviceId && timerList[i].statementId == statementId)
        {
            return &(timerList[i]);
        }
    }
    return NULL;
}

TIMER* new_timer(int time, char *unit, semo_int32 serviceId, semo_int32 statementId) {
    int uem_result;
    for (int i = 0 ; i < timerNum ; i++)
    {
        if(timerList[i].timerId == -1)
        {
            timerList[i].serviceId = serviceId;
            timerList[i].statementId = statementId;
            timerList[i].alarmed = FALSE;
            uem_result = UFTimer_SetAlarm(CONTROL_TASK_ID, time, unit, &(timerList[i].timerId));
            return &(timerList[i]);
        }
    }
    return NULL;
}

void remove_timer(TIMER* timer) {
    if(timer != NULL)
    {
        UFTimer_Reset(CONTROL_TASK_ID, timer->timerId);
        timer->timerId = -1;
        timer->serviceId = -1;
        timer->statementId = -1;
        timer->alarmed = FALSE;
    }
}

void remove_all_timer() {
	for (int i = 0 ; i < timerNum ; i++)
	{
		if (timerList[i].timerId != -1)
		{
            remove_timer(&(timerList[i]));
		}
    }
}

int timer_check(TIMER *timer) {
    if(timer != NULL)
    {
        UFTimer_GetAlarmed(CONTROL_TASK_ID, timer->timerId, &(timer->alarmed));
        return timer->alarmed;
    }
    return FALSE;
}
