#include "semo_leader.h"

void leader_init(LEADER_CLASS *leader_class, semo_int32 initial_team) {
   register_leader_selection(leader_class, initial_team);
}

void register_leader_selection(LEADER_CLASS *leader_class, semo_int32 group_id) {
    leader_class->set_leader_selection_state_func(group_id, LEADER_SELECTION_NOT_SELECTED);
}

void unregister_leader_selection(LEADER_CLASS *leader_class, semo_int32 group_id) {
    leader_class->set_leader_selection_state_func(group_id, LEADER_SELECTION_STOP);
}

void check_leader_selection_state(LEADER_CLASS *leader_class) {
    for (int i = 0 ; i < leader_class->leader_list_size ; i++){
        semo_int32 group_id = leader_class->leader_list[i].group_id;
        LEADER_SELECTION_STATE state = leader_class->get_leader_selection_state_func(group_id);
        if (state == LEADER_SELECTION_STOP) {
            continue;
        }
        semo_int8 result = leader_class->remove_malfunctioned_robot_func(group_id);
        if (result == TRUE){
            leader_class->set_leader_selection_state_func(group_id, LEADER_SELECTION_NOT_SELECTED);
        }
        if (state == LEADER_SELECTION_SELECTED && 
            (leader_class->leader_list[i].new_robot_added==TRUE || leader_class->leader_list[i].duplicated_leader==TRUE)) {
            leader_class->set_leader_selection_state_func(group_id, LEADER_SELECTION_COLLISION);
        }
    }
}