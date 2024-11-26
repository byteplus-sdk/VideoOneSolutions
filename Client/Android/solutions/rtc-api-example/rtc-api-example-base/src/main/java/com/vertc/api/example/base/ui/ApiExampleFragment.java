package com.vertc.api.example.base.ui;


import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


public class ApiExampleFragment extends Fragment {
    private static final String TAG = "ApiExampleFragment";

    public static final String RTC_API_EXAMPLE_CATEGORY = "rtc.intent.category.RTC_API_EXAMPLE";

    public ApiExampleFragment() {
        super(R.layout.fragment_api_example);
    }

    public ApiExampleFragment(@LayoutRes int contentLayoutId) {
        super(contentLayoutId);
    }

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
        requestPermission();
    }

    protected void openExample(Context context, Class<?> targetClazz) {
        context.startActivity(new Intent(context, targetClazz));
    }


    private void requestPermission() {
        List<String> requiredPermission = new ArrayList<>(Arrays.asList(
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.CAMERA
        ));

        Context context = requireContext();

        Iterator<String> iterator = requiredPermission.iterator();
        while (iterator.hasNext()) {
            String permission = iterator.next();
            if (ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED) {
                iterator.remove();
            }
        }

        if (requiredPermission.isEmpty()) {
            // All required permissions granted
            Log.d(TAG, "All required permissions are granted");
        } else {
            launcher.launch(requiredPermission.toArray(new String[0]));
        }
    }

    private final ActivityResultLauncher<String[]> launcher =
            registerForActivityResult(new ActivityResultContracts.RequestMultiplePermissions(), results -> {
                boolean allPermissionsGranted = true;
                for (Map.Entry<String, Boolean> entry : results.entrySet()) {
                    if (entry.getValue() != Boolean.TRUE) {
                        allPermissionsGranted = false;
                        Log.d(TAG, String.format("Permission: '%1$s' is not granted!", entry.getKey()));
                    }
                }

                if (allPermissionsGranted) {
                    Log.d(TAG, "All required permissions are granted");
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
}
