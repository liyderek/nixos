#include <libinput.h>
#include <stdbool.h>

struct libinput_device {
    const char *name;
    unsigned int vendor;
    unsigned int product;
    int fingers;
    bool supports_custom;
    bool reject_points;
    bool reject_apply;
    enum libinput_config_accel_profile profile;
    unsigned int applications;
    double motion_step;
    double scroll_step;
    double gesture_step;
    size_t motion_count;
    size_t scroll_count;
    size_t gesture_count;
    double motion[64];
    double scroll[64];
    double gestures[64];
};
