// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.effect.utils

import android.content.Context
import android.content.SharedPreferences
import android.text.TextUtils
import android.util.Log
import androidx.core.content.edit
import com.vertcdemo.core.utils.AppUtil.applicationContext
import com.vertcdemo.effect.BuildConfig
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

object EffectResource {
    private const val TAG: String = "EffectResource"

    private const val RESOURCE_VERSION: Int = 2

    private const val ASSETS_PATH: String = "resource"

    private val externalResourcesPath: File =
        File(applicationContext.filesDir, "cv_effect_resources")

    val licensePath: String
        get() {
            val filename: String = BuildConfig.CV_LICENSE_FILENAME
            if (TextUtils.isEmpty(filename)) {
                Log.e(TAG, "cv licence filename not set!!!")
            }
            return File(externalResourcesPath, "LicenseBag.bundle/$filename").absolutePath
        }

    val modelPath: String
        get() = File(externalResourcesPath, "ModelResource.bundle").absolutePath

    fun getBeautyPathByName(name: String): String {
        return File(externalResourcesPath, "ComposeMakeup.bundle/ComposeMakeup/$name").absolutePath
    }

    fun getStickerPathByName(name: String): String {
        return File(externalResourcesPath, "StickerResource.bundle/stickers/$name").absolutePath
    }

    fun getFilterPathByName(name: String): String {
        return File(externalResourcesPath, "FilterResource.bundle/Filter/$name").absolutePath
    }

    fun uncompressResources() {
        checkResourceVersion(applicationContext) { uncompressResources(applicationContext) }
    }

    private fun uncompressResources(context: Context) {
        val licensePath = File(externalResourcesPath, "LicenseBag.bundle")
        removeFile(licensePath)
        copyAssetFolder(context, "$ASSETS_PATH/LicenseBag.bundle", licensePath.absolutePath)

        val modelPath = File(externalResourcesPath, "ModelResource.bundle")
        removeFile(modelPath)
        copyAssetFolder(context, "$ASSETS_PATH/ModelResource.bundle", modelPath.absolutePath)

        val stickerPath = File(externalResourcesPath, "StickerResource.bundle")
        removeFile(stickerPath)
        copyAssetFolder(context, "$ASSETS_PATH/StickerResource.bundle", stickerPath.absolutePath)

        val filterPath = File(externalResourcesPath, "FilterResource.bundle")
        removeFile(filterPath)
        copyAssetFolder(context, "$ASSETS_PATH/FilterResource.bundle", filterPath.absolutePath)

        val composerPath = File(externalResourcesPath, "ComposeMakeup.bundle")
        removeFile(composerPath)
        copyAssetFolder(context, "$ASSETS_PATH/ComposeMakeup.bundle", composerPath.absolutePath)
    }

    private fun removeFile(file: File) {
        if (file.isFile) {
            file.delete()
            return
        }
        if (file.isDirectory) {
            val childFile: Array<File>? = file.listFiles()
            if (childFile.isNullOrEmpty()) {
                file.delete()
                return
            }
            for (f: File in childFile) {
                removeFile(f)
            }
            file.delete()
        }
    }


    private const val PREFS_NAME: String = "solution_data_manager"
    private const val KEY_VERSION: String = "cv_effect_resources_version"

    private fun checkResourceVersion(context: Context, command: Runnable) {
        val prefs: SharedPreferences =
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val oldVersion: Int = prefs.getInt(KEY_VERSION, 0)
        if (oldVersion != RESOURCE_VERSION) {
            command.run()
            prefs.edit {
                putInt(KEY_VERSION, RESOURCE_VERSION)
            }
        }
    }

    private fun copyAssetFolder(context: Context, srcName: String, dstName: String): Boolean {
        try {
            val fileList: Array<out String> = context.assets.list(srcName) ?: return false

            if (fileList.isEmpty()) {
                return copyAssetFile(context, srcName, dstName)
            } else {
                val file = File(dstName)
                var result = file.mkdirs()
                for (filename: String in fileList) {
                    result = result and copyAssetFolder(
                        context, "$srcName/$filename", "$dstName/$filename"
                    )
                }
                return result
            }
        } catch (e: IOException) {
            Log.d(TAG, "copyAssetFolder: ", e)
            return false
        }
    }

    private fun copyAssetFile(context: Context, srcName: String, dstName: String): Boolean {
        try {
            context.assets.open(srcName).use { inStream ->
                FileOutputStream(dstName).use { outStream ->
                    inStream.copyTo(outStream)
                    return true
                }
            }
        } catch (e: IOException) {
            Log.d(TAG, "copyAssetFile: ", e)
            return false
        }
    }
}
