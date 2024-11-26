// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.cohost;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.MutableLiveData;

import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.callback.OnResponse;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.http.LiveService;
import com.vertcdemo.solution.interactivelive.http.response.GetAnchorListResponse;
import com.vertcdemo.solution.interactivelive.http.response.LinkResponse;
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
        LiveService.get().getAnchorList(OnResponse.of(data -> {
            users.postValue(GetAnchorListResponse.anchors(data));
        }));
    }

    public void inviteHostByHost(LiveUserInfo info) {
        LiveService.get().inviteAnchorLink(roomInfo.roomId, roomInfo.anchorUserId,
                info.roomId,
                info.userId, "", new Callback<LinkResponse>() {
                    @Override
                    public void onResponse(LinkResponse response) {
                        CenteredToast.show(R.string.anchor_pk_invitation_sent);
                    }

                    @Override
                    public void onFailure(HttpException e) {
                        if (e.getCode() == 622) {
                            CenteredToast.show(R.string.anchor_pk_invitation_sent);
                        } else {
                            CenteredToast.show(ErrorTool.getErrorMessage(e));
                        }
                    }
                });
    }
}
