package com.byteplus.vodlive.recommend

import android.content.Context
import androidx.lifecycle.viewModelScope
import com.byteplus.playerkit.player.source.MediaSource
import com.byteplus.vod.scenekit.data.model.VideoItem
import com.byteplus.vodlive.model.FeedItem
import com.byteplus.vodlive.model.VodFeedItem
import com.byteplus.vodlive.network.VOD_PAGE_SIZE
import com.byteplus.vodlive.network.model.GetFeedWithLiveRequest
import com.byteplus.vodlive.network.vodLiveApi
import com.byteplus.vodlive.utils.StrategyManager
import com.byteplus.vodlive.viewmodel.PageViewModel
import com.vertcdemo.core.utils.LicenseChecker
import com.vertcdemo.core.utils.LicenseResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class RecommendViewModel : PageViewModel() {
    enum class State {
        INIT, LOADING, LOADED
    }

    private val _stateFlow: MutableStateFlow<State> = MutableStateFlow(State.INIT)
    val stateFlow: StateFlow<State> = _stateFlow

    private val _videoItemFlow: MutableStateFlow<List<FeedItem>> = MutableStateFlow(emptyList())
    val videoItemFlow: StateFlow<List<FeedItem>> = _videoItemFlow

    fun loadFirst() {
        viewModelScope.launch {
            _stateFlow.value = State.LOADING
            loadImpl(page = 0)
            _stateFlow.value = State.LOADED
        }
    }

    fun loadNext() {
        viewModelScope.launch {
            loadImpl(page = pageIndex + 1)
        }
    }

    private suspend fun loadImpl(page: Int) {
        if (loading) {
            return
        }
        loading = true
        val items = withContext(Dispatchers.IO) {
            runCatching {
                vodLiveApi.getFeedWithLive(
                    GetFeedWithLiveRequest.page(
                        page, pageSize = VOD_PAGE_SIZE
                    )
                )
            }.getOrNull()
        }?.body()?.mapNotNull {
            it.asFeed()
        } ?: emptyList()

        hasMore = (items.size >= VOD_PAGE_SIZE)
        loading = false
        pageIndex = page

        if (page == 0) {
            StrategyManager.setMediaSources(items.filterMediaSource())
            _videoItemFlow.value = items
        } else { // append items
            StrategyManager.appendMediaSources(items.filterMediaSource())
            _videoItemFlow.value += items
        }
    }

    private fun List<FeedItem>.filterMediaSource(): List<MediaSource> = mapNotNull {
        when (it) {
            is VodFeedItem -> {
                VideoItem.toMediaSource(it.videoItem, false)
            }

            else -> {
                null
            }
        }
    }

    private val _licenseResultFlow: MutableStateFlow<LicenseResult> =
        MutableStateFlow(LicenseResult.empty)
    val licenseResultFlow: StateFlow<LicenseResult> = _licenseResultFlow

    fun checkLicence(context: Context) {
        viewModelScope.launch(Dispatchers.IO) {
            val licenseUri = com.byteplus.vodcommon.BuildConfig.VOD_LICENSE_URI
            val result = LicenseChecker.check(context, licenseUri)
            _licenseResultFlow.value = result
        }
    }
}