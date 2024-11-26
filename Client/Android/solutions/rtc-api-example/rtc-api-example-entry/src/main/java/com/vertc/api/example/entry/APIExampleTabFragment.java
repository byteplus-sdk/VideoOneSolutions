package com.vertc.api.example.entry;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.vertc.api.example.base.RTCTokenManager;
import com.vertc.api.example.base.ui.ApiExampleFragment;
import com.vertcdemo.core.http.AppInfoManager;
import com.vertcdemo.core.http.Callback;
import com.vertcdemo.core.http.bean.RTCAppInfo;
import com.vertcdemo.core.net.HttpException;
import com.vertcdemo.core.utils.ErrorTool;
import com.vertcdemo.ui.CenteredToast;
import com.vertcdemo.ui.dialog.SolutionProgressDialog;

import java.util.Objects;

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
        Callback<RTCAppInfo> callback = new Callback<RTCAppInfo>() {
            @Override
            public void onResponse(RTCAppInfo data) {
                Activity activity = getActivity();
                if (activity == null || activity.isFinishing()) {
                    return;
                }
                dismissProgressDialog();
                if (data == null || data.isInvalid()) {
                    onFailure(HttpException.unknown("Invalid RTCAppInfo response."));
                    return;
                }
                RTCTokenManager.getInstance().setRemoteProvider(
                        new RemoteRTCTokenProvider(Objects.requireNonNull(data.appId), data.bid)
                );

                if (next != null) {
                    next.run();
                }
            }

            @Override
            public void onFailure(HttpException e) {
                Activity activity = getActivity();
                if (activity == null || activity.isFinishing()) {
                    return;
                }
                dismissProgressDialog();
                CenteredToast.show(ErrorTool.getErrorMessage(e));
            }
        };

        AppInfoManager.requestInfo(SOLUTION_NAME_ABBR, callback);
    }
}
