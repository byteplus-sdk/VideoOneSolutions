// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.core.annotation.InviteReply;
import com.vertcdemo.solution.interactivelive.event.InviteAudienceEvent;
import com.vertcdemo.solution.interactivelive.http.LiveService;
import com.vertcdemo.solution.interactivelive.http.response.LinkResponse;
import com.vertcdemo.ui.CenteredToast;

public class AudienceViewModel extends ViewModel {
    public final MutableLiveData<Integer> requestLinkStatus = new MutableLiveData<>(InviteReply.REJECT);

    private String mLinkerId;

    private LiveRoomInfo mLiveRoomInfo;

    public void setLiveRoomInfo(LiveRoomInfo liveRoomInfo) {
        mLiveRoomInfo = liveRoomInfo;
    }

    public String getRTSRoomId() {
        return mLiveRoomInfo.roomId;
    }

    public void setLinkerId(String linkerId) {
        mLinkerId = linkerId;
    }

    public String getLinkerId() {
        return mLinkerId;
    }

    public void sendApplyAudienceLinkRequest() {
        LiveService.get()
                .applyAudienceLink(getRTSRoomId(), mAudienceLinkResponse);
    }

    public void sendCancelAudienceLinkRequest() {
        LiveService.get()
                .cancelAudienceLink( getLinkerId(),
                        getRTSRoomId(),
                        mAudienceLinkCancelResponse);
    }

    void notifyRequestLinkStatus(@InviteReply int reply) {
        requestLinkStatus.postValue(reply);
        SolutionEventBus.post(new InviteAudienceEvent(SolutionDataManager.ins().getUserId(), reply, getLinkerId()));
    }

    private final Callback<LinkResponse> mAudienceLinkResponse = new Callback<LinkResponse>() {
        @Override
        public void onResponse(LinkResponse data) {
            if (data == null) {
                onFailure(HttpException.unknown("Response data is null"));
                return;
            }
            setLinkerId(data.linkerId);
            CenteredToast.show(R.string.request_sent_waiting);
            notifyRequestLinkStatus(InviteReply.WAITING);
        }

        @Override
        public void onFailure(HttpException e) {
            if (e.getCode() == 622) {
                CenteredToast.show(R.string.request_sent_waiting);
                notifyRequestLinkStatus(InviteReply.WAITING);
            } else {
                CenteredToast.show(ErrorTool.getErrorMessage(e));
                notifyRequestLinkStatus(InviteReply.TIMEOUT);
            }
        }
    };

    private final Callback<Void> mAudienceLinkCancelResponse = new Callback<Void>() {
        @Override
        public void onResponse(Void data) {
            CenteredToast.show(R.string.audience_link_cancel);
            notifyRequestLinkStatus(InviteReply.REJECT);
        }

        @Override
        public void onFailure(HttpException e) {
            if (e.getCode() == 560) { // record not found, treat as 'cancel success'
                onResponse(null);
            } else {
                CenteredToast.show(ErrorTool.getErrorMessage(e));
            }
        }
    };
}
