// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.net.http;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.ConnectivityManager.NetworkCallback;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.net.NetworkRequest;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.vertcdemo.core.eventbus.SolutionEventBus;

/**
 * Application network status judgment
 *
 * Reference: https://developer.android.com/reference/android/net/NetworkRequest
 *
 * Need to apply for permissions in AndroidManifest.xml:
 * <uses-permission android:name="android.permission.INTERNET" />
 * <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
 */
public class AppNetworkStatusUtil {

    private static final String TAG = "AppNetworkStatus";

    private static final NetworkCallback sCallback = new NetworkCallback(){

        /**
         * Network connection successful
         */
        @Override
        public void onAvailable(@NonNull Network network) {
            super.onAvailable(network);
            Log.e(TAG, "onAvailable");
            SolutionEventBus.post(new AppNetworkStatusEvent(AppNetworkStatus.CONNECTED));
        }

        /**
         * Network disconnected
         */
        @Override
        public void onLost(@NonNull Network network) {
            super.onLost(network);
            Log.e(TAG, "onLost");
            SolutionEventBus.post(new AppNetworkStatusEvent(AppNetworkStatus.CONNECTED));
        }

        /**
         * The network connection timed out or the network is unreachable
         */
        @Override
        public void onUnavailable() {
            super.onUnavailable();
            Log.e(TAG, "onUnavailable");
            SolutionEventBus.post(new AppNetworkStatusEvent(AppNetworkStatus.CONNECTED));
        }
    };

    /**
     * Register network status monitoring
     * @param context context object, if it is empty, the registration will fail
     */
    public static void registerNetworkCallback(@Nullable Context context) {
        if (context == null) {
            Log.e(TAG, "registerNetworkCallback failed, because app context is null");
            return;
        }
        Context appContext = context.getApplicationContext();
        ConnectivityManager connectivityManager = (ConnectivityManager) appContext.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivityManager != null) {
            Log.e(TAG, "registerNetworkCallback invoke");
            NetworkRequest.Builder builder = new NetworkRequest.Builder();

            NetworkRequest request = builder.addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                    .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                    .addTransportType(NetworkCapabilities.TRANSPORT_CELLULAR)
                    .build();

            connectivityManager.registerNetworkCallback(request, sCallback);
        } else {
            Log.e(TAG, "registerNetworkCallback failed, because ConnectivityManager is null");
        }
    }

    /**
     * Unregister network status monitoring
     * @param context context object, if it is empty, unregistration fails
     */
    public static void unregisterNetworkCallback(@Nullable Context context) {
        if (context == null) {
            Log.e(TAG, "unregisterNetworkCallback failed, because app context is null");
            return;
        }
        Context appContext = context.getApplicationContext();
        ConnectivityManager connectivityManager = (ConnectivityManager) appContext.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivityManager != null) {
            Log.e(TAG, "unregisterNetworkCallback invoke");

            connectivityManager.unregisterNetworkCallback(sCallback);
        } else {
            Log.e(TAG, "unregisterNetworkCallback failed, because ConnectivityManager is null");
        }
    }

    /**
     * Whether the network is connected
     * @param context context object
     * @return true: connected
     */
    public static boolean isConnected(Context context) {
        if (context == null) {
            return false;
        }
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        return activeNetwork != null && activeNetwork.isConnected();
    }
}
