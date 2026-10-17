{
  lib,
  stdenv,
  libinput,
  pkg-config,
  python3,
  motionScale ? 1.0,
  maxGain ? 0.0,
  gestureScale ? 1.0,
}:
assert lib.assertMsg (motionScale > 0) "motionScale must be greater than zero";
assert lib.assertMsg (gestureScale > 0) "gestureScale must be greater than zero";
assert lib.assertMsg (maxGain >= 0) "maxGain must be zero (disabled) or positive";
# Both final samples must reach the cap to keep libinput's extrapolation capped.
assert lib.assertMsg (
  maxGain == 0 || maxGain <= 5.355 / 9.0
) "maxGain must be at most 0.595 so the final two samples have constant gain";
stdenv.mkDerivation {
  pname = "libinput-macos-trackpad";
  version = "1.0";
  src = ./libinput-macos-trackpad;

  nativeBuildInputs = [
    pkg-config
    python3
  ];
  buildInputs = [ libinput ];

  buildPhase = ''
    runHook preBuild
    python3 curve.py > curve-points.h
    $CC -std=c11 -Wall -Wextra -Werror -O2 -fPIC -shared \
      -DMOTION_SCALE=${toString motionScale} \
      -DMAX_GAIN=${toString maxGain} \
      -DGESTURE_SCALE=${toString gestureScale} \
      $(pkg-config --cflags libinput) curve.c \
      -o libinput-macos-trackpad.so $(pkg-config --libs libinput) -ldl
    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    $CC -std=c11 -Wall -Wextra -Werror -fPIC -shared \
      $(pkg-config --cflags libinput) tests/fake-libinput.c -o libfakeinput.so
    $CC -std=c11 -Wall -Wextra -Werror \
      -DEXPECTED_MOTION_SCALE=${toString motionScale} \
      -DEXPECTED_MAX_GAIN=${toString maxGain} \
      -DEXPECTED_GESTURE_SCALE=${toString gestureScale} \
      $(pkg-config --cflags libinput) tests/check.c \
      -o curve-check -L. -lfakeinput -Wl,-rpath,"$PWD" -lm
    LD_PRELOAD="$PWD/libinput-macos-trackpad.so" ./curve-check
    LD_PRELOAD="$PWD/libinput-macos-trackpad.so:$PWD/libfakeinput.so" \
      EXPECTED_PRELOAD="$PWD/libfakeinput.so" ./curve-check
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 libinput-macos-trackpad.so "$out/lib/libinput-macos-trackpad.so"
    runHook postInstall
  '';

  passthru = { inherit motionScale maxGain gestureScale; };

  meta = {
    description = "User-supplied custom libinput motion and scroll curves for the Apple SPI trackpad";
    platforms = lib.platforms.linux;
  };
}
