// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.CreateLiveRoomResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.util.CenteredToast;

public class CreateLiveRoomViewModel extends ViewModel {

    public static final int STATUS_NONE = 0;
    public static final int STATUS_CREATING = 1;
    public static final int STATUS_CREATED = 2;

    public static final int STATUS_CREATE_FAILED = 3;

    public static final int STATUS_STARTING = 4;
    public static final int STATUS_STARTED = 5;
    public static final int STATUS_START_FAILED = 6;

    public CreateLiveRoomResponse response;
    public LiveUserInfo userInfo;

    public final MutableLiveData<Integer> status = new MutableLiveData<>(STATUS_NONE);

    public final MutableLiveData<Integer> countDown = new MutableLiveData<>(0);

    public void requestCreateLiveRoom() {
        if (status.getValue() == STATUS_CREATING) {
            return;
        }
        status.postValue(STATUS_CREATING);
        LiveRTCManager.ins().getRTSClient().requestCreateLiveRoom(new IRequestCallback<CreateLiveRoomResponse>() {
            @Override
            public void onSuccess(CreateLiveRoomResponse data) {
                response = data;
                status.postValue(STATUS_CREATED);
            }

            @Override
            public void onError(int errorCode, String message) {
                CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
                status.postValue(STATUS_CREATE_FAILED);
            }
        });
    }

    public void requestStartLive() {
        if (status.getValue() == STATUS_STARTING) {
            return;
        }
        status.postValue(STATUS_STARTING);
        LiveRTCManager.ins().getRTSClient().requestStartLive(response.liveRoomInfo.roomId, new IRequestCallback<LiveResponse>() {
            @Override
            public void onSuccess(LiveResponse data) {
                status.postValue(STATUS_STARTED);
            }

            @Override
            public void onError(int errorCode, String message) {
                CenteredToast.show(R.string.request_failed);
                status.postValue(STATUS_START_FAILED);
            }
        });
    }
}
