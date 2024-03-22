// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.create;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.ktv.bean.CreateRoomResponse;
import com.vertcdemo.solution.ktv.common.SolutionToast;
import com.vertcdemo.solution.ktv.core.KTVRTCManager;
import com.vertcdemo.solution.ktv.core.KTVRTSClient;

public class CreateKTVRoomViewModel extends ViewModel {
    public final MutableLiveData<Integer> bgIndex = new MutableLiveData<>(0);

    public final MutableLiveData<CreateRoomResponse> response = new MutableLiveData<>();

    private final IRequestCallback<CreateRoomResponse> mCreateRoomRequest = new IRequestCallback<CreateRoomResponse>() {
        @Override
        public void onSuccess(CreateRoomResponse data) {
            response.postValue(data);
        }

        @Override
        public void onError(int errorCode, String message) {
            SolutionToast.show(message);
        }
    };

    public void requestStartKTVRoom(String roomName, String backgroundImageName) {
        KTVRTSClient rtsClient = KTVRTCManager.ins().getRTSClient();
        assert rtsClient != null : "RTSClient is required";
        rtsClient.requestStartLive(
                roomName, backgroundImageName, mCreateRoomRequest);
    }
}
