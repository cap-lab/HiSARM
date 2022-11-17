#ifndef __SEMO_LEADER_HEADER__
#define __SEMO_LEADER_HEADER__

#define LEADER_SELECTION_PERIOD 1
#define LEADER_SELECTION_THRESHOLD 60000
#define LEADER_HEARTBEAT_PERIOD 1
#define LEADER_HEARTBEAT_THRESHOLD 60000

typedef enum _LEADER_SELECTION_STATE
{
	LEADER_SELECTION_STOP,
	LEADER_SELECTION_NOT_SELECTED,
	LEADER_SELECTION_SELECTED,
} LEADER_SELECTION_STATE;

#endif
