// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.pay;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.byteplus.vod.minidrama.event.EpisodesUnlockFailedEvent;
import com.byteplus.vod.minidrama.remote.api.HttpCallback;
import com.byteplus.vod.minidrama.remote.model.drama.DramaUnlockMeta;
import com.byteplus.vod.minidrama.event.EpisodesUnlockedEvent;
import com.byteplus.vod.minidrama.remote.GetDramas;
import com.byteplus.vod.minidrama.utils.MiniEventBus;

import java.util.List;

public class UnlockStateViewModel extends ViewModel {

    public final MutableLiveData<UnlockState> unlockState = new MutableLiveData<>();

    private final GetDramas api = new GetDramas();

    public void unlockEpisodes(String dramaId, @NonNull List<String> episodes) {
        unlockState.setValue(UnlockState.UNLOCKING);
        api.unlockEpisodes(dramaId, episodes, new HttpCallback<>() {

            @Override
            public void onSuccess(List<DramaUnlockMeta> metas) {
                unlockState.setValue(UnlockState.UNLOCKED);
                patchDramaId(dramaId, metas);
                MiniEventBus.post(new EpisodesUnlockedEvent(dramaId, metas));
            }

            @Override
            public void onError(Throwable t) {
                unlockState.setValue(UnlockState.ERROR);
                MiniEventBus.post(new EpisodesUnlockFailedEvent());
            }
        });
    }

    @Override
    protected void onCleared() {
        api.cancel();
        super.onCleared();
    }

    private static void patchDramaId(String dramaId, List<DramaUnlockMeta> metas) {
        if (metas == null || metas.isEmpty()) {
            return;
        }
        for (DramaUnlockMeta meta : metas) {
            if (meta.dramaId == null || meta.dramaId.isEmpty()) {
                meta.dramaId = dramaId;
            }
        }
    }
}
