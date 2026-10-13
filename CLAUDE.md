# CLAUDE.md — VLC redesign fork (pubfx/vlc)

This is a personal fork of VLC 4 (`master`) used to implement a UI/UX redesign
of the Qt/QML interface. Read this file first, then `docs/redesign/`.

## Goal

Implement the redesign described in `docs/redesign/SPEC.md`, using the
"VLC Redesign (Community)" Figma file as the visual source of truth.
Work in phases (see "Status"). Keep VLC's identity: orange cone, orange accent,
neutral dark greys, rectangular shapes that are only slightly rounded.

## Where things are

- Figma file key: `egvxs5uyPhLswJ2kg9TsJt` (one page, id `0:1`).
  Frame ids per feature are listed in `docs/redesign/FIGMA-MAP.md`.
  Use the Figma MCP server (configured in `.mcp.json`): `get_screenshot`,
  `get_variable_defs`, `get_metadata` with a node id. The page-level
  `get_metadata` is ~700 KB — always query a specific frame id instead.
- Qt interface: `modules/gui/qt/`
  - `style/` — palette (`systempalette.hpp/.cpp`), sizes (`VLCStyle.qml`), icons
  - `player/qml/` — player screen: `Player.qml`, `ControlBar.qml`,
    `PlayerControlLayout.qml`, `SliderBar.qml` (seek bar), `TopBar.qml`,
    `TracksMenu.qml` / `TracksPage*.qml` (track/subtitle/audio panels)
  - `player/qml/controlbarcontrols/` — one QML file per control-bar button
  - `dialogs/toolbar/controlbar_profile_model.cpp` — default button layouts
  - `menus/` — right-click and top menus (C++)
  - `medialibrary/qml/`, `maininterface/qml/` — library, main window
  - `dialogs/preferences/` — settings dialog
- Build guide: `docs/redesign/BUILD.md`

## Conventions for this fork

- Branch per phase: `redesign/phase1`, `redesign/phase2`, ... Merge into
  `master` of this fork when a phase builds and runs.
- Mark every change with a short `// Redesign: ...` comment.
- Prefer opt-in properties with defaults that keep the original behavior
  (see `SliderBar.qml`: `cornerRadius`, `handleBarWidth`, `progressColor`).
- Use theme colors (`ColorContext`, `theme.accent`, `theme.fg.primary`) so a
  user-chosen accent color keeps working. Only hardcode a color when the
  design has a fixed color (e.g. the green-to-red volume wedge).
- Sizes go in `VLCStyle.qml` (`MainCtx.dp(n, scale)`), not as raw pixels.
- Keep commits small and buildable. Commit message prefix: `qt: redesign ...`.

## Verify every change

1. Parse check for each changed QML file (fast, no build needed):
   `qmlformat path/to/File.qml > /dev/null` — a non-zero exit means a syntax error.
   (`qmlformat` ships with Qt 6; on Linux it is often in `/usr/lib/qt6/bin/`.)
2. Build: `meson compile -C build` (see BUILD.md for first-time setup).
3. Run: `./build/bin/vlc-static` (Linux dev build; plain `vlc` needs `meson install`) with a test video and look at
   the changed screen. Compare against the matching Figma frame screenshot.
4. Watch the terminal for `qml:` warnings — QML binding errors only show at runtime.

## Gotchas learned so far

- QML inline components (`component Foo: ...`) cannot see ids from the
  enclosing file. Use plain objects or pass values as properties.
- The control-bar layout is saved per user. After changing defaults in
  `controlbar_profile_model.cpp`, test with Tools → Customize Interface →
  "Default Style", or a fresh config.
- `ControlBar.qml` `TimeTextPosition.Inline` only works when the layout has an
  empty center group (`PlayerControlLayout.fillerAvailable`); otherwise it
  falls back to `LeftRightSlider`.
- Bookmarks are hidden while the seek bar is inline (they move to the
  sidebar in phase 3).
- Screenshots on WSL: WSLg refuses screenshot clients, and `x11grab` on
  XWayland gives tiled/partial images. Use `docs/redesign/tools/capture.sh`
  (Xvfb + xdotool + ffmpeg), `make-test-video.sh` for the test clip and
  `measure.py` to measure colors/sizes. The pre-redesign reference build is
  a worktree at `~/vlc-baseline` (`capture.sh -t ~/vlc-baseline ...`).
- In a fresh test config set `qt-privacy-ask=0` in `vlcrc` (private option,
  rejected on the command line), or a Welcome dialog covers the player.
  A killed VLC leaves `Playlist/RecoveryFilePath` in
  `vlc-qt-interface.conf`, which shows a "closed abruptly" dialog next start.
  `capture.sh` handles both.
- `--start-time=N` makes VLC 4 show time relative to N (00:00 / length-N).
- Volume reads -1 (empty cone, tooltip "-100%") when the audio output has
  no volume control or is stuck. Not a UI bug. If WSLg's PulseServer hangs
  (VLC freezes on play, `ffmpeg -f lavfi -i sine=duration=1 -f pulse x`
  hangs), restart only PulseAudio; WSLGd respawns it:
  `cd /mnt/c && wsl.exe --system -- sh -c 'pkill -x pulseaudio'`
  (`wsl --shutdown` also works but ends every WSL session).
- Known upstream warnings (also on the pre-redesign commit), ignore them:
  `QTimer::start: negative intervals` at startup, and
  `variable subsdelay-factor not found` when opening the old effects dialog,
  `QObject::~QObject: Timers cannot be stopped from another thread` on quit.
- Qt Quick *Templates* (`T.Button`, `T.ItemDelegate`) have no implicit size;
  set `implicitWidth/Height` from content + padding like VLC's widgets do.
- A non-modal `T.Popup` closes on press outside, so clicking the button that
  opened it closes it and the click reopens it; ignore a click right after
  `closed` (see `TracksQuickButton.qml`).
- `BooleanPropertyAction` needs a NOTIFY signal that carries the bool.
- QMenu submenus are separate windows and don't inherit the parent palette;
  set it before adding entries, since icons are colorized at creation
  (`newRedesignSubmenu` in `menus.cpp`).
- In the player, keys go to the focused control while the bars are visible;
  they become VLC hotkeys only when the bars are hidden (test with Ctrl+\).
- `vlc_actions_get_id` wants "key-play-pause", `vlc_actions_get_keycodes`
  the bare "play-pause".

## Status

- Phase 1 — DONE (branch `redesign/phase1`; builds and runs on Ubuntu 26.04
  WSL 2, Qt 6.10.2): palette, inline thick seek bar, default button layout,
  orange rounded play button, cone volume slider, top bar available in
  fullscreen. Visual gaps vs Figma 247:445 are not yet addressed.
- Phase 2 — DONE except icons (branch `redesign/phase2`): subtitle/audio
  buttons with a quick track panel (video as a tab, audio output devices),
  Hide UI (Ctrl+\), new right-click menu, one "..." top bar menu, resume
  prompt above the controls, shortcut shown in notifications. Open: Figma
  icons (needs `python3-fontforge`), resume/Open Recent checks (need
  `libmedialibrary-dev`).
- Phases 3–6: see SPEC.md.
