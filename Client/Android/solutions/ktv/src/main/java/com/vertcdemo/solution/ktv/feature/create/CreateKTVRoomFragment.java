// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.create;

import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_REFERRER;
import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_ROOM_INFO;
import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_RTC_TOKEN;
import static com.vertcdemo.solution.ktv.feature.KTVActivity.EXTRA_USER_INFO;

import android.graphics.Typeface;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.NavOptions;
import androidx.navigation.Navigation;

import com.bumptech.glide.Glide;
import com.vertcdemo.core.SolutionDataManager;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.RoomInfo;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.databinding.FragmentKtvCreateBinding;
import com.vertcdemo.ui.dialog.SolutionProgressDialog;
import com.videoone.avatars.Avatars;

public class CreateKTVRoomFragment extends Fragment {
    public CreateKTVRoomFragment() {
        super(R.layout.fragment_ktv_create);
    }

    private CreateKTVRoomViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(CreateKTVRoomViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        WindowCompat.getInsetsController(requireActivity().getWindow(), view)
                .setAppearanceLightStatusBars(false);

        FragmentKtvCreateBinding binding = FragmentKtvCreateBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            final Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineTop.setGuidelineBegin(insets.top);
            binding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        binding.close.setOnClickListener(v -> {
            Navigation.findNavController(v).popBackStack();
        });


        SolutionDataManager dataManager = SolutionDataManager.ins();
        Glide.with(binding.userAvatar)
                .load(Avatars.byUserId(dataManager.getUserId()))
                .into(binding.userAvatar);

        binding.roomName.setText(getString(R.string.label_create_name_xxx, dataManager.getUserName()));

        String hint = getString(R.string.application_experiencing_xxx_title, "20");
        binding.timeTips.setText(hint);

        binding.bg0.setOnClickListener(v -> mViewModel.bgIndex.setValue(0));
        binding.bg1.setOnClickListener(v -> mViewModel.bgIndex.setValue(1));
        binding.bg2.setOnClickListener(v -> mViewModel.bgIndex.setValue(2));

        binding.start.setOnClickListener(v -> {
            SolutionProgressDialog dialog = new SolutionProgressDialog();
            dialog.show(getChildFragmentManager(), "create-progress");

            String roomName = getString(R.string.label_create_name_xxx, dataManager.getUserName());

            final String backgroundImageName;
            final Integer bgIndex = mViewModel.bgIndex.getValue();
            assert bgIndex != null;
            switch (bgIndex) {
                case 1:
                    backgroundImageName = "KTV_background_1";
                    break;
                case 2:
                    backgroundImageName = "KTV_background_2";
                    break;
                default:
                    backgroundImageName = "KTV_background_0";
            }
            mViewModel.requestStartKTVRoom(roomName, backgroundImageName);
        });

        mViewModel.bgIndex.observe(getViewLifecycleOwner(), bgIndex -> {
            Typeface normal = Typeface.defaultFromStyle(Typeface.NORMAL);
            Typeface bold = Typeface.defaultFromStyle(Typeface.BOLD);

            binding.bg0.setSelected(bgIndex == 0);
            binding.bg0.setTypeface(bgIndex == 0 ? bold : normal);

            binding.bg1.setSelected(bgIndex == 1);
            binding.bg1.setTypeface(bgIndex == 1 ? bold : normal);

            binding.bg2.setSelected(bgIndex == 2);
            binding.bg2.setTypeface(bgIndex == 2 ? bold : normal);


            if (bgIndex == 1) {
                binding.getRoot().setBackgroundResource(R.mipmap.ktv_background_1);
            } else if (bgIndex == 2) {
                binding.getRoot().setBackgroundResource(R.mipmap.ktv_background_2);
            } else {
                binding.getRoot().setBackgroundResource(R.mipmap.ktv_background_0);
            }
        });

        mViewModel.response.observe(getViewLifecycleOwner(), response -> {
            if (response == null) {
                return;
            }

            RoomInfo roomInfo = response.roomInfo;
            UserInfo userInfo = response.userInfo;
            String rtcToken = response.rtcToken;

            Bundle args = new Bundle();
            args.putParcelable(EXTRA_ROOM_INFO, roomInfo);
            args.putParcelable(EXTRA_USER_INFO, userInfo);
            args.putString(EXTRA_RTC_TOKEN, rtcToken);
            args.putString(EXTRA_REFERRER, "create");

            NavOptions navOptions = new NavOptions.Builder()
                    .setPopUpTo(R.id.ktv_room_list, false)
                    .build();
            Navigation.findNavController(view).navigate(R.id.action_ktv_room, args, navOptions);
        });
    }
}
