package com.vertcdemo.core.net

import java.io.IOException

class HttpException(
    val code: Int,
    message: String?,
    cause: Throwable? = null
) : IOException(message, cause) {

    override fun toString(): String = "HttpException{code=$code, message='$message'}"

    companion object {
        const val ERROR_CODE_TOKEN_EMPTY = 451
        const val ERROR_CODE_TOKEN_EXPIRED = 450

        // Undefined
        const val ERROR_CODE_UNKNOWN = -1

        @JvmStatic
        fun of(t: Throwable?): HttpException = when (t) {
            is HttpException -> t
            else -> HttpException(ERROR_CODE_UNKNOWN, t?.message, t)
        }

        @JvmStatic
        fun unknown(msg: String? = null): HttpException = HttpException(ERROR_CODE_UNKNOWN, msg)
    }
}