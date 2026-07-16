package com.byteplus.live.pusher;

import com.ss.bytertc.engine.data.CameraId;
import com.ss.bytertc.engine.data.VideoBufferType;
import com.ss.bytertc.engine.data.VideoContentType;
import com.ss.bytertc.engine.data.VideoPixelFormat;
import com.ss.bytertc.engine.data.VideoRotation;
import com.ss.bytertc.engine.video.FovVideoFrameInfo;
import com.ss.bytertc.engine.video.IVideoFrame;

import java.nio.ByteBuffer;

public class CustomVideoFrame implements IVideoFrame {
    private final LivePusher.VideoFrame mFrame;

    public CustomVideoFrame(LivePusher.VideoFrame frame) {
        this.mFrame = frame;
    }

    @Override
    public VideoBufferType bufferType() {
        if (mFrame.bufferType == LivePusher.VideoFrame.VIDEO_BUFFER_TYPE_TEXTURE_ID) {
            return VideoBufferType.GL_TEXTURE;
        }
        return VideoBufferType.RAW_MEMORY;
    }

    @Override
    public VideoPixelFormat pixelFormat() {
        if (mFrame.bufferType == LivePusher.VideoFrame.VIDEO_BUFFER_TYPE_TEXTURE_ID) {
            return mFrame.pixelFormat == LivePusher.VideoFrame.VIDEO_PIXEL_FMT_OES_TEXTURE ? 
                    VideoPixelFormat.TEXTURE_OES : VideoPixelFormat.TEXTURE_2D;
        }
        return VideoPixelFormat.I420;
    }

    @Override
    public VideoContentType contentType() {
        return VideoContentType.NORMAL_FRAME;
    }

    @Override
    public long timestampUs() {
        return mFrame.pts * 1000;
    }

    @Override
    public int width() {
        return mFrame.width;
    }

    @Override
    public int height() {
        return mFrame.height;
    }

    @Override
    public VideoRotation rotation() {
        return VideoRotation.fromId(mFrame.rotation);
    }

    @Override
    public CameraId cameraId() {
        return CameraId.CAMERA_ID_FRONT;
    }

    @Override
    public int numberOfPlanes() {
        return 1;
    }

    @Override
    public ByteBuffer planeData(int i) {
        if (mFrame.buffer != null) return mFrame.buffer;
        if (mFrame.data != null) return ByteBuffer.wrap(mFrame.data);
        return null;
    }

    @Override
    public int planeStride(int i) {
        return 0;
    }

    @Override
    public ByteBuffer seiData() {
        return null;
    }

    @Override
    public int textureId() {
        return mFrame.textureId;
    }

    @Override
    public float[] textureMatrix() {
        return null;
    }

    @Override
    public android.opengl.EGLContext eglContext() {
        return null;
    }

    @Override
    public void addRef() {
    }

    @Override
    public long releaseRef() {
        return 0;
    }

    @Override
    public FovVideoFrameInfo fovTileInfo() {
        return null;
    }
}
