// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.vod.function;

import static com.videoone.vod.function.VodFunctionActivity.EXTRA_FUNCTION;
import static com.videoone.vod.function.VodFunctionActivity.EXTRA_PLAY_MODE;
import static com.videoone.vod.function.VodFunctionActivity.EXTRA_VIDEO_ITEM;
import static com.videoone.vod.function.VodFunctionActivity.EXTRA_VIDEO_LIST;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Parcelable;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentTransaction;

import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.data.model.VideoItem;
import com.byteplus.vod.scenekit.data.page.Page;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.voddemo.data.remote.RemoteApi;
import com.byteplus.voddemo.data.remote.api2.GetFeedStreamApi;
import com.byteplus.voddemo.data.remote.api2.Params;
import com.byteplus.voddemo.data.remote.api2.model.GetFeedStreamRequest;
import com.vertcdemo.ui.dialog.SolutionProgressDialog;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;

public class VodFunctionDispatchActivity extends AppCompatActivity {
    private static final String TAG = "VodFunctionDispatcher";

    GetFeedStreamApi mRemoteApi = new GetFeedStreamApi();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.add(new SolutionProgressDialog(), "dialog_loading");
        ft.commit();

        Intent intent = getIntent();
        Function function = (Function) intent.getSerializableExtra(EXTRA_FUNCTION);
        assert function != null : "No function provided";

        switch (function) {
            case VIDEO_PLAYBACK:
                dispatchToVideoPlayback();
                break;
            case PLAYLIST:
                dispatchToPlaylist();
                break;
            case SMART_SUBTITLES:
                dispatchToSmartSubtitles();
                break;
            case PREVENT_RECORDING:
                dispatchToPreventRecording();
                break;
            default:
                finish();
                Log.d(TAG, "Unknown function: " + function);
                break;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mRemoteApi.cancel();
    }

    void dispatchToVideoPlayback() {
        GetFeedStreamRequest request = createRequest();
        mRemoteApi.getFeedStream(request, new MyCallback(this, Function.VIDEO_PLAYBACK));
    }

    void dispatchToPlaylist() {
        mRemoteApi.getPlaylistStream(new MyCallback(this, Function.PLAYLIST));
    }

    void dispatchToSmartSubtitles() {
        GetFeedStreamRequest request = createRequest();
        request.supportSmartSubtitle = true;
        mRemoteApi.getFeedStream(request, new MyCallback(this, Function.SMART_SUBTITLES));
    }

    void dispatchToPreventRecording() {
        GetFeedStreamRequest request = createRequest();
        request.antiScreenshotAndRecord = true;
        mRemoteApi.getFeedStream(request, new MyCallback(this, Function.PREVENT_RECORDING));
    }

    static class MyCallback implements RemoteApi.Callback<Page<VideoItem>> {
        private final WeakReference<VodFunctionDispatchActivity> mActivityRef;
        private final Function mFunction;

        MyCallback(VodFunctionDispatchActivity activity, Function function) {
            mActivityRef = new WeakReference<>(activity);
            mFunction = function;
        }

        @Override
        public void onSuccess(Page<VideoItem> page) {
            Log.d(TAG, "MyCallback: onSuccess: ");
            Activity activity = mActivityRef.get();
            if (activity == null) {
                Log.d(TAG, "  activity is null");
                return;
            }
            if (activity.isFinishing()) {
                Log.d(TAG, "  activity isFinishing");
                return;
            }

            List<VideoItem> videoItems = page.list;
            if (videoItems == null || videoItems.isEmpty()) {
                Log.d(TAG, "  videoItems isNullOrEmpty");
                return;
            }
            VideoItem videoItem = videoItems.get(0);
            VideoItem.tag(videoItem, PlayScene.map(PlayScene.SCENE_FEED), null);

            Intent intent = new Intent(activity, VodFunctionActivity.class);
            if (Function.PLAYLIST.equals(mFunction)) {
                intent.putParcelableArrayListExtra(EXTRA_VIDEO_LIST, (ArrayList<? extends Parcelable>) page.list);
                intent.putExtra(EXTRA_PLAY_MODE, page.playMode);
            } else {
                intent.putExtra(EXTRA_VIDEO_ITEM, videoItem);
            }
            intent.putExtra(EXTRA_FUNCTION, mFunction);
            activity.startActivity(intent);

            activity.finish();
        }

        @Override
        public void onError(Exception e) {
            Log.d(TAG, "MyCallback: onError: " + e.getMessage());
            Activity activity = mActivityRef.get();
            if (activity == null) {
                Log.d(TAG, "  activity is null");
                return;
            }
            if (activity.isFinishing()) {
                Log.d(TAG, "  activity isFinishing");
                return;
            }

            activity.finish();
        }
    }

    private static GetFeedStreamRequest createRequest() {
        final String accountId = VideoSettings.stringValue(VideoSettings.FEED_VIDEO_SCENE_ACCOUNT_ID);
        return new GetFeedStreamRequest(RemoteApi.VideoType.FEED, accountId,
                0, 1,
                Params.Value.format(),
                Params.Value.codec(),
                Params.Value.definition(),
                Params.Value.fileType(),
                Params.Value.needThumbs(),
                Params.Value.enableBarrageMask(),
                Params.Value.cdnType(),
                Params.Value.unionInfo());
    }
}
