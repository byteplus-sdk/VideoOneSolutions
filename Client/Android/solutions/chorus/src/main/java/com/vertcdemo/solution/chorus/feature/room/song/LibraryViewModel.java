// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.room.song;

import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.solution.chorus.bean.StatusSongItem;

public class LibraryViewModel extends ViewModel {
    public final MutableLiveData<Integer> index = new MutableLiveData<>(0);
    @Nullable
    StatusSongItem pending;
}
