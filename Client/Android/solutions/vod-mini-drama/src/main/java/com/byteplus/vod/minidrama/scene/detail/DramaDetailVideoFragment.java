// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail;


import static com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.EXTRA_DRAMA_ITEM;
import static com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.EXTRA_INPUT;
import static com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.EXTRA_OUTPUT;
import static com.byteplus.vod.minidrama.scene.detail.DramaSpeedSelectorFragment.EXTRA_PLAYBACK_SPEED;
import static com.byteplus.vod.minidrama.scene.detail.pay.DramaEpisodeUnlockByPaymentFragment.EXTRA_FROM;
import static com.byteplus.vod.minidrama.scene.detail.pay.DramaEpisodeUnlockByPaymentFragment.VALUE_FROM_CHOICE;
import static com.byteplus.vod.minidrama.scene.detail.pay.DramaEpisodeUnlockByPaymentFragment.VALUE_FROM_SELECTOR;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.Guideline;
import androidx.core.graphics.Insets;
import androidx.core.view.OnApplyWindowInsetsListener;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.ViewModelProvider;
import androidx.viewpager2.widget.ViewPager2;

import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaDetailVideoFragmentBinding;
import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.minidrama.event.EpisodePlayLockedEvent;
import com.byteplus.vod.minidrama.event.EpisodePlayStateChanged;
import com.byteplus.vod.minidrama.event.EpisodeUserClickUnlockAllEvent;
import com.byteplus.vod.minidrama.event.EpisodeUserSelectedEvent;
import com.byteplus.vod.minidrama.event.EpisodesUnlockFailedEvent;
import com.byteplus.vod.minidrama.event.EpisodesUnlockedEvent;
import com.byteplus.vod.minidrama.event.OnCommentEvent;
import com.byteplus.vod.minidrama.remote.GetDramas;
import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.scene.comment.MDCommentDialogFragment;
import com.byteplus.vod.minidrama.scene.comment.MDCommentDialogLFragment;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.Input;
import com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.Output;
import com.byteplus.vod.minidrama.scene.detail.pay.DramaEpisodeMockAdActivity;
import com.byteplus.vod.minidrama.scene.detail.pay.DramaEpisodePayChoiceFragment;
import com.byteplus.vod.minidrama.scene.detail.pay.DramaEpisodeUnlockByPaymentFragment;
import com.byteplus.vod.minidrama.scene.detail.pay.UnlockDataHelper;
import com.byteplus.vod.minidrama.scene.detail.pay.UnlockState;
import com.byteplus.vod.minidrama.scene.detail.pay.UnlockStateViewModel;
import com.byteplus.vod.minidrama.scene.detail.selector.DramaEpisodeSelectDialogFragment;
import com.byteplus.vod.minidrama.scene.widgets.DramaVideoPageView;
import com.byteplus.vod.minidrama.scene.widgets.DramaVideoSceneView;
import com.byteplus.vod.minidrama.scene.widgets.adatper.ViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.bottom.EpisodeSelectorViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.bottom.SpeedIndicatorViewHolder;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoLayer;
import com.byteplus.vod.minidrama.scene.widgets.layer.DramaVideoPlayerConfigLayer;
import com.byteplus.vod.minidrama.scene.widgets.viewholder.DramaEpisodeVideoViewHolder;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.minidrama.utils.MiniEventBus;
import com.byteplus.vod.minidrama.utils.VideoItemHelper;
import com.byteplus.vod.scenekit.data.model.ItemType;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.ui.base.BaseFragment;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.vertcdemo.ui.CenteredToast;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class DramaDetailVideoFragment extends BaseFragment {
    public static final String TAG = "DramaDetailVideoFragment";

    private static final boolean SWIPE_BETWEEN_DRAMAS = false;

    public static final int RESULT_CODE_EXIT = 100;
    private List<DramaItem> mDramaItems;
    private int mInitDramaIndex;
    private int mCurrentDramaIndex;
    private String mInitMediaKey;
    private boolean mContinuesPlayback;
    private GetDramas mRemoteApi;
    private EpisodeSelectorViewHolder mEpisodeSelector;
    protected SpeedIndicatorViewHolder mSpeedIndicator;

    public DramaItem currentDrama() {
        return mDramaItems.get(mCurrentDramaIndex);
    }

    public DramaDetailVideoFragment() {
        // Required empty public constructor
    }

    @Override
    public boolean onBackPressed() {
        if (mSceneView.pageView().onBackPressed()) {
            return true;
        }
        final DramaItem currentDramaItem = currentDrama();
        if (currentDramaItem == null) {
            return super.onBackPressed();
        }

        if (currentDramaItem.currentItem == null) {
            return super.onBackPressed();
        }
        final ViewHolder viewHolder = mSceneView.pageView().getCurrentViewHolder();
        if (viewHolder == null) {
            return super.onBackPressed();
        }
        boolean continuesPlayback = false;
        if (viewHolder instanceof DramaEpisodeVideoViewHolder videoHolder) {
            if (DramaFeed.isLocked((VideoItem) currentDramaItem.currentItem)) {
                if (currentDramaItem.lastUnlockedItem != null) {
                    currentDramaItem.currentItem = currentDramaItem.lastUnlockedItem;
                }
            } else {
                if (mContinuesPlayback) {
                    continuesPlayback = true;
                    final VideoView videoView = videoHolder.videoView;
                    if (TextUtils.equals(videoHolder.getMediaId(), mInitMediaKey)) {
                        final PlaybackController controller = videoView != null ? videoView.controller() : null;
                        if (controller != null) {
                            controller.unbindPlayer();
                        }
                    }
                }
            }
        }
        L.d(this, "onBackPressed", "continuesPlayback", continuesPlayback,
                currentDramaItem, currentDramaItem.currentItem);
        Intent intent = new Intent();
        intent.putExtra(EXTRA_OUTPUT, new Output(currentDramaItem, continuesPlayback));
        requireActivity().setResult(RESULT_CODE_EXIT, intent);
        return super.onBackPressed();
    }

    UnlockStateViewModel unlockStateModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mRemoteApi = new GetDramas();

        final Input input = parseInput();

        if (!checkInput(input) || input == null) {
            requireActivity().onBackPressed();
            return;
        }

        unlockStateModel = new ViewModelProvider(this).get(UnlockStateViewModel.class);

        mDramaItems = input.dramaItems;
        mCurrentDramaIndex = mInitDramaIndex = input.currentDramaIndex;
        mInitMediaKey = input.mediaKey;
        mContinuesPlayback = input.continuesPlayback;

        FragmentManager childFragmentManager = getChildFragmentManager();
        childFragmentManager.setFragmentResultListener(
                DramaEpisodePayChoiceFragment.REQUEST_KEY,
                this,
                (requestKey, result) -> {
                    int choice = result.getInt(DramaEpisodePayChoiceFragment.EXTRA_CHOICE);
                    switch (choice) {
                        case DramaEpisodePayChoiceFragment.CHOICE_UNLOCK_ALL:
                            onUserRequestUnlockAll(VALUE_FROM_CHOICE);
                            break;
                        case DramaEpisodePayChoiceFragment.CHOICE_WATCH_AD:
                            onUserRequestUnlockByWatchAd();
                            break;
                    }
                }
        );

        childFragmentManager.setFragmentResultListener(
                DramaSpeedSelectorFragment.REQUEST_KEY,
                this,
                (requestKey, result) -> {
                    float speed = result.getFloat(EXTRA_PLAYBACK_SPEED);
                    onUserSelectSpeed(speed);
                }
        );
    }

    /**
     * @return false for check not pass, true for check pass.
     */
    boolean checkInput(Input input) {
        if (input == null) {
            L.w(this, "checkInput", "input = null!");
            return false;
        }
        if (input.dramaItems == null || input.dramaItems.isEmpty()) {
            L.w(this, "checkInput", "input.dramaItems is Empty!");
            return false;
        }
        if (input.currentDramaIndex < 0 || input.currentDramaIndex >= input.dramaItems.size()) {
            L.w(this, "checkInput", "input.currentDramaIndex is not valid!" + input.currentDramaIndex);
            return false;
        }
        DramaItem initDramaItem = input.dramaItems.get(input.currentDramaIndex);
        if (initDramaItem == null) {
            L.w(this, "checkInput", "dramaItem == null");
            return false;
        }
        if (initDramaItem.dramaInfo == null) {
            L.w(this, "checkInput", "initDramaItem.dramaInfo == null");
            return false;
        }
        if (initDramaItem.currentItem == null && initDramaItem.currentEpisodeNumber < 1) {
            L.w(this, "checkInput", "currentItem=null", "currentEpisodeNumber=" + initDramaItem.currentEpisodeNumber);
            return false;
        }
        return true;
    }

    @Override
    public void onDestroyView() {
        MiniEventBus.unregister(this);
        super.onDestroyView();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mRemoteApi.cancel();
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.vevod_mini_drama_detail_video_fragment;
    }

    protected VevodMiniDramaDetailVideoFragmentBinding binding;
    protected DramaVideoSceneView mSceneView;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        binding = VevodMiniDramaDetailVideoFragmentBinding.bind(view);
        Guideline guidelineTop = view.findViewById(R.id.guideline_top);
        Guideline guidelineBottom = view.findViewById(R.id.guideline_bottom);
        ViewCompat.setOnApplyWindowInsetsListener(view, new OnApplyWindowInsetsListener() {
            @NonNull
            @Override
            public WindowInsetsCompat onApplyWindowInsets(@NonNull View v, @NonNull WindowInsetsCompat windowInsets) {
                Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
                guidelineTop.setGuidelineBegin(insets.top);
                guidelineBottom.setGuidelineEnd(insets.bottom);
                return windowInsets;
            }
        });

        binding.back.setOnClickListener(v -> {
            requireActivity()
                    .getOnBackPressedDispatcher()
                    .onBackPressed();
        });

        mSceneView = new DramaVideoSceneView(view);
        mSceneView.pageView().setLifeCycle(getLifecycle());
        mSceneView.pageView().setViewHolderFactory(getViewHolderFactory());
        mSceneView.setRefreshEnabled(false);
        mSceneView.setLoadMoreEnabled(true);
        mSceneView.setOnLoadMoreListener(this::load);
        mSceneView.pageView().viewPager().registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                L.d(this, "onPageSelected", position);
                final ViewItem item = mSceneView.pageView().getItem(position);
                if (item instanceof VideoItem) {
                    DramaFeed feed = Objects.requireNonNull(DramaFeed.of((VideoItem) item));
                    DramaItem dramaItem = requireDramaItem(feed);
                    int oldEpisodeNumber = dramaItem.updateCurrent(item, feed.episodeNumber);
                    MiniEventBus.post(new EpisodePlayStateChanged(feed.dramaId, oldEpisodeNumber, feed.episodeNumber));
                    onDramaEpisodeChanged(dramaItem, feed);
                } else {
                    setActionBarTitle("");
                }
            }
        });

        mSpeedIndicator = new SpeedIndicatorViewHolder(view, mSceneView);
        mSpeedIndicator.showSpeedIndicator(false);

        mEpisodeSelector = new EpisodeSelectorViewHolder(view);
        mEpisodeSelector.setOnClickListener(v -> {
            DramaItem dramaItem = currentDrama();
            showEpisodeSelectDialog(dramaItem);
        });
        mEpisodeSelector.setOnSpeedSelectorClickListener(v -> {
            showSpeedSelectorDialog();
        });
        initData();

        MiniEventBus.register(this);

        unlockStateModel.unlockState.observe(getViewLifecycleOwner(), state -> {
            if (state == UnlockState.UNLOCKING) {
                showLoadingDialog();
            } else {
                dismissLoadingDialog();
            }
        });
    }

    protected ViewHolder.Factory getViewHolderFactory() {
        return new DetailDramaVideoViewHolderFactory();
    }

    DramaItem requireDramaItem(@NonNull DramaFeed feed) {
        if (mDramaItems == null || mDramaItems.isEmpty()) {
            throw new IllegalStateException("mDramaItems is empty!");
        }

        for (DramaItem item : mDramaItems) {
            if (TextUtils.equals(item.getDramaId(), feed.dramaId)) return item;
        }

        throw new IllegalStateException("DramaItem not found: dramaId=" + feed.dramaId);
    }

    protected class DetailDramaVideoViewHolderFactory implements ViewHolder.Factory {
        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            switch (viewType) {
                case ItemType.ITEM_TYPE_VIDEO: {
                    final DramaEpisodeVideoViewHolder viewHolder = new DramaEpisodeVideoViewHolder(
                            new FrameLayout(parent.getContext()),
                            DramaVideoLayer.Type.DETAIL,
                            mSpeedIndicator);
                    final VideoView videoView = viewHolder.videoView;
                    final PlaybackController controller = videoView == null ? null : videoView.controller();
                    if (controller != null) {
                        controller.addPlaybackListener(new Dispatcher.EventListener() {
                            @Override
                            public void onEvent(Event event) {
                                if (event.code() == PlayerEvent.State.COMPLETED) {
                                    onPlayerStateCompleted(event);
                                }
                            }
                        });
                    }
                    return viewHolder;
                }
            }
            throw new IllegalArgumentException("unsupported type!");
        }
    }

    private void onDramaEpisodeChanged(DramaItem dramaItem, DramaFeed feed) {
        if (dramaItem == null) return;
        mEpisodeSelector.bind(dramaItem.dramaInfo);
        float speed = mSceneView.pageView().getPlaybackSpeed();
        mEpisodeSelector.updatePlaySpeed(speed);
        if (dramaItem.currentItem == null) return;
        if (!(dramaItem.currentItem instanceof VideoItem)) return;

        L.d(this, "onDramaEpisodeChanged");
        setActionBarTitle(getString(R.string.vevod_mini_drama_detail_video_episode_number_desc, feed.episodeNumber));

        if (feed.isLocked()) {
            showEpisodePayChoiceDialog();
        } else {
            dramaItem.lastUnlockedItem = dramaItem.currentItem;
        }
    }

    @Nullable
    private Input parseInput() {
        Intent intent = requireActivity().getIntent();
        Input input = (Input) intent.getSerializableExtra(EXTRA_INPUT);
        if (input == null && getArguments() != null) {
            input = (Input) getArguments().getSerializable(EXTRA_INPUT);
        }
        return input;
    }

    private void initData() {
        DramaItem initDramaItem = mDramaItems.get(mInitDramaIndex);
        if (initDramaItem == null) return;

        if (initDramaItem.currentItem == null) {
            if (initDramaItem.dramaInfo != null) {
                load(initDramaItem);
            }
        } else {
            final List<ViewItem> items = new ArrayList<>();
            items.add(initDramaItem.currentItem);
            setItems(items);
            onDramaEpisodeChanged(initDramaItem, DramaFeed.of((VideoItem) initDramaItem.currentItem));
            load(initDramaItem);
        }
    }

    protected void setItems(List<ViewItem> items) {
        List<VideoItem> videoItems = VideoItemHelper.findVideoItems(items);
        VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_SHORT), null);
        VideoItem.syncProgress(videoItems, true);
        mSceneView.pageView().setItems(videoItems);
    }

    private void appendItems(List<ViewItem> items) {
        List<VideoItem> videoItems = VideoItemHelper.findVideoItems(items);
        VideoItem.tag(videoItems, PlayScene.map(PlayScene.SCENE_SHORT), null);
        VideoItem.syncProgress(videoItems, true);
        mSceneView.pageView().appendItems(videoItems);
    }

    /**
     * @see DramaVideoPlayerConfigLayer
     */
    protected void onPlayerStateCompleted(Event event) {
        final Player player = event.owner(Player.class);
        if (player != null && !player.isLooping()) {
            playNext();
        }
    }

    private void playNext() {
        DramaVideoPageView pageView = mSceneView.pageView();

        final int currentPosition = pageView.getCurrentItem();
        final int nextPosition = currentPosition + 1;
        if (nextPosition < pageView.getItemCount()) {
            final ViewItem currentItem = pageView.getCurrentItemModel();
            final ViewItem nextItem = pageView.getItem(nextPosition);
            pageView.setCurrentItem(nextPosition, true);

            DramaItem current = currentDrama();
            if (nextItem instanceof VideoItem videoItem && current.isLastEpisode(currentItem)) {
                DramaItem nextDrama = requireDramaItem(DramaFeed.of(videoItem));
                Toast.makeText(requireContext(), getString(R.string.vevod_mini_drama_play_next_drama_hint, nextDrama.getDramaTitle()), Toast.LENGTH_SHORT).show();
            }
        }
    }

    // region EventBus
    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEpisodeUserSelectEvent(EpisodeUserSelectedEvent event) {
        final int position = mSceneView.pageView().findItemPosition(other -> {
            if (other instanceof VideoItem) {
                DramaFeed feed = DramaFeed.of((VideoItem) other);
                return TextUtils.equals(feed.dramaId, event.dramaId) && feed.episodeNumber == event.episodeNumber;
            } else {
                return false;
            }
        });
        if (position >= 0) {
            int currentItem = mSceneView.pageView().getCurrentItem();
            if (currentItem == position) {
                mSceneView.pageView().play();
            } else {
                mSceneView.pageView().setCurrentItem(position, false);
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onUserClickUnlockAllEvent(EpisodeUserClickUnlockAllEvent event) {
        DramaItem dramaItem = currentDrama();
        if (UnlockDataHelper.hasLocked(dramaItem)) {
            onUserRequestUnlockAll(VALUE_FROM_SELECTOR);
        } else {
            CenteredToast.show(R.string.vevod_mini_drama_already_unlock_all);
        }
    }

    // region Pay
    protected static final String DIALOG_EPISODE_PAY_CHOICE_DIALOG = "episode_pay_choice_dialog";

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEpisodePlayLockedEvent(EpisodePlayLockedEvent event) {
        showEpisodePayChoiceDialog();
    }

    protected void showEpisodePayChoiceDialog() {
        FragmentManager fragmentManager = getChildFragmentManager();
        Fragment dialog = fragmentManager.findFragmentByTag(DIALOG_EPISODE_UNLOCK_ALL);
        if (dialog != null) {
            return;
        }

        dialog = fragmentManager.findFragmentByTag(DIALOG_EPISODE_PAY_CHOICE_DIALOG);
        if (dialog != null) {
            return;
        }

        DramaEpisodePayChoiceFragment fragment = new DramaEpisodePayChoiceFragment();
        fragment.showNow(fragmentManager, DIALOG_EPISODE_PAY_CHOICE_DIALOG);
    }

    protected static final String DIALOG_EPISODE_UNLOCK_ALL = "episode_unlock_all";

    protected void onUserRequestUnlockAll(int from) {
        FragmentManager fragmentManager = getChildFragmentManager();
        Fragment dialog = fragmentManager.findFragmentByTag(DIALOG_EPISODE_UNLOCK_ALL);
        if (dialog != null) {
            return;
        }

        DramaEpisodeUnlockByPaymentFragment fragment = new DramaEpisodeUnlockByPaymentFragment();
        Bundle bundle = new Bundle();
        DramaItem dramaItem = currentDrama();
        bundle.putSerializable(EXTRA_DRAMA_ITEM, dramaItem);
        bundle.putInt(EXTRA_FROM, from);
        fragment.setArguments(bundle);
        fragment.showNow(fragmentManager, DIALOG_EPISODE_UNLOCK_ALL);
    }

    void onUserRequestUnlockByWatchAd() {
        mSceneView.pageView().setInterceptStartPlaybackOnResume(true);
        watchAdLauncher.launch(new Intent(requireContext(), DramaEpisodeMockAdActivity.class));
    }

    final ActivityResultLauncher<Intent> watchAdLauncher = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            activityResult -> {
                if (activityResult.getResultCode() == Activity.RESULT_OK) {
                    DramaItem dramaItem = currentDrama();
                    if (dramaItem == null) return;
                    Log.d("TEST", "RESULT_OK, start unlock");
                    unlockStateModel.unlockEpisodes(
                            dramaItem.getDramaId(),
                            Collections.singletonList(dramaItem.getCurrentEpisodeId())
                    );
                } else {
                    Log.d("TEST", "RESULT_CAAAA, start unlock");
                }
            });
    // endregion

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEpisodesUnlockedEvent(EpisodesUnlockedEvent event) {
        List<DramaItem> dramaItems = mDramaItems;
        if (dramaItems == null || dramaItems.isEmpty()) return;

        for (DramaItem dramaItem : dramaItems) {
            if (TextUtils.equals(dramaItem.getDramaId(), event.dramaId)) {
                dramaItem.unlock(event.metas);
                break;
            }
        }

        if (getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.RESUMED)) {
            Log.d("TEST", "resume state");
            DramaItem current = currentDrama();
            if (current != null && TextUtils.equals(current.getDramaId(), event.dramaId)) {
                String episodeId = current.getCurrentEpisodeId();
                if (event.has(episodeId)) {
                    Log.d("TEST", "has current item");
                    // Current is a locked item,
                    // and the episode is unlocked,
                    // so we can start playback
                    mSceneView.pageView().play();
                }
            }

            mSceneView.pageView().onEpisodesUnlocked();
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onEpisodesUnlockFailedEvent(EpisodesUnlockFailedEvent event) {
        CenteredToast.show(R.string.vevod_mini_drama_unlock_failed);
    }

    @Subscribe
    public void onCommentClick(OnCommentEvent event) {
        DialogFragment fragment;
        if (event.isLandscape) {
            fragment = new MDCommentDialogLFragment();
        } else {
            fragment = new MDCommentDialogFragment();
        }
        Bundle args = new Bundle();
        args.putString("vid", event.vid);
        fragment.setArguments(args);
        fragment.show(getChildFragmentManager(), "comment");
    }
    // endregion

    private void setActionBarTitle(String title) {
        binding.title.setText(title);
    }

    private static final String DIALOG_EPISODE_SELECTOR = "dialog-episode-selector";

    private void showEpisodeSelectDialog(DramaItem dramaItem) {
        FragmentManager fragmentManager = getChildFragmentManager();
        DramaEpisodeSelectDialogFragment dialog =
                (DramaEpisodeSelectDialogFragment) fragmentManager.findFragmentByTag(DIALOG_EPISODE_SELECTOR);
        if (dialog != null && dialog.isShowing()) {
            return;
        }
        L.d(this, "showEpisodeSelectDialog");
        dialog = DramaEpisodeSelectDialogFragment.newInstance(dramaItem);
        dialog.show(fragmentManager, DIALOG_EPISODE_SELECTOR);
    }

    private static final String DIALOG_SPEED_SELECTOR = "speed-selector";

    private void showSpeedSelectorDialog() {
        FragmentManager fragmentManager = getChildFragmentManager();
        Fragment fragment = fragmentManager.findFragmentByTag(DIALOG_SPEED_SELECTOR);
        if (fragment != null) {
            return;
        }

        L.d(this, "showEpisodeSelectDialog");
        DramaSpeedSelectorFragment dialog = new DramaSpeedSelectorFragment();
        Bundle args = new Bundle();
        args.putSerializable(EXTRA_PLAYBACK_SPEED, mSceneView.pageView().getPlaybackSpeed());
        dialog.setArguments(args);
        dialog.show(fragmentManager, DIALOG_SPEED_SELECTOR);
    }

    private void onUserSelectSpeed(float speed) {
        mSceneView.pageView().setPlaybackSpeed(speed);
        mEpisodeSelector.updatePlaySpeed(speed);
    }

    private void setCurrentItemByEpisodeNumber(int episodeNumber) {
        List<ViewItem> items = mSceneView.pageView().getItems();
        int position = DramaFeed.findPositionByEpisodeNumber(items, episodeNumber);
        if (0 <= position && position < items.size()) {
            mSceneView.pageView().setCurrentItem(position, false);
        }
    }

    private void load() {
        if (mSceneView.isLoadingMore()) {
            return;
        }

        DramaItem toBeLoad = null;
        if (SWIPE_BETWEEN_DRAMAS) {
            for (int index = mCurrentDramaIndex, size = mDramaItems.size();
                 index < size;
                 index++) {
                final DramaItem item = Objects.requireNonNull(mDramaItems.get(index));
                if (!item.episodesAllLoaded) {
                    toBeLoad = item;
                }
            }
        } else {
            DramaItem item = currentDrama();
            if (item != null && !item.episodesAllLoaded) {
                toBeLoad = item;
            }
        }

        if (toBeLoad == null) {
            mSceneView.finishLoadingMore();
            L.d(this, "load", "end");
            return;
        }
        load(toBeLoad);
    }

    private void load(@NonNull DramaItem dramaItem) {
        mSceneView.showLoadingMore();
        L.d(this, "load", "start", DramaItem.dump(dramaItem));
        mRemoteApi.getDramaList(dramaItem.getDramaId(), new HttpCallback<>() {
            @Override
            public void onSuccess(List<DramaFeed> items) {
                L.d(this, "load", "success", DramaItem.dump(dramaItem), items);
                if (getActivity() == null) return;
                mSceneView.dismissLoadingMore();

                List<ViewItem> videoItems = new ArrayList<>(DramaFeed.toVideoItems(items));

                dramaItem.episodeVideoItems = videoItems;
                dramaItem.episodesAllLoaded = true;
                final DramaItem initDrama = mDramaItems.get(mInitDramaIndex);
                if (dramaItem == initDrama) {
                    setItems(videoItems);
                    if (dramaItem.currentEpisodeNumber >= 1) {
                        setCurrentItemByEpisodeNumber(dramaItem.currentEpisodeNumber);
                    }
                } else {
                    appendItems(videoItems);
                }
            }

            @Override
            public void onError(Throwable e) {
                L.e(this, "load", e, "error", DramaItem.dump(dramaItem));
                if (getActivity() == null) return;
                mSceneView.dismissLoadingMore();
                Toast.makeText(getActivity(), String.valueOf(e), Toast.LENGTH_LONG).show();
            }
        });
    }

    private static final String TAG_DIALOG_LOADING = "dialog-loading";

    void showLoadingDialog() {
        FragmentManager fragmentManager = getChildFragmentManager();
        Fragment fragment = fragmentManager.findFragmentByTag(TAG_DIALOG_LOADING);
        if (fragment != null) {
            return;
        }

        DramaLoadingDialog dialog = new DramaLoadingDialog();
        dialog.showNow(fragmentManager, TAG_DIALOG_LOADING);
    }

    void dismissLoadingDialog() {
        FragmentManager fragmentManager = getChildFragmentManager();
        DialogFragment fragment = (DialogFragment) fragmentManager.findFragmentByTag(TAG_DIALOG_LOADING);
        if (fragment != null) {
            fragment.dismiss();
        }
    }
}
