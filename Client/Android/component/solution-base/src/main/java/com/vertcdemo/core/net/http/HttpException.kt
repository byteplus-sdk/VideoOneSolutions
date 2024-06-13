package com.vertcdemo.core.net.http

class HttpException(
    val code: Int,
    val msg: String? = null
) : Exception(msg)