package com.vertc.api.example.entry;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.vertc.api.example.base.RTCTokenManager;
import com.vertc.api.example.base.ui.ApiExampleFragment;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.joinrtsparams.bean.JoinRTSRequest;
import com.vertcdemo.core.joinrtsparams.common.JoinRTSManager;
import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.ServerResponse;
import com.vertcdemo.core.net.rts.RTSInfo;
import com.vertcdemo.ui.CenteredToast;
import com.vertcdemo.ui.dialog.SolutionProgressDialog;

public class APIExampleTabFragment extends ApiExampleFragment {

    private static final String SOLUTION_NAME_ABBR = "rtc_api_example";
    private static final String DIALOG_LOADING = "api_example_dialog_loading";

    public APIExampleTabFragment() {
        super(R.layout.fragment_api_example_tab);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (TextUtils.isEmpty(RTCTokenManager.getInstance().getAppId())) {
            startup(null);
        }
    }

    private void showProgressDialog() {
        DialogFragment dialog = (DialogFragment) getChildFragmentManager().findFragmentByTag(DIALOG_LOADING);
        if (dialog == null) {
            dialog = new SolutionProgressDialog();
        }

        dialog.show(getChildFragmentManager(), DIALOG_LOADING);
    }

    private void dismissProgressDialog() {
        DialogFragment dialog = (DialogFragment) getChildFragmentManager().findFragmentByTag(DIALOG_LOADING);
        if (dialog != null) {
            dialog.dismiss();
        }
    }

    @Override
    protected void openExample(Context context, Class<?> targetClazz) {
        if (TextUtils.isEmpty(RTCTokenManager.getInstance().getAppId())) {
            showProgressDialog();
            startup(() -> super.openExample(context, targetClazz));
        } else {
            super.openExample(context, targetClazz);
        }
    }

    private void startup(@Nullable Runnable next) {
        IRequestCallback<ServerResponse<RTSInfo>> callback = new IRequestCallback<ServerResponse<RTSInfo>>() {
            @Override
            public void onSuccess(ServerResponse<RTSInfo> response) {
                Activity activity = getActivity();
                if (activity == null || activity.isFinishing()) {
                    return;
                }
                dismissProgressDialog();
                RTSInfo data = response == null ? null : response.getData();
                if (data == null || !data.isValid()) {
                    onError(-1, "Invalid RTSInfo response.");
                    return;
                }
                RTCTokenManager.getInstance().setRemoteProvider(
                        new RemoteRTCTokenProvider(data.appId)
                );

                if (next != null) {
                    next.run();
                }
            }

            @Override
            public void onError(int errorCode, String message) {
                Activity activity = getActivity();
                if (activity == null || activity.isFinishing()) {
                    return;
                }
                dismissProgressDialog();
                CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
            }
        };
        JoinRTSRequest request = new JoinRTSRequest(SOLUTION_NAME_ABBR, SolutionDataManager.ins().getToken());
        JoinRTSManager.requestRTSInfo(request, callback);
    }
}
