// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main;

import android.content.Context;
import android.util.Log;

import androidx.annotation.MainThread;
import androidx.constraintlayout.widget.ConstraintSet;

import com.google.gson.JsonSyntaxException;
import com.vertcdemo.core.common.GsonUtils;
import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.protocol.ScalingMode;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.SeiAppData;
import com.vertcdemo.solution.interactivelive.core.annotation.LiveMode;
import com.vertcdemo.solution.interactivelive.core.live.TTPlayer;
import com.vertcdemo.solution.interactivelive.databinding.FragmentLiveAudienceBinding;
import com.vertcdemo.solution.interactivelive.event.LiveModeChangeEvent;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

public class AudienceVideoPlayer extends MediaStatusObservable {

    public static final String SEI_KEY_APP_DATA = "app_data";

    private static final String TAG = "AudienceVideoPlayer";

    protected final FragmentLiveAudienceBinding mBinding;

    private final TTPlayer mVideoPlayer;

    protected AudienceVideoPlayer(FragmentLiveAudienceBinding binding) {
        this.mBinding = binding;
        Context context = binding.root.getContext();

        mVideoPlayer = new TTPlayer();
        mVideoPlayer.startWithConfiguration(context, this::onSeiUpdate);
    }

    public void playUrl(Map<String, String> urls) {
        Log.d(TAG, "playUrl url=" + urls);
        mVideoPlayer.setPlayerUrls(urls, mBinding.player);
        mVideoPlayer.play();
        mVideoPlayer.updatePlayScaleModel(ScalingMode.ASPECT_FILL);
    }

    public void stopPlay() {
        mBinding.player.removeAllViews();

        mVideoPlayer.stop();
    }

    @LiveMode
    private int mLiveMode = LiveMode.NORMAL;

    @LiveMode
    public int getLiveMode() {
        return mLiveMode;
    }

    protected LayoutMode mLayoutMode = LayoutMode.PLAYER;

    public void setLayoutMode(LayoutMode layoutMode) {
        mLayoutMode = layoutMode;
    }

    @MainThread
    public void onSeiUpdate(String message) {
        if (mLayoutMode != LayoutMode.PLAYER) {
            // No need to handle SEI message in Link Mode
            return;
        }
        Log.d(TAG, "sei=" + message);

        try {
            JSONObject json = new JSONObject(message);
            String appData = json.optString(SEI_KEY_APP_DATA);
            if (appData.isEmpty()) {
                return;
            }
            SeiAppData appDataObject = GsonUtils.gson().fromJson(appData, SeiAppData.class);
            int liveMode = appDataObject.getLiveMode();
            if (mLiveMode != liveMode) {
                mLiveMode = liveMode;
                onLiveModeChanged(liveMode);
            }
        } catch (JSONException | JsonSyntaxException jse) {
            Log.d(TAG, "Parse SEI failed.", jse);
        }
    }

    private void onLiveModeChanged(@LiveMode int liveMode) {
        Context context = mBinding.root.getContext();
        ConstraintSet constraints = new ConstraintSet();
        if (liveMode == LiveMode.LINK_1v1 || liveMode == LiveMode.LINK_1vN) {
            constraints.load(context, R.layout.constraint_live_link);
        } else if (liveMode == LiveMode.LINK_PK) {
            constraints.load(context, R.layout.constraint_live_pk);
        } else {
            constraints.load(context, R.layout.constraint_live_normal);
        }
        constraints.applyTo(mBinding.root);
        SolutionEventBus.post(new LiveModeChangeEvent(liveMode));
    }

    public void destroyPlayer() {
        stopPlay();
        mVideoPlayer.destroy();
    }

    protected enum LayoutMode {
        PLAYER,
        LINK1v1,
        LINK1vN,
    }
}
