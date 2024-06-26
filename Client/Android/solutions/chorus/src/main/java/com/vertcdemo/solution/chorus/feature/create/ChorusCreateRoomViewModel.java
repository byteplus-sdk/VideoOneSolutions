// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.create;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.chorus.bean.CreateRoomResponse;
import com.vertcdemo.solution.chorus.common.SolutionToast;
import com.vertcdemo.solution.chorus.core.ChorusRTCManager;
import com.vertcdemo.solution.chorus.core.ChorusRTSClient;

public class ChorusCreateRoomViewModel extends ViewModel {
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

    public void requestStartRoom(String roomName, String backgroundImageName) {
        ChorusRTSClient rtsClient = ChorusRTCManager.ins().getRTSClient();
        assert rtsClient != null : "RTSClient is required";
        rtsClient.requestStartLive(
                roomName, backgroundImageName, mCreateRoomRequest);
    }
}