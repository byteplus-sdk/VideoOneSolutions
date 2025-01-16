// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.player.volcengine;

import android.view.ViewGroup;

import com.ss.ttvideoengine.debugtool2.DebugTool;

public class VolcDebugTools {

    // 添加展示 debug 信息的布局，debug 信息页面撑满 containerView
    // 需要在调用 Engine 播放之前设置，
    // 设置布局后，Debug 工具会监听哪个 Engine 实例调用了 play，并将相关信息显示到布局。
    public static void setContainerView(ViewGroup containerView) {
        DebugTool.release();
        DebugTool.setContainerView(containerView);
    }

    // 完成 Debug 工具使用时，您可调用release()方法释放资源
    public static void release() {
        DebugTool.release();
    }
}
