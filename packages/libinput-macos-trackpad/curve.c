#define _GNU_SOURCE
#include <dlfcn.h>
#include <libinput.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "curve-points.h"

#ifndef MOTION_SCALE
#define MOTION_SCALE 1.0
#endif
#ifndef MAX_GAIN
#define MAX_GAIN 0.0
#endif
#ifndef GESTURE_SCALE
#define GESTURE_SCALE 1.0
#endif

/* Remove only this preload from the environment inherited by spawned apps. */
__attribute__((constructor)) static void detach_preload(void)
{
    Dl_info info;
    const char *preload = getenv("LD_PRELOAD");
    if (!preload || !dladdr((void *)detach_preload, &info))
        return;

    char *copy = strdup(preload);
    char *remaining = calloc(strlen(preload) + 1, 1);
    if (!copy || !remaining) {
        free(copy);
        free(remaining);
        return;
    }

    bool removed = false;
    char *save = NULL;
    for (char *item = strtok_r(copy, " :", &save); item;
         item = strtok_r(NULL, " :", &save)) {
        if (strcmp(item, info.dli_fname) == 0) {
            removed = true;
            continue;
        }
        if (*remaining)
            strcat(remaining, ":");
        strcat(remaining, item);
    }
    if (removed) {
        if (*remaining)
            setenv("LD_PRELOAD", remaining, 1);
        else
            unsetenv("LD_PRELOAD");
    }
    free(remaining);
    free(copy);
}

static bool is_builtin_trackpad(struct libinput_device *device)
{
    const char *name = libinput_device_get_name(device);
    return name && strcmp(name, "Apple SPI Trackpad") == 0 &&
           libinput_device_get_id_vendor(device) == 0x05ac &&
           libinput_device_get_id_product(device) == 0x0341 &&
           libinput_device_config_tap_get_finger_count(device) > 0;
}

enum libinput_config_status
libinput_device_config_accel_set_profile(struct libinput_device *device,
                                        enum libinput_config_accel_profile profile)
{
    static enum libinput_config_status (*original)(struct libinput_device *,
                                                  enum libinput_config_accel_profile);
    static _Thread_local bool applying;
    if (!original)
        original = dlsym(RTLD_NEXT, "libinput_device_config_accel_set_profile");
    if (!original)
        return LIBINPUT_CONFIG_STATUS_UNSUPPORTED;

    if (applying || !is_builtin_trackpad(device) ||
        !(libinput_device_config_accel_get_profiles(device) &
          LIBINPUT_CONFIG_ACCEL_PROFILE_CUSTOM))
        return original(device, profile);

    struct libinput_config_accel *config =
        libinput_config_accel_create(LIBINPUT_CONFIG_ACCEL_PROFILE_CUSTOM);
    if (!config)
        return original(device, profile);

    size_t count = sizeof(curve_points) / sizeof(curve_points[0]);
    double scroll_points[sizeof(curve_points) / sizeof(curve_points[0])];
    double motion_points[sizeof(curve_points) / sizeof(curve_points[0])];
    for (size_t i = 0; i < count; i++) {
        double limit = i * curve_step * MAX_GAIN;
        scroll_points[i] = MAX_GAIN > 0 && curve_points[i] > limit
                               ? limit : curve_points[i];
        motion_points[i] = scroll_points[i] * MOTION_SCALE;
    }
    enum libinput_config_status status = libinput_config_accel_set_points(
        config, LIBINPUT_ACCEL_TYPE_MOTION, curve_step, count, motion_points);
    if (status == LIBINPUT_CONFIG_STATUS_SUCCESS)
        status = libinput_config_accel_set_points(
            config, LIBINPUT_ACCEL_TYPE_SCROLL, curve_step, count, scroll_points);
    if (status == LIBINPUT_CONFIG_STATUS_SUCCESS) {
        /* Niri uses unaccelerated swipe deltas, routed through this fallback. */
        const double gesture_points[] = {0.0, GESTURE_SCALE};
        status = libinput_config_accel_set_points(
            config, LIBINPUT_ACCEL_TYPE_FALLBACK, 1.0, 2, gesture_points);
    }
    if (status == LIBINPUT_CONFIG_STATUS_SUCCESS) {
        /* apply() may call set_profile(); bypass this hook during that call. */
        applying = true;
        status = libinput_device_config_accel_apply(device, config);
        applying = false;
    }
    libinput_config_accel_destroy(config);

    if (status != LIBINPUT_CONFIG_STATUS_SUCCESS) {
        fprintf(stderr, "libinput-macos-trackpad: custom curve rejected (%d)\n", status);
        return original(device, profile);
    }

    fputs("libinput-macos-trackpad: applied custom motion and scroll curves\n", stderr);
    return status;
}
