#ifndef __SEMO_PORT_HEADER__
#define __SEMO_PORT_HEADER__

#include <UFPort.h>
#include "semo_common.h"
#include "semo_variable.h"

typedef struct _PORT
{
    char *port_name;
    int port_id;
    VARIABLE *variable;
} PORT;

typedef struct _COMM_PORT
{
    PORT *port;
    VARIABLE *variable;
    semo_int32 team_id;
} COMM_PORT;

typedef struct _CHANNEL_PORT
{
    char *in_port_name;
    int in_port_id;
    char *out_port_name;
    int out_port_id;
    void *buffer;
    semo_int32 size;
    semo_int8 refreshed;
} CHANNEL_PORT;
#pragma pack(push, 1)
typedef struct _MULTICAST_PACKET_HEADER
{
    semo_int64 time;
    semo_int32 sender_robot_id;
} MULTICAST_PACKET_HEADER;
#pragma pack(pop)
typedef struct _MULTICAST_PACKET
{
    MULTICAST_PACKET_HEADER *header;
    void *data;
} MULTICAST_PACKET;

typedef struct _MULTICAST_PORT
{
    char *multicast_port_name;
    int multicast_group_id;
    int multicast_port_id;
    char *channel_port_name;
    int channel_port_id;
    void *buffer;
    MULTICAST_PACKET *packet;
    semo_int32 size;
    semo_int64 before_time;
    char *multicast_out_port_name;
    int multicast_out_group_id;
    int multicast_out_port_id;
} MULTICAST_PORT;

typedef semo_int8 LIBRARY_AVAIL_FUNC();
typedef void LIBRARY_GET_FUNC(void *buffer);
typedef void LIBRARY_SET_FUNC(void *buffer);
typedef struct _SHARED_DATA_PORT
{
    char *multicast_port_name;
    int multicast_group_id;
    int multicast_port_id;
    LIBRARY_AVAIL_FUNC *lib_avail_func;
    LIBRARY_GET_FUNC *lib_get_func;
    LIBRARY_SET_FUNC *lib_set_func;
    void *buffer;
    MULTICAST_PACKET *packet;
    semo_int32 size;
    semo_int64 before_time;
} SHARED_DATA_PORT;

typedef semo_int8 GROUP_ACTION_AVAIL_FUNC(semo_int32 task_id);
typedef void GROUP_ACTION_SET_FUNC(semo_int32 task_id, semo_int32 robot_id, semo_int64 time);
typedef struct _GROUP_ACTION_PORT
{
    char *multicast_port_name;
    int multicast_group_id;
    int multicast_port_id;
    GROUP_ACTION_AVAIL_FUNC *lib_avail_func;
    GROUP_ACTION_SET_FUNC *lib_set_func;
    void *buffer;
    MULTICAST_PACKET *packet;
    semo_int32 size;
    semo_int64 before_time;
} GROUP_ACTION_PORT;

typedef semo_int8 LEADER_AVAIL_FUNC(semo_int32 group_id);
typedef semo_int32 LEADER_GET_FUNC(semo_int32 group_id);
typedef void LEADER_SET_FUNC(semo_int32 group_id, semo_int32 robot_id);
typedef struct _LEADER_PORT
{
    char *robot_id_port_name;
    int robot_id_group_id;
    int robot_id_port_id;
    void *robot_id_buffer;
    MULTICAST_PACKET *robot_id_packet;
    semo_int64 robot_id_before_time;
    LEADER_AVAIL_FUNC *robot_id_avail_func;
    LEADER_GET_FUNC *robot_id_get_func;
    LEADER_SET_FUNC *robot_id_set_func;

    char *heartbeat_port_name;
    int heartbeat_group_id;
    int heartbeat_port_id;
    void *heartbeat_buffer;
    MULTICAST_PACKET *heartbeat_packet;
    semo_int64 heartbeat_before_time;
    LEADER_AVAIL_FUNC *heartbeat_avail_func;
    LEADER_GET_FUNC *heartbeat_get_func;
    LEADER_SET_FUNC *heartbeat_set_func;

    semo_int32 group_id;
    semo_int32 size;
} LEADER_PORT;
#endif