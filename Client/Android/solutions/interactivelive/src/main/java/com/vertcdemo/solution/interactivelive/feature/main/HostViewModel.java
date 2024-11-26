// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.os.SystemClock;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.event.RequestFinishLiveResultEvent;
import com.vertcdemo.solution.interactivelive.http.LiveService;
import com.vertcdemo.solution.interactivelive.http.response.FinishRoomResponse;
import com.vertcdemo.ui.CenteredToast;

public class HostViewModel extends ViewModel {
    // room information
    public LiveRoomInfo roomInfo;

    public String rtsRoomId() {
        return roomInfo.roomId;
    }

    public String anchorUserId() {
        return roomInfo.anchorUserId;
    }

    private long liveStartTime;

    public boolean finishRequested = false;

    public void setLiveStartTime() {
        if (liveStartTime == 0) {
            liveStartTime = SystemClock.uptimeMillis();
        }
    }

    public long getLiveStartTime() {
        return liveStartTime;
    }

    public MutableLiveData<Boolean> showAudienceDot = new MutableLiveData<>(false);

    public void requestFinishLive() {
        finishRequested = true;
        LiveService.get()
                .finishLive(rtsRoomId(), new Callback<FinishRoomResponse>() {
                    @Override
                    public void onResponse(FinishRoomResponse response) {
                        SolutionEventBus.post(new RequestFinishLiveResultEvent(response));
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        CenteredToast.show(ErrorTool.getErrorMessage(e));
                        SolutionEventBus.post(new RequestFinishLiveResultEvent());
                    }
                });
    }
}
