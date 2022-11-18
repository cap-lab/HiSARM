#include "${robotId}_event.h"
#include "${robotId}_port.h"
#include <string.h>

semo_int8 event_list[${eventList?size}] = {<#list 1..eventList?size as i>FALSE,</#list>};
semo_int8 event_occured = FALSE;

void event_list_init() {
    memset(event_list, FALSE, ${eventList?size}*sizeof(semo_int8));
}

void event_polling() {
    int dataNum = 0;
    int dataLen = 0;
    semo_int32 event;
    for (int i = 0 ; i < throw_in_port_list_size ; i++)
    {
        UFPort_GetNumOfAvailableData(throw_in_port_list[i].port->portId, 0, &dataNum);
        if (dataNum > 0)
        {
            UFPort_ReadFromQueue(throw_in_port_list[i].port->portId, (unsigned char*) &event, sizeof(semo_int32), 0, &dataLen);
            event_list[event] = TRUE;
        }
    }
}