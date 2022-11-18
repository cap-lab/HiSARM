#ifndef __SEMO_COMMON_HEADER__
#define __SEMO_COMMON_HEADER__

#ifdef __cplusplus
extern "C"
{
#endif

    typedef char semo_int8;
    typedef short semo_int16;
    typedef long semo_int32;
    typedef long long semo_int64;
    typedef unsigned char semo_uint8;
    typedef unsigned short semo_uint16;
    typedef unsigned long semo_uint32;
    typedef unsigned long long semo_uint64;

    typedef enum _SEMO_DIRECTION
    {
        SEMO_DIRECTION_IN,
        SEMO_DIRECTION_OUT
    } SEMO_DIRECTION;

    typedef enum _SEMO_STATE
    {
        SEMO_RUN,
        SEMO_STOP,
        SEMO_WRAPUP,
        SEMO_PENDING,
    } SEMO_STATE;

#ifndef TRUE
#define TRUE (1)
#endif

#ifndef SEMO_VALID
#define SEMO_VALID (1)
#endif

#ifndef FALSE
#define FALSE (0)
#endif

#ifndef SEMO_INVALID
#define SEMO_INVALID (0)
#endif

#ifndef NULL
#define NULL (void *)(0)
#endif

#ifndef ROBOT_ID_MAX
#define ROBOT_ID_MAX 1000000
#endif

#ifdef __cplusplus
}
#endif

#endif