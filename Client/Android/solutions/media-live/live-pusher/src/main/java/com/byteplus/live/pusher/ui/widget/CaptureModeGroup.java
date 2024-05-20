// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.pusher.ui.widget;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.byteplus.live.common.DensityUtils;
import com.byteplus.live.pusher.R;


public class CaptureModeGroup {
    private TextView mLastSelectedTab = null;
    private OnSelectListener mOnSelectListener = null;
    private final SparseBooleanArray mEnableMap = new SparseBooleanArray();

    public interface OnSelectListener {
        void onSelect(int position);

        void onSelectDisableItem(int position);
    }

    private final Context context;
    private final LinearLayout container;

    public CaptureModeGroup(Context context, LinearLayout container) {
        this.context = context;
        this.container = container;
    }

    public void setListener(OnSelectListener listener) {
        mOnSelectListener = listener;
    }

    public void setEnable(int position, boolean enable) {
        mEnableMap.put(position, enable);
    }

    public void setTabs(int[] tabs, int defaultTab) {
        int marginHorizontal = DensityUtils.dip2px(context, 8);
        LayoutInflater inflater = LayoutInflater.from(context);
        for (int i = 0; i < tabs.length; i++) {
            int tab = tabs[i];
            TextView view = (TextView) inflater.inflate(R.layout.layout_live_push_tab_item, container, false);
            view.setText(tab);
            view.setTag(R.id.tab_position, i);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT
            );
            params.setMargins(marginHorizontal, 0, marginHorizontal, 0);
            container.addView(view, params);

            if (mLastSelectedTab == null && defaultTab == i) {
                mLastSelectedTab = view;
                setTabSelected(view, true);
            } else {
                setTabSelected(view, false);
            }

            view.setOnClickListener(v -> {
                if (v != mLastSelectedTab) {
                    int position = (int) v.getTag(R.id.tab_position);
                    boolean enabled = mEnableMap.get(position, true);
                    if (!enabled) {
                        if (mOnSelectListener != null) {
                            mOnSelectListener.onSelectDisableItem(position);
                        }
                        return;
                    }
                    setTabSelected(mLastSelectedTab, false);
                    mLastSelectedTab = (TextView) v;
                    setTabSelected(mLastSelectedTab, true);
                    if (mOnSelectListener != null) {
                        mOnSelectListener.onSelect(position);
                    }
                }
            });
        }
    }

    void setTabSelected(TextView view, boolean selected) {
        if (selected) {
            view.setTypeface(Typeface.DEFAULT_BOLD);
            view.setPaintFlags(view.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
        } else {
            view.setTypeface(Typeface.DEFAULT);
            view.setPaintFlags(view.getPaintFlags() & (~Paint.UNDERLINE_TEXT_FLAG));
        }
    }
}
