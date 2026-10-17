#include "fake-libinput.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>

struct libinput_config_accel {
    enum libinput_config_accel_profile profile;
    double step[3];
    size_t count[3];
    double points[3][64];
};

static bool reject_points;

const char *libinput_device_get_name(struct libinput_device *device)
{
    return device->name;
}

unsigned int libinput_device_get_id_vendor(struct libinput_device *device)
{
    return device->vendor;
}

unsigned int libinput_device_get_id_product(struct libinput_device *device)
{
    return device->product;
}

int libinput_device_config_tap_get_finger_count(struct libinput_device *device)
{
    return device->fingers;
}

uint32_t libinput_device_config_accel_get_profiles(struct libinput_device *device)
{
    reject_points = device->reject_points;
    return LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE |
           LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT |
           (device->supports_custom ? LIBINPUT_CONFIG_ACCEL_PROFILE_CUSTOM : 0);
}

enum libinput_config_status
libinput_device_config_accel_set_profile(struct libinput_device *device,
                                        enum libinput_config_accel_profile profile)
{
    device->profile = profile;
    return LIBINPUT_CONFIG_STATUS_SUCCESS;
}

struct libinput_config_accel *
libinput_config_accel_create(enum libinput_config_accel_profile profile)
{
    struct libinput_config_accel *config = calloc(1, sizeof(*config));
    if (config)
        config->profile = profile;
    return config;
}

void libinput_config_accel_destroy(struct libinput_config_accel *config)
{
    free(config);
}

enum libinput_config_status
libinput_config_accel_set_points(struct libinput_config_accel *config,
                                enum libinput_config_accel_type type, double step,
                                size_t count, const double *points)
{
    assert(config->profile == LIBINPUT_CONFIG_ACCEL_PROFILE_CUSTOM);
    assert(type == LIBINPUT_ACCEL_TYPE_MOTION || type == LIBINPUT_ACCEL_TYPE_SCROLL ||
           type == LIBINPUT_ACCEL_TYPE_FALLBACK);
    assert(step > 0 && count >= 2 && count <= 64);
    if (reject_points)
        return LIBINPUT_CONFIG_STATUS_INVALID;
    config->step[type] = step;
    config->count[type] = count;
    memcpy(config->points[type], points, count * sizeof(*points));
    return LIBINPUT_CONFIG_STATUS_SUCCESS;
}

enum libinput_config_status
libinput_device_config_accel_apply(struct libinput_device *device,
                                  struct libinput_config_accel *config)
{
    if (device->reject_apply)
        return LIBINPUT_CONFIG_STATUS_UNSUPPORTED;
    /* Exercise reentrancy through the interposed setter, as libinput may do. */
    libinput_device_config_accel_set_profile(device, config->profile);
    device->applications++;
    device->motion_step = config->step[LIBINPUT_ACCEL_TYPE_MOTION];
    device->scroll_step = config->step[LIBINPUT_ACCEL_TYPE_SCROLL];
    device->gesture_step = config->step[LIBINPUT_ACCEL_TYPE_FALLBACK];
    device->motion_count = config->count[LIBINPUT_ACCEL_TYPE_MOTION];
    device->scroll_count = config->count[LIBINPUT_ACCEL_TYPE_SCROLL];
    device->gesture_count = config->count[LIBINPUT_ACCEL_TYPE_FALLBACK];
    memcpy(device->motion, config->points[LIBINPUT_ACCEL_TYPE_MOTION], sizeof(device->motion));
    memcpy(device->scroll, config->points[LIBINPUT_ACCEL_TYPE_SCROLL], sizeof(device->scroll));
    memcpy(device->gestures, config->points[LIBINPUT_ACCEL_TYPE_FALLBACK], sizeof(device->gestures));
    return LIBINPUT_CONFIG_STATUS_SUCCESS;
}
