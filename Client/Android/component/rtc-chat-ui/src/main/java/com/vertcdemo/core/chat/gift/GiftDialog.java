// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.chat.gift;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.core.chat.annotation.GiftType;
import com.vertcdemo.rtc.chat.R;
import com.vertcdemo.rtc.chat.databinding.DialogGiftBinding;
import com.vertcdemo.rtc.chat.databinding.LayoutSendGiftItemBinding;

public class GiftDialog extends BottomSheetDialogFragment {
    public interface IGiftSender {
        void sendGift(@GiftType int giftType);
    }

    @Nullable
    private IGiftSender sender;

    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialog;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Fragment fragment = getParentFragment();
        if (fragment instanceof IGiftSender) {
            sender = (IGiftSender) fragment;
        } else {
            FragmentActivity activity = getActivity();
            if (activity instanceof IGiftSender) {
                sender = (IGiftSender) activity;
            } else {
                throw new IllegalStateException("parent fragment or activity must implement ISendGift");
            }
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_gift, container, false);
    }

    LayoutSendGiftItemBinding mCurrent = null;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        DialogGiftBinding binding = DialogGiftBinding.bind(view);

        binding.like.icon.setImageResource(R.drawable.ic_gift_like);
        binding.like.name.setText(R.string.gift_like);
        binding.like.root.setOnClickListener(v -> {
            if (mCurrent == binding.like) {
                sendGift(GiftType.LIKE);
            } else {
                selectItem(binding.like);
            }
        });
        binding.sugar.icon.setImageResource(R.drawable.ic_gift_suger);
        binding.sugar.name.setText(R.string.gift_sugar);
        binding.sugar.root.setOnClickListener(v -> {
            if (mCurrent == binding.sugar) {
                sendGift(GiftType.SUGAR);
            } else {
                selectItem(binding.sugar);
            }
        });
        binding.diamond.icon.setImageResource(R.drawable.ic_gift_diamond);
        binding.diamond.name.setText(R.string.gift_diamond);
        binding.diamond.root.setOnClickListener(v -> {
            if (mCurrent == binding.diamond) {
                sendGift(GiftType.DIAMOND);
            } else {
                selectItem(binding.diamond);
            }
        });
        binding.fireworks.icon.setImageResource(R.drawable.ic_gift_fireworks);
        binding.fireworks.name.setText(R.string.gift_fireworks);
        binding.fireworks.root.setOnClickListener(v -> {

            if (mCurrent == binding.fireworks) {
                sendGift(GiftType.FIREWORKS);
            } else {
                selectItem(binding.fireworks);
            }
        });

        selectItem(binding.like);
    }

    void selectItem(LayoutSendGiftItemBinding item) {
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

    private void sendGift(@GiftType int giftType) {
        if (sender != null) {
            sender.sendGift(giftType);
        } else {
            Log.w("GiftDialog", "sender is null");
        }
    }
}
