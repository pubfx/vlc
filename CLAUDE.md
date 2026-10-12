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
3. Run: `./build/bin/vlc` (Linux dev build) with a test video and look at
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

## Status

- Phase 1 — DONE (branch `redesign/phase1`, not yet compiled/run on a real
  machine): palette, inline thick seek bar, default button layout, orange
  rounded play button, cone volume slider, top bar available in fullscreen.
  First task in Claude Code: build it, run it, fix anything that breaks.
- Phase 2 — NEXT: quick access to tracks and menus. See SPEC.md §2.
- Phases 3–6: see SPEC.md.
