/*
 * Copyright (C) 2023 bytedance
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Create Date : 2023/6/12
 */

package com.bytedance.vod.scenekit.ui.video.layer;

import static com.bytedance.vod.scenekit.ui.video.scene.PlayScene.isFullScreenMode;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bytedance.vod.scenekit.R;
import com.bytedance.vod.scenekit.data.model.VideoItem;
import com.bytedance.vod.scenekit.ui.video.layer.adapter.PlayListItemAdapter;
import com.bytedance.vod.scenekit.ui.video.layer.base.DialogLayer;

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
        if (!isFullScreenMode(toScene)) {
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
