#include "${robotId}_event.h"
#include "${robotId}_port.h"
#include "${robotId}_group.h"
#include "semo_logger.h"

semo_int8 ${robotId}_event_list[${eventList?size}] = {<#list 1..eventList?size as i>FALSE,</#list>};

void ${robotId}_event_init(EVENT_CLASS *event_class, GROUP_CLASS *group_class) {
    SEMO_LOG_INFO("event init");
    event_class->event_list = ${robotId}_event_list;
    event_class->event_list_size = ${eventList?size};
    event_class->throw_in_port_list = ${robotId}_throw_in_port_list;
    event_class->throw_in_port_list_size = ${robotId}_throw_in_port_list_size;
    event_class->group_class = group_class;
    event_init(event_class);
}