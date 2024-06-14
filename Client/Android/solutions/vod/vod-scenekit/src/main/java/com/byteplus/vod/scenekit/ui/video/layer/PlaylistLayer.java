// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.scenekit.ui.video.layer;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.ui.video.layer.adapter.PlayListItemAdapter;
import com.byteplus.vod.scenekit.ui.video.layer.base.DialogLayer;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;

import java.util.List;

public class PlaylistLayer extends DialogLayer {

    public interface IPlaylistLayerCallback {
        List<VideoItem> getVideoList();
        VideoItem getPlayVideoItem();
        void onItemClick(VideoItem videoItem);
    }

    private final IPlaylistLayerCallback mCallback;

    private PlayListItemAdapter mAdapter;

    public PlaylistLayer(@NonNull IPlaylistLayerCallback callback) {
        mCallback = callback;
    }

    @Nullable
    @Override
    public String tag() {
        return "playlist";
    }

    @Override
    protected View createDialogView(@NonNull ViewGroup parent) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.vevod_playlist_layer, parent, false);
        RecyclerView recyclerView = view.findViewById(R.id.recyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(parent.getContext()));
        mAdapter = new PlayListItemAdapter(parent.getContext(), PlayListItemAdapter.STYLE_FULLSCREEN,
                mCallback::onItemClick);
        mAdapter.bindRecyclerView(recyclerView);
        view.setOnClickListener(v -> animateDismiss());
        return view;
    }

    @Override
    public void show() {
        super.show();
        mAdapter.setItems(mCallback.getVideoList());
        setPlayItem(mCallback.getPlayVideoItem());
    }

    public void setPlayItem(VideoItem videoItem) {
        if (mAdapter != null) {
            mAdapter.setPlayItem(videoItem);
        }
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (!PlayScene.isFullScreenMode(toScene)) {
            dismiss();
        }
    }

    @Override
    protected int backPressedPriority() {
        return Layers.BackPriority.PLAYLIST_DIALOG_BACK_PRIORITY;
    }

    public int getPlaylistSize() {
        return mCallback.getVideoList().size();
    }

}
