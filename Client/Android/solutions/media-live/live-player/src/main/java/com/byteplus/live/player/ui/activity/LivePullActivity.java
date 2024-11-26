// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.ui.activity;

import static com.byteplus.live.settings.PreferenceUtil.PULL_BUFFER_TYPE_BYTE_ARRAY;
import static com.byteplus.live.settings.PreferenceUtil.PULL_BUFFER_TYPE_BYTE_BUFFER;
import static com.byteplus.live.settings.PreferenceUtil.PULL_BUFFER_TYPE_TEXTURE;
import static com.byteplus.live.settings.PreferenceUtil.PULL_PIXEL_FORMAT_RGBA32;
import static com.byteplus.live.settings.PreferenceUtil.PULL_PIXEL_FORMAT_TEXTURE;
import static com.byteplus.live.settings.PreferenceUtil.PULL_ROTATION_0;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerPixelFormat.VeLivePlayerPixelFormatRGBA32;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerPixelFormat.VeLivePlayerPixelFormatTexture;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerRotation.VeLivePlayerRotation0;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerRotation.VeLivePlayerRotation180;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerRotation.VeLivePlayerRotation270;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerRotation.VeLivePlayerRotation90;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerVideoBufferType.VeLivePlayerVideoBufferTypeByteArray;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerVideoBufferType.VeLivePlayerVideoBufferTypeByteBuffer;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerVideoBufferType.VeLivePlayerVideoBufferTypeTexture;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.opengl.GLES20;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.SurfaceView;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.byteplus.live.common.panel.MultiInfoPanel;
import com.byteplus.live.common.panel.SingleInfoPanel;
import com.byteplus.live.player.LivePlayer;
import com.byteplus.live.player.LivePlayerCycleInfo;
import com.byteplus.live.player.LivePlayerImpl;
import com.byteplus.live.player.LivePlayerListener;
import com.byteplus.live.player.LivePlayerObserver;
import com.byteplus.live.player.R;
import com.byteplus.live.player.ui.widget.BasicSettingsDialog;
import com.byteplus.live.player.ui.widget.MediaSettingsDialog;
import com.byteplus.live.common.FileUtils;
import com.byteplus.live.player.utils.ProgramTexture2d;
import com.byteplus.live.settings.PreferenceUtil;
import com.pandora.common.env.Env;
import com.ss.videoarch.liveplayer.VeLivePlayer;
import com.ss.videoarch.liveplayer.VeLivePlayerDef;
import com.ss.videoarch.liveplayer.VeLivePlayerVideoFrame;

import java.io.File;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Locale;

import javax.microedition.khronos.opengles.GL10;

public class LivePullActivity extends AppCompatActivity implements LivePlayerListener {
    private static final String TAG = LivePullActivity.class.getSimpleName();
    private SurfaceView mLiveView;
    private FrameLayout mViewContainer;
    private LivePlayer mLivePlayer;
    private BasicSettingsDialog mBasicSettingDialog;
    private MediaSettingsDialog mMediaSettingDialog;
    private LivePlayerCycleInfo mCycleInfo;
    private SingleInfoPanel mCycleInfoPanel;
    private MultiInfoPanel mCallbackInfoPanel;

    private boolean mHasBackPressed;

