// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomListResponse;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.util.CenteredToast;

import java.util.Collections;
import java.util.List;

public class LiveRoomListViewModel extends ViewModel {

    public MutableLiveData<List<LiveRoomInfo>> rooms = new MutableLiveData<>(Collections.emptyList());

    public void requestRoomList() {
        LiveRTCManager.rts().requestLiveClearUser(() -> {
            LiveRTCManager.ins().getRTSClient().requestLiveRoomList(mRequestListRoomList);
        });
    }


    private final IRequestCallback<LiveRoomListResponse> mRequestListRoomList = new IRequestCallback<LiveRoomListResponse>() {

        @Override
        public void onSuccess(LiveRoomListResponse data) {
            rooms.postValue(data.getRoomList());
        }

        @Override
        public void onError(int errorCode, String message) {
            CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
        }
    };
}
