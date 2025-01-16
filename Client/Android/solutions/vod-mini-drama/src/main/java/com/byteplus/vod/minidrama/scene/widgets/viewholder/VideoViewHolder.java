// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.viewholder;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.playerkit.player.playback.VideoLayerHost;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.vod.minidrama.scene.widgets.adatper.MultiTypeAdapter;
import com.byteplus.vod.minidrama.scene.widgets.adatper.ViewHolder;
import com.byteplus.vod.minidrama.utils.L;
import com.byteplus.vod.scenekit.data.model.ViewItem;
import com.byteplus.vod.scenekit.ui.video.layer.Layers;

public abstract class VideoViewHolder extends ViewHolder {

    public final int RETRY_MAX_COUNT = 2;

    public VideoViewHolder(@NonNull View itemView) {
        super(itemView);
        L.d(this, "create");
    }

    public abstract VideoView videoView();

    @Override
    public void onViewDetachedFromWindow() {
        super.onViewDetachedFromWindow();

        actionStop();
    }

    @Override
    public void onViewRecycled() {
        super.onViewRecycled();

        actionStop();
    }

    @Override
    public void executeAction(int action, @Nullable Object o) {
        final VideoView videoView = videoView();
        if (videoView == null) return;

        switch (action) {
            case ViewHolderAction.ACTION_PLAY:
                actionPlay();
                break;
            case ViewHolderAction.ACTION_STOP:
                actionStop();
                break;
            case ViewHolderAction.ACTION_PAUSE:
                actionPause();
                break;
            case ViewHolderAction.ACTION_VIEW_PAGER_ON_PAGE_PEEK_START:
                actionOnPagerPeekStart();
                break;
        }
    }

    @Override
    public boolean onBackPressed() {
        final VideoView videoView = videoView();
        if (videoView != null) {
            VideoLayerHost host = videoView.layerHost();
            if (host != null && host.onBackPressed()) {
                return true;
            }
        }
        return super.onBackPressed();
    }

    @Nullable
    private ViewItem getAdapterItem(int position) {
        final RecyclerView.Adapter<?> adapter = getBindingAdapter();
        if (adapter instanceof MultiTypeAdapter) {
            if (position >= 0 && position < adapter.getItemCount()) {
                return ((MultiTypeAdapter) adapter).getItem(position);
            }
        }
        return null;
    }

    private void actionOnPagerPeekStart() {
        final VideoView videoView = videoView();
        if (videoView == null) return;

        VideoLayerHost host = videoView.layerHost();
        if (host != null) {
            host.notifyEvent(Layers.Event.VIEW_PAGER_ON_PAGE_PEEK_START.ordinal(), null);
        }
    }

    private void actionPlay() {
        actionPlay(RETRY_MAX_COUNT);
    }

    private Runnable mPlayRetryRunnable;

    private void actionPlay(final int retryCount) {
        final VideoView videoView = videoView();
        if (videoView == null) return;
        final int adapterPosition = getBindingAdapterPosition();
        final ViewItem bindingItem = getBindingItem();
        final ViewItem adapterItem = getAdapterItem(adapterPosition);
        if (bindingItem != adapterItem) {
            videoView.removeCallbacks(mPlayRetryRunnable);
            if (retryCount > 0) {
                L.d(this, "actionPlay", adapterPosition, "retry post and waiting",
                        "retryCount:" + retryCount, "newest data not bind yet! Wait adapter onBindViewHolder invoke!",
                        videoView, "bindingItem", bindingItem, "adapterItem", adapterItem);
                mPlayRetryRunnable = new Runnable() {
                    @Override
                    public void run() {
                        actionPlay(retryCount - 1);
                    }
                };
                videoView.postOnAnimation(mPlayRetryRunnable);
            } else {
                L.d(this, "actionPlay", adapterPosition, "retry end",
                        "retryCount:" + retryCount, "newest data not bind yet!",
                        videoView, "bindingItem", bindingItem, "adapterItem", adapterItem);
            }
        } else {
            L.d(this, "actionPlay", adapterPosition);
            videoView.startPlayback();
        }
    }

    private void actionPause() {
        final VideoView videoView = videoView();
        if (videoView == null) return;
        if (videoView.player() == null) return;

        L.d(this, "actionPause", getBindingAdapterPosition());
        videoView.pausePlayback();
    }

    private void actionStop() {
        final VideoView videoView = videoView();
        if (videoView == null) return;
        if (videoView.player() == null) return;

        L.d(this, "actionStop", getBindingAdapterPosition());
        videoView.stopPlayback();
    }
}
