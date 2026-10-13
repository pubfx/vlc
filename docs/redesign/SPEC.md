# Redesign spec

Summary of the redesign goals, written from the design video and the Figma
file. Figma frame ids are in `FIGMA-MAP.md`. Status: ✅ done, ⏳ next, ☐ later.

## Principles

- Keep it simple and keep VLC's identity: orange traffic cone, orange accent,
  neutral greys/black.
- Rectangular, but slightly less sharp than today. Not round like other players.
- Icons: two-tone (grey + orange) for non-clickable menu icons; a consistent
  monochrome set everywhere else.
- Put controls where people look for them (most players put tracks, settings
  and fullscreen bottom-right).
- Don't make the user leave the video to change things.

## 1. Player layout ✅ (phase 1, branch `redesign/phase1`)

- ✅ One thin bottom row that doesn't cover much video.
- ✅ Play stays on the left (most people pause with the keyboard), slightly
  bigger; previous/next on either side of it.
- ✅ Fullscreen, settings and queue move to the right.
- ✅ The "toggle playlist" button becomes a **queue** button. (Rename the
  concept everywhere: the queue plays things in order; playlists are saved
  collections.) ☐ Rename strings in menus/tooltips.
- ✅ Volume: keep the classic VLC wedge, completed into a full cone shape.
- ✅ Seek bar inline in the row and much thicker.
- ☐ Thumbnail preview while hovering/seeking the seek bar (frame 2151:9673).
- ✅ Top bar (menu, media title, window buttons) restyled and available in
  fullscreen; top and bottom bars appear on hover and hide when the mouse
  leaves. ☐ Tune hide timing to be quicker.
- ☐ Optional fullscreen and picture-in-picture buttons in the top bar.

## 2. Quick access — tracks and menus ✅ (phase 2, branch `redesign/phase2`)

- ✅ Subtitle button (bottom-right) opens a list of subtitle tracks directly
  (frames "subtitle one" / "subtitle multiple"). `TracksQuickMenu.qml`,
  `SubtitleTracksButton.qml`.
- ✅ Audio button next to it shows audio tracks **and** audio output devices
  (headphones/speakers). `AudioTracksButton.qml`.
- ✅ Video tracks: a tab in the same panel, no separate button (rarely used).
- ✅ Remove the duplicated top menu; replace with one "⋯" menu icon holding
  media options and extra settings (frame "menu"). ☐ "Profile" entry
  (phase 6). The F10 menu bar is still available.
- ✅ Clean up the right-click menu in the new style and add "Hide UI"
  (also as a keyboard shortcut, Ctrl+\) (frame "right-click menu",
  "Player - hide UI").
- ✅ Move "Continue where you left off" prompt next to the playback controls in
  the center, not far away (ResumeDialog.qml). ☐ Verify end to end with a
  media library build.
- ✅ On-screen messages show the shortcut that was pressed, not just the action
  (Qt notification, e.g. "Mute · M"; the video OSD text is unchanged).
- ☐ Figma icons (CC subtitle, waveform audio, orange two-tone menu icons):
  the icon font needs regenerating with fontforge (`pixmaps/makeIconFont.py`).

## 3. Player sidebar ☐ (phase 3)

Replace the big "extended settings" overlay with a right sidebar with four tabs.

- **Subtitles**: sync options as sliders (not typed numbers); a subtitle
  timeline showing when lines appear so you can line them up with the audio;
  font, size (relative or exact value), outline, position; default subtitle
  track/language.
- **Audio**: default audio track, audio delay, filters (equalizer, compressor,
  spatializer, stereo widener) with simple presets and preview icons for
  casual users, full controls for experts.
- **Video**: filters with previews; flip, rotate, zoom, crop, colors, HDR,
  resolution, aspect ratio.
- **Playback**: speed, reverse playback, sleep timer, show subtitle timeline,
  waveform seek bar, show metadata.
- **Presets**: save all of the above per show and reapply with one click.
- **Bookmarks and chapters** on a timeline in the sidebar; a quick shortcut
  (e.g. Ctrl+B) adds a bookmark instantly.

## 4. Library ☐ (phase 4)

- Library sections: Videos, Music (songs/albums/artists/genres), Network
  streams, Playlists.
- Toolbar: back/forward, clickable address path, sort (including
  watched/unwatched first), view mode (grid/list/details), search, and a menu
  with "Add file/folder".
- Open the library from the folder/show name in the top bar plus a sidebar
  icon; it opens as a compact sidebar next to the video. Drag items into the
  queue. A full-screen library with mini player is still available.
- Music playback screen with large cover art and optional waveform seek bar.
- Library sidebar: pinned items, Recent files, and a Home page showing recent
  files, playlists and streams instead of the empty cone screen.
- Creating a playlist: one button, a name, select files. "Add to playlist" in
  file context menus.
- Split the all-in-one "Open media" dialog into separate actions: open file,
  open folder, network stream, capture device, clipboard, recent media,
  convert, stream to another device. A pasted playlist URL (e.g. an IPTV list)
  becomes a playlist automatically.

## 5. Settings ☐ (phase 5)

- One settings window: for each category, basic settings first, advanced
  settings below (no separate "simple/all" modes).
- Categories: General (theme light/dark, accent color), Interface, Privacy,
  Controls, Playback, Video, Audio, Subtitles (incl. on-screen messages),
  Library, Network, Performance, Recording/streaming, Extensions (add-ons,
  skins; internal plugins go under advanced).
- Every setting has an info icon instead of a hover-only tooltip.
- Remove duplicate settings and inconsistent wording; replace numeric codes
  with words (e.g. subtitle autodetect fuzziness becomes a dropdown).
- Keyboard shortcuts get their own dialog with a direct menu entry.

## 6. Extras ☐ (phase 6)

- Add subtitles to a file, a folder or a playlist; from the computer or a
  site like OpenSubtitles; auto-match by name or match manually, remembered
  for future episodes.
- Customize screen: one large frame where buttons can be dragged in and out;
  save layouts per profile (profiles change all settings).
- Onboarding: pick a theme and learn the basic shortcuts.
- Light theme and accent color picker.
