// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.playerkit.utils;


public enum Scheme {
    HTTP("http"), HTTPS("https"), FILE("file"), ASSETS("assets"), UNKNOWN("");

    private final String scheme;
    private final String uriPrefix;

    Scheme(String scheme) {
        this.scheme = scheme;
        uriPrefix = scheme + "://";
    }

    /**
     * Defines scheme of incoming URI
     *
     * @param uri URI for scheme detection
     * @return Scheme of incoming URI
     */
    public static Scheme ofUri(String uri) {
        if (uri != null) {
            for (Scheme s : values()) {
                if (s.belongsTo(uri)) {
                    return s;
                }
            }
        }
        return UNKNOWN;
    }

    private boolean belongsTo(String uri) {
        return uri.startsWith(uriPrefix);
    }

    /**
     * Appends scheme to incoming path
     */
    public String wrap(String path) {
        return uriPrefix + path;
    }

    /**
     * Removed scheme part ("scheme://") from incoming URI
     */
    public String crop(String uri) {
        if (!belongsTo(uri)) {
            throw new IllegalArgumentException(String.format("URI [%1$s] doesn't have expected scheme [%2$s]", uri, scheme));
        }
        return uri.substring(uriPrefix.length());
    }
}
