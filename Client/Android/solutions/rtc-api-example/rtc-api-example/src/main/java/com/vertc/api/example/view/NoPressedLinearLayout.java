package com.vertc.api.example.view;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.LinearLayoutCompat;

/**
 * A custom LinearLayout that doesn't propagate press states to its child views
 */
public class NoPressedLinearLayout extends LinearLayoutCompat {
    public NoPressedLinearLayout(@NonNull Context context) {
        super(context);
    }

    public NoPressedLinearLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public NoPressedLinearLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void dispatchSetPressed(boolean pressed) {
        // Leave it blank
    }
}
