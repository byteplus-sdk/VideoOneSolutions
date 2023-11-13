// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.login;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.entity.LoginInfo;
import com.vertcdemo.core.eventbus.RefreshUserNameEvent;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.net.ServerResponse;
import com.vertcdemo.core.utils.Activities;
import com.vertcdemo.core.utils.IMEUtils;
import com.vertcdemo.core.utils.TextWatcherAdapter;
import com.vertcdemo.login.databinding.ActivityLoginBinding;
import com.vertcdemo.login.net.LoginApi;
import com.vertcdemo.login.utils.LengthFilterWithCallback;

import java.util.regex.Pattern;

public class LoginActivity extends AppCompatActivity {

    public static final String INPUT_REGEX = "^[\\u4e00-\\u9fa5a-zA-Z0-9@_-]+$";

    private ActivityLoginBinding mViewBinding;

    private final TextWatcherAdapter mTextWatcher = new TextWatcherAdapter() {
        @Override
        public void afterTextChanged(Editable s) {
            setupConfirmStatus();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Activities.transparentStatusBar(this);

        mViewBinding = ActivityLoginBinding.inflate(getLayoutInflater());
        setContentView(mViewBinding.getRoot());

        mViewBinding.verifyConfirm.setOnClickListener(v -> onClickConfirm());
        mViewBinding.verifyRootLayout.setOnClickListener(IMEUtils::closeIME);
        mViewBinding.verifyPolicyText.setOnClickListener(v -> mViewBinding.verifyCb.toggle());
        mViewBinding.verifyPolicyText.setText(getSpannedText());
        mViewBinding.verifyPolicyText.setMovementMethod(LinkMovementMethod.getInstance());

        InputFilter userNameFilter = new LengthFilterWithCallback(18, (overflow) -> {
            if (overflow) {
                mViewBinding.verifyInputUserNameWaringTv.setVisibility(View.VISIBLE);
                mViewBinding.verifyInputUserNameWaringTv.setText(getString(R.string.content_limit, "18"));
            } else {
                mViewBinding.verifyInputUserNameWaringTv.setVisibility(View.GONE);
            }
        });
        InputFilter[] userNameFilters = new InputFilter[]{userNameFilter};
        mViewBinding.verifyInputUserNameEt.setFilters(userNameFilters);

        mViewBinding.verifyInputUserNameEt.addTextChangedListener(mTextWatcher);

        mViewBinding.verifyCb.setOnCheckedChangeListener((v, isChecked) -> setupConfirmStatus());
        setupConfirmStatus();
    }

    private CharSequence getSpannedText() {
        String termsOfService = getString(R.string.login_terms_of_service);
        String privacyPolicy = getString(R.string.login_privacy_policy);
        String completeTip = getString(R.string.read_and_agree, termsOfService, privacyPolicy);

        SpannableStringBuilder ssb = new SpannableStringBuilder(completeTip);

        int termsIndex = completeTip.indexOf(termsOfService);
        if (termsIndex >= 0) {
            ssb.setSpan(new ClickableSpan() {
                @Override
                public void onClick(@NonNull View widget) {
                    openBrowser(BuildConfig.TERMS_OF_SERVICE_URL);
                }

                @Override
                public void updateDrawState(@NonNull TextPaint ds) {
                    ds.setColor(Color.parseColor("#4080FF"));
                    ds.setUnderlineText(false);
                }
            }, termsIndex, termsIndex + termsOfService.length(), Spannable.SPAN_INCLUSIVE_INCLUSIVE);
        }

        int policyIndex = completeTip.indexOf(privacyPolicy);
        if (policyIndex >= 0) {
            ssb.setSpan(new ClickableSpan() {
                @Override
                public void onClick(@NonNull View widget) {
                    openBrowser(BuildConfig.PRIVACY_POLICY_URL);
                }

                @Override
                public void updateDrawState(@NonNull TextPaint ds) {
                    ds.setColor(Color.parseColor("#4080FF"));
                    ds.setUnderlineText(false);
                }
            }, policyIndex, policyIndex + privacyPolicy.length(), Spannable.SPAN_INCLUSIVE_INCLUSIVE);
        }

        return ssb;
    }

    private void setupConfirmStatus() {
        String userName = mViewBinding.verifyInputUserNameEt.getText().toString().trim();

        if (TextUtils.isEmpty(userName)) {
            mViewBinding.verifyConfirm.setAlpha(0.3F);
            mViewBinding.verifyConfirm.setEnabled(false);
        } else {
            boolean matchRegex = Pattern.matches(INPUT_REGEX, userName);
            boolean isPolicyChecked = mViewBinding.verifyCb.isChecked();
            if (isPolicyChecked && matchRegex) {
                mViewBinding.verifyConfirm.setEnabled(true);
                mViewBinding.verifyConfirm.setAlpha(1F);
            } else {
                if (!matchRegex) {
                    mViewBinding.verifyInputUserNameWaringTv.setVisibility(View.VISIBLE);
                    mViewBinding.verifyInputUserNameWaringTv.setText(getString(R.string.content_limit, "18"));
                }
                mViewBinding.verifyConfirm.setAlpha(0.3F);
                mViewBinding.verifyConfirm.setEnabled(false);
            }
        }
    }

    private void onClickConfirm() {
        String userName = mViewBinding.verifyInputUserNameEt.getText().toString().trim();
        mViewBinding.verifyConfirm.setEnabled(false);
        IMEUtils.closeIME(mViewBinding.verifyConfirm);
        LoginApi.passwordFreeLogin(userName, new IRequestCallback<ServerResponse<LoginInfo>>() {
            @Override
            public void onSuccess(ServerResponse<LoginInfo> data) {
                LoginInfo login = data.getData();
                if (login == null) {
                    Toast.makeText(LoginActivity.this, com.vertcdemo.base.R.string.network_message_1011, Toast.LENGTH_SHORT).show();
                    return;
                }

                mViewBinding.verifyConfirm.setEnabled(true);
                SolutionDataManager.ins().setUserName(login.userName);
                SolutionDataManager.ins().setUserId(login.userId);
                SolutionDataManager.ins().setToken(login.loginToken);
                SolutionEventBus.post(new RefreshUserNameEvent(login.userName, true));
                setResult(RESULT_OK);
                LoginActivity.this.finish();
            }

            @Override
            public void onError(int errorCode, String message) {
                Toast.makeText(LoginActivity.this, com.vertcdemo.base.R.string.network_message_1011, Toast.LENGTH_SHORT).show();
                mViewBinding.verifyConfirm.setEnabled(true);
            }
        });
    }

    private void openBrowser(String url) {
        Intent i = new Intent(Intent.ACTION_VIEW);
        i.setData(Uri.parse(url));
        startActivity(i);
    }
}
