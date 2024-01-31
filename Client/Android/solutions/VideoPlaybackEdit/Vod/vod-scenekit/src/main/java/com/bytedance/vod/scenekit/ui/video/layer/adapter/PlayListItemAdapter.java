package com.bytedance.vod.scenekit.ui.video.layer.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CenterCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.databinding.VevodPlaylistLayerVideoItemBinding;
import com.bytedance.vod.scenekit.utils.FormatHelper;
import com.bytedance.vod.scenekit.utils.UIUtils;

import java.util.ArrayList;
import java.util.List;

public class PlayListItemAdapter extends RecyclerView.Adapter<PlayListItemAdapter.ViewHolder> {

    public interface OnItemClickListener {
        void onItemClick(VideoItem videoItem);
    }

    public static final int STYLE_FULLSCREEN = 1;
    public static final int STYLE_HALFSCREEN = 2;

    @NonNull
    private final List<VideoItem> mItems = new ArrayList<>();

    private final OnItemClickListener mItemClickListener;
    private final Context mContext;
    private final int mStyle;

    private final int mCoverCorner;

    private VideoItem mPlayVideoItem;

    private RecyclerView mRecyclerView;

    public PlayListItemAdapter(@NonNull Context context, int style,
                               OnItemClickListener itemClickListener) {
        mContext = context;
        mStyle = style;
        mItemClickListener = itemClickListener;
        mCoverCorner = (int) UIUtils.dip2Px(mContext, 4);
    }

    public void bindRecyclerView(RecyclerView recyclerView) {
        mRecyclerView = recyclerView;
        recyclerView.setAdapter(this);
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ViewHolder(
                VevodPlaylistLayerVideoItemBinding.inflate(
                        LayoutInflater.from(parent.getContext()),
                        parent,
                        false
                )
        );
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        final VideoItem videoItem = mItems.get(position);
        Glide.with(holder.binding.cover)
                .load(videoItem.getCover())
                .transform(new CenterCrop(), new RoundedCorners(mCoverCorner))
                .into(holder.binding.cover);

        holder.binding.title.setText(videoItem.getTitle());
        if (mStyle == STYLE_FULLSCREEN) {
            holder.binding.username.setVisibility(View.GONE);
            holder.binding.videoDescription.setVisibility(View.GONE);
        } else {
            holder.binding.username.setVisibility(View.VISIBLE);
            holder.binding.videoDescription.setVisibility(View.VISIBLE);
            holder.binding.username.setText(videoItem.getUserName());
            holder.binding.videoDescription.setText(FormatHelper.formatCountAndCreateTime(mContext, videoItem));
        }

        if (mPlayVideoItem == videoItem) {
            holder.binding.duration.setVisibility(View.GONE);
            holder.binding.playing.setVisibility(View.VISIBLE);
        } else {
            holder.binding.duration.setVisibility(View.VISIBLE);
            holder.binding.playing.setVisibility(View.GONE);
            holder.binding.duration.setText(FormatHelper.formatDuration(mContext, videoItem));
        }

        holder.binding.getRoot().setOnClickListener(v -> {
            if (mItemClickListener != null) {
                mItemClickListener.onItemClick(videoItem);
            }
        });
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setPlayItem(VideoItem videoItem) {
        if (mPlayVideoItem != videoItem) {
            mPlayVideoItem = videoItem;
            notifyDataSetChanged();
            if (mRecyclerView != null) {
                for (int i = 0; i < mItems.size(); i++) {
                    if (mItems.get(i) == videoItem) {
                        mRecyclerView.smoothScrollToPosition(i);
                        break;
                    }
                }
            }
        }
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void clear() {
        int count = mItems.size();
        if (count == 0) {
            return;
        }
        mItems.clear();
        notifyItemRangeRemoved(0, count);
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setItems(List<VideoItem> videoItems) {
        mItems.clear();
        mItems.addAll(videoItems);
        notifyDataSetChanged();
    }

    public void appendItems(List<VideoItem> videoItems) {
        int count = mItems.size();
        mItems.addAll(videoItems);
        notifyItemRangeInserted(count, videoItems.size());
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public final VevodPlaylistLayerVideoItemBinding binding;

        public ViewHolder(@NonNull VevodPlaylistLayerVideoItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }
    }
}
