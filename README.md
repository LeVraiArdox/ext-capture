# ExtCapture QML component

Capture a Wayland foreign toplevel (by `app_id`) into a `QQuickItem`
using only **standard Wayland staging protocols**. No Hyprland dependency.

I did this because Quickshell's `ScreencopyView` uses hyprland protocols and I wanted a more portable solution. This demo supports Hyprland tho.

> [!IMPORTANT]
> This is a side project, don't expect it to be stable

## Protocols used

| Protocol | Role |
|---|---|
| `ext-image-copy-capture-v1` | Frame capture session + frames |
| `ext-foreign-toplevel-list-v1` | Enumerate / watch running windows |
| `zwp-linux-dmabuf-v1` | Zero-copy GPU buffer import |

All three are part of [wayland-protocols](https://gitlab.freedesktop.org/wayland/wayland-protocols).

Verify your wayland-protocols version has the staging protocols:

## Check for XML files in pkgdatadir

```bash
ls $(pkg-config --variable=pkgdatadir wayland-protocols)/staging/
# should list: ext-image-copy-capture  ext-foreign-toplevel-list  ...
```

If the XML files are missing, vendor them from the upstream repo into `protocols/`.

## Build

```bash
cmake -B build
cmake --build build -j$(nproc)
./build/ext-capture-demo
```

## QML usage

```qml
import Sleex.ExtCapture

ExtCaptureItem {
    anchors.fill: parent
    appId: "firefox"
    active: true

    // read-only: true once frames are flowing
    onRunningChanged: console.log("live:", running)
}
```

## Notes on buffer ping-pong

Two `GbmBuffer` objects alternate roles:

```
  ┌──────────┐  capture  ┌──────────┐
  │ buffer 0 │ ────────► │ GPU mem  │ (compositor writes)
  └──────────┘           └──────────┘
       ↕  swap when ready
  ┌──────────┐  display  ┌──────────┐
  │ buffer 1 │ ◄──────── │ Qt SG    │ (GL reads via EGLImage)
  └──────────┘           └──────────┘
```

`inUse = true` prevents the SG-side buffer from being sent to the compositor
while Qt is still rendering with it.

## Known limitations

- Single DRM plane only (no multi-plane YUV formats).
- EGL display is obtained from the Wayland display; may need adjustment for
  multi-GPU setups.
- No fallback to SHM (software path) if DMA-BUF is unavailable.
- Cursor capture is disabled (`OPTIONS_NONE`); set `OPTIONS_PAINT_CURSORS` to include it.
