// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.chorus.feature.create;

import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.solution.chorus.core.ErrorCodes;
import com.vertcdemo.solution.chorus.http.ChorusService;
import com.vertcdemo.solution.chorus.http.response.CreateRoomResponse;
import com.vertcdemo.ui.CenteredToast;

import java.util.Objects;

public class ChorusCreateRoomViewModel extends ViewModel {
    public final MutableLiveData<Integer> bgIndex = new MutableLiveData<>(0);

    public final MutableLiveData<CreateRoomResponse> createResult = new MutableLiveData<>();

    public void requestStartRoom(String roomName, String backgroundImageName) {
        ChorusService.get()
                .startLive(roomName, backgroundImageName, new Callback<CreateRoomResponse>() {
                    @Override
                    public void onResponse(@Nullable CreateRoomResponse response) {
                        CreateRoomResponse body = Objects.requireNonNull(response, "ResponseBody is null.");
                        createResult.postValue(body);
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        CenteredToast.show(ErrorCodes.prettyMessage(e));
                    }
                });
    }
}