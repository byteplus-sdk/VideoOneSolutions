// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.ui

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.CreationExtras
import androidx.lifecycle.viewmodel.ViewModelInitializer
import com.vertcdemo.effect.core.IEffect
import com.vertcdemo.effect.bean.BeautyItem
import com.vertcdemo.effect.bean.EffectType
import com.vertcdemo.effect.bean.FilterItem
import com.vertcdemo.effect.bean.StickerItem
import com.vertcdemo.effect.core.IEffect.EffectResult
import com.vertcdemo.effect.utils.EffectDataConfig
import com.vertcdemo.effect.utils.EffectResource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File

sealed interface EffectState {
    object NONE : EffectState
    object LOADING : EffectState
    class LOADED(val result: EffectResult) : EffectState
}

class EffectViewModel(private val mParent: IEffect) : ViewModel(),
    OnEffectHandlerUpdatedListener {

    private val _state = MutableLiveData<EffectState>(EffectState.NONE)

    val state: LiveData<EffectState>
        get() = _state

    override fun onEffectHandlerUpdated(policy: EffectHandlerUpdatePolicy) {
        val state = _state.value
        if (state is EffectState.LOADED && !state.result.success) {
            Log.d(TAG, "onEffectHandlerUpdated: skip by not LOADED: $state")
            return
        }

        Log.d(TAG, "onEffectHandlerUpdated: policy=$policy")

        viewModelScope.launch {
            enableEffect()

            when (policy) {
                EffectHandlerUpdatePolicy.DISCARD -> {
                    tabIndex = 0
                    defaults()
                }

                EffectHandlerUpdatePolicy.KEEP -> {
                    if (!selectedBeauty.isClose) {
                        // Restore beauty value to new handler
                        val checkedNodes = beautyItems.filter { !it.isClose && it.isChecked }
                        val checkedNodePaths = checkedNodes.map {
                            EffectResource.getBeautyPathByName(it.path)
                        }.distinct()

                        if (checkedNodePaths.isNotEmpty()) {
                            mParent.setEffectNodes(checkedNodePaths)

                            for (item in checkedNodes) {
                                mParent.updateEffectNode(
                                    EffectResource.getBeautyPathByName(item.path),
                                    item.key,
                                    item.value
                                )
                            }
                        }
                    }

                    if (!selectedFilter.isClose) {
                        // Restore beauty value to new handler
                        val item = selectedFilter
                        mParent.setColorFilter(EffectResource.getFilterPathByName(item.path))
                        mParent.setColorFilterIntensity(item.value)
                    }

                    if (!selectedSticker.isClose) {
                        val item = selectedSticker
                        mParent.setSticker(EffectResource.getStickerPathByName(item.path))
                    }
                }
            }
        }
    }

    var tabIndex: Int = 0

    var beautyItems: List<BeautyItem> = emptyList()
    var filterItems: List<FilterItem> = emptyList()
    var stickerItems: List<StickerItem> = emptyList()

    var selectedBeauty: BeautyItem = EffectDataConfig.BEAUTY_CLOSE
        set(value) {
            field = value

            if (value.isClose) {
                mParent.setEffectNodes(emptyList())
            } else {
                val checkedNodePaths = beautyItems.filter { !it.isClose && it.isChecked }
                    .map { EffectResource.getBeautyPathByName(it.path) }.distinct()

                mParent.setEffectNodes(checkedNodePaths)

                mParent.updateEffectNode(
                    EffectResource.getBeautyPathByName(value.path), value.key, value.value
                )
            }
        }

    var selectedFilter: FilterItem = EffectDataConfig.FILTER_CLOSE
        set(value) {
            field = value

            if (value.isClose) {
                mParent.setColorFilter("")
                mParent.setColorFilterIntensity(0f)
            } else {
                mParent.setColorFilter(EffectResource.getFilterPathByName(value.path))
                mParent.setColorFilterIntensity(value.value)
            }
        }

    var selectedSticker: StickerItem = EffectDataConfig.STICKER_CLOSE
        set(value) {
            field = value

            if (value.isClose) {
                mParent.setSticker("")
            } else {
                mParent.setSticker(EffectResource.getStickerPathByName(value.path))
            }
        }

    init {
        mParent.setOnEffectHandlerUpdatedListener(this)
        defaults()
    }

    fun updateItemValue(type: EffectType, value: Float) {
        when (type) {
            EffectType.beauty -> {
                if (!selectedBeauty.isClose) {
                    selectedBeauty.value = value
                    val path = EffectResource.getBeautyPathByName(selectedBeauty.path)
                    mParent.updateEffectNode(path, selectedBeauty.key, value)
                }
            }

            EffectType.filter -> {
                if (!selectedFilter.isClose) {
                    selectedFilter.value = value
                    mParent.setColorFilterIntensity(value)
                }
            }

            else -> {
                // do nothing
            }
        }
    }

    private fun enableEffect(): EffectResult {
        val licensePath = EffectResource.licensePath
        val modelPath = EffectResource.modelPath

        if (!licensePath.exists()) return EffectResult(-1, "License not found")
        if (!modelPath.exists()) return EffectResult(-1, "Model resource not found")

        return mParent.enableEffect(licensePath, modelPath)
    }

    fun uncompressResources() {
        _state.postValue(EffectState.LOADING)

        viewModelScope.launch(Dispatchers.IO) {
            EffectResource.uncompressResources()
            val result = enableEffect()
            _state.postValue(EffectState.LOADED(result))
        }
    }

    private fun defaults() {
        beautyItems = EffectDataConfig.defaultBeauty()
        selectedBeauty = EffectDataConfig.BEAUTY_CLOSE.apply { isSelected = true }

        filterItems = EffectDataConfig.defaultFilters()
        selectedFilter = EffectDataConfig.FILTER_CLOSE.apply { isSelected = true }

        stickerItems = EffectDataConfig.defaultStickers()
        selectedSticker = EffectDataConfig.STICKER_CLOSE.apply { isSelected = true }
    }

    private fun String.exists() = File(this).exists()

    companion object {
        private const val TAG = "EffectUIViewModel"

        @JvmField
        val KEY_EFFECT = object : CreationExtras.Key<IEffect> {}

        @JvmStatic
        val initializer: ViewModelInitializer<EffectViewModel> =
            ViewModelInitializer(EffectViewModel::class.java) {
                EffectViewModel(this[KEY_EFFECT]!!)
            }
    }
}
