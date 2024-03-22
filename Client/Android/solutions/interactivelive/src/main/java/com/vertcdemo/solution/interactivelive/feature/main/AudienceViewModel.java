// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveInviteResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.core.annotation.InviteReply;
import com.vertcdemo.solution.interactivelive.event.InviteAudienceEvent;
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
        LiveRTCManager.rts().requestLinkByAudience(getRTSRoomId(), mAudienceLinkResponse);
    }

    public void sendCancelAudienceLinkRequest() {
        LiveRTCManager.rts().requestCancelApplyLinkByAudience(
                getLinkerId(),
                getRTSRoomId(),
                mAudienceLinkCancelResponse);
    }

    void notifyRequestLinkStatus(@InviteReply int reply) {
        requestLinkStatus.postValue(reply);
        SolutionEventBus.post(new InviteAudienceEvent(SolutionDataManager.ins().getUserId(), reply, getLinkerId()));
    }

    private final IRequestCallback<LiveInviteResponse> mAudienceLinkResponse = new IRequestCallback<LiveInviteResponse>() {
        @Override
        public void onSuccess(LiveInviteResponse data) {
            setLinkerId(data.linkerId);
            CenteredToast.show(R.string.request_sent_waiting);
            notifyRequestLinkStatus(InviteReply.WAITING);
        }

        @Override
        public void onError(int errorCode, String message) {
            if (errorCode == 622) {
                CenteredToast.show(R.string.request_sent_waiting);
                notifyRequestLinkStatus(InviteReply.WAITING);
            } else {
                CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
                notifyRequestLinkStatus(InviteReply.TIMEOUT);
            }
        }
    };

    private final IRequestCallback<Void> mAudienceLinkCancelResponse = new IRequestCallback<Void>() {
        @Override
        public void onSuccess(Void data) {
            CenteredToast.show(R.string.audience_link_cancel);
            notifyRequestLinkStatus(InviteReply.REJECT);
        }

        @Override
        public void onError(int errorCode, String message) {
            if (errorCode == 560) { // record not found, treat as 'cancel success'
                onSuccess(null);
            } else {
                CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
            }
        }
    };
}
