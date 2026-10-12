# Figma map

File: "VLC Redesign (Community)" — key `egvxs5uyPhLswJ2kg9TsJt`, page `0:1`.
URL: https://www.figma.com/design/egvxs5uyPhLswJ2kg9TsJt/VLC-Redesign--Community-

Use a frame id with the Figma MCP tools, e.g.
`get_screenshot(fileKey: "egvxs5uyPhLswJ2kg9TsJt", nodeId: "247:445")`.

## Design tokens (from `get_variable_defs` on 247:445)

| Token | Value | Used for |
|---|---|---|
| Dark/Accent/Main, Logo | `#D37918` | accent, play button, seek marker |
| Dark/BG/Accent Bright | `#371F06` | played part of seek bar (≈ accent at 22% on `#090909`) |
| Dark/BG/A3 | `#1B1B1B` | top bar, control bar |
| Dark/BG/A4 | `#191919` | panels |
| Dark/BG/B1 Transparent | `#0E0E0E` | overlays |
| Dark/BG/B2 | `#090909` | seek bar / slider track |
| Dark/Divider/Bright | `#373737` | hover, strong dividers |
| Dark/Divider/Dim | `#222222` | dividers |
| Dark/FG/A1 | `#969696` | icons, secondary text |
| Dark/FG/A2 | `#8F8F8F` | |
| Dark/FG/A3 | `#6B6B6B` | disabled |
| Dark/FG/A4 | `#404040` | |
| Dark/FG/B1 | `#161616` | dark glyph on accent |
| bg blur | background blur, radius 50 | menus / sidebars |

## Screens

| Feature | Frame name | Ids |
|---|---|---|
| Player (video) | Player | 247:445, 187:328, 970:2703, 970:3308, 970:3792, 970:4028, 6261:15078 |
| Player (music) | Player - Music | 4767:23726, 4778:25123 |
| Hidden UI | Player - hide UI | 3328:11554 |
| Light theme | Player - Light | 2425:13624 |
| Customize layout | Player - customize | 2107:5604, 2160:6137, 2160:6564, 2160:7005, 2160:7437, 2160:7869, 6587:19923, 2160:8301, 2160:8732 |
| Settings | Settings - global | 999:5047, 3046:9282 |
| | Settings - interface | 3046:10057, 3062:11379 |
| | Settings - privacy | 3062:11911 |
| | Settings - playback | 3062:12552, 3072:13408 |
| | Settings - video | 3073:14187, 3073:15375 |
| | Settings - audio | 3073:15879, 3180:17398 |
| | Settings - subtitles | 3180:17989, 6536:13908 |
| | Settings - controls | 6536:14482 |
| | Settings - library | 6542:15251 |
| | Settings - network | 6543:15649 |
| | Settings - performance | 6571:15958 |
| | Settings - recording | 6571:16429 |
| | Settings - extensions | 6575:17137 |
| Add subtitles to folder/playlist | Add Subtitles to Playlist/Folder | 1911:7545, 1919:8707, 1919:9278, 3336:11929 |
| Keyboard shortcuts | Keyboard Shortcuts | 2437:14832 |
| Open network stream | Open network stream | 6216:13614 |
| New playlist | new playlist | 6259:14954 |
| Onboarding | Onboarding | 1899:3055, 1902:3670, 1902:4020, 1902:4325, 1902:4634, 1902:4940, 1902:5245, 1902:5550, 1902:6160, 1902:6465, 1902:6770 |

## Components

| Component | Ids |
|---|---|
| Icons | 42:356, Icon Wrapper 177:98, play 848:1712 |
| Volume cone | 244:184 |
| Controls sheet (large) | 491:1780 |
| Seek thumbnail | 2151:9673 |
| Button, Toggle | 500:3063, 536:1014 |
| Current time / Duration / audio value | 1904:7238, 1905:7312, 2245:9805 |
| Sidebar (library) | 848:1996 |
| Sorting / View options | 856:2215, 858:3290 |
| Menus | menu 6062:13354, right-click menu 6065:13616, context menu 2107:5903, folder 2139:8935, file 2404:13340, playlist 2459:9389, option 2107:5935 |
| Media / playlist cards | 2404:9167, 2459:9352 |
| Miniplayer | 970:3091 |
| Subtitle track lists | subtitle one 1919:9121, subtitle multiple 1915:8397, sub filename 6456:13892 |
| Subtitle matching | origin 1963:5465, target 1959:5325 |
| Sidebar panels — video | Video - Essential 536:1855, Video - Crop 543:990, Video - Colors 614:1430, HDR Options 2372:8733 |
| Sidebar panels — audio | Equalizer 6114:13610, Compressor 536:1513, Spatializer 536:1703, Stereo Widener 612:1223, EQ presets 2372:8487, Audio Visualizer 2372:8639, EQ 3178:16769 |
| Values, Dropdown, Setting Preset | 804:1208, 3176:16556, 2372:8300, 2372:8834 |
| Settings category item | 3021:9835 |
| Profiles | 6648:20666 |
