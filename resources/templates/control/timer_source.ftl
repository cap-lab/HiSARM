#include "${robotId}_timer.h"
#include "${robotId}_common.h"
#include "semo_logger.h"

static TIMER ${robotId}_timer_list[${timerCount+1}] = {
<#list 0..timerCount as timerIndex>
    {-1, -1, -1, FALSE},
</#list>
};

void ${robotId}_timer_init(int control_task_id, TIMER_CLASS* timer_class) {
    SEMO_LOG_INFO("timer init");
    timer_class->timer_list = ${robotId}_timer_list;
    timer_class->timer_list_size = ${timerCount + 1};
    timer_class->control_task_id = control_task_id;
}