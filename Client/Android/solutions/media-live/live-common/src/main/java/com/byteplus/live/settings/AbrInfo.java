// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.live.settings;

import org.json.JSONException;
import org.json.JSONObject;

public class AbrInfo {
    public static final String ABR_INFO_URL = "url";
    public static final String ABR_INFO_GOP = "gop";
    public static final String ABR_INFO_BITRATE = "bitrate";

    public String mUrl;
    public int mGop;
    public int mBitrate;

    public AbrInfo(String url, int bitrate) {
        this(url, 0, bitrate);
    }

    public AbrInfo(String url, int gop, int bitrate) {
        mUrl = url;
        mGop = gop;
        mBitrate = bitrate;
    }

    public static AbrInfo json2AbrInfo(String jsonStr) {
        String url = null;
        int gop = -1;
        int bitrate = -1;
        try {
            JSONObject json = new JSONObject(jsonStr);
            if (json.has(ABR_INFO_URL)) {
                url = json.getString(ABR_INFO_URL);
            }
            if (json.has(ABR_INFO_GOP)) {
                gop = json.getInt(ABR_INFO_GOP);
            }
            if (json.has(ABR_INFO_BITRATE)) {
                bitrate = json.getInt(ABR_INFO_BITRATE);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return new AbrInfo(url, gop, bitrate);
    }

    @Override
    public String toString() {
        JSONObject json = new JSONObject();
        try {
            json.put(ABR_INFO_URL, mUrl);
            json.put(ABR_INFO_GOP, mGop);
            json.put(ABR_INFO_BITRATE, mBitrate);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return json.toString();
    }
}
