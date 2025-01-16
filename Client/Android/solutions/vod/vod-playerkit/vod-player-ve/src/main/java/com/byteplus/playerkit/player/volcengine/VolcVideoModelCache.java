// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import android.text.TextUtils;
import android.util.LruCache;

import androidx.annotation.Nullable;

import com.ss.ttvideoengine.model.IVideoModel;
import com.ss.ttvideoengine.model.VideoModel;

import org.json.JSONObject;

public class VolcVideoModelCache {
    /**
     * NOTE: {@link LruCache} is thread safe
     */
    private static final LruCache<String, IVideoModel> CACHE = new LruCache<String, IVideoModel>(100);

    private static boolean sEnabled;

    public static void setEnabled(boolean enabled) {
        sEnabled = enabled;
    }

    public static void resize(int maxSize) {
        CACHE.resize(maxSize);
    }

    public static void cache(String jsonModel) {
        acquire(jsonModel);
    }

    @Nullable
    static IVideoModel acquire(String jsonModel) {
        IVideoModel videoModel = get(jsonModel);
        if (videoModel != null) {
            return videoModel;
        }
        videoModel = Factory.create(jsonModel);
        if (videoModel != null) {
            put(jsonModel, videoModel);
        }
        return videoModel;
    }

    private static IVideoModel get(String key) {
        if (!sEnabled) {
            return null;
        }
        if (TextUtils.isEmpty(key)) return null;
        return CACHE.get(key);
    }

    private static IVideoModel put(String key, IVideoModel value) {
        if (TextUtils.isEmpty(key)) return value;
        if (value == null) return null;
        return CACHE.put(key, value);
    }

    public static void trim(int maxSize) {
        CACHE.trimToSize(maxSize);
    }

    public static void clear() {
        CACHE.evictAll();
    }

    static class Factory {

        @Nullable
        static IVideoModel create(String jsonModel) {
            if (TextUtils.isEmpty(jsonModel)) return null;
            try {
                VideoModel model = new VideoModel();
                model.extractFields(new JSONObject(jsonModel));
                return model;
            } catch (Throwable e) {
                return null;
            }
        }
    }
}
