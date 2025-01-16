// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.widgets.layer;

import com.byteplus.vod.scenekit.ui.video.layer.TitleBarLayer;


public class DramaTitleBarLayer extends TitleBarLayer {

    public interface ITitleResolve {
        String resolveTitle();
    }

    final ITitleResolve titleResolve;

    public DramaTitleBarLayer(ITitleResolve titleResolve) {
        this.titleResolve = titleResolve;
    }

    @Override
    public String tag() {
        return "drama_title_bar";
    }

    @Override
    protected String resolveTitle() {
        return titleResolve == null ? super.resolveTitle() : titleResolve.resolveTitle();
    }
}
