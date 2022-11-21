#ifndef __SEMO_COMMUNICATION_HEADER__
#define __SEMO_COMMUNICATION_HEADER__

#include "semo_common.h"

int channel_port_read(int port_id, void *buffer, semo_int32 buffer_size, semo_int8 is_buffer);
int channel_port_write(int port_id, void *buffer, semo_int32 buffer_size, semo_int8 is_buffer);

#endif
