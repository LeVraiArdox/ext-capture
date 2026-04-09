#pragma once

#include <gbm.h>
#include <cstdint>

struct wl_buffer;

// ---------------------------------------------------------------------------
// GbmBuffer
// RAII wrapper around a GBM buffer object (BO).
// Owns:
//   - the gbm_bo*
//   - the exported DMA-BUF file descriptor
//   - the wl_buffer* (created later via linux-dmabuf)
//
// Ping-pong state:
//   inUse  – Qt Scene Graph is currently reading from this buffer.
//   ready  – The compositor has finished writing a frame into it.
// ---------------------------------------------------------------------------
class GbmBuffer {
public:
    GbmBuffer() = default;

    // Allocate a BO.  Returns false (and leaves the object invalid) on failure.
    bool allocate(gbm_device* dev,
                  int         width,
                  int         height,
                  uint32_t    format,
                  uint64_t    modifier); // DRM_FORMAT_MOD_LINEAR or negotiated

    ~GbmBuffer();

    // Non-copyable, moveable
    GbmBuffer(const GbmBuffer&)            = delete;
    GbmBuffer& operator=(const GbmBuffer&) = delete;
    GbmBuffer(GbmBuffer&&) noexcept;
    GbmBuffer& operator=(GbmBuffer&&) noexcept;

    bool     isValid()   const { return m_bo != nullptr; }
    int      fd()        const { return m_fd; }
    uint32_t stride()    const { return m_stride; }
    uint32_t offset()    const { return 0; }          // single plane
    uint32_t format()    const { return m_format; }
    uint64_t modifier()  const { return m_modifier; }
    int      width()     const { return m_width; }
    int      height()    const { return m_height; }

    // wl_buffer is set externally after the linux-dmabuf roundtrip.
    wl_buffer* waylandBuffer() const        { return m_wlBuffer; }
    void       setWaylandBuffer(wl_buffer* b) { m_wlBuffer = b; }

    // Ping-pong flags
    bool inUse = false;   // Qt SG is displaying this buffer
    bool ready = false;   // compositor wrote a new frame

private:
    void release();

    gbm_bo*    m_bo       = nullptr;
    int        m_fd       = -1;
    uint32_t   m_stride   = 0;
    uint32_t   m_format   = 0;
    uint64_t   m_modifier = 0;
    int        m_width    = 0;
    int        m_height   = 0;
    wl_buffer* m_wlBuffer = nullptr;
};
