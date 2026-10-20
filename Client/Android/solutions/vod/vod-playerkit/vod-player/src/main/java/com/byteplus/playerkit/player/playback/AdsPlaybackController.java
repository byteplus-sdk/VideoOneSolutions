// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.playback;

import static com.byteplus.playerkit.utils.event.Dispatcher.EventListener;

import android.view.Surface;
import android.view.ViewGroup;
import android.view.View;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import android.graphics.Color;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.view.Gravity;
import android.app.Activity; 

import androidx.annotation.AnyThread;
import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.byteplus.mediaplus.mediaads.api.MediaAds;
import com.byteplus.mediaplus.mediaads.api.AdPlaybackSession;
import com.byteplus.mediaplus.mediaads.api.AdViewContainer;
import com.byteplus.mediaplus.mediaads.api.AdObstruction;
import com.byteplus.mediaplus.mediaads.api.AdPlayEvent;
import com.byteplus.mediaplus.mediaads.api.AdSchedule;
import com.byteplus.mediaplus.mediaads.api.AdAppInfo;
import com.byteplus.mediaplus.mediaads.api.AdBreakItem;
import com.byteplus.mediaplus.mediaads.api.AdConfig;
import com.byteplus.mediaplus.mediaads.api.ContentPlayer;

import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.AdSources;

import com.byteplus.playerkit.player.BuildConfig;
import com.byteplus.playerkit.player.source.MediaSource;
import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.utils.Asserts;
import com.byteplus.playerkit.utils.L;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.playerkit.player.event.StateCompleted;

import java.lang.ref.WeakReference;
import java.util.List;
import java.util.ArrayList;
import java.time.Duration;

import com.byteplus.playerkit.player.event.StateCompleted;

public class AdsPlaybackController extends PlaybackController {
    
    private static boolean preroll = false;
    private static boolean midroll = true;
    private static boolean postroll = false;

    public static void enablePrerollAd(boolean enable) {
        preroll = enable;
    }

    public static boolean isPrerollAdEnabled() {
        return preroll;
    }

    public static void enableMidrollAd(boolean enable) {
        midroll = enable;
    }

    public static boolean isMidrollAdEnabled() {
        return midroll;
    }

    public static void enablePostrollAd(boolean enable) {
        postroll = enable;
    }

    public static boolean isPostrollAdEnabled() {
        return postroll;
    }

    private final AdsPlayerListener mAdsPlayerListener = new AdsPlayerListener(this);
    private AdPlaybackSession mSession = null;
    private int mAdViewId = -1;
    private FrameLayout mAdContainerView = null;
    private AdOverlayProvider.AdOverlay mAdOverlay = null;

    @MainThread
    public AdsPlaybackController() {
        super();
    }

    @MainThread
    public AdsPlaybackController(PlayerPool playerPool, Player.Factory playerFactory) {
        super(playerPool, playerFactory);
    }

    @Override
    protected void bindPlayer(Player newPlayer) {
        super.bindPlayer(newPlayer);
        if (super.player() != null && newPlayer != null && !newPlayer.isReleased()) {
            super.player().addPlayerListener(mAdsPlayerListener);
            super.player().removePlayerListener(super.mPlayerListener);
        }
    }

    @Override
    protected void unbindPlayer(boolean recycle) {
        if (super.player() != null) {
            super.player().removePlayerListener(mAdsPlayerListener);
        }
        super.unbindPlayer(recycle);
        teardownAdSession();
    }

    private static String formatDuration(long millis) {
        // Create a Duration object from the milliseconds
        Duration duration = Duration.ofMillis(millis);
        // Extract the parts of the duration
        long hours = duration.toHours();
        long minutes = duration.toMinutesPart();
        long seconds = duration.toSecondsPart();
        int nanos = duration.toNanosPart();
        int millisPart = nanos / 1_000_000;
        // Format the string, ensuring leading zeros
        return String.format("%02d:%02d:%02d.%03d",
                hours,
                minutes,
                seconds,
                millisPart);
    }

    private List<AdBreakItem> createAdBreaks(long duration) {
        List<AdBreakItem> adBreaks = new ArrayList<AdBreakItem>();
        if (preroll) {
            AdBreakItem prerollBr = new AdBreakItem.Builder()
                    .setVastAdTagUrl(AdSources.prerollUrl)
                    .setTimeOffset(AdBreakItem.TIME_OFFSET_START)
                    .build();
            adBreaks.add(prerollBr);
        }

        if (midroll) {
            String midOffset = formatDuration(duration / 2);
            // two ad breaks at the same offset reproduce the 2-ad midroll pod
            AdBreakItem midBr1 = new AdBreakItem.Builder()
                    .setVastAdTagUrl(AdSources.midrollUrl)
                    .setTimeOffset(midOffset)
                    .build();
            adBreaks.add(midBr1);

            AdBreakItem midBr2 = new AdBreakItem.Builder()
                    .setVastAdTagUrl(AdSources.midrollUrl2)
                    .setTimeOffset(midOffset)
                    .build();
            adBreaks.add(midBr2);
        }

        if (postroll) {
            AdBreakItem postBr = new AdBreakItem.Builder()
                    .setVastAdTagUrl(AdSources.postrollUrl)
                    .setTimeOffset(AdBreakItem.TIME_OFFSET_END)
                    .build();
            adBreaks.add(postBr);
        }

        return adBreaks;
    }

