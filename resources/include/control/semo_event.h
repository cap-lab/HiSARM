#ifndef __SEMO_EVENT_HEADER__
#define __SEMO_EVENT_HEADER__

#include "semo_common.h"
#include "semo_port.h"
#include "semo_group.h"

typedef struct _EVENT_CLASS
{
    semo_int8 event_occured;
    semo_int8 *event_list;
    semo_int32 event_list_size;
    COMM_PORT *throw_in_port_list;
    semo_int32 throw_in_port_list_size;
    GROUP_CLASS *group_class;
} EVENT_CLASS;

void event_init(EVENT_CLASS *event_class);
void event_polling(EVENT_CLASS *event_class);
void set_event(semo_int32 event_id, EVENT_CLASS *event_class);
void reset_event(EVENT_CLASS *event_class);

#endif
