package com.vertc.api.example.examples.thirdpart.bytebeauty;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import com.vertc.api.example.BuildConfig;
import com.vertc.api.example.utils.ExampleExecutor;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Properties;

/**
 * EffectResourceManager
 * 1. Copy effect resources
 * 2. Manage effect resource paths
 */
public class EffectResourceManager {
    private static final String TAG = "ByteBeauty";

    private static final String MODEL_RESOURCE_VERSION = BuildConfig.CV_MODEL_RESOURCE_VERSION;
    private static final String COMPOSE_MAKEUP_RESOURCE_VERSION = BuildConfig.CV_COMPOSE_MAKEUP_RESOURCE_VERSION;
    private static final String STICKER_RESOURCE_VERSION = BuildConfig.CV_STICKER_RESOURCE_VERSION;
    private static final String FILTER_RESOURCE_VERSION = BuildConfig.CV_FILTER_RESOURCE_VERSION;

    private static final String LICENSE_FILENAME = BuildConfig.CV_LICENSE_FILENAME;

    private final Context context;

    public EffectResourceManager(Context context) {
        this.context = context.getApplicationContext();
    }

    public String getLicensePath() {
        if (TextUtils.isEmpty(LICENSE_FILENAME)) {
            Log.e(TAG, "[EffectResourceManager] cv license filename not set!!!");
        }
        return getExternalResourcePath("resource/cvlab/LicenseBag.bundle/" + LICENSE_FILENAME).getAbsolutePath();
    }

    public String getModelPath() {
        return getExternalResourcePath("resource/cvlab/ModelResource.bundle").getAbsolutePath();
    }

    public String getBeautyPath() {
        return getExternalResourcePath("resource/cvlab/ComposeMakeup.bundle/ComposeMakeup/beauty_Android_lite").getAbsolutePath();
    }

    public String getReshapePath() {
        return getExternalResourcePath("resource/cvlab/ComposeMakeup.bundle/ComposeMakeup/reshape_lite").getAbsolutePath();
    }

    @NonNull
    public ArrayList<String> basicEffectNodePaths() {
        ArrayList<String> items = new ArrayList<>();
        items.add(getBeautyPath());
        items.add(getReshapePath());
        return items;
    }

    public String getEffectPortraitPath() {
        return getStickerPathByName("matting_bg");
    }

    public String getStickerPathByName(String name) {
        return getExternalResourcePath("resource/cvlab/StickerResource.bundle/stickers/" + name).getAbsolutePath();
    }

    public String getFilterPathByName(String name) {
        return getExternalResourcePath("resource/cvlab/FilterResource.bundle/Filter/" + name).getAbsolutePath();
    }

    public void initVideoEffectResource() {
        File licenseBundle = getExternalResourcePath("resource/cvlab/LicenseBag.bundle");
        licenseBundle.deleteOnExit();
        copyAssetFolder(context, "resource/LicenseBag.bundle", licenseBundle);

        Properties properties = new Properties();
        File versionFile = getExternalResourcePath("resource/cvlab/version.properties");
        if (versionFile.exists()) {
            try (InputStream in = new FileInputStream(versionFile)) {
                properties.load(in);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        File modelBundle = getExternalResourcePath("resource/cvlab/ModelResource.bundle");
        if (!MODEL_RESOURCE_VERSION.equals(properties.getProperty("ModelResource", ""))) {
            deleteRecursive(modelBundle);
            copyAssetFolder(context,
                    "resource/ModelResource.bundle",
                    modelBundle);
            properties.put("ModelResource", MODEL_RESOURCE_VERSION);
        }

        File stickerBundle = getExternalResourcePath("resource/cvlab/StickerResource.bundle");
        if (!STICKER_RESOURCE_VERSION.equals(properties.getProperty("StickerResource", ""))) {
            deleteRecursive(stickerBundle);
            copyAssetFolder(context,
                    "resource/StickerResource.bundle",
                    stickerBundle);
            properties.put("StickerResource", STICKER_RESOURCE_VERSION);
        }

        File filterBundle = getExternalResourcePath("resource/cvlab/FilterResource.bundle");
        if (!FILTER_RESOURCE_VERSION.equals(properties.getProperty("FilterResource", ""))) {
            deleteRecursive(filterBundle);
            copyAssetFolder(context,
                    "resource/FilterResource.bundle",
                    filterBundle);
            properties.put("FilterResource", FILTER_RESOURCE_VERSION);
        }

        File composerBundle = getExternalResourcePath("resource/cvlab/ComposeMakeup.bundle");
        if (!COMPOSE_MAKEUP_RESOURCE_VERSION.equals(properties.getProperty("ComposeMakeup", ""))) {
            deleteRecursive(composerBundle);
            copyAssetFolder(context,
                    "resource/ComposeMakeup.bundle",
                    composerBundle);
            properties.put("ComposeMakeup", COMPOSE_MAKEUP_RESOURCE_VERSION);
        }
        File virtualBackground = getExternalResourcePath("resource/background.jpg");
        if (!virtualBackground.exists()) {
            copyAssetFile(context,
                    "background.jpg",
                    virtualBackground);
        }
        try (OutputStream out = new FileOutputStream(versionFile)) {
            properties.store(out, null);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public String getVirtualBackgroundResourcePath() {
        return getExternalResourcePath("resource/background.jpg").getAbsolutePath();
    }

    public void initVideoEffectResource(Runnable next) {
        ExampleExecutor.cached.submit(() -> {
            initVideoEffectResource();
            if (next != null) {
                next.run();
            }
        });
    }

    private File getExternalResourcePath(String path) {
        return new File(context.getExternalFilesDir("byte_beauty"), path);
    }

    public static boolean copyAssetFolder(Context context, String srcName, File dstFile) {
        try {
            boolean result = true;
            String[] fileList = context.getAssets().list(srcName);
            if (fileList == null) return false;

            if (fileList.length == 0) {
                result = copyAssetFile(context, srcName, dstFile);
            } else {
                result = dstFile.mkdirs();
                for (String filename : fileList) {
                    result &= copyAssetFolder(context, srcName + "/" + filename, new File(dstFile, filename));
                }
            }
            return result;
        } catch (IOException e) {
            Log.d(TAG, "[EffectResourceManager] copyAssetFolder: failed", e);
            return false;
        }
    }

    public static boolean copyAssetFile(Context context, String srcName, File dstFile) {
        try (InputStream in = context.getAssets().open(srcName);
             OutputStream out = new FileOutputStream(dstFile)) {
            byte[] buffer = new byte[1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            return true;
        } catch (IOException e) {
            Log.d(TAG, "[EffectResourceManager] copyAssetFile: failed", e);
            return false;
        }
    }

    public static boolean deleteRecursive(File file) {
        if (!file.exists()) {
            return true;
        }
        if (file.isDirectory()) {
            File[] files = file.listFiles();
            if (files != null) {
                for (File f : files) {
                    boolean success = deleteRecursive(f);
                    if (!success) {
                        return false;
                    }
                }
            }
        }
        return file.delete();
    }
}
