// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.audience;

import static com.vertcdemo.solution.ktv.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.graphics.Typeface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.bean.UserInfo;
import com.vertcdemo.solution.ktv.core.rts.annotation.UserStatus;
import com.vertcdemo.solution.ktv.databinding.DialogKtvManageAudiencesBinding;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.KTVRoomViewModel;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.TabViewModel;

import java.util.List;
import java.util.Objects;

public class ManageAudiencesDialog extends BottomSheetDialogFragment {
    private static final String TAG = "ManageAudiencesDialog";

    @Override
    public int getTheme() {
        return R.style.KTVBottomSheetDialog;
    }

    public static final int SEAT_ID_BY_SERVER = -1;

    private String mRoomId;
    private int mSeatId;

    private final OnOptionSelected mUserInfoOption = new OnOptionSelected() {
        @Override
        public void onOption(int option, UserInfo userInfo) {
            int status = userInfo.userStatus;

            if (status == UserStatus.NORMAL) {
                mRoomViewModel.inviteInteract(mRoomId, userInfo.userId, mSeatId);
            } else if (status == UserStatus.APPLYING) {
                mRoomViewModel.replyApply(mRoomId, userInfo.userId, option == OnOptionSelected.ACTION_OK);
            }
        }
    };


    private KTVRoomViewModel mRoomViewModel;

    private TabViewModel mViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mRoomViewModel = navGraphViewModelProvider(this, R.id.ktv_room_graph).get(KTVRoomViewModel.class);
        mViewModel = new ViewModelProvider(this).get(TabViewModel.class);

        mRoomId = mRoomViewModel.requireRoomId();

        mSeatId = -1;

        List<UserInfo> applies = mRoomViewModel.appliedAudiences.getValue();
        if (applies != null && !applies.isEmpty()) {
            mViewModel.index.setValue(1);
        }

        Bundle arguments = getArguments();
        if (arguments != null) {
            mSeatId = arguments.getInt("seat_id", SEAT_ID_BY_SERVER);
        } else {
            mSeatId = SEAT_ID_BY_SERVER;
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_ktv_manage_audiences, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        ((BottomSheetDialog) Objects.requireNonNull(getDialog())).getBehavior().setDraggable(false);

        DialogKtvManageAudiencesBinding binding = DialogKtvManageAudiencesBinding.bind(view);

        binding.tab0.setOnClickListener(v -> mViewModel.index.postValue(0));
        binding.tab1.setOnClickListener(v -> mViewModel.index.postValue(1));


        binding.recycler0.setLayoutManager(new LinearLayoutManager(getContext()));
        ManageAudienceAdapter onlineAudienceAdapter = new ManageAudienceAdapter(mUserInfoOption);
        binding.recycler0.setAdapter(onlineAudienceAdapter);

        binding.recycler1.setLayoutManager(new LinearLayoutManager(getContext()));
        ManageAudienceAdapter applyAudienceAdapter = new ManageAudienceAdapter(mUserInfoOption, true);
        binding.recycler1.setAdapter(applyAudienceAdapter);

        mViewModel.index.observe(getViewLifecycleOwner(), tabIndex -> {
            if (tabIndex == 1) {
                binding.tab0.setSelected(false);
                binding.tab0.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                binding.group0.setVisibility(View.GONE);

                binding.tab1.setSelected(true);
                binding.tab1.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                binding.group1.setVisibility(View.VISIBLE);

                if (applyAudienceAdapter.getItemCount() == 0) {
                    binding.emptyView.setText(R.string.label_raise_hand_list_empty);
                    binding.emptyView.setVisibility(View.VISIBLE);
                } else {
                    binding.emptyView.setVisibility(View.GONE);
                }
            } else {
                binding.tab0.setSelected(true);
                binding.tab0.setTypeface(Typeface.defaultFromStyle(Typeface.BOLD));
                binding.group0.setVisibility(View.VISIBLE);

                binding.tab1.setSelected(false);
                binding.tab1.setTypeface(Typeface.defaultFromStyle(Typeface.NORMAL));
                binding.group1.setVisibility(View.GONE);

                if (onlineAudienceAdapter.getItemCount() == 0) {
                    binding.emptyView.setText(R.string.label_user_list_empty);
                    binding.emptyView.setVisibility(View.VISIBLE);
                } else {
                    binding.emptyView.setVisibility(View.GONE);
                }
            }
        });


        binding.needApply.setOnClickListener(v -> {
            boolean newValue = !v.isSelected();
            mRoomViewModel.updateNeedApply(mRoomId, newValue);
        });

        mRoomViewModel.needApply.observe(getViewLifecycleOwner(), allowApply -> {
            binding.needApply.setSelected(allowApply == Boolean.TRUE);
        });

        mRoomViewModel.onlineAudiences.observe(getViewLifecycleOwner(), users -> {
            assert users != null;
            Integer tabIndex = mViewModel.index.getValue();
            assert tabIndex != null;
            if (tabIndex == 0) {
                binding.emptyView.setText(R.string.label_user_list_empty);
                binding.emptyView.setVisibility(users.isEmpty() ? View.VISIBLE : View.GONE);
            }

            onlineAudienceAdapter.setList(users);
        });

        mRoomViewModel.appliedAudiences.observe(getViewLifecycleOwner(), users -> {
            assert users != null;
            binding.hasAppliesIndicator.setVisibility(users.isEmpty() ? View.GONE : View.VISIBLE);
            Integer tabIndex = mViewModel.index.getValue();
            assert tabIndex != null;
            if (tabIndex == 1) {
                binding.emptyView.setText(R.string.label_raise_hand_list_empty);
                binding.emptyView.setVisibility(users.isEmpty() ? View.VISIBLE : View.GONE);
            }

            applyAudienceAdapter.setList(users);
        });
    }
}
