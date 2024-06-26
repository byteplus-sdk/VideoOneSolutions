// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: MIT

package com.vertcdemo.solution.chorus.core;

import androidx.annotation.NonNull;

import com.ss.bytertc.engine.IAudioFrameObserver;
import com.ss.bytertc.engine.audio.IMediaPlayer;
import com.ss.bytertc.engine.data.AudioMixingType;
import com.ss.bytertc.engine.data.MediaPlayerConfig;
import com.ss.bytertc.engine.data.MediaPlayerCustomSource;
import com.ss.bytertc.engine.data.MediaPlayerCustomSourceMode;
import com.ss.bytertc.engine.data.MediaPlayerCustomSourceStreamType;
import com.ss.bytertc.engine.data.RemoteStreamKey;
import com.ss.bytertc.engine.utils.AudioFrame;
import com.ss.bytertc.engine.utils.IAudioFrame;

public class ForwardAudioFrameObserver implements IAudioFrameObserver {
    @NonNull
    private final String remoteUid;
    @NonNull
    private final IMediaPlayer player;

    public String remoteUid() {
        return remoteUid;
    }

    public ForwardAudioFrameObserver(@NonNull String remoteUid, @NonNull IMediaPlayer player) {
        this.remoteUid = remoteUid;
        this.player = player;

        MediaPlayerCustomSource source = new MediaPlayerCustomSource(null, MediaPlayerCustomSourceMode.PUSH, MediaPlayerCustomSourceStreamType.RAW);
        player.openWithCustomSource(source, new MediaPlayerConfig(AudioMixingType.AUDIO_MIXING_TYPE_PLAYOUT_AND_PUBLISH, 1));
    }

    @Override
    public void onRecordAudioFrame(IAudioFrame audioFrame) {

    }

    @Override
    public void onPlaybackAudioFrame(IAudioFrame audioFrame) {

    }

    @Override
    public void onRemoteUserAudioFrame(RemoteStreamKey streamInfo, IAudioFrame audioFrame) {
        if (remoteUid.equals(streamInfo.getUserId())) {
            player.pushExternalAudioFrame(wrapAudioFrame(audioFrame));
        }
    }

    @Override
    public void onMixedAudioFrame(IAudioFrame audioFrame) {

    }

    private static AudioFrame wrapAudioFrame(IAudioFrame source) {
        int size = source.data_size();
        byte[] buffer = new byte[size];
        source.getDataBuffer().get(buffer);

        int samples = size / source.channel().value() / 2;

        return new AudioFrame(
                buffer,
                samples,
                source.sample_rate(),
                source.channel()
        );
    }
}
