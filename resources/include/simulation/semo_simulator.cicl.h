extern LIBFUNC(RemoteAPIClient*, get_handler);
extern LIBFUNC(int64_t, get_object, std::string path);
extern LIBFUNC(void, set_joint_target_velocity, int64_t objectHandle, double targetVelocity);