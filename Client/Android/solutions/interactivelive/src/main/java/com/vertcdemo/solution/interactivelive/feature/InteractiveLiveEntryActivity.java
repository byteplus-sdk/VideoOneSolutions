// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature;

import static com.vertcdemo.core.net.rts.RTSInfo.KEY_RTS;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentTransaction;

import com.vertcdemo.core.joinrtsparams.bean.JoinRTSRequest;
import com.vertcdemo.core.joinrtsparams.common.JoinRTSManager;
import com.vertcdemo.core.common.ProgressDialogFragment;
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.ServerResponse;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveJoinRTSRequest;
import com.vertcdemo.solution.interactivelive.util.CenteredToast;
import com.vertcdemo.core.utils.AppUtil;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class InteractiveLiveEntryActivity extends AppCompatActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.add(new ProgressDialogFragment(), "dialog_loading");
        ft.commit();

        SolutionEventBus.register(this);
        startup();
    }

    @Override
    protected void onDestroy() {
        SolutionEventBus.unregister(this);
        super.onDestroy();
    }

    private void startup() {
        IRequestCallback<ServerResponse<RTSInfo>> callback = new IRequestCallback<ServerResponse<RTSInfo>>() {
            @Override
            public void onSuccess(ServerResponse<RTSInfo> response) {
                if (isFinishing()) {
                    return;
                }
                RTSInfo data = response == null ? null : response.getData();
                if (data == null || !data.isValid()) {
                    onError(-1, "RTSInfo response not valid.");
                    return;
                }
                Intent intent = new Intent(Intent.ACTION_MAIN);
                intent.setClass(AppUtil.getApplicationContext(), InteractiveLiveActivity.class);
                intent.putExtra(KEY_RTS, data);
                startActivity(intent);
                finish();
            }

            @Override
            public void onError(int errorCode, String message) {
                if (isFinishing()) {
                    return;
                }
                CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
                finish();
            }
        };
        JoinRTSRequest request = new LiveJoinRTSRequest();
        JoinRTSManager.requestRTSInfo(request, callback);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        finish();
    }
}
