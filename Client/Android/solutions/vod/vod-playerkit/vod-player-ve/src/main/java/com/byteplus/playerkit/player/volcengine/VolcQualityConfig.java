// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import androidx.annotation.IntDef;

import com.byteplus.playerkit.player.config.ABRQualityConfig;
import com.byteplus.playerkit.player.source.Quality;

import java.io.Serializable;
import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

public class VolcQualityConfig implements Serializable {
    /**
     * Quality mode. One of
     * {@link #QUALITY_MODE_DEFAULT},
     * {@link #QUALITY_MODE_STARTUP_ABR},
     * {@link #QUALITY_MODE_ABR}
     */
    @Documented
    @Retention(RetentionPolicy.SOURCE)
    @IntDef({QUALITY_MODE_DEFAULT, QUALITY_MODE_STARTUP_ABR, QUALITY_MODE_ABR})
    public @interface QualityMode {
    }
    public static final int QUALITY_MODE_DEFAULT = 0;
    public static final int QUALITY_MODE_STARTUP_ABR = 1;
    public static final int QUALITY_MODE_ABR = 2;

    @QualityMode
    public int qualityMode;
    public boolean enableSupperResolutionDowngrade;
    public Quality userSelectedQuality;
    public ABRQualityConfig abrQualityConfig;
}
