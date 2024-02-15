#include "${robotId}_leader.h"
#include "${robotId}_leader_data.h"
#include "${robotId}_group.h"
#include "${robotId}_leader_lib.cicl.h"
#include "${robotId}_port.h"

void ${robotId}_leader_init(LEADER_CLASS *leader){
    leader->leader_list = ${robotId}_leader_list;
    leader->leader_list_size = ${robotId}_leader_list_size;
    leader->leader_selection_info_size = ${robotId}_leader_selection_info_size;
    leader->remove_malfunctioned_robot_func = l_${robotId}_leader_lib_remove_malfunctioned_robot;
    leader->set_leader_selection_state_func = l_${robotId}_leader_lib_set_leader_selection_state;
    leader->get_leader_selection_state_func = l_${robotId}_leader_lib_get_leader_selection_state;
    leader->port_of_leader = &${robotId}_port_of_leader;
    leader_init(leader, ID_GROUP_${robotId}_${initialTeam});
}