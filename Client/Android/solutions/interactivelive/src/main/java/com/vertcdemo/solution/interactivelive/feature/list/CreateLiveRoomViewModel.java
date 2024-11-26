// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.http.LiveService;
import com.vertcdemo.solution.interactivelive.http.response.CreateRoomResponse;
import com.vertcdemo.ui.CenteredToast;

import java.util.Objects;

public class CreateLiveRoomViewModel extends ViewModel {

    public static final int STATUS_NONE = 0;
    public static final int STATUS_CREATING = 1;
    public static final int STATUS_CREATED = 2;

    public static final int STATUS_CREATE_FAILED = 3;

    public static final int STATUS_STARTING = 4;
    public static final int STATUS_STARTED = 5;
    public static final int STATUS_START_FAILED = 6;

    public CreateRoomResponse createResult;
    public LiveUserInfo userInfo;

    public final MutableLiveData<Integer> status = new MutableLiveData<>(STATUS_NONE);

    public final MutableLiveData<Integer> countDown = new MutableLiveData<>(0);

    public void requestCreateLiveRoom() {
        if (Objects.requireNonNull(status.getValue()) == STATUS_CREATING) {
            return;
        }
        status.postValue(STATUS_CREATING);

        LiveService.get().createLive(new Callback<CreateRoomResponse>() {

            @Override
            public void onResponse(CreateRoomResponse response) {
                createResult = Objects.requireNonNull(response);
                status.postValue(STATUS_CREATED);
            }

            @Override
            public void onFailure(HttpException e) {
                CenteredToast.show(ErrorTool.getErrorMessage(e));
                status.postValue(STATUS_CREATE_FAILED);
            }
        });
    }

    public void requestStartLive() {
        Integer current = Objects.requireNonNull(status.getValue());
        if (current == STATUS_STARTING) {
            return;
        }
        status.postValue(STATUS_STARTING);
        LiveService.get()
                .startLive(requireRoomId(), new Callback<Void>() {
                    @Override
                    public void onResponse(Void response) {
                        status.postValue(STATUS_STARTED);
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        CenteredToast.show(com.vertcdemo.rtc.toolkit.R.string.request_failed);
                        status.postValue(STATUS_START_FAILED);
                    }
                });
    }

    @NonNull
    public String requireRoomId() {
        CreateRoomResponse result = createResult;
        if (result == null) {
            throw new IllegalStateException("createResult is null");
        }
        if (result.liveRoomInfo == null) {
            throw new IllegalStateException("createResult.liveRoomInfo is null");
        }
        if (result.liveRoomInfo.roomId == null) {
            throw new IllegalStateException("createResult.liveRoomInfo.roomId is null");
        }
        return result.liveRoomInfo.roomId;
    }
}
