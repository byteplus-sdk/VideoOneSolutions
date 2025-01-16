// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.detail.pay;

import static com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract.EXTRA_DRAMA_ITEM;

import android.app.Dialog;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Paint;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatDialog;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.ViewModelProvider;

import com.bumptech.glide.Glide;
import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaEpisodeUnlockByPaymentFragmentBinding;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.scene.detail.DramaLoadingDialog;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

import java.util.List;
import java.util.Locale;
import java.util.Objects;

public class DramaEpisodeUnlockByPaymentFragment extends BottomSheetDialogFragment {
    public static final String EXTRA_FROM = "extra_from";

    public static final int VALUE_FROM_SELECTOR = 1;
    public static final int VALUE_FROM_CHOICE = 2;

    private static final double PRICE_PER_EPISODE = 5.00;
    private static final double DISCOUNT = 0.60;

    public static final int DEFAULT_UNLOCK_COUNT = 3;

    public DramaEpisodeUnlockByPaymentFragment() {
        super(R.layout.vevod_mini_drama_episode_unlock_by_payment_fragment);
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        if (isLandscape()) {
            return new AppCompatDialog(requireContext(), getTheme());
        }
        return super.onCreateDialog(savedInstanceState);
    }

    @Override
    public int getTheme() {
        return isLandscape() ? R.style.VeVodMiniDramaUnlockAllLandscapeDialog
                : R.style.VeVodMiniDramaUnlockAllDialog;
    }

    UnlockStateViewModel unlockStateModel;
    UnlockByPaymentViewModel viewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ViewModelProvider modelProvider = new ViewModelProvider(this);

        viewModel = modelProvider.get(UnlockByPaymentViewModel.class);
        unlockStateModel = modelProvider.get(UnlockStateViewModel.class);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        VevodMiniDramaEpisodeUnlockByPaymentFragmentBinding binding = VevodMiniDramaEpisodeUnlockByPaymentFragmentBinding.bind(view);

        ViewCompat.setOnApplyWindowInsetsListener(binding.getRoot(), (v, windowInsets) -> {
            Insets insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            binding.guidelineBottom.setGuidelineEnd(insets.bottom);
            return WindowInsetsCompat.CONSUMED;
        });

        Bundle arguments = requireArguments();
        DramaItem dramaItem = Objects.requireNonNull((DramaItem) arguments.getSerializable(EXTRA_DRAMA_ITEM));
        boolean fromSelector = (arguments.getInt(EXTRA_FROM, VALUE_FROM_CHOICE) == VALUE_FROM_SELECTOR);
        UnlockDataHelper helper = new UnlockDataHelper(dramaItem, fromSelector);

        int unlockCount = Math.min(helper.getRemindLockedEpisodeCount(), DEFAULT_UNLOCK_COUNT);
        double unlockCountPrice = unlockCount * PRICE_PER_EPISODE;

        int totalLockedEpisodeCount = helper.getTotalLockedEpisodeCount();
        double unlockAllPrice = totalLockedEpisodeCount * PRICE_PER_EPISODE * DISCOUNT;
        double unlockAllPriceDiscount = totalLockedEpisodeCount * PRICE_PER_EPISODE * DISCOUNT;

        binding.close.setOnClickListener(v -> dismiss());
        Glide.with(binding.dramaCover)
                .load(dramaItem.getCoverUrl())
                .centerCrop()
                .into(binding.dramaCover);
        binding.dramaTitle.setText(dramaItem.getDramaTitle());
        binding.dramaAllEpisodes.setText(getString(R.string.vevod_mini_drama_all_episodes_count, dramaItem.getTotalEpisodeNumber()));

        binding.skuCount.setText(String.valueOf(unlockCount));
        binding.skuCountPrice.setText(getString(R.string.vevod_mini_drama_price_usd, unlockCountPrice));

        binding.discountLabel.setText(String.format(Locale.ENGLISH, "%.0f%%", DISCOUNT * 100));

        binding.skuAllPriceDiscount.setText(
                getString(R.string.vevod_mini_drama_price_usd, unlockAllPriceDiscount)
        );

        int paintFlags = binding.skuAllPriceOriginal.getPaintFlags();
        paintFlags |= Paint.STRIKE_THRU_TEXT_FLAG;
        binding.skuAllPriceOriginal.setPaintFlags(paintFlags);
        binding.skuAllPriceOriginal.setText(
                getString(R.string.vevod_mini_drama_price_usd, unlockAllPrice)
        );

        binding.cardUnlockCount.setOnClickListener(v -> {
            viewModel.sku.setValue(SKU.COUNT);
        });

        binding.cardUnlockAll.setOnClickListener(v -> {
            viewModel.sku.setValue(SKU.ALL);
        });

        viewModel.sku.observe(getViewLifecycleOwner(), sku -> {
            switch (sku) {
                case COUNT:
                    binding.cardUnlockCount.setSelected(true);
                    binding.cardUnlockAll.setSelected(false);
                    binding.action.setText(getString(R.string.vevod_mini_drama_pay_for_usd, unlockCountPrice));
                    break;
                case ALL:
                    binding.cardUnlockCount.setSelected(false);
                    binding.cardUnlockAll.setSelected(true);
                    binding.action.setText(getString(R.string.vevod_mini_drama_pay_for_usd, unlockAllPriceDiscount));
                    break;
            }
        });

        binding.action.setOnClickListener(v -> {
            SKU value = Objects.requireNonNull(viewModel.sku.getValue());
            List<String> episodes = switch (value) {
                case COUNT -> helper.getEpisodes(unlockCount);
                case ALL -> helper.allEpisodes();
            };

            unlockStateModel.unlockEpisodes(dramaItem.getDramaId(), episodes);
        });

        unlockStateModel.unlockState.observe(getViewLifecycleOwner(), state -> {
            if (state == UnlockState.UNLOCKING) {
                showLoadingDialog();
            } else if (state == UnlockState.UNLOCKED) {
                dismissLoadingDialog();
                dismiss();
            } else {
                dismissLoadingDialog();
            }
        });
    }

    private boolean isLandscape() {
        Context context = requireContext();
        Configuration configuration = context.getResources().getConfiguration();
        return configuration.orientation == Configuration.ORIENTATION_LANDSCAPE;
    }

    private static final String TAG_DIALOG_LOADING = "dialog-loading";

    void showLoadingDialog() {
        FragmentManager fragmentManager = getChildFragmentManager();
        Fragment fragment = fragmentManager.findFragmentByTag(TAG_DIALOG_LOADING);
        if (fragment != null) {
            return;
        }

        DramaLoadingDialog dialog = new DramaLoadingDialog();
        dialog.showNow(fragmentManager, TAG_DIALOG_LOADING);
    }

    void dismissLoadingDialog() {
        FragmentManager fragmentManager = getChildFragmentManager();
        DialogFragment fragment = (DialogFragment) fragmentManager.findFragmentByTag(TAG_DIALOG_LOADING);
        if (fragment != null) {
            fragment.dismiss();
        }
    }
}