    private void initUI() {
        findViewById(R.id.close).setOnClickListener(v -> finish());

        mLiveView = new SurfaceView(this);
        mLiveView.getHolder().setFormat(PixelFormat.RGBA_8888);
        mViewContainer = findViewById(R.id.view_container);
        mViewContainer.addView(mLiveView);
        findViewById(R.id.basic_settings).setOnClickListener(v -> {
            mBasicSettingDialog = new BasicSettingsDialog(LivePullActivity.this, LivePullActivity.this);
            mBasicSettingDialog.show();
        });

        mCycleInfoPanel = new SingleInfoPanel(R.string.medialive_cycle_info, findViewById(R.id.medialive_cycle_info));
        mCallbackInfoPanel = new MultiInfoPanel(R.string.medialive_callback_info, findViewById(R.id.medialive_callback_info));

        onEnableCycleInfo(PreferenceUtil.getInstance().getPullEnableCycleInfo(false));
        onEnableCallbackRecord(PreferenceUtil.getInstance().getPullEnableCallbackInfo(false));

        findViewById(R.id.media_settings).setOnClickListener(v -> {
            if (mMediaSettingDialog == null) {
                mMediaSettingDialog = new MediaSettingsDialog(LivePullActivity.this, LivePullActivity.this);
            }
            mMediaSettingDialog.show();
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.live_activity_live_pull);
        initUI();
        PreferenceUtil.getInstance().setPullAbrCurrent(PreferenceUtil.getInstance().getPullAbrDefault(PreferenceUtil.PULL_ABR_ORIGIN));
        LivePlayerObserver observer = new LivePlayerObserver() {
            @Override
            public void onCycleInfoUpdate(LivePlayerCycleInfo info) {
                mCycleInfo = info;
                Log.d(TAG, info.toString());
                SingleInfoPanel panel = mCycleInfoPanel;
                if (panel != null) {
                    runOnUiThread(() -> panel.updateContent(info.toString()));
                }
            }

            @Override
            public void onCallbackRecordUpdate(String content) {
                if (content == null) {
                    return;
                }
                Log.d(TAG, content);
                MultiInfoPanel panel = mCallbackInfoPanel;
                if (panel != null) {
                    runOnUiThread(() -> panel.appendContent(content));
                }
            }

            @Override
            public void onResolutionUpdate(String resolution) {
                if (mBasicSettingDialog != null) {
                    runOnUiThread(() -> mBasicSettingDialog.switchResolution(resolution));
                }
            }

            @Override
            public void onRenderVideoFrame(VeLivePlayer player, VeLivePlayerVideoFrame videoFrame) {
                glReadBitmap(videoFrame.texture.texId, videoFrame.width, videoFrame.height, true);
            }
        };
        mLivePlayer = LivePlayerImpl.createLivePlayer(observer);

        mLivePlayer.setSurfaceView(mLiveView);
        mLivePlayer.setSurfaceContainer(mViewContainer);
    }

    public static final float[] mtx = new float[16];
    public static final float[] mvp = new float[16];
    public int texId = -1;
    public int fboId = -1;

    public void glReadBitmap(int textureId, final int texWidth, final int texHeight, boolean isRender) {
        if (isRender) {
            render(textureId, texWidth, texHeight);
            return;
        }

        if (texId == -1) {
            int[] textures = new int[1];
            GLES20.glGenTextures(1, textures, 0);
            texId = textures[0];
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textures[0]);
            GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, texWidth, texHeight, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);

            int[] mFrameBuffers = new int[1];
            GLES20.glGenFramebuffers(1, mFrameBuffers, 0);
            fboId = mFrameBuffers[0];
//        GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
//        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textures[0]);
            GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, fboId);
            GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0, GLES20.GL_TEXTURE_2D, textures[0], 0);
        }
        int[] viewport = new int[4];
        GLES20.glGetIntegerv(GLES20.GL_VIEWPORT, viewport, 0);
        GLES20.glViewport(0, 0, texWidth, texHeight);
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, fboId);
        new ProgramTexture2d().drawFrame(textureId, mtx, mvp);
        GLES20.glFinish();
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, fboId);

        ByteBuffer buf = ByteBuffer.allocateDirect(texWidth * texHeight * 4);
        buf.rewind();
        buf.order(ByteOrder.LITTLE_ENDIAN);
        GLES20.glReadPixels(0, 0, texWidth, texHeight, GL10.GL_RGBA, GL10.GL_UNSIGNED_BYTE, buf);
        buf.rewind();
        GLES20.glFinish();
