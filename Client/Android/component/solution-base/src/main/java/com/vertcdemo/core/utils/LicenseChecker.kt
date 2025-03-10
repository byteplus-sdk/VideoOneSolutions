// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.core.utils

import android.content.Context
import android.net.Uri
import android.util.Base64
import android.util.Log
import com.google.gson.JsonSyntaxException
import com.google.gson.annotations.SerializedName
import com.vertcdemo.base.R
import com.vertcdemo.core.common.GsonUtils
import java.io.FileNotFoundException
import java.io.InputStream
import java.io.InputStreamReader

class LicenseResult(
    @JvmField
    val message: Int = 0,
) {
    fun isOk() = this == ok
    fun isEmpty() = this == empty

    companion object {
        @JvmField
        val empty = LicenseResult()

        @JvmField
        val ok = LicenseResult()
    }
}

object LicenseChecker {
    private const val TAG = "LicenseChecker"

    @JvmStatic
    fun check(context: Context, licenseUri: String): LicenseResult {
        Log.w(TAG, "License Uri=$licenseUri")
        val uri = Uri.parse(licenseUri)
        if (uri.path.isNullOrEmpty()) {
            Log.d(TAG, "License Error: Uri path is null or empty")
            return LicenseResult(R.string.solution_license_uri_path_null)
        }
        return if (uri.scheme == "assets") {
            checkAssets(context, uri)
        } else {
            Log.d(
                TAG,
                "License Error: schema '${uri.scheme}://' is unsupported, only support 'assets://'"
            )
            LicenseResult(R.string.solution_license_uri_schema_unsupported)
        }
    }

    private fun checkAssets(context: Context, uri: Uri): LicenseResult {
        val path = uri.path!!
        val assetPath = if (path.startsWith('/')) {
            // Assets is relative path should remove leading '/'
            path.substring(1)
        } else {
            path
        }
        return try {
            context.assets.open(assetPath).use {
                checkPackageName(context, it)
            }
        } catch (e: FileNotFoundException) {
            Log.d(TAG, "License Error: license file not found.\n")
            Log.d(TAG, "Please check PROJECT file : 'app/src/main/assets/$assetPath'")
            LicenseResult(R.string.solution_license_assets_not_exists)
        } catch (e: Exception) {
            Log.d(TAG, "License Error: unknown", e)
            LicenseResult(R.string.solution_license_unknown_error)
        }
    }

    private fun checkPackageName(context: Context, input: InputStream): LicenseResult {
        try {
            val license = GsonUtils.gson()
                .fromJson(InputStreamReader(input), License::class.java)
            if (license?.content == null) {
                return LicenseResult(R.string.solution_license_parse_error)
            }
            val decoded = String(Base64.decode(license.content, Base64.NO_WRAP))
            val content = GsonUtils.gson().fromJson(
                decoded,
                LicenseContent::class.java
            )
            return if (context.packageName.equals(content?.packageName)) {
                Log.w(TAG, "License Ok")
                LicenseResult.ok
            } else {
                Log.w(TAG, "License Error: PackageName mismatch!")
                Log.w(TAG, " Expect: '${context.packageName}'")
                Log.w(TAG, " But   : '${content?.packageName}'")
                LicenseResult(R.string.solution_license_package_name_not_match)
            }
        } catch (e: JsonSyntaxException) {
            Log.w(TAG, "License Error: License parse failed", e)
            return LicenseResult(R.string.solution_license_parse_error)
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "License Error: License parse failed", e)
            return LicenseResult(R.string.solution_license_parse_error)
        }
    }
}

private class License(
    @SerializedName("Content")
    val content: String?
)

private class LicenseContent(
    @SerializedName("PackageName")
    val packageName: String?
)
