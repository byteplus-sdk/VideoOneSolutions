package com.vertcdemo.app

import androidx.annotation.LayoutRes
import androidx.fragment.app.Fragment

open class VersionFragment : Fragment {
    constructor() : super()
    constructor(@LayoutRes contentLayoutId: Int) : super(contentLayoutId)
}
