#include "${robotId}_event.h"
#include "${robotId}_port.h"
#include <string.h>
#include "semo_logger.h"

semo_int8 event_list[${eventList?size}] = {<#list 1..eventList?size as i>FALSE,</#list>};
semo_int8 event_occured = FALSE;

void event_list_init() {
    SEMO_LOG_INFO("evetn init");
    memset(event_list, FALSE, ${eventList?size}*sizeof(semo_int8));
}

void event_polling() {
    int dataNum = 0;
    int dataLen = 0;
    semo_int32 event;
    for (int i = 0 ; i < throw_in_port_list_size ; i++)
    {
        uem_result result = UFPort_GetNumOfAvailableData(throw_in_port_list[i].port->port_id, 0, &dataNum);
        ERRIFGOTO(result, _EXIT);
        if (dataNum > 0)
        {
            UFPort_ReadFromQueue(throw_in_port_list[i].port->port_id, (unsigned char*) &event, sizeof(semo_int32), 0, &dataLen);
            event_list[event] = TRUE;
        }
    }
_EXIT:
    return;
}