// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.app;

import android.app.Dialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.bumptech.glide.Glide;
import com.vertcdemo.login.ILoginImpl;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.eventbus.AppTokenExpiredEvent;
import com.vertcdemo.core.eventbus.RefreshUserNameEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.videoone.avatars.Avatars;
import com.vertcdemo.app.R;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.List;

public class ProfileFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_profile, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        updateUserInfo();

        bindSettingData(view, initSettingData());

        view.findViewById(R.id.profile_exit_login).setOnClickListener(
                (v) -> {
                    Dialog dialog = new Dialog(getContext());
                    dialog.setContentView(R.layout.dialog_account_security);
                    dialog.getWindow().setBackgroundDrawableResource(R.drawable.account_info_bg);
                    ((TextView)dialog.findViewById(R.id.title)).setText(R.string.log_out);
                    ((TextView)dialog.findViewById(R.id.content)).setText(R.string.log_out_alert_message);
                    dialog.findViewById(R.id.cancel).setOnClickListener(view1 -> dialog.cancel());
                    dialog.findViewById(R.id.confirm).setOnClickListener(view12 -> {
                        SolutionDataManager.ins().logout();
                        SolutionEventBus.post(new AppTokenExpiredEvent());
                        dialog.dismiss();
                    });
                    dialog.show();
                });
        SolutionEventBus.register(this);
    }

    private List<SettingInfo> initSettingData() {
        List<SettingInfo> list = new ArrayList<>();
        list.add(new SettingInfo(getString(R.string.language), "English"));
        list.add(new SettingInfo(getString(R.string.privacy_policy), v -> openBrowser(BuildConfig.PRIVACY_POLICY_URL)));
        list.add(new SettingInfo(getString(R.string.terms_of_service), v -> openBrowser(BuildConfig.TERMS_OF_SERVICE_URL)));
        list.add(new SettingInfo(getString(R.string.cancel_account), view -> {
            Dialog dialog = new Dialog(getContext());
            dialog.setContentView(R.layout.dialog_account_security);
            dialog.getWindow().setBackgroundDrawableResource(R.drawable.account_info_bg);
            dialog.findViewById(R.id.cancel).setOnClickListener(view1 -> dialog.cancel());
            dialog.findViewById(R.id.confirm).setOnClickListener(view12 -> {
                new ILoginImpl().closeAccount(null);
                dialog.dismiss();
            });
            dialog.show();
        }));
        list.add(new SettingInfo(getString(R.string.app_version), String.format("v%1$s", BuildConfig.VERSION_NAME)));
        return list;
    }

    private void bindSettingData(View rootView, List<SettingInfo> infoList) {
        if (infoList == null || infoList.isEmpty()) {
            return;
        }
        final LayoutInflater inflater = getLayoutInflater();
        LinearLayout container = rootView.findViewById(R.id.setting_container);
        for (SettingInfo info : infoList) {
            View keyValueView = inflater.inflate(R.layout.layout_common_key_value, container, false);
            View moreIndicator = keyValueView.findViewById(R.id.more);
            TextView keyView = keyValueView.findViewById(R.id.key);
            TextView valueView = keyValueView.findViewById(R.id.value);

            moreIndicator.setVisibility((info.listener != null) ? View.VISIBLE : View.GONE);
            keyView.setText(info.key);
            valueView.setText(info.value);

            keyValueView.setOnClickListener(info.listener);
            container.addView(keyValueView);
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
    }

    private void updateUserInfo() {
        View view = getView();
        if (view == null) return;
        ImageView userAvatar = view.findViewById(R.id.profile_user_avatar);
        Glide.with(userAvatar)
                .load(Avatars.byUserId(SolutionDataManager.ins().getUserId()))
                .circleCrop()
                .into(userAvatar);
        TextView userNameTv = view.findViewById(R.id.profile_user_name);
        userNameTv.setText(SolutionDataManager.ins().getUserName());
    }

    private void openBrowser(String url) {
        startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onRefreshUserNameEvent(RefreshUserNameEvent event) {
        if (event.isSuccess) {
            SolutionDataManager.ins().setUserName(event.userName);
            updateUserInfo();
        }
    }

    private static class SettingInfo {

        public final String key;
        public final String value;
        public final View.OnClickListener listener;

        public SettingInfo(String key, String value) {
            this(key, value, null);
        }

        public SettingInfo(String key, View.OnClickListener listener) {
            this(key, null, listener);
        }

        public SettingInfo(String key, String value, View.OnClickListener listener) {
            this.key = key;
            this.value = value;
            this.listener = listener;
        }
    }
}
