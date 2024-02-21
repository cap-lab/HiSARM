#ifndef __SEMO_PORT_HEADER__
#define __SEMO_PORT_HEADER__

#include "UFPort.h"
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
typedef struct _MULTICAST_PACKET_HEADER {
    semo_int64 time;
    semo_int32 sender_robot_id;
} MULTICAST_PACKET_HEADER;
#pragma pack(pop)
typedef struct _MULTICAST_PACKET
{
    semo_int64 before_time;
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
    MULTICAST_PACKET *packet;
    semo_int32 size;
    char *multicast_out_port_name;
    int multicast_out_group_id;
    int multicast_out_port_id;
} MULTICAST_PORT;

typedef struct _SHARED_DATA_PACKET
{
    semo_int64 before_time;
    MULTICAST_PACKET_HEADER *header;
    semo_int8 *data;
} SHARED_DATA_PACKET;

typedef semo_int8 SHARED_DATA_AVAIL_FUNC();
typedef void SHARED_DATA_GET_FUNC(semo_int8 *buffer);
typedef void SHARED_DATA_SET_FUNC(semo_int32 robot_id, semo_int64 updated_time, semo_int8 *buffer);
typedef struct _SHARED_DATA_PORT
{
    char *multicast_port_name;
    int multicast_group_id;
    int multicast_port_id;
    SHARED_DATA_AVAIL_FUNC *lib_avail_func;
    SHARED_DATA_GET_FUNC *lib_get_func;
    SHARED_DATA_SET_FUNC *lib_set_func;
    SHARED_DATA_PACKET *packet;
    semo_int32 size;
    char *multicast_out_port_name;
    int multicast_out_group_id;
    int multicast_out_port_id;
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
    MULTICAST_PACKET *packet;
    semo_int32 size;
    char *multicast_out_port_name;
    int multicast_out_group_id;
    int multicast_out_port_id;
} GROUP_ACTION_PORT;

typedef struct _LEADER_SELECTION_INFO_PACKET
{
    semo_int64 before_time;
    MULTICAST_PACKET_HEADER *header;
    semo_int8 *data;
} LEADER_SELECTION_INFO_PACKET;
typedef struct _LEADER_HEARTBEAT_PACKET
{
    semo_int64 before_time;
    MULTICAST_PACKET_HEADER *header;
    semo_int32 *leader_id;
} LEADER_HEARTBEAT_PACKET;

typedef semo_int8 LEADER_AVAIL_FUNC(semo_int32 group_id);
typedef void LEADER_SELECTION_INFO_GET_FUNC(semo_int32 group_id, semo_int8 *data);
typedef void LEADER_SELECTION_INFO_SET_FUNC(semo_int32 group_id, semo_int32 robot_id, semo_int64 updated_time, semo_int8 *data);
typedef void LEADER_HEARTBEAT_GET_FUNC(semo_int32 group_id, semo_int32 *leader_id);
typedef void LEADER_HEARTBEAT_SET_FUNC(semo_int32 group_id, semo_int32 robot_id , semo_int64 updated_time, semo_int32 leader_id);
typedef struct _LEADER_PORT
{
    char *selection_info_port_name;
    int selection_info_group_id;
    int selection_info_port_id;
    LEADER_SELECTION_INFO_PACKET *selection_info_packet;
    LEADER_AVAIL_FUNC *selection_info_avail_func;
    LEADER_SELECTION_INFO_GET_FUNC *selection_info_get_func;
    LEADER_SELECTION_INFO_SET_FUNC *selection_info_set_func;

    char *heartbeat_port_name;
    int heartbeat_group_id;
    int heartbeat_port_id;
    LEADER_HEARTBEAT_PACKET *heartbeat_packet;
    LEADER_AVAIL_FUNC *heartbeat_avail_func;
    LEADER_HEARTBEAT_GET_FUNC *heartbeat_get_func;
    LEADER_HEARTBEAT_SET_FUNC *heartbeat_set_func;

    semo_int32 group_id;

    char *selection_info_out_port_name;
    int selection_info_out_group_id;
    int selection_info_out_port_id;
    char *heartbeat_out_port_name;
    int heartbeat_out_group_id;
    int heartbeat_out_port_id;
} LEADER_PORT;

#pragma pack(push, 1)
typedef struct _GROUPING_PACKET_HEADER
{
    semo_int64 time;
    semo_int32 sender_robot_id;
    semo_int32 mode_id;
} GROUPING_PACKET_HEADER;

typedef struct _GROUPING_PACKET
{
    semo_int64 before_time;
    GROUPING_PACKET_HEADER *header;
    void *data;
} GROUPING_PACKET;

#pragma pack(pop)
typedef semo_int8 GROUPING_AVAIL_FUNC();
typedef void GROUPING_GET_FUNC(semo_int32 *mode_id, semo_uint8 *data);
typedef void GROUPING_SET_FUNC(semo_int32 mode_id, semo_int32 robot_id, semo_int64 updated_time, semo_uint8 *data);
typedef struct _GROUPING_PORT
{
    char *multicast_port_name;
    int multicast_group_id;
    int multicast_port_id;
    GROUPING_AVAIL_FUNC *lib_avail_func;
    GROUPING_GET_FUNC *lib_get_func;
    GROUPING_SET_FUNC *lib_set_func;
    GROUPING_PACKET *packet;
    char *multicast_out_port_name;
    int multicast_out_group_id;
    int multicast_out_port_id;
} GROUPING_PORT;

#endif