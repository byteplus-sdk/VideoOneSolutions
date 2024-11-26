// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.create;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.solution.ktv.core.ErrorCodes;
import com.vertcdemo.solution.ktv.http.KTVService;
import com.vertcdemo.solution.ktv.http.response.CreateRoomResponse;
import com.vertcdemo.ui.CenteredToast;

public class CreateKTVRoomViewModel extends ViewModel {
    public final MutableLiveData<Integer> bgIndex = new MutableLiveData<>(0);

    public final MutableLiveData<CreateRoomResponse> createResult = new MutableLiveData<>();

    public void requestStartKTVRoom(String roomName, String backgroundImageName) {
        KTVService.get().
                startLive(roomName, backgroundImageName, new Callback<CreateRoomResponse>() {
                    @Override
                    public void onResponse(CreateRoomResponse response) {
                        if (response != null) {
                            createResult.postValue(response);
                        } else {
                            onFailure(HttpException.unknown("Response is null"));
                        }
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        CenteredToast.show(ErrorCodes.prettyMessage(e));
                    }
                });
    }
}