//        AsyncTask.execute(new Runnable() {
//            @Override
//            public void run() {
//                final int bitmapSource[] = new int[texWidth * texHeight];
//                int offset1, offset2;
//                int[] data = intBuffer.array();
//                for (int i = 0; i < texHeight; i++) {
//                    offset1 = i * texWidth;
//                    offset2 = (texHeight - i - 1) * texWidth;
//                    for (int j = 0; j < texWidth; j++) {
//                        int texturePixel = data[offset1 + j];
//                        int blue = (texturePixel >> 16) & 0xff;
//                        int red = (texturePixel << 16) & 0x00ff0000;
//                        int pixel = (texturePixel & 0xff00ff00) | red | blue;
//                        bitmapSource[offset2 + j] = pixel;
//                    }
//                }
//                final Bitmap shotCaptureBitmap = Bitmap.createBitmap(bitmapSource, texWidth, texHeight, Bitmap.Config.ARGB_8888).copy(Bitmap.Config.ARGB_8888, true);
////                if (listener != null) {
////                    listener.onReadBitmapListener(shotCaptureBitmap);
////                }
        if (buf != null) {
            Bitmap bmp = Bitmap.createBitmap(texWidth, texHeight, Bitmap.Config.ARGB_8888);
            buf.rewind();
            bmp.copyPixelsFromBuffer(buf);

            Context context = Env.getApplicationContext();
            File parent = new File(context.getExternalFilesDir("TTSDK"), "TextureCallback");
            File file = new File(parent, "frame_" + System.currentTimeMillis() + ".jpg");
            FileUtils.saveBitmap(bmp, file);
        }
//
//            }
//        });
        GLES20.glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
