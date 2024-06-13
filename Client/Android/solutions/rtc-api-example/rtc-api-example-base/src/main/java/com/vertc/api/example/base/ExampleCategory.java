package com.vertc.api.example.base;

import androidx.annotation.StringRes;

public enum ExampleCategory {
    BASIC(R.string.label_example_base),

    ROOM(R.string.label_example_room),

    AUDIO_VIDEO_TRANSMISSION(R.string.label_example_transmission),

    AUDIO(R.string.label_example_audio),

    VIDEO(R.string.label_example_video),

    IMPORTANT(R.string.label_example_important),

    MESSAGING(R.string.label_example_message);

    @StringRes
    public final int title;

    ExampleCategory(int title) {
        this.title = title;
    }
}
