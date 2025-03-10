// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.list;

import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_PUSH_URL;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_ROOM_INFO;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_RTC_ROOM_ID;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_RTC_TOKEN;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_RTS_TOKEN;
import static com.vertcdemo.solution.interactivelive.feature.InteractiveLiveActivity.EXTRA_USER_INFO;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;

import com.bumptech.glide.Glide;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.core.http.bean.RTCAppInfo;
import com.vertcdemo.core.utils.DebounceClickListener;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.databinding.FragmentLiveCreateRoomBinding;
import com.vertcdemo.solution.interactivelive.effect.InteractiveLiveEffectFragment;
import com.vertcdemo.solution.interactivelive.feature.main.settings.LiveSettingDialog;
import com.vertcdemo.solution.interactivelive.http.response.CreateRoomResponse;
import com.vertcdemo.solution.interactivelive.util.RTCEngineViewModel;
import com.vertcdemo.ui.CenteredToast;
import com.videoone.avatars.Avatars;

public class CreateLiveRoomFragment extends Fragment {
    private boolean mRequestStartLive = false;
    private boolean mKeepVideoCapture = false;

    CreateLiveRoomViewModel mViewModel;

    private static final int MSG_COUNT_DOWN = 2;

    @SuppressLint("HandlerLeak")
    private final Handler mHandler = new Handler() {
        @Override
        public void handleMessage(@NonNull Message msg) {
            if (msg.what == MSG_COUNT_DOWN) {
                mViewModel.countDown.postValue(msg.arg1);
                if (msg.arg1 == 0) {
                    requestStartLive();
                    return;
                }
                final Message next = mHandler.obtainMessage(MSG_COUNT_DOWN);
                next.arg1 = msg.arg1 - 1;
                sendMessageDelayed(next, 1000);
            }
        }
    };

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        RTCEngineViewModel.inject(this,
                R.id.room_host,
                RTCAppInfo.require(requireActivity()));

        mViewModel = new ViewModelProvider(this).get(CreateLiveRoomViewModel.class);
        getLifecycle().addObserver(new DefaultLifecycleObserver() {
            @Override
            public void onResume(@NonNull LifecycleOwner owner) {
                WindowCompat.getInsetsController(requireActivity().getWindow(), requireView())
                        .setAppearanceLightStatusBars(false);
            }
        });
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_live_create_room, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        LiveRTCManager.ins().switchToHostConfig();
        LiveRTCManager.ins().startCaptureVideo(true);

        FragmentLiveCreateRoomBinding binding = FragmentLiveCreateRoomBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            binding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        binding.back.setOnClickListener(v -> Navigation.findNavController(v).popBackStack());

        Glide.with(binding.userAvatar)
                .load(Avatars.byUserId(SolutionDataManager.ins().getUserId()))
                .into(binding.userAvatar);

        binding.title.setText(getString(R.string.live_show_suffix, SolutionDataManager.ins().getUserName()));

        String hint = getString(R.string.application_experiencing_xxx_title, "20");
        binding.timeTips.setText(hint);

        binding.flip.setOnClickListener(v -> {
            v.setSelected(!v.isSelected());
            LiveRTCManager.ins().switchCamera();
        });

        binding.beauty.setOnClickListener(v -> openEffectDialog());

        binding.settings.setOnClickListener(v -> {
            LiveSettingDialog settingDialog = new LiveSettingDialog();
            settingDialog.show(getChildFragmentManager(), "settings_dialog");
        });

        binding.startLive.setOnClickListener(DebounceClickListener.create(v -> {
            binding.groupContent.setVisibility(View.GONE);
            final Message next = mHandler.obtainMessage(MSG_COUNT_DOWN);
            next.arg1 = 3;
            mHandler.sendMessage(next);
        }));

        LiveRTCManager.ins().setLocalVideoView(binding.texture);

        mViewModel.status.observe(getViewLifecycleOwner(), status -> {
            switch (status) {
                case CreateLiveRoomViewModel.STATUS_NONE:
                    mViewModel.requestCreateLiveRoom();
                    break;

                case CreateLiveRoomViewModel.STATUS_CREATING:
                case CreateLiveRoomViewModel.STATUS_STARTING:
                    binding.loading.setVisibility(View.VISIBLE);
                    break;

                case CreateLiveRoomViewModel.STATUS_CREATED:
                    binding.loading.setVisibility(View.GONE);
                    if (mRequestStartLive) {
                        mViewModel.requestStartLive();
                    }
                    break;

                case CreateLiveRoomViewModel.STATUS_STARTED:
                    CenteredToast.show(R.string.start_live_title);
                    jumpToHostView();
                    break;

                case CreateLiveRoomViewModel.STATUS_CREATE_FAILED:
                case CreateLiveRoomViewModel.STATUS_START_FAILED:
                    binding.loading.setVisibility(View.GONE);
                    break;
            }
        });

        mViewModel.countDown.observe(getViewLifecycleOwner(), countDown -> {
            if (countDown > 0) {
                binding.countDown.setVisibility(View.VISIBLE);
                binding.countDown.setText(String.valueOf(countDown));
            } else {
                binding.countDown.setVisibility(View.GONE);
                binding.countDown.setText("0");
            }
        });
    }

    // region Effect
    void openEffectDialog() {
        FragmentManager fragmentManager = getChildFragmentManager();
        Fragment fragment = fragmentManager.findFragmentByTag("effect-dialog");
        if (fragment != null) {
            return;
        }

        DialogFragment dialog = new InteractiveLiveEffectFragment();
        dialog.showNow(fragmentManager, "effect-dialog");
    }

    // endregion Effect

    void requestStartLive() {
        mRequestStartLive = true;
        if (mViewModel.createResult != null) {
            mViewModel.requestStartLive();
        } else {
            mViewModel.requestCreateLiveRoom();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (!mKeepVideoCapture) {
            LiveRTCManager.ins().startCaptureVideo(false);
        }
    }

    void jumpToHostView() {
        mKeepVideoCapture = true;
        final CreateRoomResponse response = mViewModel.createResult;
        Bundle args = new Bundle();
        args.putSerializable(EXTRA_ROOM_INFO, response.liveRoomInfo);
        args.putSerializable(EXTRA_USER_INFO, response.userInfo);
        args.putString(EXTRA_PUSH_URL, response.streamPushUrl);
        args.putString(EXTRA_RTS_TOKEN, response.rtsToken);
        args.putString(EXTRA_RTC_TOKEN, response.rtcToken);
        args.putString(EXTRA_RTC_ROOM_ID, response.rtcRoomId);
        Navigation.findNavController(requireView()).navigate(R.id.host_view, args);
    }
}
