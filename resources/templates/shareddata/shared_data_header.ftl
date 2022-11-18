#include "${robotId}_variable.h"

extern LIBFUNC(void, init, void);
extern LIBFUNC(void, wrapup, void);

extern LIBFUNC(void, set_${variableType.name}_listen, void *buffer);
extern LIBFUNC(void, get_${variableType.name}_action, void *buffer);
extern LIBFUNC(semo_int8, avail_${variableType.name}_action);
extern LIBFUNC(void, set_${variableType.name}_action, void *buffer);
extern LIBFUNC(void, get_${variableType.name}_report, void *buffer);
extern LIBFUNC(semo_int8, avail_${variableType.name}_report);