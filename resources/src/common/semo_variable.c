#include "semo_variable.h"
#include <string.h>

void fill_buffer_from_elements(VARIABLE *variable)
{
    for (int i = 0; i < variable->element_list_size; i++)
    {
        memcpy(variable->element_list[i], variable->buffer + i, variable->element_size);
    }
}

void fill_elements_from_buffer(VARIABLE *variable)
{
    for (int i = 0; i < variable->element_list_size; i++)
    {
        memcpy(variable->buffer + i, variable->element_list[i], variable->element_size);
    }
}

semo_int8 compare_variable(VARIABLE *var1, VARIABLE *var2)
{
    if (memcmp(var1->buffer, var2->buffer, var1->size) == 0)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

void copy_variable(VARIABLE *src, VARIABLE *dst)
{
    if (src->size != dst->size)
    {
        return;
    }
    fill_buffer_from_elements(src);
    memcpy(dst->buffer, src->buffer, src->size);
    fill_elements_from_buffer(dst);
}