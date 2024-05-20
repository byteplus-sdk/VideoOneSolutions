// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.base;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.CallSuper;
import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.byteplus.playerkit.utils.L;


public class BaseFragment extends Fragment {

    private boolean mUserExiting = false;

    @Override
    @CallSuper
    public void onAttach(@NonNull Context context) {
        L.d(this, "onAttach");
        super.onAttach(context);
    }

    @Override
    @CallSuper
    public void onCreate(@Nullable Bundle savedInstanceState) {
        L.d(this, "onCreate");
        super.onCreate(savedInstanceState);
        mUserExiting = false;
        initBackPressedHandler();
    }

    @Nullable
    @Override
    @CallSuper
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        L.d(this, "onCreateView");
        final int layoutResId = getLayoutResId();
        return layoutResId > 0 ? inflater.inflate(layoutResId, container, false) : null;
    }

    @LayoutRes
    protected int getLayoutResId() {
        return -1;
    }

    @Override
    @CallSuper
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        L.d(this, "onViewCreated");
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    @CallSuper
    public void onStart() {
        L.d(this, "onStart");
        super.onStart();
    }

    @Override
    @CallSuper
    public void onResume() {
        L.d(this, "onResume");
        super.onResume();
    }

    @Override
    @CallSuper
    public void onPause() {
        L.d(this, "onPause");
        super.onPause();
    }

    @Override
    @CallSuper
    public void onStop() {
        L.d(this, "onStop");
        super.onStop();
    }

    @Override
    @CallSuper
    public void onHiddenChanged(boolean hidden) {
        L.d(this, "onHiddenChanged", hidden);
        super.onHiddenChanged(hidden);
    }

    @Override
    @CallSuper
    public void onDestroyView() {
        L.d(this, "onDestroyView");
        super.onDestroyView();
    }

    @Override
    @CallSuper
    public void onDestroy() {
        L.d(this, "onDestroy");
        super.onDestroy();
    }


    @Override
    @CallSuper
    public void onDetach() {
        L.d(this, "onDetach");
        super.onDetach();
    }

    protected void initBackPressedHandler() {
        requireActivity().getOnBackPressedDispatcher()
                .addCallback(this, new OnBackPressedCallback(true) {
                    @Override
                    public void handleOnBackPressed() {
                        L.d(BaseFragment.this, "back try");
                        if (!onBackPressed()) {
                            L.d(BaseFragment.this, "back");
                            setEnabled(false);
                            requireActivity().onBackPressed();
                        } else {
                            setEnabled(true);
                        }
                    }
                });
    }

    public boolean onBackPressed() {
        return false;
    }

    protected void setUserExiting(boolean userExiting) {
        this.mUserExiting = userExiting;
    }

    protected boolean isUserExiting() {
        return mUserExiting;
    }
}
