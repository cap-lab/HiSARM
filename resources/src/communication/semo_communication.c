#include "semo_communication.h"
#include "UFPort.h"

int channel_port_read(int port_id, void *buffer, semo_int32 buffer_size, semo_int8 is_buffer)
{
	int data_num = 0;
	int received_length = 0;
	uem_result result = UFPort_GetNumOfAvailableData(port_id, 0, &data_num);
	ERRIFGOTO(result, _EXIT);

	if (data_num >= buffer_size)
	{
		if (is_buffer == TRUE)
		{
			UFPort_ReadFromBuffer(port_id, (unsigned char *)buffer, buffer_size, 0, &received_length);
		}
		else
		{
			UFPort_ReadFromQueue(port_id, (unsigned char *)buffer, buffer_size, 0, &received_length);
		}
	}
_EXIT:
	return received_length;
}

int channel_port_write(int port_id, void *buffer, semo_int32 buffer_size, semo_int8 is_buffer)
{
	int data_num = 0;
	int channel_size = 0;
	int sent_length = 0;
	uem_result result = UFPort_GetNumOfAvailableData(port_id, 0, &data_num);
	ERRIFGOTO(result, _EXIT);
	channel_size = UFPort_GetChannelSize(port_id);
	if (channel_size - data_num >= buffer_size)
	{
		if (is_buffer == TRUE)
		{
			UFPort_WriteToBuffer(port_id, (unsigned char *)buffer, buffer_size, 0, &sent_length);
		}
		else
		{
			UFPort_WriteToQueue(port_id, (unsigned char *)buffer, buffer_size, 0, &sent_length);
		}
	}
_EXIT:
	return sent_length;
}
