#include "semo_event.h"
#include "semo_logger.h"

void event_init(EVENT_CLASS *event_class) {
    SEMO_LOG_INFO("event init");
    event_class->event_occured = FALSE;
    memset(event_class->event_list, FALSE, event_class->event_list_size*sizeof(semo_int8));
}

void set_event(semo_int32 event, EVENT_CLASS *event_class) {
    event_class->event_occured = TRUE;
    event_class->event_list[event] = TRUE;
}

void event_polling(EVENT_CLASS *event_class) {
    int dataNum = 0;
    int dataLen = 0;
    semo_int32 event;
    for (int i = 0 ; i < event_class->throw_in_port_list_size ; i++)
    {
        UFPort_GetNumOfAvailableData(event_class->throw_in_port_list[i].port->port_id, 0, &dataNum);
        if (dataNum > 0)
        {
            UFPort_ReadFromQueue(event_class->throw_in_port_list[i].port->port_id, (unsigned char*) &event, sizeof(semo_int32), 0, &dataLen);
            if(get_group_state(event_class->throw_in_port_list[i].team_id, event_class->group_class) <= 0) 
            {
                continue;
            }
            set_event(event, event_class);
        }
    }
    return;
}

void reset_event(EVENT_CLASS *event_class) {
    event_class->event_occured = FALSE;
    memset(event_class->event_list, FALSE, event_class->event_list_size*sizeof(semo_int8));
}