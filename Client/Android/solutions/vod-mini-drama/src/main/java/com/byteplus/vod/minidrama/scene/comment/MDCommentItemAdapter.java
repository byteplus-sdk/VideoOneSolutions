// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.minidrama.scene.comment;

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
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.byteplus.minidrama.R;
import com.byteplus.vod.scenekit.utils.FormatHelper;
import com.byteplus.vodcommon.ui.video.scene.comment.model.CommentItem;
import com.vertcdemo.base.ReportDialog;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;
import com.videoone.avatars.Avatars;

import java.util.ArrayList;
import java.util.List;

class MDCommentItemAdapter extends RecyclerView.Adapter<MDCommentItemViewHolder> {

    public static final String REQUEST_DELETE_KEY = "confirm_delete";

    private List<CommentItem> mItems = new ArrayList<>();

    @NonNull
    private final Fragment mHost;
    private final Context mContext;
    private final Consumer<Integer> mCountObserver;

    private final int mLayoutId;

    public MDCommentItemAdapter(@NonNull Fragment host, @LayoutRes int layoutId, Consumer<Integer> countObserver) {
        this.mHost = host;
        this.mContext = host.requireContext();
        this.mLayoutId = layoutId;
        this.mCountObserver = countObserver;

        host.getChildFragmentManager()
                .setFragmentResultListener(
                        MDCommentItemAdapter.REQUEST_DELETE_KEY,
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
    public MDCommentItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View inflate = LayoutInflater.from(mContext).inflate(mLayoutId, parent, false);
        return new MDCommentItemViewHolder(inflate);
    }

    @Override
    public void onBindViewHolder(@NonNull MDCommentItemViewHolder holder, int position) {
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
            notifyItemChanged(holder.getBindingAdapterPosition(), PAYLOAD_LIKE);
        });
    }

    @Override
    public void onBindViewHolder(@NonNull MDCommentItemViewHolder holder, int position, @NonNull List<Object> payloads) {
        if (payloads.isEmpty()) {
            onBindViewHolder(holder, position);
        } else {
            Object payload = payloads.get(0);
            if (PAYLOAD_LIKE == payload) {
                CommentItem item = mItems.get(position);
                holder.likeNum.setSelected(item.iLikeIt);
                holder.likeNum.setText(FormatHelper.formatCount(mContext, item.likeNumber));
            }
        }
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void setItems(List<CommentItem> items) {
        final List<CommentItem> oldItems = mItems;
        mItems = new ArrayList<>(items);

        DiffUtil.calculateDiff(new DiffUtil.Callback() {
            @Override
            public int getOldListSize() {
                return oldItems.size();
            }

            @Override
            public int getNewListSize() {
                return items.size();
            }

            @Override
            public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
                CommentItem oldItem = oldItems.get(oldItemPosition);
                CommentItem newItem = items.get(newItemPosition);
                if (oldItem == newItem) return true;

                return oldItem.userId.equals(newItem.userId)
                        && oldItem.userName.equals(newItem.userName)
                        && oldItem.content.equals(newItem.content)
                        && oldItem.createTime.equals(newItem.createTime)
                        && oldItem.isSelf == newItem.isSelf;
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                CommentItem oldItem = oldItems.get(oldItemPosition);
                CommentItem newItem = items.get(newItemPosition);

                return oldItem.likeNumber == newItem.likeNumber
                        && oldItem.iLikeIt == newItem.iLikeIt;
            }

            @Override
            public Object getChangePayload(int oldItemPosition, int newItemPosition) {
                return PAYLOAD_LIKE;
            }
        }).dispatchUpdatesTo(this);

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
        args.putInt(EXTRA_BUTTON_POSITIVE, com.vertcdemo.base.R.string.confirm);
        args.putInt(EXTRA_BUTTON_NEGATIVE, com.vertcdemo.base.R.string.cancel);
        args.putInt("delete_position", position);
        dialog.setArguments(args);
        dialog.show(mHost.getChildFragmentManager(), "confirm_finish_interact_dialog");
    }

    private static final String PAYLOAD_LIKE = "like";
}
