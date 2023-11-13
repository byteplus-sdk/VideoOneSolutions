// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.core.live;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertcdemo.solution.interactivelive.core.annotation.LiveResolution;

import java.util.Map;

public class StreamUrls {
    static String get480Url(@NonNull Map<String, String> urls) {
        return urls.get(LiveResolution.RES480);
    }

    static String get540Url(@NonNull Map<String, String> urls) {
        return urls.get(LiveResolution.RES540);
    }

    static String get720Url(@NonNull Map<String, String> urls) {
        return urls.get(LiveResolution.RES720);
    }

    static String get1080Url(@NonNull Map<String, String> urls) {
        return urls.get(LiveResolution.RES1080);
    }

    @Nullable
    static String getOriginUrl(@NonNull Map<String, String> urls) {
        String origin = urls.get(LiveResolution.RES_ORIGIN);
        if (origin != null) {
            return origin;
        }

        String res1080 = get1080Url(urls);
        if (res1080 != null) {
            return toOriginUrl(res1080);
        }

        String res720 = get720Url(urls);
        if (res720 != null) {
            return toOriginUrl(res720);
        }
        String res540 = get540Url(urls);
        if (res540 != null) {
            return toOriginUrl(res540);
        }
        String res480 = get480Url(urls);
        if (res480 != null) {
            return toOriginUrl(res480);
        }

        return null;
    }

    /**
     * Try to remove the url suffix to get the origin url
     * <p>
     * 480p: _ld, _lc
     * 540p: _sd, _bq
     * 720p: _hd, _gq
     * 1080p: _uhd, _cq
     *
     * @param suffixedUrl url with suffix
     * @return origin url
     */
    private static String toOriginUrl(@NonNull String suffixedUrl) {
        return suffixedUrl.replaceFirst("(?:_lc|_bq|_cq|_gq|_ld|_sd|_hd|_uhd)(?=\\.flv$)", "");
    }
}
