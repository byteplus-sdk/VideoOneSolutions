// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player;

import static com.byteplus.live.settings.PreferenceUtil.PULL_ABR_HD;
import static com.byteplus.live.settings.PreferenceUtil.PULL_ABR_LD;
import static com.byteplus.live.settings.PreferenceUtil.PULL_ABR_ORIGIN;
import static com.byteplus.live.settings.PreferenceUtil.PULL_ABR_SD;
import static com.byteplus.live.settings.PreferenceUtil.PULL_ABR_UHD;
import static com.ss.videoarch.liveplayer.ILivePlayer.DISABLE;
import static com.ss.videoarch.liveplayer.ILivePlayer.ENABLE;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatFLV;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFormat.VeLivePlayerFormatRTM;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerPixelFormat.VeLivePlayerPixelFormatRGBA32;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerPixelFormat.VeLivePlayerPixelFormatTexture;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerStatus.VeLivePlayerStatusPlaying;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerVideoBufferType.VeLivePlayerVideoBufferTypeByteArray;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerVideoBufferType.VeLivePlayerVideoBufferTypeByteBuffer;

import android.content.Context;
import android.graphics.Bitmap;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.os.Environment;
import android.text.TextUtils;
import android.util.Log;
import android.view.SurfaceView;
import android.widget.FrameLayout;
import android.widget.Toast;

