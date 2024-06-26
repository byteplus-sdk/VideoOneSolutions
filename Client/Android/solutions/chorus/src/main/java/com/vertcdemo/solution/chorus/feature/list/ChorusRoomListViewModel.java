// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.list;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.chorus.bean.GetActiveRoomsResponse;
import com.vertcdemo.solution.chorus.bean.RoomInfo;
import com.vertcdemo.solution.chorus.common.SolutionToast;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;
import com.vertcdemo.solution.chorus.core.ChorusRTSClient;
import com.vertcdemo.solution.chorus.core.ErrorCodes;

import java.util.Collections;
import java.util.List;

public class ChorusRoomListViewModel extends ViewModel {
    public final MutableLiveData<List<RoomInfo>> rooms = new MutableLiveData<>();

    public void requestRoomList() {
        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        if (rtsClient == null) {
            return;
        }
        rtsClient.requestClearUser(() -> {
            rtsClient.getActiveRoomList(mRequestListRoomList);
        });
    }


    private final IRequestCallback<GetActiveRoomsResponse> mRequestListRoomList = new IRequestCallback<GetActiveRoomsResponse>() {
        @Override
        public void onSuccess(GetActiveRoomsResponse data) {
            List<RoomInfo> list = data.roomList != null ? data.roomList : Collections.emptyList();
            rooms.postValue(list);
        }

        @Override
        public void onError(int errorCode, String message) {
            SolutionToast.show(ErrorCodes.prettyMessage(errorCode, message));
        }
    };
}