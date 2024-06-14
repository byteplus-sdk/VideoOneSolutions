package com.vertc.api.example.examples.video.pip;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.os.Build;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.TextureView;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;

import com.vertc.api.example.R;

public class FloatWindowManager {

    private WindowManager windowManager;
    private WindowManager.LayoutParams windowParams;
    private FrameLayout floatView;
    private TextureView mainTextureView;
    private Button closeButton;
    private boolean isWindowOpen;
    private int windowSizeInDp = 250;
    private float initialTouchX;
    private float initialTouchY;
    private float initialWindowX;
    private float initialWindowY;

    public FloatWindowManager(Context context, TextureView mainTextureView) {
        this.mainTextureView = mainTextureView;
        windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics displayMetrics = new DisplayMetrics();
        windowManager.getDefaultDisplay().getMetrics(displayMetrics);
        int windowSizeInPixel = convertDpToPixel(windowSizeInDp, displayMetrics.density);
        windowParams = new WindowManager.LayoutParams(
                windowSizeInPixel,
                windowSizeInPixel,
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY : WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
        );
        windowParams.gravity = Gravity.TOP | Gravity.START;
        floatView = new FrameLayout(context);
        closeButton = new Button(context);
        closeButton.setText(R.string.close);
        floatView.addView(closeButton, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL
        ));
        floatView.setBackgroundColor(Color.GRAY);
        isWindowOpen = false;

        floatView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        initialTouchX = event.getRawX();
                        initialTouchY = event.getRawY();
                        initialWindowX = windowParams.x;
                        initialWindowY = windowParams.y;
                        return true;
                    case MotionEvent.ACTION_MOVE:
                        float dx = event.getRawX() - initialTouchX;
                        float dy = event.getRawY() - initialTouchY;
                        windowParams.x = (int) (initialWindowX + dx);
                        windowParams.y = (int) (initialWindowY + dy);
                        windowManager.updateViewLayout(floatView, windowParams);
                        return true;
                }
                return false;
            }
        });
    }

    public void openWindow() {
        if (!isWindowOpen) {
            floatView.addView(mainTextureView);
            windowManager.addView(floatView, windowParams);
            isWindowOpen = true;
        }
    }

    public void closeWindow() {
        if (isWindowOpen) {
            floatView.removeView(mainTextureView);
            windowManager.removeView(floatView);
            isWindowOpen = false;
        }
    }

    public Button getCloseButton() {
        return closeButton;
    }

    public boolean isWindowOpen() {
        return isWindowOpen;
    }

    private int convertDpToPixel(float dp, float density) {
        return (int) (dp * density + 0.5f);
    }
}
