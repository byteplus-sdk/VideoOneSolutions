// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.player.utils;

import static android.media.AudioTrack.WRITE_BLOCKING;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;

public class AudioPlayer {
    
    private static final String TAG = "AudioPlayer";

    private static final int DEFAULT_STREAM_TYPE = AudioManager.STREAM_MUSIC;
    private static final int DEFAULT_SAMPLE_RATE = 44100;
    private static final int DEFAULT_CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_STEREO;
    private static final int DEFAULT_AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;
    private static final int DEFAULT_PLAY_MODE = AudioTrack.MODE_STREAM;
            
    private boolean mIsPlayStarted = false;
    private int mMinBufferSize = 0;
    private AudioTrack mAudioTrack;

    private int mAudioFormat;
    
    public boolean startPlayer() {
        return startPlayer(DEFAULT_STREAM_TYPE,DEFAULT_SAMPLE_RATE,DEFAULT_CHANNEL_CONFIG,DEFAULT_AUDIO_FORMAT);
    }
    
    public boolean startPlayer(int streamType, int sampleRateInHz, int channelConfig, int audioFormat) {
        
        if (mIsPlayStarted) {
            Log.e(TAG, "Player already started !");
            return false;
        }
        
        mMinBufferSize = AudioTrack.getMinBufferSize(sampleRateInHz,channelConfig,audioFormat);
        if (mMinBufferSize == AudioTrack.ERROR_BAD_VALUE) {
            Log.e(TAG, "Invalid parameter !");
            return false;
        }
        Log.d(TAG , "getMinBufferSize = "+mMinBufferSize+" bytes !");

        mAudioFormat = audioFormat;
        mAudioTrack = new AudioTrack(streamType,sampleRateInHz,channelConfig,audioFormat,mMinBufferSize,DEFAULT_PLAY_MODE);
        if (mAudioTrack.getState() == AudioTrack.STATE_UNINITIALIZED) {
            Log.e(TAG, "AudioTrack initialize fail !");
            return false;
        }            
        
        mIsPlayStarted = true;
        mAudioTrack.play();
        Log.d(TAG, "Start audio player success !");
        
        return true;
    }
    
    public int getMinBufferSize() {
        return mMinBufferSize;
    }
    
    public void stopPlayer() {
        
        if (!mIsPlayStarted) {
            return;
        }
        
        if (mAudioTrack.getPlayState() == AudioTrack.PLAYSTATE_PLAYING) {
            mAudioTrack.stop();                        
        }
        
        mAudioTrack.release();
        mIsPlayStarted = false;
           
        Log.d(TAG, "Stop audio player success !");
    }

    public void write(byte[] audioData) {
        if (!mIsPlayStarted) {
            Log.e(TAG, "Player not started !");
            return;
        }
        int ret;
        if (mAudioFormat == AudioFormat.ENCODING_PCM_FLOAT) {
            float[] floatAudioData = byteArrayToFloatArray(audioData);
            ret = mAudioTrack.write(floatAudioData, 0, floatAudioData.length, WRITE_BLOCKING);
        } else {
            ret = mAudioTrack.write(audioData, 0, audioData.length);
        }
        if (ret != audioData.length) {
            Log.e(TAG, "Could not write all the samples to the audio device ! ret: " + ret);
        }

        mAudioTrack.play();
    }

    private float[] byteArrayToFloatArray(byte[] bytes) {
        ByteBuffer buffer = ByteBuffer.wrap(bytes);
        FloatBuffer fb = buffer.asFloatBuffer();
        float[] floatArray = new float[fb.limit()];
        fb.get(floatArray);
        return floatArray;
    }
}