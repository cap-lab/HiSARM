#ifndef __SEMO_PORT_HEADER__
#define __SEMO_PORT_HEADER__

#include <UFPort.h>
#include "semo_common.h"
#include "semo_variable.h"

typedef struct _PORT
{
	char *portName;
	int portId;
	VARIABLE *variable;
} PORT;

typedef struct _COMM_PORT
{
	PORT *port;
	VARIABLE *variable;
} COMM_PORT;

typedef struct _CHANNEL_PORT
{
	char *inPortName;
	int inPortId;
	char *outPortName;
	int outPortId;
	void *buffer;
	semo_int32 size;
	semo_int8 refreshed;
} CHANNEL_PORT;

typedef struct _MULTICAST_PACKET_HEADER
{
	semo_int64 time;
	semo_int32 senderRobotId;
} MULTICAST_PACKET_HEADER;

typedef struct _MULTICAST_PACKET
{
	MULTICAST_PACKET_HEADER *header;
	void *data;
} MULTICAST_PACKET;

typedef struct _MULTICAST_PORT
{
	char *multicastPortName;
	int multicastGroupId;
	int multicastPortId;
	char *channelPortName;
	int channelPortId;
	void *buffer;
	MULTICAST_PACKET *packet;
	semo_int32 size;
	semo_int64 beforeTime;
} MULTICAST_PORT;

typedef semo_int8 LIBRARY_AVAIL_FUNC();
typedef void LIBRARY_GET_FUNC(void *buffer);
typedef void LIBRARY_SET_FUNC(void *buffer);
typedef struct _SHARED_DATA_PORT
{
	char *multicastPortName;
	int multicastGroupId;
	int multicastPortId;
	LIBRARY_AVAIL_FUNC *libAvailFunc;
	LIBRARY_GET_FUNC *libGetFunc;
	LIBRARY_SET_FUNC *libSetFunc;
	void *buffer;
	MULTICAST_PACKET *packet;
	semo_int32 size;
	semo_int64 beforeTime;
} SHARED_DATA_PORT;

typedef semo_int8 LEADER_AVAIL_FUNC(semo_int32 groupId);
typedef semo_int32 LEADER_GET_FUNC(semo_int32 groupId);
typedef void LEADER_SET_FUNC(semo_int32 groupId, semo_int32 robotId);
typedef struct _LEADER_PACKET
{
	MULTICAST_PACKET_HEADER header;
	semo_int32 body;
} LEADER_PACKET;
typedef struct _LEADER_PORT
{
	char *robotIdPortName;
	int robotIdGroupId;
	int robotIdPortId;
	LEADER_PACKET robotIdBuffer;
	semo_int64 robotIdBeforeTime;
	LEADER_AVAIL_FUNC *robotIdAvailFunc;
	LEADER_GET_FUNC *robotIdGetFunc;
	LEADER_SET_FUNC *robotIdSetFunc;

	char *heartbeatPortName;
	int heartbeatGroupId;
	int heartbeatPortId;
	LEADER_PACKET heartbeatBuffer;
	semo_int64 heartbeatBeforeTime;
	LEADER_AVAIL_FUNC *heartbeatAvailFunc;
	LEADER_GET_FUNC *heartbeatGetFunc;
	LEADER_SET_FUNC *heartbeatSetFunc;

	semo_int32 groupId;
} LEADER_PORT;
#endif
