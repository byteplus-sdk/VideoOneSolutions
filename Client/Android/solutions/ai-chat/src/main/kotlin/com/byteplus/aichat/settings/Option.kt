package com.byteplus.aichat.settings

enum class Source {
    USER,
    DEFAULT,
}

class Option<T>(val value: T, source: Source = Source.DEFAULT) {
    val isUserChanged = source == Source.USER
}

val OptionEmpty = Option<String>("")