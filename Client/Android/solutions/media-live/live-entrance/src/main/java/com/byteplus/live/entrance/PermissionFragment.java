// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.entrance;

import android.content.Context;
import android.content.pm.PackageManager;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Queue;

public class PermissionFragment extends Fragment {
    public PermissionFragment() {
        super();
    }

    public PermissionFragment(@LayoutRes int contentLayoutId) {
        super(contentLayoutId);
    }

    final Queue<PendingAction> mActions = new ArrayDeque<>();

    final ActivityResultLauncher<String[]> requestPermissionsLauncher = registerForActivityResult(
            new ActivityResultContracts.RequestMultiplePermissions(),
            results -> {
                PendingAction action = mActions.poll();
                if (action != null) {
                    boolean granted = true;
                    for (Map.Entry<String, Boolean> entry : results.entrySet()) {
                        if (entry.getValue() != Boolean.TRUE) {
                            granted = false;
                            break;
                        }
                    }

                    if (granted) {
                        if (action.onGranted != null) {
                            action.onGranted.run();
                        }
                    } else {
                        if (action.onDenied != null) {
                            action.onDenied.run();
                        }
                    }
                }
            });

    protected void askForPermission(List<String> permissions, @Nullable Runnable onGranted) {
        askForPermission(permissions, onGranted, null);
    }

    protected void askForPermission(List<String> permissions, @Nullable Runnable onGranted, @Nullable Runnable onDenied) {
        List<String> pendingPermissions = new ArrayList<>(permissions);
        Iterator<String> iterator = pendingPermissions.iterator();
        Context context = requireContext();

        while (iterator.hasNext()) {
            String permission = iterator.next();
            if (ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED) {
                iterator.remove();
            }
        }

        if (pendingPermissions.isEmpty()) { // All permission Granted
            if (onGranted != null) {
                onGranted.run();
            }
        } else {
            if (onGranted != null || onDenied != null) {
                mActions.add(PendingAction.create(onGranted, onDenied));
            }

            requestPermissionsLauncher.launch(pendingPermissions.toArray(new String[0]));
        }
    }

    static class PendingAction {
        @Nullable
        final Runnable onDenied;
        @Nullable
        final Runnable onGranted;

        private PendingAction(@Nullable Runnable onGranted, @Nullable Runnable onDenied) {
            this.onGranted = onGranted;
            this.onDenied = onDenied;
        }

        static PendingAction create(@Nullable Runnable onGranted, @Nullable Runnable onDenied) {
            return new PendingAction(onGranted, onDenied);
        }
    }
}
