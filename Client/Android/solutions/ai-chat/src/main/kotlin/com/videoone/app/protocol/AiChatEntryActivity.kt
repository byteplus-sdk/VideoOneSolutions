package com.videoone.app.protocol

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.lifecycle.lifecycleScope
import com.byteplus.aichat.AiChatActivity
import com.vertcdemo.core.http.AppInfoManager
import com.vertcdemo.core.http.Callback
import com.vertcdemo.core.http.bean.RTCAppInfo
import com.vertcdemo.core.net.HttpException
import com.vertcdemo.core.ui.SolutionLoadingActivity
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine

private const val TAG = "AiChat"

class AiChatEntryActivity : SolutionLoadingActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        lifecycleScope.launch {
            try {
                val appInfo = startup()

                startActivity(Intent(this@AiChatEntryActivity, AiChatActivity::class.java).apply {
                    putExtra(RTCAppInfo.KEY_APP_INFO, appInfo)
                })
            } catch (e: Exception) {
                if (e is HttpException) {
                    Log.d(TAG, "startup failed: $e")
                }
            }

            finish()
        }
    }

    suspend fun startup(): RTCAppInfo = suspendCancellableCoroutine { cont ->
        AppInfoManager.requestInfo("live", object : Callback<RTCAppInfo> {
            override fun onResponse(data: RTCAppInfo?) {
                if (data == null || data.isInvalid) {
                    cont.resumeWith(Result.failure(HttpException.Companion.unknown("Invalid RTCAppInfo response.")))
                } else {
                    cont.resumeWith(Result.success(data))
                }
            }

            override fun onFailure(e: HttpException) {
                cont.resumeWith(Result.failure(e))
            }
        })
    }
}