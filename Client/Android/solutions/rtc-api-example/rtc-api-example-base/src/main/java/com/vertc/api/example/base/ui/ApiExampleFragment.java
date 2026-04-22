package com.vertc.api.example.base.ui;


import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.vertc.api.example.base.ExampleCategory;
import com.vertc.api.example.base.R;
import com.vertc.api.example.base.annotation.ApiExample;
import com.vertc.api.example.base.bean.ExampleInfo;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Queue;


public class ApiExampleFragment extends Fragment {
    private static final String TAG = "ApiExampleFragment";

    public static final String RTC_API_EXAMPLE_CATEGORY = "rtc.intent.category.RTC_API_EXAMPLE";

    public ApiExampleFragment() {
        super(R.layout.fragment_api_example);
    }

    public ApiExampleFragment(@LayoutRes int contentLayoutId) {
        super(contentLayoutId);
    }

    final Queue<PendingAction> mActions = new ArrayDeque<>();

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        Context context = requireContext();

        ViewGroup listview = view.findViewById(R.id.list);

        LayoutInflater inflater = LayoutInflater.from(context);

        List<ExampleInfo> items = buildExampleList(context);

        ExampleCategory category = null;

        ViewGroup categoryItems = null;

        for (ExampleInfo info : items) {
            if (category == null || category != info.category) {
                category = info.category;

                View categoryLayout = inflater.inflate(R.layout.layout_api_example_category, listview, false);
                TextView categoryTitle = categoryLayout.findViewById(R.id.title);
                categoryTitle.setText(category.title);

                categoryItems = categoryLayout.findViewById(R.id.items);

                listview.addView(categoryLayout);
            }

            View itemView = inflater.inflate(R.layout.layout_api_example_item,
                    categoryItems, false);
            TextView itemText = itemView.findViewById(R.id.title);
            itemText.setText(info.label);
            ImageView itemImg = itemView.findViewById(R.id.icon);
            itemImg.setImageDrawable(info.icon);
            itemImg.setVisibility(View.VISIBLE);
            itemView.setOnClickListener(v -> {
                Class<?> targetClazz = info.getAction();
                openExample(context, targetClazz);
            });

            categoryItems.addView(itemView);
        }
    }

    protected void openExample(Context context, Class<?> targetClazz) {
        askForPermission(
                Arrays.asList(Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO),
                () ->  context.startActivity(new Intent(context, targetClazz)),
                () -> Toast.makeText(context, "Missing required permission(s)", Toast.LENGTH_LONG).show()
        );
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

    private static List<ExampleInfo> buildExampleList(Context context) {
        final PackageManager pm = context.getPackageManager();

        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.setPackage(context.getPackageName());
        intent.addCategory(RTC_API_EXAMPLE_CATEGORY);

        List<ResolveInfo> resolveInfos = context.getPackageManager().queryIntentActivities(intent, 0);

        List<ExampleInfo> examples = new ArrayList<>();
        for (ResolveInfo resolveInfo : resolveInfos) {
            ActivityInfo activityInfo = resolveInfo.activityInfo;
            try {
                Class<?> clazz = Class.forName(activityInfo.name);
                if (clazz.isAnnotationPresent(ApiExample.class)) {
                    CharSequence label = activityInfo.loadLabel(pm);
                    Drawable icon = activityInfo.loadIcon(pm);
                    ApiExample annotation = clazz.getAnnotation(ApiExample.class);
                    assert annotation != null;
                    ExampleInfo info = new ExampleInfo(label, icon, clazz, annotation);
                    examples.add(info);
                }
            } catch (ClassNotFoundException e) {
                throw new RuntimeException(e);
            }
        }

        Collections.sort(examples);
        return examples;
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
