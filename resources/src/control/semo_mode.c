#include "semo_mode.h"
#include "semo_logger.h"

void stop_mode(semo_int32 mode_id, MODE_CLASS *mode_class)
{
    SEMO_LOG_INFO("stop mode %d", mode_id);
    mode_class->mode_list[mode_id].state = SEMO_STOP;
    for (int i = 0 ; i < mode_class->mode_list[mode_id].service_list_size; i++)
    {
        stop_service(mode_class->mode_list[mode_id].service_list[i], mode_class->service_class);
    }
    if (mode_class->mode_list[mode_id].need_select_group == TRUE) {
        stop_selecting_group(mode_id, &mode_class->mode_list[mode_id].selected_group, mode_class->group_class);
    }
    set_group_state(mode_class->mode_list[mode_id].group, SEMO_DECREASE, mode_class->group_class);
    if (get_group_state(mode_class->mode_list[mode_id].group, mode_class->group_class) == 0) 
    {
        unregister_leader_selection(mode_class->leader_class, mode_class->mode_list[mode_id].group);
    }
}

void run_mode(semo_int32 mode_id, MODE_CLASS *mode_class)
{
    SEMO_LOG_INFO("run mode %d", mode_id);
    mode_class->mode_list[mode_id].state = SEMO_RUN;
    for (int i = 0 ; i < mode_class->mode_list[mode_id].variable_map_list_size ; i++)
    {
        copy_variable(mode_class->mode_list[mode_id].variable_map_list[i].src, mode_class->mode_list[mode_id].variable_map_list[i].dst);
    }
    for (int i = 0 ; i < mode_class->mode_list[mode_id].service_list_size; i++)
    {
        run_service(mode_class->mode_list[mode_id].service_list[i], mode_class->mode_list[mode_id].group, mode_class->service_class);
    }
    if (mode_class->mode_list[mode_id].need_select_group == TRUE) {
        register_group_selection(mode_id, &mode_class->mode_list[mode_id].selected_group, mode_class->group_class);
    }
    set_group_state(mode_class->mode_list[mode_id].group, SEMO_INCREASE, mode_class->group_class);
}