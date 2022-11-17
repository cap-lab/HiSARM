#ifndef __SEMO_COMMUNICATION_HEADER__
#define __SEMO_COMMUNICATION_HEADER__

#include "semo_common.h"

int channelPortRead(int portId, void *buffer, semo_int32 bufferSize, semo_int8 isBuffer);
int channelPortWrite(int portId, void *buffer, semo_int32 bufferSize, semo_int8 isBuffer);

#endif
