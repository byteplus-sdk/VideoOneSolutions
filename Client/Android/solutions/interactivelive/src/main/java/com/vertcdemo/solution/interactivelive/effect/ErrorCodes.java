// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.effect;

import com.ss.bytertc.engine.video.IVideoEffect;

/**
 * Provides human-readable error messages for BEF (ByteDance Effect Framework) and RTC (Real-Time Communication)
 * SDK error codes. These codes are returned by video effect processing APIs in {@link IVideoEffect}.
 *
 * <p>Reference documentation:
 * <ul>
 *   <li><a href="https://docs.byteplus.com/en/docs/byteplus-rtc/docs-70080#IVideoEffect-initcvresource">RTC Video Effect API</a></li>
 *   <li><a href="https://docs.byteplus.com/en/docs/effects/docs-error-code-table">BEF Error Code Table</a></li>
 * </ul>
 *
 * @see IVideoEffect#initCVResource(String, String)
 * @see IVideoEffect#enableVideoEffect()
 */
public final class ErrorCodes {
    public static String str(int code) {
        return switch (code) {
            // BEF defined codes
            case 0 -> "0: BEF_RESULT_SUC";
            case -1 -> "-1: BEF_RESULT_FAIL";
            case -2 -> "-2: BEF_RESULT_FILE_NOT_FIND";
            case -3 -> "-3: BEF_RESULT_INVALID_INTERFACE";
            case -4 -> "-4: BEF_RESULT_FILE_OPEN_FAILED";
            case -5 -> "-5: BEF_RESULT_INVALID_EFFECT_HANDLE";
            case -6 -> "-6: BEF_RESULT_INVALID_EFFECT_MANAGER";
            case -7 -> "-7: BEF_RESULT_INVALID_FEATURE_HANDLE";
            case -8 -> "-8: BEF_RESULT_INVALID_FEATURE";
            case -9 -> "-9: BEF_RESULT_INVALID_RENDER_MANAGER";
            case -11 -> "-11: BEF_RESULT_INVALID_ALGORITHM_RESULT";
            case -12 -> "-12: BEF_RESULT_INVALID_ALG_FACE_RES";
            case -22 -> "-22: BEF_RESULT_ALG_FACE_106_CREATE_FAIL";
            case -23 -> "-23: BEF_RESULT_ALG_FACE_280_CREATE_FAIL";
            case -24 -> "-24: BEF_RESULT_ALG_FACE_PREDICT_FAIL";
            case -26 -> "-26: BEF_RESULT_ALG_HAND_CREATE_FAIL";
            case -27 -> "-27: BEF_RESULT_ALG_HAND_PREDICT_FAIL";
            case -36 -> "-36: BEF_RESULT_INVALID_TEXTURE";
            case -37 -> "-37: BEF_RESULT_INVALID_IMAGE_DATA";
            case -38 -> "-38: BEF_RESULT_INVALID_IMAGE_FORMAT";
            case -39 -> "-39: BEF_RESULT_INVALID_PARAM_TYPE";
            case -40 -> "-40: BEF_RESULT_INVALID_RESOURCE_VERSION";
            case -47 -> "-47: BEF_RESULT_INVALID_PARAM_VALUE";
            case -101 -> "-101: BEF_RESULT_SMASH_E_INTERNAL";
            case -102 -> "-102: BEF_RESULT_SMASH_E_NOT_INITED";
            case -103 -> "-103: BEF_RESULT_SMASH_E_MALLOC";
            case -104 -> "-104: BEF_RESULT_SMASH_E_INVALID_PARAM";
            case -105 -> "-105: BEF_RESULT_SMASH_E_ESPRESSO";
            case -106 -> "-106: BEF_RESULT_SMASH_E_MOBILECV";
            case -107 -> "-107: BEF_RESULT_SMASH_E_INVALID_CONFIG";
            case -108 -> "-108: BEF_RESULT_SMASH_E_INVALID_HANDLE";
            case -109 -> "-109: BEF_RESULT_SMASH_E_INVALID_MODEL";
            case -110 -> "-110: BEF_RESULT_SMASH_E_INVALID_PIXEL_FORMAT";
            case -111 -> "-111: BEF_RESULT_SMASH_E_INVALID_POINT";
            case -112 -> "-112: BEF_RESULT_SMASH_E_REQUIRE_FEATURE_NOT_INIT";
            case -113 -> "-113: BEF_RESULT_SMASH_E_NOT_IMPL";
            case -114 -> "-114: BEF_RESULT_INVALID_LICENSE";
            case -115 -> "-115: BEF_RESULT_NULL_BUNDLEID";
            case -116 -> "-116: BEF_RESULT_LICENSE_STATUS_INVALID";
            case -117 -> "-117: BEF_RESULT_LICENSE_STATUS_EXPIRED";
            case -118 -> "-118: BEF_RESULT_LICENSE_STATUS_NO_FUNC";
            case -119 -> "-119: BEF_RESULT_LICENSE_STATUS_ID_NOT_MATCH";
            case -120 -> "-120: BEF_RESULT_LICENSE_BAG_NULL_PATH";
            case -121 -> "-121: BEF_RESULT_LICENSE_BAG_INVALID_PATH";
            case -122 -> "-122: BEF_RESULT_LICENSE_BAG_TYPE_NOT_MATCH";
            case -123 -> "-123: BEF_RESULT_LICENSE_BAG_INVALID_VERSION";
            case -124 -> "-124: BEF_RESULT_LICENSE_BAG_INVALID_BLOCK_COUNT";
            case -125 -> "-125: BEF_RESULT_LICENSE_BAG_INVALID_BLOCK_LEN";
            case -126 -> "-126: BEF_RESULT_LICENSE_BAG_INCOMPLETE_BLOCK";
            case -127 -> "-127: BEF_RESULT_LICENSE_BAG_UNAUTHORIZED_FUNC";
            case -128 -> "-128: BEF_RESULT_SDK_FUNC_NOT_INCLUDE";
            case -129 -> "-129: BEF_RESULT_LICENSE_BAG_INVALID_SUB_FUNC";
            case -150 -> "-150: BEF_RESULT_GL_ERROR_OCCUR";
            case -151 -> "-151: BEF_RESULT_GL_CONTECT";
            case -152 -> "-152: BEF_RESULT_GL_TEXTURE";

            // RTC defined codes
            case -1000 -> "-1000: The Effects SDK is not integrated.";
            case -1001 -> "-1001: This API is unavailable for your Effects SDK.";
            case -1002 -> "-1002: Your Effects SDK's version is incompatible.";
            default -> "ERROR_UNKNOWN(" + code + ")";
        };
    }
}
