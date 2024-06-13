package com.vertc.api.example.examples.thirdpart.bytebeauty.bean;

import androidx.annotation.StringRes;
import androidx.core.content.res.ResourcesCompat;

import com.vertc.api.example.R;

public enum EffectSection {

    BEAUTY(R.string.label_beauty_title, R.string.label_beauty_intensity),
    FILTER(R.string.label_filter_title, R.string.label_filter_intensity),
    STICKER(R.string.label_sticker_title),
    BACKGROUND(R.string.label_virtual_title);


    @StringRes
    public final int title;

    @StringRes
    public final int progressTitle;

    public boolean hasProgress() {
        return progressTitle != ResourcesCompat.ID_NULL;
    }

    EffectSection(int title) {
        this(title, ResourcesCompat.ID_NULL);
    }

    EffectSection(int title, @StringRes int progressTitle) {
        this.title = title;
        this.progressTitle = progressTitle;
    }
}
