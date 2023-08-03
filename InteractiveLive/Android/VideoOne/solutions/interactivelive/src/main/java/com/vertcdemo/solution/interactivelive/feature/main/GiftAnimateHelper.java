// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.util.SparseBooleanArray;
import android.view.View;

import androidx.annotation.MainThread;

import com.bumptech.glide.Glide;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.MessageBody;
import com.vertcdemo.solution.interactivelive.core.annotation.GiftType;
import com.vertcdemo.solution.interactivelive.databinding.LayoutGiftShowItemBinding;
import com.vertcdemo.solution.interactivelive.event.MessageEvent;
import com.videoone.avatars.Avatars;

import java.util.LinkedList;
import java.util.Queue;

public class GiftAnimateHelper {

    private static final long DURATION_GIFT = 500;
    private static final long DURATION_WAIT = 3000;

    private final Queue<MessageEvent> mEvents = new LinkedList<>();

    private final LayoutGiftShowItemBinding[] mSlots;

    private final SparseBooleanArray mUsedMap = new SparseBooleanArray();

    private final int mGiftLayoutWidth;

    private final Context mContext;

    private boolean mViewDestroyed;

    public GiftAnimateHelper(Context context, LayoutGiftShowItemBinding... slots) {
        mContext = context;
        mGiftLayoutWidth = context.getResources().getDimensionPixelSize(R.dimen.live_gift_show_item_width);
        mSlots = slots;
        mViewDestroyed = false;
    }

    public void onDestroyView() {
        mViewDestroyed = true;
    }

    @MainThread
    public void post(MessageEvent event) {
        if (mViewDestroyed) {
            return;
        }
        mEvents.add(event);
        renderNext();
    }

    private void renderNext() {
        if (mViewDestroyed) {
            return;
        }
        for (int position = 0; position < mSlots.length; position++) {
            final boolean used = mUsedMap.get(position, false);
            if (!used) {
                final MessageEvent event = mEvents.poll();
                if (event == null) {
                    return;
                }
                mUsedMap.put(position, true);
                renderGift(position, event, mSlots[position]);
                return;
            }
        }
    }

    private void renderGift(int position, MessageEvent next, LayoutGiftShowItemBinding binding) {
        final MessageBody body = next.getBody();
        String giftName;
        switch (body.giftType) {
            case GiftType.LIKE:
                giftName = mContext.getString(R.string.gift_like);
                binding.giftIcon.setImageResource(R.drawable.ic_gift_like);
                break;
            case GiftType.SUGAR:
                giftName = mContext.getString(R.string.gift_sugar);
                binding.giftIcon.setImageResource(R.drawable.ic_gift_suger);
                break;
            case GiftType.DIAMOND:
                giftName = mContext.getString(R.string.gift_diamond);
                binding.giftIcon.setImageResource(R.drawable.ic_gift_diamond);
                break;
            case GiftType.FIREWORKS:
                giftName = mContext.getString(R.string.gift_fireworks);
                binding.giftIcon.setImageResource(R.drawable.ic_gift_fireworks);
                break;

            default:
                mUsedMap.put(position, false);
                renderNext();
                return;
        }

        Glide.with(binding.userAvatar)
                .load(Avatars.byUserId(next.user.userId))
                .circleCrop()
                .into(binding.userAvatar);

        binding.userName.setText(next.user.userName);
        binding.description.setText(mContext.getString(R.string.send_gift, giftName));

        binding.groupCount.setVisibility(body.count > 0 ? View.VISIBLE : View.GONE);
        binding.count.setText(String.valueOf(body.count));

        final ObjectAnimator gift = ObjectAnimator
                .ofFloat(binding.root, View.TRANSLATION_X, -mGiftLayoutWidth, 0)
                .setDuration(DURATION_GIFT);

        final ValueAnimator wait = ValueAnimator
                .ofInt(0, 0)
                .setDuration(DURATION_WAIT);

        AnimatorSet set = new AnimatorSet();
        set.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                super.onAnimationStart(animation);
                binding.root.setVisibility(View.VISIBLE);
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                binding.root.setVisibility(View.GONE);
                mUsedMap.put(position, false);
                renderNext();
            }
        });
        set.playSequentially(gift, wait);
        set.start();
    }
}
