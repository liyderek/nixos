#include "fake-libinput.h"
#include <assert.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#ifndef EXPECTED_MOTION_SCALE
#define EXPECTED_MOTION_SCALE 1.0
#endif
#ifndef EXPECTED_MAX_GAIN
#define EXPECTED_MAX_GAIN 0.0
#endif
#ifndef EXPECTED_GESTURE_SCALE
#define EXPECTED_GESTURE_SCALE 1.0
#endif

static double expected_sample(double base, double speed)
{
    return EXPECTED_MAX_GAIN > 0 ? fmin(base, speed * EXPECTED_MAX_GAIN) : base;
}

static struct libinput_device builtin_trackpad(void)
{
    return (struct libinput_device){
        .name = "Apple SPI Trackpad",
        .vendor = 0x05ac,
        .product = 0x0341,
        .fingers = 5,
        .supports_custom = true,
    };
}

static void configure(struct libinput_device *device)
{
    assert(libinput_device_config_accel_set_profile(
               device, LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE) ==
           LIBINPUT_CONFIG_STATUS_SUCCESS);
}

static void check_passthrough(struct libinput_device device)
{
    configure(&device);
    assert(device.applications == 0);
    assert(device.profile == LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE);
}

int main(void)
{
    /* The curve must stay local to the compositor, not its child apps. */
    const char *expected_preload = getenv("EXPECTED_PRELOAD");
    const char *preload = getenv("LD_PRELOAD");
    assert((!expected_preload && !preload) ||
           (expected_preload && preload && strcmp(expected_preload, preload) == 0));

    struct libinput_device device = builtin_trackpad();
    configure(&device);
    assert(device.applications == 1);
    assert(device.profile == LIBINPUT_CONFIG_ACCEL_PROFILE_CUSTOM);
    assert(device.motion_step == 0.5 && device.scroll_step == 0.5);
    assert(device.motion_count == 20 && device.scroll_count == 20);
    /* Swipes need their own constant gain, independent of motion/scroll curves. */
    assert(device.gesture_step == 1.0 && device.gesture_count == 2);
    assert(device.gestures[0] == 0.0);
    assert(fabs(device.gestures[1] - EXPECTED_GESTURE_SCALE) < 1e-9);
    const double gesture_speeds[] = {0.01, 1.0, 10.0, 100.0, 1000.0};
    double gesture_slope = (device.gestures[1] - device.gestures[0]) /
                           device.gesture_step;
    for (size_t i = 0; i < sizeof(gesture_speeds) / sizeof(gesture_speeds[0]); i++) {
        double delta = device.gestures[0] + gesture_slope * gesture_speeds[i];
        assert(fabs(delta / gesture_speeds[i] - EXPECTED_GESTURE_SCALE) < 1e-9);
    }
    for (size_t i = 0; i < device.motion_count; i++)
        assert(fabs(device.motion[i] - device.scroll[i] * EXPECTED_MOTION_SCALE) < 1e-9);
    /* Independent reference samples from the supplied script's printed output. */
    assert(device.motion[0] == 0.0);
    assert(fabs(device.motion[1] - expected_sample(0.053, 0.5) * EXPECTED_MOTION_SCALE) < 1e-9);
    assert(fabs(device.motion[10] - expected_sample(1.375, 5.0) * EXPECTED_MOTION_SCALE) < 1e-9);
    assert(fabs(device.motion[19] - expected_sample(6.139, 9.5) * EXPECTED_MOTION_SCALE) < 1e-9);
    assert(fabs(device.scroll[1] - expected_sample(0.053, 0.5)) < 1e-9);
    assert(fabs(device.scroll[10] - expected_sample(1.375, 5.0)) < 1e-9);
    assert(fabs(device.scroll[13] - expected_sample(2.446, 6.5)) < 1e-9);
    assert(fabs(device.scroll[19] - expected_sample(6.139, 9.5)) < 1e-9);
    for (size_t i = 1; i < device.motion_count; i++)
        assert(device.motion[i] > device.motion[i - 1]);

    if (EXPECTED_MAX_GAIN > 0) {
        size_t last = device.scroll_count - 1;
        double last_speed = last * device.scroll_step;
        double scroll_slope = (device.scroll[last] - device.scroll[last - 1]) /
                              device.scroll_step;
        double motion_slope = (device.motion[last] - device.motion[last - 1]) /
                              device.motion_step;
        assert(fabs(scroll_slope - EXPECTED_MAX_GAIN) < 1e-9);
        assert(fabs(motion_slope - EXPECTED_MAX_GAIN * EXPECTED_MOTION_SCALE) < 1e-9);
        /* libinput extrapolates linearly: flicks beyond the table must stay capped. */
        const double speeds[] = {10.0, 20.0, 100.0, 1000.0};
        for (size_t i = 0; i < sizeof(speeds) / sizeof(speeds[0]); i++) {
            double scroll = device.scroll[last] + scroll_slope * (speeds[i] - last_speed);
            double motion = device.motion[last] + motion_slope * (speeds[i] - last_speed);
            assert(fabs(scroll / speeds[i] - EXPECTED_MAX_GAIN) < 1e-9);
            assert(fabs(motion / speeds[i] - EXPECTED_MAX_GAIN * EXPECTED_MOTION_SCALE) < 1e-9);
        }
    }

    /* Niri reloads and profile changes must not replace the supplied curve. */
    configure(&device);
    assert(device.applications == 2);
    assert(device.profile == LIBINPUT_CONFIG_ACCEL_PROFILE_CUSTOM);
    assert(fabs(device.gestures[1] - EXPECTED_GESTURE_SCALE) < 1e-9);

    device = builtin_trackpad();
    device.name = "External Mouse";
    check_passthrough(device);
    device = builtin_trackpad();
    device.product = 0x0265; /* External Apple trackpad. */
    check_passthrough(device);
    device = builtin_trackpad();
    device.vendor = 0x046d;
    check_passthrough(device);
    device = builtin_trackpad();
    device.fingers = 0;
    check_passthrough(device);
    device = builtin_trackpad();
    device.supports_custom = false;
    check_passthrough(device);

    /* Rejected custom configuration must fall back to Niri's normal profile. */
    device = builtin_trackpad();
    device.reject_points = true;
    check_passthrough(device);
    device = builtin_trackpad();
    device.reject_apply = true;
    check_passthrough(device);
    return 0;
}
