// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.os.SystemClock;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.interactivelive.bean.LiveFinishResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.event.RequestFinishLiveResultEvent;
import com.vertcdemo.solution.interactivelive.util.CenteredToast;

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
        LiveRTCManager.ins().getRTSClient().requestFinishLive(rtsRoomId(), mFinishLiveCallback);
    }
    // anchor finishes the live callback
    private final IRequestCallback<LiveFinishResponse> mFinishLiveCallback = new IRequestCallback<LiveFinishResponse>() {
        @Override
        public void onSuccess(LiveFinishResponse data) {
            SolutionEventBus.post(new RequestFinishLiveResultEvent(data));
        }

        @Override
        public void onError(int errorCode, String message) {
            CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
            SolutionEventBus.post(new RequestFinishLiveResultEvent());
        }
    };
}
