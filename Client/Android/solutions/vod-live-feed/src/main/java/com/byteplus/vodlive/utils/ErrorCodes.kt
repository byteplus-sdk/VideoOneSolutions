package com.byteplus.vodlive.utils

import com.vertcdemo.core.net.HttpException
import com.vertcdemo.core.utils.ErrorTool

object ErrorCodes {
    fun prettyMessage(e: HttpException): String = ErrorTool.getErrorMessage(e.code, e.message)
}