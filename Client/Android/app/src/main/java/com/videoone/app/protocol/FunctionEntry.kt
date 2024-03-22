// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.videoone.app.protocol

import android.util.Log

private const val TAG = "FunctionEntry"

class FunctionEntry(
    entry: IFunctionEntry
) : IFunctionEntry by entry {
    companion object {
        /**
         * @see FunctionVideoPlayback
         * @see FunctionPlaylist
         * @see FunctionSmartSubtitles
         * @see FunctionPreventRecording
         */
        private val entryNames = listOf(
            "com.videoone.app.protocol.FunctionVideoPlayback",
            "com.videoone.app.protocol.FunctionPlaylist",
            "com.videoone.app.protocol.FunctionSmartSubtitles",
            "com.videoone.app.protocol.FunctionPreventRecording",
        )

        val entries: List<FunctionEntry> by lazy {
            entryNames.mapNotNull { entryClass ->
                try {
                    val clazz = Class.forName(entryClass)
                    val instance = clazz.newInstance() as IFunctionEntry
                    FunctionEntry(instance)
                } catch (e: ReflectiveOperationException) {
                    Log.w(TAG, "Entry not found: $entryClass")
                    null
                }
            }
        }
    }
}