//        GLES20.glDeleteTextures(1, textures, 0);
//        GLES20.glDeleteFramebuffers(1, mFrameBuffers, 0);
    }


    public void render(int textureId, final int texWidth, final int texHeight) {
        int[] viewport = new int[4];
        GLES20.glGetIntegerv(GLES20.GL_VIEWPORT, viewport, 0);
        GLES20.glViewport(0, 0, texWidth, texHeight);
        new ProgramTexture2d().drawFrame(textureId, mtx, mvp);
        GLES20.glFinish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mLivePlayer.destroy();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mHasBackPressed) {
            return;
        }
        if (!PreferenceUtil.getInstance().getPullEnableBackgroundPlay(false)) {
            onStopPlay();
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(new Intent(this, KeepPlayerLiveService.class));
            } else {
                startService(new Intent(this, KeepPlayerLiveService.class));
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        onStartPlay();
        if (PreferenceUtil.getInstance().getPullEnableBackgroundPlay(false)) {
            stopService(new Intent(this, KeepPlayerLiveService.class));
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        mHasBackPressed = true;
    }

    @Override
    public void onStartPlay() {
        if (!mLivePlayer.isPlaying()) {
            mLivePlayer.startPlay();
        }
    }

    @Override
    public void onStopPlay() {
        LivePlayerCycleInfo info = mCycleInfo = new LivePlayerCycleInfo();
        SingleInfoPanel panel = mCycleInfoPanel;
        if (panel != null) {
            runOnUiThread(() -> panel.updateContent(info.toString()));
        }
        mLivePlayer.stopPlay();
    }

    @Override
    public void onPausePlay() {
        mLivePlayer.pause();
    }

    @Override
    public void onResumePlay() {
        mLivePlayer.resume();
    }

    @Override
    public void onSwitchResolution(String resolution) {
        mLivePlayer.switchResolution(resolution);
    }

    @Override
    public void onSwitchUrl(String url) {
        mLivePlayer.switchUrl(url);
    }

    @Override
    public void onEnableCycleInfo(boolean enable) {
        SingleInfoPanel panel = mCycleInfoPanel;
        if (panel != null) {
            runOnUiThread(() -> {
                panel.setEnabled(enable);
                if (enable && mCycleInfo != null) {
                    panel.updateContent(mCycleInfo.toString());
                }
            });
        }
    }

    @Override
    public void onEnableCallbackRecord(boolean enable) {
        MultiInfoPanel panel = mCallbackInfoPanel;
        if (panel != null) {
            runOnUiThread(() -> panel.setEnabled(enable));
        }
    }

    @Override
    public int onChangeFillMode(int fillMode) {
        Log.i(TAG, "onChangeFillMode, fillMode: " + fillMode);
        if (mLivePlayer.setRenderFillMode(fillMode) != 0) {
            Toast.makeText(LivePullActivity.this, R.string.medialive_not_support_change_fill_mode, Toast.LENGTH_SHORT).show();
            return -1;
        }
        return 0;
    }

    @Override
    public void onChangeRotation(int rotation) {
        Log.i(TAG, "onChangeRotation, rotation: " + rotation);

        VeLivePlayerDef.VeLivePlayerRotation veLivePlayerRotation = VeLivePlayerRotation0;
        switch (rotation) {
            case PULL_ROTATION_0:
                veLivePlayerRotation = VeLivePlayerRotation0;
                break;
            case PreferenceUtil.PULL_ROTATION_90:
                veLivePlayerRotation = VeLivePlayerRotation90;
                break;
            case PreferenceUtil.PULL_ROTATION_180:
                veLivePlayerRotation = VeLivePlayerRotation180;
                break;
            case PreferenceUtil.PULL_ROTATION_270:
                veLivePlayerRotation = VeLivePlayerRotation270;
                break;
        }
        mLivePlayer.setRenderRotation(veLivePlayerRotation);
    }

    @Override
    public void onChangeMirrorMode(int mirrorMode) {
        Log.i(TAG, "onChangeMirrorMode, mirrorMode: " + mirrorMode);
        VeLivePlayerDef.VeLivePlayerMirror playerMirror = VeLivePlayerDef.VeLivePlayerMirror.VeLivePlayerMirrorNone;
        if (mirrorMode == PreferenceUtil.PULL_MIRROR_HORIZONTAL) {
            playerMirror = VeLivePlayerDef.VeLivePlayerMirror.VeLivePlayerMirrorHorizontal;
        } else if (mirrorMode == PreferenceUtil.PULL_MIRROR_VERTICAL) {
            playerMirror = VeLivePlayerDef.VeLivePlayerMirror.VeLivePlayerMirrorVertical;
        }
        mLivePlayer.setRenderMirror(playerMirror);
    }

    @Override
    public void onSnapShot() {
        Log.i(TAG, "onSnapShot");
        mLivePlayer.snapshot();
    }

    @Override
    public int onEnableVideoFrameObserver(boolean enable, int pixelFormat, int bufferType) {
        VeLivePlayerDef.VeLivePlayerPixelFormat format;
        VeLivePlayerDef.VeLivePlayerVideoBufferType vBufferType;
        if (pixelFormat == PULL_PIXEL_FORMAT_RGBA32 && bufferType == PULL_BUFFER_TYPE_BYTE_BUFFER) {
            format = VeLivePlayerPixelFormatRGBA32;
            vBufferType = VeLivePlayerVideoBufferTypeByteBuffer;
        } else if (pixelFormat == PULL_PIXEL_FORMAT_TEXTURE && bufferType == PULL_BUFFER_TYPE_TEXTURE) {
            format = VeLivePlayerPixelFormatTexture;
            vBufferType = VeLivePlayerVideoBufferTypeTexture;
        } else if (pixelFormat == PULL_PIXEL_FORMAT_RGBA32 && bufferType == PULL_BUFFER_TYPE_BYTE_ARRAY) {
            format = VeLivePlayerPixelFormatRGBA32;
            vBufferType = VeLivePlayerVideoBufferTypeByteArray;
        } else {
            Log.d(TAG, String.format(Locale.ENGLISH, "Pixel Format(%1$d) & Buffer Type(%2$d) combination invalid", pixelFormat, bufferType));
            Toast.makeText(LivePullActivity.this, R.string.medialive_video_frame_format_buffer_combination_invalid, Toast.LENGTH_SHORT).show();
            return -1;
        }
        mLivePlayer.enableVideoFrameObserver(enable, format, vBufferType);
        return 0;
    }

    @Override
    public void onSetVolume(float volume) {
        mLivePlayer.setVolume(volume);
    }

    @Override
    public boolean onGetIsMute() {
        return mLivePlayer.isMute();
    }

    public boolean isPlaying() {
        return mLivePlayer.isPlaying();
    }

    @Override
    public void onSetMute(boolean isMute) {
        mLivePlayer.setMute(isMute);
    }

    @Override
    public int onEnableAudioFrameObserver(boolean enable, boolean enableRendering) {
        return mLivePlayer.enableAudioFrameObserver(enable, enableRendering);
    }
}
