// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vodlive.recommend

import android.content.Intent
import android.os.Bundle
import com.byteplus.vodlive.live.room.RTCManager
import com.byteplus.vodlive.utils.ErrorCodes
import com.vertcdemo.core.http.AppInfoManager
import com.vertcdemo.core.http.Callback
import com.vertcdemo.core.http.bean.RTCAppInfo
import com.vertcdemo.core.net.HttpException
import com.vertcdemo.core.ui.SolutionLoadingActivity
import com.vertcdemo.ui.CenteredToast

class RecommendEntryActivity : SolutionLoadingActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        AppInfoManager.requestInfo("livefeed", object : Callback<RTCAppInfo> {
            override fun onResponse(data: RTCAppInfo?) {
                if (isFinishing) {
                    return
                }

                if (data == null || data.isInvalid) {
                    onFailure(HttpException.unknown("Invalid RTCAppInfo response."))
                }
                RTCManager.rtcAppInfo = data
                startActivity(Intent(this@RecommendEntryActivity, RecommendActivity::class.java))
                finish()
            }

            override fun onFailure(e: HttpException) {
                if (isFinishing) {
                    return
                }

                CenteredToast.show(ErrorCodes.prettyMessage(e))
                finish()
            }
        })
    }
}