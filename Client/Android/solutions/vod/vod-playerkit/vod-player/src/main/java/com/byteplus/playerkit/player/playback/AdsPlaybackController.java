// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.playerkit.player.playback;

import static com.byteplus.playerkit.utils.event.Dispatcher.EventListener;

import android.view.Surface;
import android.view.ViewGroup;
import android.view.View;
import androidx.core.graphics.Insets;
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
    private static int mAdViewId = -1;

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
        mSession = null;
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
            AdBreakItem.Builder preBrBuilder = new AdBreakItem.Builder();
            preBrBuilder.setVastAdTagUrl(AdSources.prerollUrl);
            preBrBuilder.setTimeOffset(AdBreakItem.TIME_OFFSET_START);
            adBreaks.add(preBrBuilder.build());
        }

        if (midroll) {
            AdBreakItem.Builder mid1BrBuilder = new AdBreakItem.Builder();
            mid1BrBuilder.setVastAdTagUrl(AdSources.midrollUrl);
            mid1BrBuilder.setTimeOffset(formatDuration(duration/2));
            adBreaks.add(mid1BrBuilder.build());
        }

        if (postroll) {
            AdBreakItem.Builder postBrBuilder = new AdBreakItem.Builder();
            postBrBuilder.setVastAdTagUrl(AdSources.postrollUrl);
            postBrBuilder.setTimeOffset(AdBreakItem.TIME_OFFSET_END);
            adBreaks.add(postBrBuilder.build());
        }

        return adBreaks;
    }

    private AdSchedule creatAdSchedule(long duration) {
        AdAppInfo.Builder appInfo = new AdAppInfo.Builder();
        appInfo.setAppId(BuildConfig.VOD_APP_ID);
        appInfo.setAppName(BuildConfig.VOD_APP_NAME);
        appInfo.setAppChannel(BuildConfig.VOD_APP_CHANNEL);

        AdConfig.Builder adConfig = new AdConfig.Builder();
        adConfig.setAppInfo(appInfo.build());
        adConfig.setEnablePreloadVast(true);    
        adConfig.setEnablePreloadAdMediaFile(true);
        adConfig.setEnablePreRenderAdPlayer(true);

        AdSchedule.Builder adSchedule = new AdSchedule.Builder();
        adSchedule.setAdConfig(adConfig.build());
        adSchedule.setAdBreaks(createAdBreaks(duration));

        return adSchedule.build();
    }

    private AdPlaybackSession createAdPlaybackSession(VideoView view) {
        Class<?> PlayerClass = Player.class;
        MediaAds.instance().getContentPlayerFactoryMap().put(PlayerClass, new VideoContentPlayer.Factory());
        AdPlaybackSession session = MediaAds.instance().createAdSession(view.getContext());

        session.setAdViewContainer(createAdViewContainer((view)));

        session.addListener( (@NonNull AdPlaybackSession s, @NonNull AdPlayEvent e) -> {
                Activity activity = (Activity) view.getContext();
                ViewGroup decorView = (ViewGroup) activity.getWindow().getDecorView();
                View backgroundView = decorView.findViewById(mAdViewId);
                if (backgroundView != null) {
                    if (session.isAdShowing()) { 
                        backgroundView.setBackgroundColor(Color.BLACK);
                    } else {
                        backgroundView.setBackgroundColor(Color.TRANSPARENT);
                    }
                }

                if (e.type == AdPlayEvent.Type.PLAY_COMPLETED) {
                    mDispatcher.obtain(StateCompleted.class, super.player()).dispatch();
                }
            });

        return session;
    }

    private AdViewContainer createAdViewContainer(ViewGroup view) {
        AdViewContainer adViewContainer = new AdViewContainer();

        Activity activity = (Activity) view.getContext();
        ViewGroup decorView = (ViewGroup) activity.getWindow().getDecorView();

        if (mAdViewId == -1 || decorView.findViewById(mAdViewId) == null) {
            FrameLayout frameLayout = new FrameLayout(view.getContext()) {};
            
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
            adViewContainer.setAdContainerView(frameLayout);
        } else {
            adViewContainer.setAdContainerView(decorView.findViewById(mAdViewId));
        }

        return adViewContainer;
    }

    @Override
    protected void startPlayer(boolean startWhenPrepared, @NonNull Player player, @NonNull MediaSource viewSource) {
        player.setStartWhenPrepared(false);

        if (mSession == null) {
            player.prepare(viewSource);
        } else {
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
        if (mSession != null) {
            mSession.stop();
        }
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
                    if (controller.mSession == null) {
                        long duration = controller.player().getDuration();
                        controller.mSession = controller.createAdPlaybackSession(controller.videoView());

                        VideoContentPlayer.Factory f = new VideoContentPlayer.Factory();
                        ContentPlayer cp = f.create(controller.player());
                        controller.mSession.setContentPlayer(cp);
                        controller.mSession.setSchedule(controller.creatAdSchedule(duration));
                    }
                    controller.mSession.play();
                }

                final Dispatcher dispatcher = controller.mDispatcher;
                if (dispatcher != null && event.code() != PlayerEvent.State.COMPLETED) {
                    dispatcher.dispatchEvent(event);
                }
            }
        }
    }
}
