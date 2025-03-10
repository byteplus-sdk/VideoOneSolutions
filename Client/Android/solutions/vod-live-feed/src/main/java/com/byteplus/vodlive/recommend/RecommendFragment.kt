// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.recommend

import android.os.Bundle
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import com.byteplus.playerkit.player.playback.PlaybackController
import com.byteplus.vodlive.R
import com.byteplus.vodlive.databinding.FragmentRecommendBinding
import com.byteplus.vodlive.live.LiveController
import com.byteplus.vodlive.live.player.PlayerScene
import com.byteplus.vodlive.model.VodFeedItem
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.byteplus.vodlive.utils.OnPageChangeCallbackExt
import com.byteplus.vodlive.utils.StrategyManager
import com.byteplus.vodlive.utils.findViewHolderForLayoutPosition
import com.byteplus.vodlive.utils.playerLog
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class RecommendFragment : Fragment(R.layout.fragment_recommend) {
    private val viewModel: RecommendViewModel by viewModels()

    private var playType = PlayType.NONE

    private val playbackController = PlaybackController()

    private val liveController by lazy { LiveController(requireContext(), PlayerScene.RECOMMEND) }

    private var binding: FragmentRecommendBinding? = null

    private val lifecycleObserver = LifecycleEventObserver { source, event ->
        liveController.onStateChanged(source, event)
        when (event) {
            Lifecycle.Event.ON_START -> {
                if (playType == PlayType.VOD) {
                    resumePlay()
                }
            }

            Lifecycle.Event.ON_STOP -> {
                if (playType == PlayType.VOD) {
                    pausePlay()
                }
            }

            else -> {}
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        StrategyManager.enable()
        lifecycle.addObserver(lifecycleObserver)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        WindowCompat.getInsetsController(
            requireActivity().window, view
        ).isAppearanceLightStatusBars = false

        val binding = FragmentRecommendBinding.bind(view).also {
            this.binding = it
        }

        val adapter = RecommendAdapter(liveController)

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsets ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            binding.guidelineTop.setGuidelineBegin(insets.top)
            adapter.insets = insets
            windowInsets
        }

        binding.back.setOnClickListener {
            @Suppress("DEPRECATION")
            requireActivity().onBackPressed()
        }

        binding.refreshLayout.setOnRefreshListener {
            viewModel.loadFirst()
        }

        binding.viewPager.orientation = ViewPager2.ORIENTATION_VERTICAL
        binding.viewPager.offscreenPageLimit = 1
        binding.viewPager.adapter = adapter

        // Handle load more
        binding.viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                if (!viewModel.canLoadMore) {
                    return
                }

                if (position >= adapter.itemCount - 2) {
                    viewModel.loadNext()
                }
            }
        })

        val pageChangeCallback = object : OnPageChangeCallbackExt() {

            override fun onPageScrollStateChanged(state: Int) {
                super.onPageScrollStateChanged(state)
                if (state == ViewPager2.SCROLL_STATE_DRAGGING) {
                    playerLog(TAG, "stop VOD Preload")
                    StrategyManager.stopPreload()
                }
            }

            override fun onPositionVisibilityChanged(oldPosition: Int, newPosition: Int) {
                if (newPosition == RecyclerView.NO_POSITION) return
                val newVideoItem = newPosition.findViewHolder<RecommendViewHolder>()
                if (newVideoItem is LiveViewHolder) {
                    liveController.preview(
                        newVideoItem,
                        adapter.getItem(newPosition) as LiveFeedItem
                    )
                }
            }

            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)

                when (val holder = position.findViewHolder<RecommendViewHolder>()) {
                    is LiveViewHolder -> {
                        playType = PlayType.LIVE
                        playbackController.stopPlayback()

                        liveController.select(holder, adapter.getItem(position) as LiveFeedItem)
                    }

                    is VodViewHolder -> {
                        playType = PlayType.VOD
                        liveController.stop()

                        togglePlayback(position)
                    }
                }

                val next = position + 1
                if (next < adapter.itemCount) {
                    val item = adapter.getItem(next)
                    if (item is LiveFeedItem) {
                        liveController.preload(
                            next.findViewHolder<LiveViewHolder>(),
                            item
                        )
                    } else if (item is VodFeedItem) {
                        playerLog(TAG, "start VOD Preload")
                        StrategyManager.startPreload()
                    }
                }
            }
        }.also {
            binding.viewPager.registerOnPageChangeCallback(it)
        }

        lifecycleScope.launch {
            viewModel.stateFlow.collectLatest { state ->
                when (state) {
                    RecommendViewModel.State.INIT -> {
                        viewModel.loadFirst()
                    }

                    RecommendViewModel.State.LOADING, RecommendViewModel.State.LOADED -> {
                        binding.refreshLayout.isRefreshing =
                            (state == RecommendViewModel.State.LOADING)
                    }
                }
            }
        }

        lifecycleScope.launch {
            viewModel.videoItemFlow.collectLatest { items ->
                adapter.setItems(items)
                if (viewModel.pageIndex == 0) {
                    if (pageChangeCallback.currentPosition == RecyclerView.NO_POSITION) {
                        // First time load, ViewPager2 will called onPageSelected, no need to fix
                        // Skip patch
                        return@collectLatest
                    }
                    // After pull down refresh, ViewPager2 not called onPageSelected
                    binding.viewPager.post {
                        // Note: Must use post to wait for ViewPager2 layout
                        pageChangeCallback.onPageSelected(0)
                    }
                }
            }
        }

        lifecycleScope.launch {
            viewModel.licenseResultFlow.collectLatest { result ->
                when {
                    result.isEmpty() -> {
                        viewModel.checkLicence(requireContext().applicationContext)
                    }

                    !result.isOk() -> {
                        binding.licenseTips.visibility = View.VISIBLE
                        binding.licenseTips.setText(result.message)
                        binding.licenseTips.setOnClickListener { /* consume the click event */ }
                    }
                }
            }
        }
    }

    private inline fun <reified T> Int.findViewHolder(): T? {
        return binding?.viewPager?.findViewHolderForLayoutPosition<T>(this)
    }

    // region Vod
    private var mInterceptStartPlaybackOnResume = false

    private fun togglePlayback(position: Int) {
        if (!lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
            // state not resumed, do nothing
            return
        }

        val newVideoView = position.findViewHolder<VodViewHolder>()?.videoView
        val oldVideoView = playbackController.videoView()

        if (oldVideoView != null && oldVideoView != newVideoView) {
            playbackController.stopPlayback()
        }

        newVideoView.let {
            playbackController.bind(it)
            playbackController.startPlayback()
        }
    }

    private fun resumePlay() {
        if (FORCE_RESUME_PLAY || !mInterceptStartPlaybackOnResume) {
            playbackController.startPlayback()
        }
        mInterceptStartPlaybackOnResume = false
    }

    private fun pausePlay() {
        val player = playbackController.player()
        if (player != null && (player.isPaused || (!player.isLooping && player.isCompleted))) {
            mInterceptStartPlaybackOnResume = true
        } else {
            mInterceptStartPlaybackOnResume = false
            playbackController.pausePlayback()
        }
    }
    // endregion

    companion object {
        private const val TAG = "RecommendFragment"

        /**
         * Enable this to resume play when onResume even if use paused
         */
        private const val FORCE_RESUME_PLAY = true

        enum class PlayType {
            LIVE, VOD, NONE
        }
    }
}