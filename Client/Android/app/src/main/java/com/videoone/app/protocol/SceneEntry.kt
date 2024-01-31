// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.videoone.app.protocol

import android.util.Log

private const val TAG = "SceneEntry"


/**
 * @see InteractiveLiveEntry
 *
 * @see PlaybackEditEntry
 */
class SceneEntry(
    entry: ISceneEntry,
) : ISceneEntry by entry {
    companion object {
        private val entryNames = listOf(
            "com.videoone.app.protocol.PlaybackEditEntry",
            "com.videoone.app.protocol.InteractiveLiveEntry"
        )

        val entries: List<SceneEntry> by lazy {
            entryNames.mapNotNull { entryClass ->
                try {
                    val clazz = Class.forName(entryClass)
                    val instance = clazz.newInstance() as ISceneEntry
                    SceneEntry(instance)
                } catch (e: ReflectiveOperationException) {
                    Log.w(TAG, "Entry not found: $entryClass")
                    null
                }
            }
        }
    }
}