    private AdSchedule creatAdSchedule(long duration) {
        AdAppInfo appInfo = new AdAppInfo.Builder()
                .setAppId(BuildConfig.VOD_APP_ID)
                .setAppName(BuildConfig.VOD_APP_NAME)
                .setAppChannel(BuildConfig.VOD_APP_CHANNEL)
                .build();

        AdConfig adConfig = new AdConfig.Builder()
                .setAppInfo(appInfo)
                .setEnablePreloadVast(true)
                .setEnablePreloadAdMediaFile(true)
                .setEnablePreRenderAdPlayer(true)
                .setDisableDefaultAdUI(true) // disable default UI to use custom overlay instead
                .build();

        AdSchedule adSchedule = new AdSchedule.Builder()
                .setAdConfig(adConfig)
                .setAdBreaks(createAdBreaks(duration))
                .build();

        return adSchedule;
    }

    private AdPlaybackSession createAdPlaybackSession(VideoView view) {
        Class<?> PlayerClass = Player.class;
        MediaAds.instance().getContentPlayerFactoryMap().put(PlayerClass, new VideoContentPlayer.Factory());
        AdPlaybackSession session = MediaAds.instance().createAdSession(view.getContext());

        AdViewContainer adViewContainer = createAdViewContainer(view);
        session.setAdViewContainer(adViewContainer);

        // custom display-only ad overlay rendered above the ad container
        setupAdOverlay(view, adViewContainer);

        final WeakReference<AdsPlaybackController> ref = new WeakReference<>(this);
        session.addListener((@NonNull AdPlaybackSession s, @NonNull AdPlayEvent e) -> {
            final AdsPlaybackController controller = ref.get();
            if (controller != null) {
                controller.onAdSessionEvent(s, e);
            }
        });

        return session;
    }

    private void onAdSessionEvent(@NonNull AdPlaybackSession session, @NonNull AdPlayEvent e) {
        // keep the ad container opaque (black) while an ad is showing so the letterbox bars
        // around the ad are black
        setAdBackgroundOpaque(session.isAdShowing());

        driveAdOverlay(e);

        if (e.type == AdPlayEvent.Type.PLAY_COMPLETED && mDispatcher != null) {
            mDispatcher.obtain(StateCompleted.class, super.player()).dispatch();
        }
    }

    private void setAdBackgroundOpaque(boolean opaque) {
        final VideoView view = videoView();
        if (view != null && view.getContext() instanceof Activity) {
            Activity activity = (Activity) view.getContext();
            ViewGroup decorView = (ViewGroup) activity.getWindow().getDecorView();
            View backgroundView = decorView.findViewById(mAdViewId);
            if (backgroundView != null) {
                backgroundView.setBackgroundColor(opaque ? Color.BLACK : Color.TRANSPARENT);
            }
        }
    }

