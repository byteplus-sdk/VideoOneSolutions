// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.list;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.ktv.bean.GetActiveKTVListResponse;
import com.vertcdemo.solution.ktv.bean.RoomInfo;
import com.vertcdemo.solution.ktv.common.SolutionToast;
import com.vertcdemo.solution.ktv.core.ErrorCodes;
import com.vertcdemo.solution.ktv.core.KTVRTCManager;
import com.vertcdemo.solution.ktv.core.KTVRTSClient;

import java.util.Collections;
import java.util.List;

public class KTVRoomListViewModel extends ViewModel {
    public final MutableLiveData<List<RoomInfo>> rooms = new MutableLiveData<>();

    public void requestRoomList() {
        KTVRTSClient rtsClient = KTVRTCManager.ins().getRTSClient();
        if (rtsClient == null) {
            return;
        }
        rtsClient.requestClearUser(() -> {
            rtsClient.getActiveRoomList(mRequestListRoomList);
        });
    }


    private final IRequestCallback<GetActiveKTVListResponse> mRequestListRoomList = new IRequestCallback<GetActiveKTVListResponse>() {
        @Override
        public void onSuccess(GetActiveKTVListResponse data) {
            List<RoomInfo> list = data.roomList != null ? data.roomList : Collections.emptyList();
            rooms.postValue(list);
        }

        @Override
        public void onError(int errorCode, String message) {
            SolutionToast.show(ErrorCodes.prettyMessage(errorCode, message));
        }
    };
}
