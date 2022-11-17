#include "semo_communication.h"
#include "UFPort.h"

int channelPortRead(int portId, void *buffer, semo_int32 bufferSize, semo_int8 isBuffer)
{
	int dataNum = 0;
	int receivedLength = 0;
	UFPort_GetNumOfAvailableData(portId, 0, &dataNum);
	if (dataNum >= bufferSize)
	{
		if (isBuffer == TRUE)
		{
			UFPort_ReadFromBuffer(portId, (unsigned char *)buffer, bufferSize, 0, &receivedLength);
		}
		else
		{
			UFPort_ReadFromQueue(portId, (unsigned char *)buffer, bufferSize, 0, &receivedLength);
		}
	}

	return receivedLength;
}

int channelPortWrite(int portId, void *buffer, semo_int32 bufferSize, semo_int8 isBuffer)
{
	int dataNum = 0;
	int channelSize = 0;
	int sentLength = 0;
	UFPort_GetNumOfAvailableData(portId, 0, &dataNum);
	channelSize = UFPort_GetChannelSize(portId);
	if (channelSize - dataNum >= bufferSize)
	{
		if (isBuffer == TRUE)
		{
			UFPort_WriteToBuffer(portId, (unsigned char *)buffer, bufferSize, 0, &sentLength);
		}
		else
		{
			UFPort_WriteToQueue(portId, (unsigned char *)buffer, bufferSize, 0, &sentLength);
		}
	}
	return sentLength;
}