    private void setupAdOverlay(VideoView view, AdViewContainer adViewContainer) {
        AdOverlayProvider provider = AdOverlayProvider.Holder.get();
        if (provider == null || mAdContainerView == null) {
            return;
        }
        mAdOverlay = provider.createOverlay(view.getContext());
        if (mAdOverlay == null) {
            return;
        }
        View overlayView = mAdOverlay.getView();
        overlayView.setVisibility(View.GONE);
        mAdContainerView.addView(overlayView, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT));
        // register the overlay with the ad SDK so it is treated as a friendly obstruction
        AdObstruction obstruction = new AdObstruction.Builder()
                .setView(overlayView)
                .setPurpose(AdObstruction.Purpose.VIDEO_CONTROLS)
                .setDetailedReason("Custom ad controls overlay")
                .build();
        adViewContainer.registerFriendlyObstruction(obstruction);
    }

    private void driveAdOverlay(@NonNull AdPlayEvent e) {
        if (mAdOverlay == null) {
            return;
        }
        final View overlayView = mAdOverlay.getView();
        switch (e.type) {
            case AD_STARTED:
            case AD_RESUMED:
                mAdOverlay.reset();
                overlayView.setVisibility(View.VISIBLE);
                overlayView.bringToFront();
                break;
            case AD_PROGRESS_UPDATED: {
                long current = e.getLong(AdPlayEvent.Param.LONG_VIDEO_PROGRESS_MS, 0);
                long total = e.getLong(AdPlayEvent.Param.LONG_VIDEO_DURATION_MS, 0);
                mAdOverlay.updateProgress(current, total);
                break;
            }
            case AD_COMPLETED:
            case AD_STOPPED:
            case AD_ERROR:
            case AD_ALL_COMPLETED:
            case CONTENT_ACTION_PLAY:
                overlayView.setVisibility(View.GONE);
                mAdOverlay.reset();
                break;
            default:
                break;
        }
    }

    private AdViewContainer createAdViewContainer(ViewGroup view) {
        AdViewContainer adViewContainer = new AdViewContainer();

        Activity activity = (Activity) view.getContext();
        ViewGroup decorView = (ViewGroup) activity.getWindow().getDecorView();

        if (mAdViewId == -1 || decorView.findViewById(mAdViewId) == null) {
            FrameLayout frameLayout = new FrameLayout(view.getContext());
            
            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            );
            layoutParams.gravity = Gravity.CENTER;
    
            frameLayout.setLayoutParams(layoutParams);
            frameLayout.setForegroundGravity(Gravity.CENTER);

            WindowInsetsCompat insets = ViewCompat.getRootWindowInsets(view);
            if (insets != null && insets.isVisible(WindowInsetsCompat.Type.statusBars())) {
                frameLayout.setFitsSystemWindows(true);
            }

            mAdViewId = View.generateViewId();
            frameLayout.setId(mAdViewId);

            decorView.addView(frameLayout);
            mAdContainerView = frameLayout;
            adViewContainer.setAdContainerView(frameLayout);
        } else {
            mAdContainerView = decorView.findViewById(mAdViewId);
            adViewContainer.setAdContainerView(mAdContainerView);
        }

        applyLandscapeHorizontalInset();

        return adViewContainer;
    }

    // fixed horizontal padding applied to the ad container in landscape so IMA's corner UI
    // is not clipped at the physical screen edges
    private void applyLandscapeHorizontalInset() {
        final int AD_LANDSCAPE_HORIZONTAL_INSET_DP = 36;
        if (mAdContainerView == null) return;
        boolean landscape = mAdContainerView.getResources().getConfiguration().orientation
                == android.content.res.Configuration.ORIENTATION_LANDSCAPE;
        if (!landscape) {
            mAdContainerView.setPadding(0, 0, 0, 0);
            return;
        }
        float density = mAdContainerView.getResources().getDisplayMetrics().density;
        int inset = (int) (AD_LANDSCAPE_HORIZONTAL_INSET_DP * density + 0.5f);
        mAdContainerView.setPadding(inset, 0, inset, 0);
    }

    @Override
    protected void startPlayer(boolean startWhenPrepared, @NonNull Player player, @NonNull MediaSource viewSource) {
        player.setStartWhenPrepared(false);

        if (mSession == null) {
            player.prepare(viewSource);
        } else if (!player.isReleased()) {
            mSession.play();
        }
    }

    @MainThread 
    protected void pausePlayer() {
        if (mSession != null) {
            mSession.pause();
        }
    }

    @MainThread 
    protected void stopPlayer() {
        // tear the ad session down so a reused/recycled controller does not try to resume a
        // released playback engine via a stale session
        teardownAdSession();
    }

    // reset all ad state and removes the ad-related views
    @MainThread
    private void teardownAdSession() {
        if (mSession != null) {
            mSession.clearListeners();
            mSession.stop();
            mSession = null;
        }
        if (mAdOverlay != null) {
            View overlayView = mAdOverlay.getView();
            if (overlayView.getParent() instanceof ViewGroup) {
                ((ViewGroup) overlayView.getParent()).removeView(overlayView);
            }
            mAdOverlay = null;
        }
        if (mAdContainerView != null) {
            mAdContainerView.setBackgroundColor(Color.TRANSPARENT);
            if (mAdContainerView.getParent() instanceof ViewGroup) {
                ((ViewGroup) mAdContainerView.getParent()).removeView(mAdContainerView);
            }
            mAdContainerView = null;
        }
        mAdViewId = -1;
    }

    private static final class AdsPlayerListener implements EventListener {

        private final WeakReference<AdsPlaybackController> controllerRef;

        AdsPlayerListener(AdsPlaybackController controller) {
            controllerRef = new WeakReference<>(controller);
        }

        @Override
        public void onEvent(Event event) {
            final AdsPlaybackController controller = controllerRef.get();

            if (controller != null) {

                if (event.code() == PlayerEvent.State.PREPARED) {
                    final Player player = controller.player();
                    if (player == null || player.isReleased()) {
                        return;
                    }
                    if (controller.mSession == null) {
                        long duration = player.getDuration();
                        controller.mSession = controller.createAdPlaybackSession(controller.videoView());

                        VideoContentPlayer.Factory f = new VideoContentPlayer.Factory();
                        ContentPlayer cp = f.create(player);
                        controller.mSession.setContentPlayer(cp);
                        controller.mSession.setSchedule(controller.creatAdSchedule(duration));
                    }
                    if (controller.mSession != null) {
                        controller.mSession.play();
                    }
                }

                final Dispatcher dispatcher = controller.mDispatcher;
                if (dispatcher != null && event.code() != PlayerEvent.State.COMPLETED) {
                    dispatcher.dispatchEvent(event);
                }
            }
        }
    }
}
