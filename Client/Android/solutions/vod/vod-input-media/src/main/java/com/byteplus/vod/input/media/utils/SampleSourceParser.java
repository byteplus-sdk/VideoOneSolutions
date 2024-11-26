package com.byteplus.vod.input.media.utils;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.byteplus.vod.scenekit.data.model.VideoItem;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.util.ArrayList;

public class SampleSourceParser {

    public static ArrayList<VideoItem> parse(String input) {
        try {
            JSONArray array = new JSONArray(input);
            return createVideoItems(array);
        } catch (JSONException e) {
            return createVideoItems(input.split("\n"));
        }
    }

    private static ArrayList<VideoItem> createVideoItems(JSONArray jsonArray) {
        final ArrayList<VideoItem> videoItems = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject object = jsonArray.optJSONObject(i);
            VideoItem videoItem = createVideoItem(object);
            videoItems.add(videoItem);
        }
        return videoItems;
    }

    @NonNull
    private static VideoItem createVideoItem(JSONObject object) {
        int type = object.optInt("type", 1);
        String vid = object.optString("vid");
        String title = object.optString("title");
        String cover = object.optString("cover");
        long duration = object.optLong("duration");
        VideoItem videoItem;
        switch (type) {
            case VideoItem.SOURCE_TYPE_VID: {
                String playAuthToken = object.optString("playAuthToken");
                String subtitleAuthToken = object.optString("subtitleAuthToken");
                videoItem = VideoItem.createVidItem(vid, playAuthToken, duration, cover, title, subtitleAuthToken);
                break;
            }
            case VideoItem.SOURCE_TYPE_URL: {
                String httpUrl = object.optString("httpUrl");
                videoItem = VideoItem.createUrlItem(vid, httpUrl, null, duration, cover, title);
                break;
            }
            case VideoItem.SOURCE_TYPE_MODEL: {
                String videoModel = object.optString("videoModel");
                videoItem = VideoItem.createVideoModelItem(vid, videoModel, duration, cover, title);
                break;
            }
            default:
                throw new IllegalArgumentException("supported type " + type);
        }
        return videoItem;
    }


    private static ArrayList<VideoItem> createVideoItems(String[] urls) {
        final ArrayList<VideoItem> videoItems = new ArrayList<>();
        for (int i = 0; i < urls.length; i++) {
            String url = urls[i];

            if (TextUtils.isEmpty(url)) continue;
            if (url.startsWith("/")) {
                File file = new File(url);
                if (!file.exists()) continue;
            }
            if (!url.startsWith("http") && !url.startsWith("file")) continue;

            VideoItem videoItem = VideoItem.createUrlItem(
                    md5sum(url),
                    url,
                    null,
                    0,
                    null,
                    i + ": " + url
            );
            videoItems.add(videoItem);
        }

        return videoItems;
    }

    @NonNull
    public static String md5sum(String s) {
        if (s == null) return "";
        String result = "";
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(s.getBytes());
            return (new BigInteger(1, md.digest())).toString(16);
        } catch (Exception e) {
            return result;
        }
    }
}