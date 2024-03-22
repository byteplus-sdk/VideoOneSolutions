// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.cohost;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.MutableLiveData;

import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveInviteResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.ui.CenteredToast;

import java.util.Collections;
import java.util.List;

public class InviteHostViewModel extends AndroidViewModel {

    LiveRoomInfo roomInfo;

    MutableLiveData<List<LiveUserInfo>> users = new MutableLiveData<>(Collections.emptyList());

    public InviteHostViewModel(@NonNull Application application) {
        super(application);
    }

    public void requestActiveHostList() {
        LiveRTCManager.ins().getRTSClient().requestActiveHostList(data -> {
            final List<LiveUserInfo> list = data.anchorList;
            users.postValue(list == null ? Collections.emptyList() : list);
        });
    }

    public void inviteHostByHost(LiveUserInfo info) {
        final Application context = getApplication();
        final IRequestCallback<LiveInviteResponse> callback = new IRequestCallback<LiveInviteResponse>() {
            @Override
            public void onSuccess(LiveInviteResponse data) {
                CenteredToast.show(R.string.anchor_pk_invitation_sent);
            }

            @Override
            public void onError(int errorCode, String message) {
                if (errorCode == 622) {
                    CenteredToast.show(R.string.anchor_pk_invitation_sent);
                } else {
                    CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
                }
            }
        };
        LiveRTCManager.rts().inviteHostByHost(roomInfo.roomId, roomInfo.anchorUserId,
                info.roomId,
                info.userId, "", callback);
    }
}
