// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.playback;

import static com.byteplus.playerkit.player.playback.DisplayModeHelper.DisplayMode;
import static com.byteplus.playerkit.player.playback.DisplayModeHelper.calDisplayAspectRatio;
import static com.byteplus.playerkit.player.playback.DisplayModeHelper.map;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.SparseArray;
import android.view.Gravity;
import android.view.Surface;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.event.InfoTrackInfoReady;
import com.byteplus.playerkit.player.playback.ext.PictureInPictureModeChangedListener;
import com.byteplus.playerkit.player.playback.ext.VideoViewAttachedToWindowListener;
import com.byteplus.playerkit.player.playback.widgets.RatioFrameLayout;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.source.Track;
import com.byteplus.playerkit.utils.Asserts;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.ReturnableRunnable;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * <P> The official video display view of PlayerKit SDK. {@code VideoView} wrap the android
 * {@link android.view.SurfaceView} and {@link android.view.TextureView} to display video.
 * You can choose one of display view by using {@link #selectDisplayView(int)} method.
 *
 * <P>You can use {@link VideoLayerHost} and {@link VideoLayer} to help you simplify the implement
 * of your custom video view ui style.
 *
 * <p> See java doc of {@link PlaybackController} for usage of VideoView.
 *
 * @see VideoLayerHost
 * @see VideoLayer
 * @see PlaybackController
 */
public class VideoView extends RatioFrameLayout implements Dispatcher.EventListener, DisplayView.SurfaceListener {

    private PlaybackController mController;

    private MediaSource mSource;

    private DisplayView mDisplayView;

    private final DisplayModeHelper mDisplayModeHelper;

    private VideoLayerHost mLayerHost;

    @NonNull
    private final CopyOnWriteArrayList<VideoViewListener> mListeners = new CopyOnWriteArrayList<>();

    private final SparseArray<CopyOnWriteArrayList<VideoViewPlaybackActionInterceptor>> mPriorityInterceptors = new SparseArray<>();

    private OnClickListener mOnClickListener;

    private boolean mInterceptDispatchClick;

    private int mPlayScene;

    private Boolean mHasWindowFocus;

    public interface VideoViewPlaybackActionInterceptor {
        /**
         * @return Intercept reason. Not intercept return null
         */
        default String onVideoViewInterceptStartPlayback(VideoView videoView) {
            return null;
        }

        /**
         * @return Intercept reason. Not intercept return null
         */
        default String onVideoViewInterceptStopPlayback(VideoView videoView) {
            return null;
        }

        /**
         * @return Intercept reason. Not intercept return null
         */
        default String onVideoViewInterceptPausePlayback(VideoView videoView) {
            return null;
        }
    }

    public interface ViewEventListener extends VideoViewAttachedToWindowListener {
        void onConfigurationChanged(Configuration newConfig);

        void onWindowFocusChanged(boolean hasWindowFocus);
    }

    public interface VideoViewListener extends DisplayView.SurfaceListener,
            ViewEventListener,
            PictureInPictureModeChangedListener {

        void onVideoViewBindController(PlaybackController controller);

        void onVideoViewUnbindController(PlaybackController controller);

        void onVideoViewBindDataSource(MediaSource dataSource);

        void onVideoViewClick(VideoView videoView);

        void onVideoViewDisplayModeChanged(@DisplayMode int oldMode, @DisplayMode int newMode);

        void onVideoViewDisplayViewCreated(View displayView);

        void onVideoViewDisplayViewChanged(View oldView, View newView);

        void onVideoViewPlaySceneChanged(int fromScene, int toScene);

        void onVideoViewStartPlaybackIntercepted(VideoView videoView, String reason);

        void onVideoViewStopPlaybackIntercepted(VideoView videoView, String reason);

        void onVideoViewPausePlaybackIntercepted(VideoView videoView, String reason);

        class Adapter implements VideoViewListener {

            @Override
            public void onVideoViewBindController(PlaybackController controller) {
            }

            @Override
            public void onVideoViewUnbindController(PlaybackController controller) {
            }

            @Override
            public void onVideoViewBindDataSource(MediaSource dataSource) {
            }

            @Override
            public void onVideoViewClick(VideoView videoView) {
            }

            @Override
            public void onVideoViewDisplayViewChanged(View oldView, View newView) {
            }

            public void onVideoViewDisplayModeChanged(@DisplayMode int fromMode, @DisplayMode int toMode) {
            }

            @Override
            public void onVideoViewDisplayViewCreated(View displayView) {
            }

            @Override
            public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
            }

            @Override
            public void onVideoViewStartPlaybackIntercepted(VideoView videoView, String reason) {

            }

            @Override
            public void onVideoViewStopPlaybackIntercepted(VideoView videoView, String reason) {

            }

            @Override
            public void onVideoViewPausePlaybackIntercepted(VideoView videoView, String reason) {

            }

            @Override
            public void onConfigurationChanged(Configuration newConfig) {
            }

            @Override
            public void onWindowFocusChanged(boolean hasWindowFocus) {
            }

            @Override
            public void onSurfaceAvailable(Surface surface, int width, int height) {
            }

            @Override
            public void onSurfaceSizeChanged(Surface surface, int width, int height) {
            }

            @Override
            public void onSurfaceUpdated(Surface surface) {
            }

            @Override
            public void onSurfaceDestroy(Surface surface) {
            }

            // region VideoOne Enhancement
            @Override
            public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig) {

            }

            @Override
            public void onVideoViewAttachedToWindow(@NonNull VideoView videoView) {

            }

            @Override
            public void onVideoViewDetachedFromWindow(@NonNull VideoView videoView) {

            }
            // endregion
        }
    }

    public VideoView(@NonNull Context context) {
        this(context, null);
    }

    public VideoView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public VideoView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mDisplayModeHelper = new DisplayModeHelper();
        super.setOnClickListener(v -> {
            if (mOnClickListener != null) {
                mOnClickListener.onClick(v);
            }
            if (!mInterceptDispatchClick) {
                for (VideoViewListener listener : mListeners) {
                    listener.onVideoViewClick(VideoView.this);
                }
            }
        });
    }

    @Override
    public void setOnClickListener(@Nullable OnClickListener l) {
        mOnClickListener = l;
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        mDisplayModeHelper.apply();
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        for (VideoViewListener listener : mListeners) {
            listener.onConfigurationChanged(newConfig);
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasWindowFocus) {
        super.onWindowFocusChanged(hasWindowFocus);
        // Using mHasWindowFocus to avoid onWindowFocusChanged callback multi times with same
        // hasWindowFocus value on some devices.
        if (mHasWindowFocus == null || mHasWindowFocus != hasWindowFocus) {
            mHasWindowFocus = hasWindowFocus;
            for (VideoViewListener listener : mListeners) {
                listener.onWindowFocusChanged(hasWindowFocus);
            }
        }
    }

    @Override
    public void requestLayout() {
        super.requestLayout();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (mIsInPictureInPictureMode) {
            mDisplayView.getDisplayView().measure(widthMeasureSpec, heightMeasureSpec);
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
    }

    @Override
    public void onSurfaceAvailable(Surface surface, int width, int height) {
        for (VideoViewListener listener : mListeners) {
            listener.onSurfaceAvailable(surface, width, height);
        }
    }

    @Override
    public void onSurfaceSizeChanged(Surface surface, int width, int height) {
        for (VideoViewListener listener : mListeners) {
            listener.onSurfaceSizeChanged(surface, width, height);
        }
    }

    @Override
    public void onSurfaceUpdated(Surface surface) {
        // do nothing
        // for (VideoViewListener listener : mListeners) {
        //     listener.onSurfaceUpdated(surface);
        // }
    }

    @Override
    public void onSurfaceDestroy(Surface surface) {
        for (VideoViewListener listener : mListeners) {
            listener.onSurfaceDestroy(surface);
        }
    }

    @Override
    public void onEvent(Event event) {
        switch (event.code()) {
            case PlaybackEvent.Action.START_PLAYBACK:
                setKeepScreenOn(true);
                break;
            case PlaybackEvent.Action.STOP_PLAYBACK:
                setKeepScreenOn(false);
                break;
            case PlayerEvent.Action.SET_SURFACE: {
                final Player player = event.owner(Player.class);
                if (player.isInPlaybackState()) {
                    mDisplayModeHelper.setDisplayAspectRatio(
                            calDisplayAspectRatio(
                                    player.getVideoWidth(),
                                    player.getVideoHeight(),
                                    player.getVideoSampleAspectRatio()));
                } else {
                    MediaSource source = player.getDataSource();
                    if (source != null && source.getDisplayAspectRatio() > 0) {
                        mDisplayModeHelper.setDisplayAspectRatio(source.getDisplayAspectRatio());
                    }
                }
                break;
            }
            case PlayerEvent.Info.VIDEO_SAR_CHANGED:
            case PlayerEvent.Info.VIDEO_SIZE_CHANGED:
            case PlayerEvent.State.PREPARED: {
                final Player player = event.owner(Player.class);
                mDisplayModeHelper.setDisplayAspectRatio(
                        calDisplayAspectRatio(
                                player.getVideoWidth(),
                                player.getVideoHeight(),
                                player.getVideoSampleAspectRatio()));
                break;
            }
            case PlayerEvent.Info.TRACK_INFO_READY: {
                List<Track> tracks = event.cast(InfoTrackInfoReady.class).tracks;
                if (tracks.isEmpty()) return;
                final Track first = tracks.get(0);
                if (first != null) {
                    int width = first.getVideoWidth();
                    int height = first.getVideoHeight();
                    if (width > 0 && height > 0) {
                        mDisplayModeHelper.setDisplayAspectRatio(
                                calDisplayAspectRatio(
                                        width,
                                        height,
                                        0));
                    }
                }
                break;
            }
        }
    }

    void bindLayerHost(VideoLayerHost layerHost) {
        Asserts.checkNotNull(layerHost);
        if (this.mLayerHost == null) {
            mLayerHost = layerHost;
        }
    }

    void unbindLayerHost(VideoLayerHost layerHost) {
        Asserts.checkNotNull(layerHost);
        if (mLayerHost != null && mLayerHost == layerHost) {
            mLayerHost = null;
        }
    }

    void bindController(PlaybackController controller) {
        Asserts.checkNotNull(controller);
        if (mController == null) {
            L.d(this, "bindController", controller);
            mController = controller;
            mController.addPlaybackListener(this);
            for (VideoViewListener listener : mListeners) {
                listener.onVideoViewBindController(controller);
            }
        }
    }

    void unbindController(PlaybackController controller) {
        Asserts.checkNotNull(controller);
        if (mController != null && mController == controller) {
            L.d(this, "unbindController", controller);
            mController = null;
            for (VideoViewListener listener : mListeners) {
                listener.onVideoViewUnbindController(controller);
            }
            controller.removePlaybackListener(this);
        }
    }

    final void addVideoViewListener(VideoViewListener listener) {
        if (listener != null) {
            mListeners.addIfAbsent(listener);
        }
    }

    final void removeVideoViewListener(VideoViewListener listener) {
        if (listener != null) {
            mListeners.remove(listener);
        }
    }

    final void removeAllVideoViewListeners() {
        mListeners.clear();
    }

    public void addPlaybackInterceptor(int priority, VideoViewPlaybackActionInterceptor interceptor) {
        CopyOnWriteArrayList<VideoViewPlaybackActionInterceptor> interceptors = mPriorityInterceptors.get(priority);
        if (interceptors == null) {
            interceptors = new CopyOnWriteArrayList<>();
            mPriorityInterceptors.put(priority, interceptors);
        }
        interceptors.addIfAbsent(interceptor);
    }

    public void removePlaybackInterceptor(int priority, VideoViewPlaybackActionInterceptor interceptor) {
        List<VideoViewPlaybackActionInterceptor> interceptors = mPriorityInterceptors.get(priority);
        if (interceptors != null) {
            interceptors.remove(interceptor);
        }
    }

    public void removePlaybackInterceptor(int priority) {
        mPriorityInterceptors.put(priority, null);
    }

    public void removeAllPlaybackInterceptor() {
        mPriorityInterceptors.clear();
    }

    public void setInterceptDispatchClick(boolean interceptClick) {
        this.mInterceptDispatchClick = interceptClick;
    }

    public boolean isInterceptDispatchClick() {
        return mInterceptDispatchClick;
    }

    /**
     * Select Using {@link android.view.TextureView} or {@link android.view.SurfaceView} to display
     * video content.
     *
     * @param viewType one of
     *                 <ul>
     *                   <li>{@link DisplayView#DISPLAY_VIEW_TYPE_NONE}</li>
     *                   <li>{@link DisplayView#DISPLAY_VIEW_TYPE_TEXTURE_VIEW}</li>
     *                   <li>{@link DisplayView#DISPLAY_VIEW_TYPE_SURFACE_VIEW}</li>
     *                 </ul>
     */
    public void selectDisplayView(@DisplayView.DisplayViewType int viewType) {
        final DisplayView current = mDisplayView;
        if (current != null && current.getViewType() != viewType) {
            // detach old one
            current.setReuseSurface(false);
            removeView(current.getDisplayView());
            current.setSurfaceListener(null);
            mDisplayModeHelper.setDisplayView(null);
            mDisplayView = null;
        }
        if (mDisplayView == null) {
            mDisplayView = DisplayView.create(getContext(), viewType);
            mDisplayView.setSurfaceListener(this);
            if (mListeners != null) {
                for (VideoViewListener listener : mListeners) {
                    listener.onVideoViewDisplayViewCreated(mDisplayView.getDisplayView());
                }
            }
            addView(mDisplayView.getDisplayView(), 0,
                    new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, Gravity.CENTER));
            mDisplayModeHelper.setContainerView(this);
            mDisplayModeHelper.setDisplayView(mDisplayView.getDisplayView());

            if (mListeners != null) {
                for (VideoViewListener listener : mListeners) {
                    listener.onVideoViewDisplayViewChanged(current == null ? null : current.getDisplayView(),
                            mDisplayView.getDisplayView());
                }
            }
        }
    }

    /**
     * Only works for TextureView.
     *
     * @param reuseSurface true reuse or false destroy when
     *                     {@link DisplayView.SurfaceListener#onSurfaceDestroy(Surface)}
     */
    public void setReuseSurface(boolean reuseSurface) {
        if (mDisplayView != null) {
            mDisplayView.setReuseSurface(reuseSurface);
        }
    }

    /**
     * @return true reuse or false destroy when
     * {@link DisplayView.SurfaceListener#onSurfaceDestroy(Surface)}
     */
    public boolean isReuseSurface() {
        if (mDisplayView != null) {
            return mDisplayView.isReuseSurface();
        }
        return false;
    }

    public void setPlayScene(int playScene) {
        if (mPlayScene != playScene) {
            L.d(this, "setPlayScene", mPlayScene, playScene);
            int fromScene = mPlayScene;
            mPlayScene = playScene;
            for (VideoViewListener listener : mListeners) {
                listener.onVideoViewPlaySceneChanged(fromScene, playScene);
            }
        }
    }

    public int getPlayScene() {
        return mPlayScene;
    }

    /**
     * @return The {@link VideoLayerHost} instance
     */
    @Nullable
    public final VideoLayerHost layerHost() {
        return mLayerHost;
    }

    /**
     * @return The {@link PlaybackController} instance
     */
    @Nullable
    public final PlaybackController controller() {
        return mController;
    }

    /**
     * @return The {@link Player} instance hold by {@link #mController}
     */
    @Nullable
    public final Player player() {
        if (mController != null) {
            return mController.player();
        }
        return null;
    }

    /**
     * @see PlaybackController#startPlayback()
     */
    public final void startPlayback() {
        if (mController == null) return;

        final String reason = interceptPlaybackAction(interceptor -> interceptor.onVideoViewInterceptStartPlayback(VideoView.this));
        if (!TextUtils.isEmpty(reason)) {
            L.d(this, "startPlayback", "intercepted! " + reason);
            for (VideoViewListener listener : mListeners) {
                listener.onVideoViewStartPlaybackIntercepted(this, reason);
            }
            return;
        }

        mController.startPlayback();
    }

    /**
     * @see PlaybackController#stopPlayback()
     */
    public final void stopPlayback() {
        if (mController == null) return;

        final String reason = interceptPlaybackAction(interceptor -> interceptor.onVideoViewInterceptStopPlayback(VideoView.this));
        if (!TextUtils.isEmpty(reason)) {
            L.d(this, "stopPlayback", "intercepted! " + reason);
            for (VideoViewListener listener : mListeners) {
                listener.onVideoViewStopPlaybackIntercepted(this, reason);
            }
            return;
        }

        mController.stopPlayback();
    }

    /**
     * Pauses playback when player in {@link Player#isInPlaybackState()}
     *
     * @see PlaybackController#stopPlayback()
     * @see Player#pause()
     */
    public final void pausePlayback() {
        if (mController == null) return;

        final String reason = interceptPlaybackAction(interceptor -> interceptor.onVideoViewInterceptPausePlayback(VideoView.this));
        if (!TextUtils.isEmpty(reason)) {
            L.d(this, "pausePlayback", "intercepted! " + reason);
            for (VideoViewListener listener : mListeners) {
                listener.onVideoViewPausePlaybackIntercepted(this, reason);
            }
            return;
        }

        mController.pausePlayback();
    }

    /**
     * @param displayMode One of:
     *                    <ul>
     *                      <li>{@link DisplayModeHelper#DISPLAY_MODE_DEFAULT}</li>
     *                      <li>{@link DisplayModeHelper#DISPLAY_MODE_ASPECT_FILL_X}</li>
     *                      <li>{@link DisplayModeHelper#DISPLAY_MODE_ASPECT_FILL_Y}</li>
     *                      <li>{@link DisplayModeHelper#DISPLAY_MODE_ASPECT_FIT}</li>
     *                      <li>{@link DisplayModeHelper#DISPLAY_MODE_ASPECT_FILL}</li>
     *                    </ul>
     * @see DisplayModeHelper
     */
    public void setDisplayMode(@DisplayMode int displayMode) {
        final int current = getDisplayMode();
        if (current != displayMode) {
            L.v(this, "setDisplayMode", map(current), map(displayMode));
            mDisplayModeHelper.setDisplayMode(displayMode);

            if (mListeners != null) {
                for (VideoViewListener listener : mListeners) {
                    listener.onVideoViewDisplayModeChanged(current, displayMode);
                }
            }
        }
    }

    /**
     * @return current display mode
     */
    @DisplayMode
    public int getDisplayMode() {
        return mDisplayModeHelper.getDisplayMode();
    }

    public void setDisplayAspectRatio(float dar) {
        mDisplayModeHelper.setDisplayAspectRatio(dar);
    }

    /**
     * @return {@link android.view.TextureView} or {@link android.view.SurfaceView}
     */
    @Nullable
    public final View getDisplayView() {
        if (mDisplayView != null) {
            return mDisplayView.getDisplayView();
        }
        return null;
    }

    /**
     * @return current display view type. One of:
     * <ul>
     *   <li>{@link DisplayView#DISPLAY_VIEW_TYPE_NONE}</li>
     *   <li>{@link DisplayView#DISPLAY_VIEW_TYPE_TEXTURE_VIEW}</li>
     *   <li>{@link DisplayView#DISPLAY_VIEW_TYPE_SURFACE_VIEW}</li>
     * </ul>
     * @see #selectDisplayView(int)
     */
    @DisplayView.DisplayViewType
    public final int getDisplayViewType() {
        if (mDisplayView != null) {
            return mDisplayView.getViewType();
        }
        return DisplayView.DISPLAY_VIEW_TYPE_NONE;
    }

    /**
     * @return surface of display view
     */
    @Nullable
    public final Surface getSurface() {
        if (mDisplayView != null) {
            return mDisplayView.getSurface();
        }
        return null;
    }

    /**
     * @return the {@link MediaSource} instance.
     * @see #bindDataSource(MediaSource)
     */
    @Nullable
    public MediaSource getDataSource() {
        return mSource;
    }

    /**
     * Bind {@link MediaSource} to {@code VideoView}. This method should be called before
     * {@link #startPlayback()}. {@link #stopPlayback()} should be called first If
     * {@link MediaSource} instance is changed.
     *
     * @param source {@link MediaSource} instance
     */
    public void bindDataSource(@NonNull MediaSource source) {
        L.d(this, "bindDataSource", MediaSource.dump(mSource), MediaSource.dump(source));
        mSource = source;
        if (mListeners != null) {
            for (VideoViewListener listener : mListeners) {
                listener.onVideoViewBindDataSource(source);
            }
        }

        if (mSource != null && mSource.getDisplayAspectRatio() > 0) {
            mDisplayModeHelper.setDisplayAspectRatio(mSource.getDisplayAspectRatio());
        }
    }

    public String dump() {
        return String.format("%s %s %s", L.obj2String(this), L.obj2String(getSurface()), map(getDisplayMode()));
    }

    private String interceptPlaybackAction(ReturnableRunnable<String, VideoViewPlaybackActionInterceptor> runnable) {
        for (int i = mPriorityInterceptors.size() - 1; i >= 0; i--) {
            final List<VideoViewPlaybackActionInterceptor> interceptors = mPriorityInterceptors.get(mPriorityInterceptors.keyAt(i));
            if (interceptors != null) {
                for (VideoViewPlaybackActionInterceptor interceptor : interceptors) {
                    final String reason = runnable.run(interceptor);
                    if (!TextUtils.isEmpty(reason)) {
                        return reason;
                    }
                }
            }
        }
        return null;
    }

    // region VideoOne Enhancement
    private boolean mIsInPictureInPictureMode = false;

    public void setPictureInPictureModeChanged(boolean isInPictureInPictureMode,
                                               @NonNull Configuration newConfig) {
        if (mIsInPictureInPictureMode != isInPictureInPictureMode) {
            mIsInPictureInPictureMode = isInPictureInPictureMode;
            for (VideoViewListener listener : mListeners) {
                listener.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
            }
        }
    }

    public boolean isInPictureInPictureMode() {
        return mIsInPictureInPictureMode;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        for (VideoViewListener listener : mListeners) {
            listener.onVideoViewAttachedToWindow(this);
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        for (VideoViewListener listener : mListeners) {
            listener.onVideoViewDetachedFromWindow(this);
        }
        super.onDetachedFromWindow();
    }
    // endregion
}
