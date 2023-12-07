/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
 * SPDX-License-Identifier: Apache-2.0
 */

package com.bytedance.voddemo.ui.video.scene.comment;

import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_NEGATIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_POSITIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_MESSAGE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_REQUEST_KEY;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_TITLE;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.core.util.Consumer;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bytedance.vod.scenekit.utils.FormatHelper;
import com.bytedance.voddemo.impl.R;
import com.bytedance.voddemo.ui.video.scene.comment.model.CommentItem;
import com.vertcdemo.base.ReportDialog;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;
import com.videoone.avatars.Avatars;

import java.util.ArrayList;
import java.util.List;

class CommentItemAdapter extends RecyclerView.Adapter<CommentItemViewHolder> {

    public static final String REQUEST_DELETE_KEY = "confirm_delete";

    private final List<CommentItem> mItems = new ArrayList<>();

    @NonNull
    private final Fragment mHost;
    private final Context mContext;
    private final Consumer<Integer> mCountObserver;

    private final int mLayoutId;

    public CommentItemAdapter(@NonNull Fragment host, @LayoutRes int layoutId, Consumer<Integer> countObserver) {
        this.mHost = host;
        this.mContext = host.requireContext();
        this.mLayoutId = layoutId;
        this.mCountObserver = countObserver;

        host.getChildFragmentManager()
                .setFragmentResultListener(
                        CommentItemAdapter.REQUEST_DELETE_KEY,
                        host.getViewLifecycleOwner(),
                        (requestKey, result) -> {
                            if (Dialog.BUTTON_POSITIVE == result.getInt(SolutionCommonDialog.EXTRA_RESULT)) {
                                Bundle args = result.getBundle(SolutionCommonDialog.EXTRA_SOURCE_ARGS);
                                assert args != null;
                                int position = args.getInt("delete_position");
                                removeItemAt(position);
                            }
                        });
    }

    @NonNull
    @Override
    public CommentItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View inflate = LayoutInflater.from(mContext).inflate(mLayoutId, parent, false);
        return new CommentItemViewHolder(inflate);
    }

    @Override
    public void onBindViewHolder(@NonNull CommentItemViewHolder holder, int position) {
        CommentItem item = mItems.get(position);
        Glide.with(holder.avatar)
                .load(Avatars.byUserId(item.userId))
                .transform(new CircleCrop())
                .into(holder.avatar);
        holder.name.setText(item.userName);
        holder.comment.setText(item.content);
        holder.time.setText(FormatHelper.formatCreateTime(mContext, item.createTime));

        holder.likeNum.setText(FormatHelper.formatCount(mContext, item.likeNumber));

        holder.delete.setVisibility(
                item.isSelf ? View.VISIBLE : View.GONE);
        if (item.isSelf) {
            holder.delete.setOnClickListener(v -> {
                showDeleteConfirmDialog(holder.getBindingAdapterPosition());
            });
            holder.itemView.setOnLongClickListener(null);
        } else {
            holder.itemView.setOnLongClickListener(v -> {
                ReportDialog.show(v.getContext());
                return true;
            });
        }

        holder.likeNum.setSelected(item.iLikeIt);
        holder.likeNum.setOnClickListener(v -> {
            item.iLikeIt = !item.iLikeIt;
            item.likeNumber += (item.iLikeIt ? 1 : -1);
            notifyItemChanged(holder.getBindingAdapterPosition());
        });
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void setItems(List<CommentItem> items) {
        mItems.clear();
        mItems.addAll(items);
        notifyDataSetChanged();
        mCountObserver.accept(mItems.size());
    }

    public void removeItemAt(int position) {
        mItems.remove(position);
        notifyItemRemoved(position);
        mCountObserver.accept(mItems.size());
    }

    public void addFirstItem(CommentItem item) {
        mItems.add(0, item);
        notifyItemRangeInserted(0, 1);
        mCountObserver.accept(mItems.size());
    }

    void showDeleteConfirmDialog(int position) {
        SolutionCommonDialog dialog = new SolutionCommonDialog();
        final Bundle args = new Bundle();
        args.putString(EXTRA_REQUEST_KEY, REQUEST_DELETE_KEY);
        args.putInt(EXTRA_TITLE, R.string.vevod_confirm_delete_title);
        args.putInt(EXTRA_MESSAGE, R.string.vevod_confirm_delete_message);
        args.putInt(EXTRA_BUTTON_POSITIVE, R.string.confirm);
        args.putInt(EXTRA_BUTTON_NEGATIVE, R.string.cancel);
        args.putInt("delete_position", position);
        dialog.setArguments(args);
        dialog.show(mHost.getChildFragmentManager(), "confirm_finish_interact_dialog");
    }
}
