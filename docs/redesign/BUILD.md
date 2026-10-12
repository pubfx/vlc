# Building this fork

VLC 4 needs **Qt 6.2 or newer with private headers** and **Meson 1.10 or
newer**. Linux is the easiest platform for development builds. Expect the
first build to take a while; later rebuilds of the Qt interface are quick.

If a step fails, paste the error into Claude Code. Missing packages show up
as clear `meson setup` errors naming the dependency.

## Linux (Ubuntu 24.04+ / Debian 13+) — recommended

```sh
# 1. Base build dependencies for VLC (needs "deb-src" lines enabled in your apt sources)
sudo apt update
sudo apt build-dep vlc

# 2. Qt 6 with private headers + build tools
sudo apt install git ninja-build pipx \
  qt6-base-dev qt6-base-private-dev \
  qt6-declarative-dev qt6-declarative-private-dev \
  qt6-svg-dev qt6-shadertools-dev \
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts \
  qml6-module-qtquick-templates qml6-module-qtquick-window \
  qml6-module-qtqml-workerscript qml6-module-qtquick-dialogs

# 3. Recent Meson (distro versions are usually too old)
pipx install meson
pipx ensurepath   # then open a new terminal

# 4. Get the fork on the redesign branch
git clone https://github.com/pubfx/vlc.git
cd vlc
git checkout redesign/phase1

# 5. Configure, build, run
meson setup build -Dqt=enabled
meson compile -C build
./build/bin/vlc /path/to/a/video.mkv
```

Package names vary slightly between distro versions. If `meson setup`
reports something missing, install the matching `-dev` package and run
`meson setup --reconfigure build`.

## Windows

VLC can't be built with Visual Studio. Use **WSL 2** (Ubuntu) and
cross-compile a Windows build:

```sh
# Inside WSL (Ubuntu)
sudo apt install git wget bzip2 file libwine-dev unzip libtool libtool-bin \
  libltdl-dev pkg-config ant build-essential automake texinfo yasm p7zip-full \
  autopoint gettext cmake zip wine nsis g++-mingw-w64-i686 g++-mingw-w64-x86-64 \
  curl gperf flex bison libcurl4-gnutls-dev python3 python3-setuptools \
  python3-mako python3-requests python3-venv gcc make procps ca-certificates \
  openjdk-11-jdk-headless nasm jq gnupg meson autoconf

git clone https://github.com/pubfx/vlc.git && cd vlc
git checkout redesign/phase1
mkdir -p win64 && cd win64
../extras/package/win32/build.sh -a x86_64 -p -m
```

`-p` downloads prebuilt dependencies (much faster), `-m` builds with Meson.
Run `../extras/package/win32/build.sh -h` for all options. Full official
guide: `doc/BUILD-win32.md` in this repo.

Simpler alternative on Windows: develop and test inside WSL as a Linux build
(follow the Linux steps in WSL; WSL 2 on Windows 11 can show Linux windows).

## macOS

```sh
xcode-select --install
git clone https://github.com/pubfx/vlc.git && cd vlc
git checkout redesign/phase1
mkdir build-macos && cd build-macos
../extras/package/macosx/build.sh
```

This builds VLC's tools and dependencies (including Qt) first, which takes
a long time the first time. Run `../extras/package/macosx/build.sh -h` for
options.

## Quick checks without a full build

Each changed QML file can be syntax-checked in a second:

```sh
qmlformat modules/gui/qt/player/qml/ControlBar.qml > /dev/null && echo OK
```

On Linux, `qmlformat` is usually in `/usr/lib/qt6/bin/`.
