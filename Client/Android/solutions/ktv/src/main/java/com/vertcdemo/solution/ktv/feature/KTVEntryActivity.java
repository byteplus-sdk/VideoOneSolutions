// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature;

import static com.vertcdemo.core.net.rts.RTSInfo.KEY_RTS;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentTransaction;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.event.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.joinrtsparams.bean.JoinRTSRequest;
import com.vertcdemo.core.joinrtsparams.common.JoinRTSManager;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.ServerResponse;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.core.utils.AppUtil;
import com.vertcdemo.solution.ktv.common.SolutionToast;
import com.vertcdemo.solution.ktv.core.ErrorCodes;
import com.vertcdemo.ui.dialog.SolutionProgressDialog;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

public class KTVEntryActivity extends AppCompatActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.add(new SolutionProgressDialog(), "dialog_loading");
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
                    onError(-1, "Invalid RTSInfo response.");
                    return;
                }
                Intent intent = new Intent(Intent.ACTION_MAIN);
                intent.setClass(AppUtil.getApplicationContext(), KTVActivity.class);
                intent.putExtra(KEY_RTS, data);
                startActivity(intent);
                finish();
            }

            @Override
            public void onError(int errorCode, String message) {
                if (isFinishing()) {
                    return;
                }
                SolutionToast.show(ErrorCodes.prettyMessage(errorCode, message));
                finish();
            }
        };
        JoinRTSRequest request = new JoinRTSRequest("ktv", SolutionDataManager.ins().getToken());
        JoinRTSManager.requestRTSInfo(request, callback);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onTokenExpiredEvent(AppTokenExpiredEvent event) {
        finish();
    }
}
