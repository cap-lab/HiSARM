#ifndef __SEMO_LOGGER_HEADER__
#define __SEMO_LOGGER_HEADER__

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdio.h>
#include <string.h>

#define SEMO_LOGLEVEL_INFO

#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

#if defined(SEMO_LOGLEVEL_DEBUG)
#define SEMO_LOG_DEBUG(fmt, ...) fprintf(stderr, "%s: [%s,%s,%d] " fmt "\n", "DEBUG", __FILENAME__, __func__, __LINE__, ##__VA_ARGS__)
#else
#define SEMO_LOG_DEBUG(fmt, ...)
#endif

#if defined(SEMO_LOGLEVEL_DEBUG) || defined(SEMO_LOGLEVEL_INFO)
#define SEMO_LOG_INFO(fmt, ...) fprintf(stderr, "%s: [%s,%s,%d] " fmt "\n", "INFO", __FILENAME__, __func__, __LINE__, ##__VA_ARGS__)
#else
#define SEMO_LOG_INFO(fmt, ...)
#endif

#if defined(SEMO_LOGLEVEL_DEBUG) || defined(SEMO_LOGLEVEL_INFO) || defined(SEMO_LOGLEVEL_WARN)
#define SEMO_LOG_WARN(fmt, ...) fprintf(stderr, "%s: [%s,%s,%d] " fmt "\n", "WARN", __FILENAME__, __func__, __LINE__, ##__VA_ARGS__)
#else
#define SEMO_LOG_WARN(fmt, ...)
#endif

#if defined(SEMO_LOGLEVEL_DEBUG) || defined(SEMO_LOGLEVEL_INFO) || defined(SEMO_LOGLEVEL_WARN) || defined(SEMO_LOGLEVEL_ERROR)
#define SEMO_LOG_ERROR(fmt, ...) fprintf(stderr, "%s: [%s,%s,%d] " fmt "\n", "ERROR", __FILENAME__, __func__, __LINE__, ##__VA_ARGS__)
#else
#define SEMO_LOG_ERROR(fmt, ...)
#endif

#ifdef __cplusplus
}
#endif
#endif