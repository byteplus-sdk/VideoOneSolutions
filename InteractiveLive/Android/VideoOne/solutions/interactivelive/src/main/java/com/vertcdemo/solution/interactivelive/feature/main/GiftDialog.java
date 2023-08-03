// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertcdemo.core.net.ErrorTool;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.feature.bottomsheet.BottomDialogFragmentX;
import com.vertcdemo.solution.interactivelive.bean.LiveResponse;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.databinding.DialogGiftLayoutBinding;
import com.vertcdemo.solution.interactivelive.databinding.LayoutGiftItemBinding;
import com.vertcdemo.solution.interactivelive.util.CenteredToast;

public class GiftDialog extends BottomDialogFragmentX {
    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialogTheme;
    }

    private String mRoomId;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Bundle arguments = requireArguments();
        mRoomId = arguments.getString("rtsRoomId");
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_gift_layout, container, false);
    }

    LayoutGiftItemBinding mCurrent = null;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        DialogGiftLayoutBinding binding = DialogGiftLayoutBinding.bind(view);

        binding.like.icon.setImageResource(R.drawable.ic_gift_like);
        binding.like.name.setText(R.string.gift_like);
        binding.like.root.setOnClickListener(v -> {
            if (mCurrent == binding.like) {
                sendGift(MessageBody.GIFT_LIKE);
            } else {
                selectItem(binding.like);
            }
        });
        binding.sugar.icon.setImageResource(R.drawable.ic_gift_suger);
        binding.sugar.name.setText(R.string.gift_sugar);
        binding.sugar.root.setOnClickListener(v -> {
            if (mCurrent == binding.sugar) {
                sendGift(MessageBody.GIFT_SUGAR);
            } else {
                selectItem(binding.sugar);
            }
        });
        binding.diamond.icon.setImageResource(R.drawable.ic_gift_diamond);
        binding.diamond.name.setText(R.string.gift_diamond);
        binding.diamond.root.setOnClickListener(v -> {
            if (mCurrent == binding.diamond) {
                sendGift(MessageBody.GIFT_DIAMOND);
            } else {
                selectItem(binding.diamond);
            }
        });
        binding.fireworks.icon.setImageResource(R.drawable.ic_gift_fireworks);
        binding.fireworks.name.setText(R.string.gift_fireworks);
        binding.fireworks.root.setOnClickListener(v -> {

            if (mCurrent == binding.fireworks) {
                sendGift(MessageBody.GIFT_FIREWORKS);
            } else {
                selectItem(binding.fireworks);
            }
        });

        selectItem(binding.like);
    }

    void selectItem(LayoutGiftItemBinding item) {
        if (mCurrent != null) {
            mCurrent.root.setSelected(false);
            mCurrent.name.setVisibility(View.VISIBLE);
            mCurrent.send.setVisibility(View.INVISIBLE);
        }

        item.root.setSelected(true);
        item.name.setVisibility(View.INVISIBLE);
        item.send.setVisibility(View.VISIBLE);

        mCurrent = item;
    }

    private void sendGift(MessageBody body) {
        LiveRTCManager.ins().getRTSClient().sendMessage(mRoomId, body, sCallback);
    }

    private static final IRequestCallback<LiveResponse> sCallback = new IRequestCallback<LiveResponse>() {
        @Override
        public void onSuccess(LiveResponse data) {

        }

        @Override
        public void onError(int errorCode, String message) {
            CenteredToast.show(ErrorTool.getErrorMessageByErrorCode(errorCode, message));
        }
    };
}