import com.byteplus.live.common.WriterPCMFile;
import com.byteplus.live.common.WriterRGBAFile;
import com.byteplus.live.player.utils.AudioPlayer;
import com.byteplus.live.common.FileUtils;
import com.byteplus.live.player.utils.PullerSettings;
import com.byteplus.live.settings.AbrInfo;
import com.byteplus.live.settings.PreferenceUtil;
import com.pandora.common.env.Env;
import com.ss.videoarch.liveplayer.VeLivePlayer;
import com.ss.videoarch.liveplayer.VeLivePlayerAudioFrame;
import com.ss.videoarch.liveplayer.VeLivePlayerConfiguration;
import com.ss.videoarch.liveplayer.VeLivePlayerDef;
import com.ss.videoarch.liveplayer.VeLivePlayerError;
import com.ss.videoarch.liveplayer.VeLivePlayerObserver;
import com.ss.videoarch.liveplayer.VeLivePlayerProperty;
import com.ss.videoarch.liveplayer.VeLivePlayerStatistics;
import com.ss.videoarch.liveplayer.VeLivePlayerStreamData;
import com.ss.videoarch.liveplayer.VeLivePlayerVideoFrame;
import com.ss.videoarch.liveplayer.VideoLiveManager;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class LivePlayerImpl implements LivePlayer {
    private static final String TAG = "LivePlayerImpl";

    private final File mParentPath = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "VideoOne/TTSDK");
    private VeLivePlayer mLivePlayer;
    private AudioPlayer mAudioPlayer;
    private final LivePlayerCycleInfo mCycleInfo = new LivePlayerCycleInfo();
    private boolean mIsPlaying;
    private LivePlayerObserver mAppObserver;
    private VeLivePlayerDef.VeLivePlayerFormat mCurrentFormat = VeLivePlayerFormatFLV;
    private WriterPCMFile mWriterPCMFile;
    private WriterRGBAFile mWriterRGBAFile;
    private boolean mEnableAudioRendering;
    private final VeLivePlayerObserver mLivePlayerObserver = new VeLivePlayerObserver() {
        @Override
        public void onError(VeLivePlayer player, VeLivePlayerError error) {
            String info = "[" + getTimestamp() + "] onError: " + format(error);
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onFirstVideoFrameRender(VeLivePlayer player, boolean isFirstFrame) {
            String info = "[" + getTimestamp() + "] onFirstVideoFrameRender";
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onFirstAudioFrameRender(VeLivePlayer player, boolean isFirstFrame) {
            String info = "[" + getTimestamp() + "] onFirstAudioFrameRender";
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onStallStart(VeLivePlayer player) {
            String info = "[" + getTimestamp() + "] onStallStart";
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onStallEnd(VeLivePlayer player) {
            String info = "[" + getTimestamp() + "] onStallEnd";
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onVideoRenderStall(VeLivePlayer player, long stallTime) {
            String info = "[" + getTimestamp() + "] onVideoRenderStall";
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onAudioRenderStall(VeLivePlayer player, long stallTime) {
            String info = "[" + getTimestamp() + "] onAudioRenderStall";
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onResolutionSwitch(VeLivePlayer player, VeLivePlayerDef.VeLivePlayerResolution resolution, VeLivePlayerError error, VeLivePlayerDef.VeLivePlayerResolutionSwitchReason reason) {
            String info = "[" + getTimestamp() + "] onResolutionSwitch: " + resolution +
                    ", err: " + format(error) +
                    ", reason: " + reason;
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
                mAppObserver.onResolutionUpdate(transResolution(resolution));
                PreferenceUtil.getInstance().setPullAbrCurrent(transResolution(resolution));
            }
        }

        @Override
        public void onVideoSizeChanged(VeLivePlayer player, int width, int height) {
            String info = "[" + getTimestamp() + "] onVideoSizeChanged: width:" + width + ", height: " + height;
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onReceiveSeiMessage(VeLivePlayer videoLiveManager, String message) {
            String info = "[" + getTimestamp() + "] onReceiveSeiMessage: " + message;
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onMainBackupSwitch(VeLivePlayer player, VeLivePlayerDef.VeLivePlayerStreamType streamType, VeLivePlayerError error) {
            String info = "[" + getTimestamp() + "] onMainBackupSwitch: " + streamType + "; " + format(error);
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
        }

        @Override
        public void onPlayerStatusUpdate(VeLivePlayer player, VeLivePlayerDef.VeLivePlayerStatus status) {
            String info = "[" + getTimestamp() + "] onPlayerStatusUpdate: " + status;
            Log.d(TAG, info);
            if (mAppObserver != null) {
                mAppObserver.onCallbackRecordUpdate(info);
            }
            if (status == VeLivePlayerStatusPlaying) {
                mIsPlaying = true;
            } else {
                mIsPlaying = false;
            }
            mCycleInfo.isPlaying = mIsPlaying;
            if (mAppObserver != null) {
                mAppObserver.onCycleInfoUpdate(mCycleInfo);
            }
        }

        @Override
        public void onStatistics(VeLivePlayer player, VeLivePlayerStatistics statistics) {
            if (!TextUtils.equals(mCycleInfo.url, statistics.url)) {
                Log.i(TAG, "onStatistics: url updated: before: " + mCycleInfo.url + ", after: " + statistics.url);
            }
            mCycleInfo.url = statistics.url;
            mCycleInfo.width = statistics.width;
            mCycleInfo.height = statistics.height;
            mCycleInfo.fps = statistics.fps;
            mCycleInfo.bitrate = statistics.bitrate;
            String codec = statistics.videoCodec;
            if (TextUtils.equals(codec, "bytevc1")) {
                codec = "H.265";
            }
            mCycleInfo.videoCodec = codec;
            mCycleInfo.stallTimeMs = statistics.stallTimeMs;
            mCycleInfo.delayMs = statistics.delayMs;
            mCycleInfo.videoBufferMs = statistics.videoBufferMs;
            mCycleInfo.audioBufferMs = statistics.audioBufferMs;
            mCycleInfo.format = statistics.format;
            mCycleInfo.protocol = statistics.protocol;
            mCycleInfo.isHardwareDecode = statistics.isHardwareDecode;
            mCycleInfo.isPlaying = mIsPlaying;
            mCycleInfo.isMute = mLivePlayer.isMute();
            if (mAppObserver != null) {
                mAppObserver.onCycleInfoUpdate(mCycleInfo);
            }
        }

        @Override
        public void onSnapshotComplete(VeLivePlayer player, Bitmap bitmap) {
            Log.i(TAG, "onSnapshotComplete: ");
            Context context = Env.getApplicationContext();
            File file = new File(mParentPath, "Snapshot_" + System.currentTimeMillis() + ".jpg");
            Log.i(TAG, "onSnapshotComplete: " + file);
            boolean retValue = FileUtils.saveBitmap(bitmap, file);
            if (retValue) {
                FileUtils.updateToAlbum(context, file);
                Toast.makeText(context, "onSnapshotComplete:" + file, Toast.LENGTH_SHORT).show();
            } else {
                Log.i(TAG, "onSnapshotComplete: save failed");
            }
        }

        @Override
        public void onRenderVideoFrame(VeLivePlayer player, VeLivePlayerVideoFrame videoFrame) {
            Log.i(TAG, "onRenderVideoFrame:");
            if (videoFrame.pixelFormat == VeLivePlayerPixelFormatRGBA32) {
                if (mWriterRGBAFile == null) {
                    mWriterRGBAFile = new WriterRGBAFile(videoFrame.width, videoFrame.height);
                }
                if (videoFrame.bufferType == VeLivePlayerVideoBufferTypeByteArray) {
                    mWriterRGBAFile.writeBytes(videoFrame.data);
                } else if (videoFrame.bufferType == VeLivePlayerVideoBufferTypeByteBuffer) {
                    mWriterRGBAFile.writeBytes(videoFrame.buffer);
                }
            } else if (videoFrame.pixelFormat == VeLivePlayerPixelFormatTexture) {
                if (mAppObserver != null) {
                    mAppObserver.onRenderVideoFrame(player, videoFrame);
                }
            }
        }

        @Override
        public void onRenderAudioFrame(VeLivePlayer player, VeLivePlayerAudioFrame audioFrame) {
            if (mWriterPCMFile == null) {
                mWriterPCMFile = new WriterPCMFile(audioFrame.sampleRate, audioFrame.channels, audioFrame.bitDepth, "playerSubscribeAudio", "be");
            }
            Log.i(TAG, "onRenderAudioFrame: samples:" + audioFrame.samples
                    + ", bitDepth:" + audioFrame.bitDepth
                    + ", channels:" + audioFrame.channels
                    + ", bufferSize:" + audioFrame.buffer.length);
            mWriterPCMFile.writeBytes(audioFrame.buffer);
            if (!mEnableAudioRendering) {
                if (PreferenceUtil.getInstance().getPullEnableAudioSelfRender(false) && mAudioPlayer == null) {
                    mAudioPlayer = new AudioPlayer();
                    int bitDepth = ((audioFrame.bitDepth == 8) ? AudioFormat.ENCODING_PCM_8BIT : ((audioFrame.bitDepth == 16) ? AudioFormat.ENCODING_PCM_16BIT : AudioFormat.ENCODING_PCM_FLOAT));
                    mAudioPlayer.startPlayer(AudioManager.STREAM_MUSIC, audioFrame.sampleRate,
                            ((audioFrame.channels == 1) ? AudioFormat.CHANNEL_IN_MONO : AudioFormat.CHANNEL_IN_STEREO),
                            bitDepth);
                }
                if (mAudioPlayer != null) {
                    mAudioPlayer.write(audioFrame.buffer);
                }
            }
        }

        @Override
        public void onStreamFailedOpenSuperResolution(VeLivePlayer player, VeLivePlayerError error) {
            Log.i(TAG, "onStreamFailedOpenSuperResolution: " + format(error));
        }

        @Override
        public void onStreamFailedOpenSharpen(VeLivePlayer player, VeLivePlayerError error) {
            Log.i(TAG, "onStreamFailedOpenSharpen: " + format(error));
        }
    };

    private void setAdvancedProperty() {
        int abrAlgorithm = PreferenceUtil.getInstance().getPullAutoAbr(false) ? ENABLE : DISABLE;
        Log.i(TAG, "setAdvancedProperty: abrAlgorithm: " + abrAlgorithm);
        mLivePlayer.setProperty(VeLivePlayerProperty.VeLivePlayerKeySetABRAlgorithm, abrAlgorithm);
    }

    private LivePlayerImpl(LivePlayerObserver appObserver) {
        mLivePlayer = new VideoLiveManager(Env.getApplicationContext());
        mAppObserver = appObserver;
        VeLivePlayerConfiguration config = new VeLivePlayerConfiguration();
        config.enableSei = PreferenceUtil.getInstance().getPullSei(false);
        int callbackInterval = 5;
        if (callbackInterval <= 0) {
            config.enableStatisticsCallback = false;
        } else {
            config.enableStatisticsCallback = true;
            config.statisticsCallbackInterval = callbackInterval;
        }
        mLivePlayer.setConfig(config);
        setAdvancedProperty();
        mLivePlayer.setObserver(mLivePlayerObserver);

        setStreamData();
    }

    private void setStreamData() {
        configStreamData(
                PreferenceUtil.getInstance().getPullAbr(false),
                PreferenceUtil.getInstance().getPullUrl("")
        );
    }

    private void configStreamData(boolean enableABR, String mainUrl) {
        VeLivePlayerStreamData streamData = new VeLivePlayerStreamData();
        streamData.enableABR = enableABR;
        streamData.mainStreamList = getMainStreamList(enableABR, mainUrl);
        if (streamData.enableMainBackupSwitch) {
            streamData.backupStreamList = getBackupStreamList();
        }
        if (streamData.enableABR) {
            streamData.defaultResolution = transAbrResolution(PreferenceUtil.getInstance().getPullAbrCurrent(PULL_ABR_ORIGIN));
        } else {
            streamData.defaultResolution = transAbrResolution(PULL_ABR_ORIGIN);
        }

        mCurrentFormat = streamData.defaultFormat = PullerSettings.getPullFormat();
        streamData.defaultProtocol = PullerSettings.getPullProtocol();
        mLivePlayer.setPlayStreamData(streamData);
    }

    private static List<VeLivePlayerStreamData.VeLivePlayerStream> getMainStreamList(boolean enableABR, String mainUrl) {
        List<VeLivePlayerStreamData.VeLivePlayerStream> streamList = new ArrayList<>();
        if (enableABR) {
            String abrOrigin = PreferenceUtil.getInstance().getPullAbrOrigin("");
            String abrUhd = PreferenceUtil.getInstance().getPullAbrUhd("");
            String abrHd = PreferenceUtil.getInstance().getPullAbrHd("");
            String abrLd = PreferenceUtil.getInstance().getPullAbrLd("");
            String abrSd = PreferenceUtil.getInstance().getPullAbrSd("");

            if (!TextUtils.isEmpty(abrOrigin)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrOrigin, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeMain);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionOrigin;
                streamList.add(stream);
            }
            if (!TextUtils.isEmpty(abrUhd)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrUhd, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeMain);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionUHD;
                streamList.add(stream);
            }
            if (!TextUtils.isEmpty(abrHd)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrHd, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeMain);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionHD;
                streamList.add(stream);
            }
            if (!TextUtils.isEmpty(abrLd)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrLd, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeMain);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionLD;
                streamList.add(stream);
            }
            if (!TextUtils.isEmpty(abrSd)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrSd, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeMain);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionSD;
                streamList.add(stream);
            }
        } else {
            if (!TextUtils.isEmpty(mainUrl)) {
                String[] urls = mainUrl.split("\\n");
                for (String url : urls) {
                    VeLivePlayerStreamData.VeLivePlayerStream main = new VeLivePlayerStreamData.VeLivePlayerStream();
                    main.url = url;
                    main.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionOrigin;
                    main.streamType = VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeMain;
                    main.format = PullerSettings.guessUrlFormat(url);
                    streamList.add(main);
                }
            }
        }
        return streamList;
    }

    private static List<VeLivePlayerStreamData.VeLivePlayerStream> getBackupStreamList() {
        List<VeLivePlayerStreamData.VeLivePlayerStream> streamList = new ArrayList<>();
        if (PreferenceUtil.getInstance().getPullAbr(false)) {
            String abrOrigin = PreferenceUtil.getInstance().getPullAbrOriginBackup("");
            String abrUhd = PreferenceUtil.getInstance().getPullAbrUhdBackup("");
            String abrHd = PreferenceUtil.getInstance().getPullAbrHdBackup("");
            String abrLd = PreferenceUtil.getInstance().getPullAbrLdBackup("");
            String abrSd = PreferenceUtil.getInstance().getPullAbrSdBackup("");

            if (!TextUtils.isEmpty(abrOrigin)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrOrigin, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeBackup);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionOrigin;
                streamList.add(stream);
            }
            if (!TextUtils.isEmpty(abrUhd)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrUhd, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeBackup);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionUHD;
                streamList.add(stream);
            }
            if (!TextUtils.isEmpty(abrHd)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrHd, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeBackup);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionHD;
                streamList.add(stream);
            }
            if (!TextUtils.isEmpty(abrLd)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrLd, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeBackup);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionLD;
                streamList.add(stream);
            }
            if (!TextUtils.isEmpty(abrSd)) {
                VeLivePlayerStreamData.VeLivePlayerStream stream = getAbrStream(abrSd, VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeBackup);
                stream.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionSD;
                streamList.add(stream);
            }
        } else {
            String backupURL = PreferenceUtil.getInstance().getPullUrlBackup("");
            if (!TextUtils.isEmpty(backupURL)) {
                String[] urls = backupURL.split("\\n");
                for (String url : urls) {
                    VeLivePlayerStreamData.VeLivePlayerStream backup = new VeLivePlayerStreamData.VeLivePlayerStream();
                    backup.url = url;
                    backup.resolution = VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionOrigin;
                    backup.streamType = VeLivePlayerDef.VeLivePlayerStreamType.VeLivePlayerStreamTypeBackup;
                    backup.format = PullerSettings.guessUrlFormat(url);
                    streamList.add(backup);
                }
            }
        }

        return streamList;
    }

    private static VeLivePlayerDef.VeLivePlayerResolution transAbrResolution(String abrDefault) {
        if (abrDefault.contains(PULL_ABR_ORIGIN)) {
            return VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionOrigin;
        } else if (abrDefault.contains(PULL_ABR_UHD)) {
            return VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionUHD;
        } else if (abrDefault.contains(PULL_ABR_HD)) {
            return VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionHD;
        } else if (abrDefault.contains(PULL_ABR_LD)) {
            return VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionLD;
        } else if (abrDefault.contains(PULL_ABR_SD)) {
            return VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionSD;
        }
        return null;
    }

    private static String transResolution(VeLivePlayerDef.VeLivePlayerResolution resolution) {
        if (resolution == VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionOrigin) {
            return PULL_ABR_ORIGIN;
        } else if (resolution == VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionUHD) {
            return PULL_ABR_UHD;
        } else if (resolution == VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionHD) {
            return PULL_ABR_HD;
        } else if (resolution == VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionLD) {
            return PULL_ABR_LD;
        } else if (resolution == VeLivePlayerDef.VeLivePlayerResolution.VeLivePlayerResolutionSD) {
            return PULL_ABR_SD;
        }
        return null;
    }

    private static VeLivePlayerStreamData.VeLivePlayerStream getAbrStream(String abrJsonStr, VeLivePlayerDef.VeLivePlayerStreamType streamType) {
        VeLivePlayerStreamData.VeLivePlayerStream stream = new VeLivePlayerStreamData.VeLivePlayerStream();
        AbrInfo abrInfo = AbrInfo.json2AbrInfo(abrJsonStr);
        stream.url = abrInfo.mUrl;
        stream.streamType = streamType;
        // abr only support flv stream
        stream.format = VeLivePlayerFormatFLV;
        stream.bitrate = abrInfo.mBitrate;
        return stream;
    }

    public static LivePlayer createLivePlayer(LivePlayerObserver observer) {
        return new LivePlayerImpl(observer);
    }

    private static String getTimestamp() {
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss:SSS", Locale.ENGLISH);
        return sdf.format(new Date());
    }

    @Override
    public void setSurfaceView(SurfaceView surfaceView) {
        mLivePlayer.setSurfaceHolder(surfaceView.getHolder());
    }

    @Override
    public void setSurfaceContainer(FrameLayout container) {

    }

    @Override
    public void startPlay() {
        mLivePlayer.play();
        setVolume(PreferenceUtil.getInstance().getPullVolume(1.0f));
    }

    @Override
    public void stopPlay() {
        mLivePlayer.stop();
    }

    @Override
    public void pause() {
        if (mCurrentFormat == VeLivePlayerFormatRTM) {
            Toast.makeText(Env.getApplicationContext(), R.string.medialive_rtm_not_support_pause_resume, Toast.LENGTH_SHORT).show();
            return;
        }
        mLivePlayer.pause();
    }

    @Override
    public void resume() {
        if (mCurrentFormat == VeLivePlayerFormatRTM) {
            Toast.makeText(Env.getApplicationContext(), R.string.medialive_rtm_not_support_pause_resume, Toast.LENGTH_SHORT).show();
            return;
        }
        mLivePlayer.play();
    }

    @Override
    public void destroy() {
        mLivePlayer.destroy();
    }

    @Override
    public void switchResolution(String resolution) {
        mLivePlayer.switchResolution(transAbrResolution(resolution));
    }

    @Override
    public void setVolume(float volume) {
        PreferenceUtil.getInstance().setPullVolume(volume);
        mLivePlayer.setPlayerVolume(volume);
    }

    @Override
    public void setMute(boolean isMute) {
        mLivePlayer.setMute(isMute);
    }

    @Override
    public boolean isMute() {
        return mLivePlayer.isMute();
    }

    @Override
    public boolean isPlaying() {
        return mIsPlaying;
    }

    @Override
    public void switchUrl(String url) {
        configStreamData(false, url);
        startPlay();
    }

    @Override
    public int setRenderFillMode(int mode) {
        if (!PreferenceUtil.getInstance().getPullEnableTextureRender(false)) {
            return -1;
        }
        if (mode == PreferenceUtil.PULL_RENDER_FILL_MODE_ASPECT_FILL) {
            mLivePlayer.setRenderFillMode(VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFill);
        } else if (mode == PreferenceUtil.PULL_RENDER_FILL_MODE_ASPECT_FIT) {
            mLivePlayer.setRenderFillMode(VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFit);
        } else if (mode == PreferenceUtil.PULL_RENDER_FILL_MODE_FULL_FILL) {
            mLivePlayer.setRenderFillMode(VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeFullFill);
        }
        return 0;
    }

    @Override
    public void setRenderRotation(VeLivePlayerDef.VeLivePlayerRotation rotation) {
        if (mLivePlayer != null) {
            mLivePlayer.setRenderRotation(rotation);
        }
    }

    @Override
    public void setRenderMirror(VeLivePlayerDef.VeLivePlayerMirror mirror) {
        if (mLivePlayer != null) {
            mLivePlayer.setRenderMirror(mirror);
        }
    }

    @Override
    public void snapshot() {
        if (mLivePlayer != null) {
            int retValue = mLivePlayer.snapshot();
            Log.i(TAG, "snapshot: " + retValue);
        } else {
            Log.i(TAG, "snapshot error: NO player");
        }
    }

    @Override
    public int enableVideoFrameObserver(boolean enable, VeLivePlayerDef.VeLivePlayerPixelFormat pixelFormat, VeLivePlayerDef.VeLivePlayerVideoBufferType bufferType) {
        Log.i(TAG, "enableVideoFrameObserver: enable: " + enable
                + ", pixelFormat:" + pixelFormat
                + ", bufferType:" + bufferType);
        if (mLivePlayer != null) {
            mLivePlayer.enableVideoFrameObserver(enable, pixelFormat, bufferType);
        }
        if (!enable && mWriterRGBAFile != null) {
            mWriterRGBAFile.finish();
            mWriterRGBAFile = null;
        }
        return 0;
    }

    @Override
    public int enableAudioFrameObserver(boolean enable, boolean enableRendering) {
        Log.i(TAG, "enableAudioFrameObserver: enable: " + enable
                + ", enableRendering:" + enableRendering);
        if (mLivePlayer != null) {
            mLivePlayer.enableAudioFrameObserver(enable, enableRendering);
        }
        mEnableAudioRendering = enableRendering;
        if (!enable) {
            if (mWriterPCMFile != null) {
                mWriterPCMFile.finish();
                mWriterPCMFile = null;
            }
            if (mAudioPlayer != null) {
                mAudioPlayer.stopPlayer();
                mAudioPlayer = null;
            }
        }
        return 0;
    }

    private static String format(VeLivePlayerError error) {
        if (null == error) {
            return "";
        } else {
            return "VeLivePlayerError{ErrCode:" + error.mErrorCode + ", ErrMsg: '" + error.mErrorMsg + "'}";
        }
    }
}
