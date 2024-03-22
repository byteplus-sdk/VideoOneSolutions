// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.ktv.feature.main.audience;

import static com.vertcdemo.solution.ktv.utils.ViewModelProviderHelper.navGraphViewModelProvider;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.DialogFragment;

import com.vertcdemo.base.databinding.DialogSolutionCommonBinding;
import com.vertcdemo.solution.ktv.R;
import com.vertcdemo.solution.ktv.common.SolutionToast;
import com.vertcdemo.solution.ktv.core.rts.annotation.ReplyType;
import com.vertcdemo.solution.ktv.feature.main.viewmodel.KTVRoomViewModel;

public class ConfirmInviteDialog extends DialogFragment {
    private static final String TAG = "ConfirmInviteDialog";

    @Override
    public int getTheme() {
        return R.style.SolutionCommonDialogTheme;
    }

    private KTVRoomViewModel mRoomViewModel;

    public ConfirmInviteDialog() {
        super(com.vertcdemo.base.R.layout.dialog_solution_common);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mRoomViewModel = navGraphViewModelProvider(this, R.id.ktv_room_graph).get(KTVRoomViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        DialogSolutionCommonBinding binding = DialogSolutionCommonBinding.bind(view);
        binding.title.setVisibility(View.GONE);
        binding.message.setText(R.string.toast_receive_invite_guest);

        binding.button1.setText(R.string.button_alert_accept);
        binding.button1.setOnClickListener(v -> {
            if (ContextCompat.checkSelfPermission(requireContext(), Manifest.permission.RECORD_AUDIO)
                    == PackageManager.PERMISSION_GRANTED) {
                replyInvite(ReplyType.ACCEPT);
            } else {
                launcher.launch(Manifest.permission.RECORD_AUDIO);
            }
        });

        binding.button2.setText(R.string.button_alert_reject);
        binding.button2.setOnClickListener(v -> replyInvite(ReplyType.REJECT));
    }

    void replyInvite(@ReplyType int reply) {
        Bundle arguments = requireArguments();
        int seatId = arguments.getInt("seat_id", -1);
        assert seatId >= 1 : "SeatId must be set >=1";

        mRoomViewModel.replyInvite(mRoomViewModel.requireRoomId(), seatId, reply);
        dismiss();
    }

    final ActivityResultLauncher<String> launcher = registerForActivityResult(new ActivityResultContracts.RequestPermission(), result -> {
        if (result != Boolean.TRUE) {
            Log.d(TAG, "No permission: " + Manifest.permission.RECORD_AUDIO);
            SolutionToast.show(R.string.toast_ktv_no_mic_permission);
        }
        replyInvite(ReplyType.ACCEPT);
    });
}
