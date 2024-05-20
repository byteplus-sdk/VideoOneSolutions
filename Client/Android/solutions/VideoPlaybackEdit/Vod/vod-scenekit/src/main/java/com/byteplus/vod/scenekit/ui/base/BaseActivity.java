// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.scenekit.ui.base;

import android.app.Activity;
import android.app.Application;
import android.app.PictureInPictureParams;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.Lifecycle;

import com.byteplus.playerkit.utils.L;
import com.byteplus.vod.scenekit.ui.video.layer.helper.MiniPlayerHelper;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;


public class BaseActivity extends AppCompatActivity {

    public interface IPictureInPictureCallback {
        void goIntoBackground();
        void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig);
    }

    private static final List<WeakReference<BaseActivity>> mActivities = new ArrayList<>();
    private static final List<WeakReference<IPictureInPictureCallback>> mCallbacks = new ArrayList<>();

    public static void registerPictureInPictureCallback(IPictureInPictureCallback callback) {
        synchronized (mCallbacks) {
            if (callback == null) {
                return;
            }
            for (WeakReference<IPictureInPictureCallback> wrf : mCallbacks) {
                if (wrf.get() == callback) {
                    return;
                }
            }
            mCallbacks.add(new WeakReference<>(callback));
        }
    }

    public static void unregisterPictureInPictureCallback(IPictureInPictureCallback callback) {
        synchronized (mCallbacks) {
            Iterator<WeakReference<IPictureInPictureCallback>> iterator = mCallbacks.iterator();
            while (iterator.hasNext()) {
                WeakReference<IPictureInPictureCallback> wrf = iterator.next();
                IPictureInPictureCallback c = wrf.get();
                if (c == null || c == callback) {
                    iterator.remove();
                }
            }
        }
    }

    private static void notifyGoIntoBackground() {
        synchronized (mCallbacks) {
            Iterator<WeakReference<IPictureInPictureCallback>> iterator = mCallbacks.iterator();
            while (iterator.hasNext()) {
                WeakReference<IPictureInPictureCallback> wrf = iterator.next();
                IPictureInPictureCallback c = wrf.get();
                if (c == null) {
                    iterator.remove();
                } else {
                    c.goIntoBackground();
                }
            }
        }
    }

    private static void notifyPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig) {
        synchronized (mCallbacks) {
            Iterator<WeakReference<IPictureInPictureCallback>> iterator = mCallbacks.iterator();
            while (iterator.hasNext()) {
                WeakReference<IPictureInPictureCallback> wrf = iterator.next();
                IPictureInPictureCallback c = wrf.get();
                if (c == null) {
                    iterator.remove();
                } else {
                    c.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
                }
            }
        }
    }

    private boolean mResume = true;

    @Override
    @CallSuper
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mActivities.add(new WeakReference<>(this));
        L.d(this, "onCreate");
    }

    @Override
    @CallSuper
    protected void onStart() {
        super.onStart();
        L.d(this, "onStart");
    }

    @Override
    @CallSuper
    protected void onResume() {
        super.onResume();
        MiniPlayerHelper.get().exitPictureInPictureMode();
        mResume = true;
        L.d(this, "onResume");
    }

    @Override
    @CallSuper
    protected void onPause() {
        super.onPause();
        mResume = false;
        L.d(this, "onPause");
    }

    @Override
    @CallSuper
    protected void onStop() {
        super.onStop();
        L.d(this, "onStop");
    }

    @Override
    @CallSuper
    protected void onDestroy() {
        super.onDestroy();
        L.d(this, "onDestroy");
    }

    @Override
    public void onBackPressed() {
        L.d(this, "onBackPressed");
        super.onBackPressed();
    }

    @Override
    public void finish() {
        super.finish();
        for (int i = mActivities.size() - 1; i >= 0; i--) {
            WeakReference<BaseActivity> wrf = mActivities.get(i);
            BaseActivity baseActivity = wrf.get();
            if (baseActivity == null || baseActivity == this) {
                mActivities.remove(i);
            }
        }
        if (mActivities.isEmpty()) {
            MiniPlayerHelper.get().exitPictureInPictureMode();
        }
        unregisterActivityLifecycleCallbacks();
        L.d(this, "finish");
    }

    @Override
    protected void onUserLeaveHint() {
        super.onUserLeaveHint();
        L.d(this, "onUserLeaveHint");
        boolean isMayGoIntoBackground = true;
        for (int i = mActivities.size() - 1; i >= 0; i--) {
            WeakReference<BaseActivity> wrf = mActivities.get(i);
            BaseActivity baseActivity = wrf.get();
            if (baseActivity == null || baseActivity.isFinishing()) {
                mActivities.remove(i);
                continue;
            }
            if (baseActivity == this) {
                continue;
            }
            if (baseActivity.mResume) {
                isMayGoIntoBackground = false;
                break;
            }
        }
        if (isMayGoIntoBackground) {
            Log.i("BaseActivity", "It looks like go into the background.");
            notifyGoIntoBackground();
        }
    }

    @Override
    public boolean enterPictureInPictureMode(@NonNull PictureInPictureParams params) {
        MiniPlayerHelper.get().enterPictureInPictureMode();
        return super.enterPictureInPictureMode(params);
    }

    private Application.ActivityLifecycleCallbacks mActivityLifecycleCallbacks;

    private void registerActivityLifecycleCallbacks() {
        if (mActivityLifecycleCallbacks == null) {
            mActivityLifecycleCallbacks = new Application.ActivityLifecycleCallbacks() {
                @Override
                public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {

                }

                @Override
                public void onActivityStarted(@NonNull Activity activity) {

                }

                @Override
                public void onActivityResumed(@NonNull Activity activity) {
                    if (BaseActivity.this != activity) {
                        activity.startActivity(new Intent(activity, BaseActivity.this.getClass()));
                    }
                }

                @Override
                public void onActivityPaused(@NonNull Activity activity) {

                }

                @Override
                public void onActivityStopped(@NonNull Activity activity) {

                }

                @Override
                public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

                }

                @Override
                public void onActivityDestroyed(@NonNull Activity activity) {

                }
            };
        }
        getApplication().registerActivityLifecycleCallbacks(mActivityLifecycleCallbacks);
    }

    private void unregisterActivityLifecycleCallbacks() {
        if (mActivityLifecycleCallbacks != null) {
            getApplication().unregisterActivityLifecycleCallbacks(mActivityLifecycleCallbacks);
            mActivityLifecycleCallbacks = null;
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, @NonNull Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        if (isInPictureInPictureMode) {
            MiniPlayerHelper.get().enterPictureInPictureMode();
            registerActivityLifecycleCallbacks();
        } else {
            unregisterActivityLifecycleCallbacks();
            MiniPlayerHelper.get().exitPictureInPictureMode();
            if (getLifecycle().getCurrentState() == Lifecycle.State.CREATED) {
                // user click on close button of picture in picture window
                finish();
            }
        }
        notifyPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
    }

}
