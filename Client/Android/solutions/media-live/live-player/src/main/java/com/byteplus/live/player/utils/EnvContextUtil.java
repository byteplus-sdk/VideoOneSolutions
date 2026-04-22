package com.byteplus.live.player.utils;

import android.content.Context;

import com.pandora.common.env.Env;
import com.pandora.common.env.config.Config;

public final class EnvContextUtil {
        private EnvContextUtil() {
        }

        public static Context getApplicationContext() {
            Config config = Env.getConfig();

            return config == null ? null : config.getApplicationContext();
        }
}
