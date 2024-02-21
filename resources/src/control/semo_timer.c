#include "semo_timer.h"
#include "semo_logger.h"
#include "UFTimer.h"

TIMER* get_timer(semo_int32 service_id, semo_int32 statement_id, TIMER_CLASS *timer_class) {
    for (int i = 0 ; i < timer_class->timer_list_size ; i++)
    {
        if(timer_class->timer_list[i].service_id == service_id && timer_class->timer_list[i].statement_id == statement_id)
        {
            return &(timer_class->timer_list[i]);
        }
    }
    return NULL;
}

TIMER* new_timer(int time, char *unit, semo_int32 service_id, semo_int32 statement_id, TIMER_CLASS *timer_class) {
    for (int i = 0 ; i < timer_class->timer_list_size ; i++)
    {
        if(timer_class->timer_list[i].timer_id == -1)
        {
            timer_class->timer_list[i].service_id = service_id;
            timer_class->timer_list[i].statement_id = statement_id;
            timer_class->timer_list[i].alarmed = FALSE;
            UFTimer_SetAlarm(timer_class->control_task_id, time, unit, &(timer_class->timer_list[i].timer_id));
            return &(timer_class->timer_list[i]);
        }
    }
    return NULL;
}

void remove_timer(TIMER* timer, TIMER_CLASS *timer_class) {
    if(timer != NULL)
    {
        UFTimer_Reset(timer_class->control_task_id, timer->timer_id);
        timer->timer_id = -1;
        timer->service_id = -1;
        timer->statement_id = -1;
        timer->alarmed = FALSE;
    }
}

void remove_all_service_timer(semo_int32 service_id, TIMER_CLASS *timer_class) {
    for (int i = 0 ; i < timer_class->timer_list_size ; i++)
	{
		if (timer_class->timer_list[i].timer_id != -1 && timer_class->timer_list[i].service_id == service_id)
		{
            remove_timer(&(timer_class->timer_list[i]), timer_class);
		}
    }
}

void remove_all_timer(TIMER_CLASS *timer_class) {
	for (int i = 0 ; i < timer_class->timer_list_size ; i++)
	{
		if (timer_class->timer_list[i].timer_id != -1)
		{
            remove_timer(&(timer_class->timer_list[i]), timer_class);
		}
    }
}

int timer_check(TIMER *timer, TIMER_CLASS *timer_class) {
    if(timer != NULL)
    {
        UFTimer_GetAlarmed(timer_class->control_task_id, timer->timer_id, &(timer->alarmed));
        return timer->alarmed;
    }
    return FALSE;
}
