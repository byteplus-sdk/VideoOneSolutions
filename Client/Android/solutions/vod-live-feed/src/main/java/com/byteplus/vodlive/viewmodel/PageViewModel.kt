package com.byteplus.vodlive.viewmodel

import androidx.lifecycle.ViewModel


open class PageViewModel : ViewModel() {
    protected var loading = false
    protected var hasMore = true

    var pageIndex = -1
        protected set

    val canLoadMore: Boolean
        get() = !loading && hasMore
}