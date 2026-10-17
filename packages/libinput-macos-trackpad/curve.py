#!/usr/bin/env python3
"""Emit the points from fufexan's user-supplied macOS-like curve generator."""

SAMPLE_POINT_COUNT = 20
MAX_SPEED = 10
LOW = 0.1
MID = 0.01
HIGH = 0.005

step = MAX_SPEED / SAMPLE_POINT_COUNT
points = []
for i in range(SAMPLE_POINT_COUNT):
    speed = step * i
    value = LOW * speed + MID * speed**2 + HIGH * speed**3
    # Match the original script's three-decimal output passed to libinput.
    points.append(f"{value:.3f}")

print(f"static const double curve_step = {step};")
print("static const double curve_points[] = {" + ", ".join(points) + "};")
