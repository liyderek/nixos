#!/usr/bin/env python3
"""Toggle a black clock overlay on every Wayland monitor."""

import os
import random
import signal
import subprocess
import sys
from datetime import datetime
from pathlib import Path

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, Gio, GLib, Gtk, GtkLayerShell

AUDIO_EXTENSIONS = {
    ".mp3",
    ".wav",
    ".flac",
    ".ogg",
    ".opus",
    ".m4a",
    ".aac",
    ".aiff",
    ".aif",
}
CSS = b"""
window.sleep-screen, window.sleep-screen box { background: #000000; }
window.sleep-screen label { background: transparent; color: #80786e; }
window.sleep-screen .clock { font-family: sans-serif; font-size: 54px; font-weight: 300; }
window.sleep-screen .date { font-family: sans-serif; font-size: 15px; color: #514d46; }
window.sleep-screen .hint { font-family: sans-serif; font-size: 12px; color: #302d29; }
"""


def audio_files(directory):
    return sorted(
        path
        for path in directory.rglob("*")
        if path.is_file() and path.suffix.lower() in AUDIO_EXTENSIONS
    )


def stop_player(player):
    if player is not None and player.poll() is None:
        player.terminate()
        try:
            player.wait(timeout=2)
        except subprocess.TimeoutExpired:
            player.kill()
            player.wait()


class SleepScreen(Gtk.Application):
    def __init__(self):
        super().__init__(
            application_id="dev.derek.NiriSleepScreen",
            flags=Gio.ApplicationFlags.HANDLES_COMMAND_LINE,
        )
        self.screens = {}
        self.player = None
        self.opened = False
        self.clock_source = None

    def do_startup(self):
        Gtk.Application.do_startup(self)
        for signum in (signal.SIGTERM, signal.SIGINT):
            GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signum, self.close)

    def do_command_line(self, command_line):
        # Gio forwards a second invocation to this process: no PID files or pkill.
        if self.opened:
            self.close()
            return 0
        try:
            self.open_screen()
        except (RuntimeError, GLib.Error) as error:
            command_line.printerr_literal("Sleep screen: " + str(error) + "\n")
            self.quit()
            return 1
        return 0

    def open_screen(self):
        display = Gdk.Display.get_default()
        if display is None or not GtkLayerShell.is_supported():
            raise RuntimeError(
                "A Wayland session with layer-shell support is required."
            )
        if display.get_n_monitors() == 0:
            raise RuntimeError("No active monitors found.")
        self.opened = True
        self.hold()
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            display.get_default_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER
        )
        display.connect("monitor-added", self.add_monitor)
        display.connect("monitor-removed", self.remove_monitor)
        for index in range(display.get_n_monitors()):
            self.add_monitor(display, display.get_monitor(index))
        self.update_clock()
        self.clock_source = GLib.timeout_add_seconds(1, self.update_clock)
        self.play_audio()

    def add_monitor(self, display, monitor):
        if monitor in self.screens:
            return
        window = Gtk.ApplicationWindow(application=self)
        window.set_title("Sleep screen")
        window.get_style_context().add_class("sleep-screen")
        window.set_decorated(False)
        GtkLayerShell.init_for_window(window)
        GtkLayerShell.set_namespace(window, "niri-sleep-screen")
        GtkLayerShell.set_monitor(window, monitor)
        GtkLayerShell.set_layer(window, GtkLayerShell.Layer.OVERLAY)
        # Cover the whole output, including space normally reserved for panels.
        GtkLayerShell.set_exclusive_zone(window, -1)
        GtkLayerShell.set_keyboard_mode(window, GtkLayerShell.KeyboardMode.EXCLUSIVE)
        for edge in (
            GtkLayerShell.Edge.TOP,
            GtkLayerShell.Edge.BOTTOM,
            GtkLayerShell.Edge.LEFT,
            GtkLayerShell.Edge.RIGHT,
        ):
            GtkLayerShell.set_anchor(window, edge, True)
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        box.set_halign(Gtk.Align.CENTER)
        box.set_valign(Gtk.Align.CENTER)
        clock = Gtk.Label()
        clock.get_style_context().add_class("clock")
        date = Gtk.Label()
        date.get_style_context().add_class("date")
        hint = Gtk.Label(label="Super + Alt + S to return")
        hint.get_style_context().add_class("hint")
        hint.set_margin_top(22)
        for label in (clock, date, hint):
            box.pack_start(label, False, False, 0)
        window.add(box)
        window.connect("key-press-event", self.on_key)
        window.connect("realize", self.hide_cursor)
        self.screens[monitor] = (window, clock, date)
        self.update_clock()
        window.show_all()

    def remove_monitor(self, display, monitor):
        widgets = self.screens.pop(monitor, None)
        if widgets is not None:
            widgets[0].destroy()

    def hide_cursor(self, window):
        cursor = Gdk.Cursor.new_for_display(
            window.get_display(), Gdk.CursorType.BLANK_CURSOR
        )
        window.get_window().set_cursor(cursor)

    def on_key(self, window, event):
        if event.keyval == Gdk.KEY_Escape:
            self.close()
        return True

    def update_clock(self):
        now = datetime.now().astimezone()
        time_text = now.strftime("%I:%M %p").lstrip("0")
        date_text = now.strftime("%A, %B %-d")
        for window, clock, date in self.screens.values():
            if clock.get_text() != time_text:
                clock.set_text(time_text)
            if date.get_text() != date_text:
                date.set_text(date_text)
        return GLib.SOURCE_CONTINUE

    def play_audio(self):
        directory = Path(
            os.environ.get("SLEEP_SCREEN_AUDIO_DIR", "/etc/nixos/audio")
        ).expanduser()
        try:
            tracks = audio_files(directory)
            if not tracks:
                print(
                    "Sleep screen: no audio files in " + str(directory), file=sys.stderr
                )
                return
            self.player = subprocess.Popen(
                [
                    "@MPV@",
                    "--no-config",
                    "--no-video",
                    "--audio-display=no",
                    "--loop-file=inf",
                    "--volume=25",
                    "--no-terminal",
                    "--input-terminal=no",
                    "--",
                    str(random.choice(tracks)),
                ],
                stdin=subprocess.DEVNULL,
            )
        except OSError as error:
            print("Sleep screen audio: " + str(error), file=sys.stderr)

    def close(self):
        self.quit()
        return GLib.SOURCE_REMOVE

    def do_shutdown(self):
        if self.clock_source is not None:
            GLib.source_remove(self.clock_source)
        stop_player(self.player)
        Gtk.Application.do_shutdown(self)


if __name__ == "__main__":
    sys.exit(SleepScreen().run(sys.argv))
