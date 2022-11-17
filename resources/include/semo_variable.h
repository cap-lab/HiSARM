#ifndef __SEMO_VARIABLE_HEADER__
#define __SEMO_VARIABLE_HEADER__

#include "semo_common.h"

typedef struct _VARIABLE
{
    semo_int32 size;
    void *buffer;
    semo_int32 element_size;
    semo_int32 element_list_size;
    void *element_list;
} VARIABLE;

void fill_buffer_from_elements(VARIABLE *variable);
void fill_elements_from_buffer(VARIABLE *variable);
semo_int8 compare_variable(VARIABLE *var1, VARIABLE *var2);
#endif