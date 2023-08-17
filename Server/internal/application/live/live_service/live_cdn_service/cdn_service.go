/*
 * Copyright 2023 CloudWeGo Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package live_cdn_service

import (
	"context"
	"crypto/md5"
	"encoding/hex"
	"strconv"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
)

const (
	resolution480    = "480"
	resolution540    = "540"
	resolution720    = "720"
	resolution1080   = "1080"
	resolutionOrigin = "origin"
)

const (
	postfix480  = "_ld"
	postfix540  = "_sd"
	postfix720  = "_hd"
	postfix1080 = "_uhd"
)

func GenPushUrl(ctx context.Context, appID, streamID string) string {
	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, appID)

	volcTime := strconv.FormatInt(time.Now().Add(12*time.Hour).Unix(), 10)
	hasher := md5.New()

	hasher.Write([]byte("/" + appInfo.LiveAppName + "/" + streamID + appInfo.LiveStreamKey + volcTime))
	volcSecret := hex.EncodeToString(hasher.Sum(nil))

	return appInfo.LivePushDomain + "/" + appInfo.LiveAppName + "/" + streamID + "?expire=" + volcTime + "&sign=" + volcSecret
}

func GenPullUrl(ctx context.Context, appID, streamID string) map[string]string {
	appInfoService := login_service.GetAppInfoService()
	appInfo, _ := appInfoService.ReadAppInfoByAppId(ctx, appID)
	res := make(map[string]string)
	res[resolutionOrigin] = appInfo.LivePullDomain + "/" + appInfo.LiveAppName + "/" + streamID + ".flv"
	res[resolution480] = appInfo.LivePullDomain + "/" + appInfo.LiveAppName + "/" + streamID + postfix480 + ".flv"
	res[resolution540] = appInfo.LivePullDomain + "/" + appInfo.LiveAppName + "/" + streamID + postfix540 + ".flv"
	res[resolution720] = appInfo.LivePullDomain + "/" + appInfo.LiveAppName + "/" + streamID + postfix720 + ".flv"
	res[resolution1080] = appInfo.LivePullDomain + "/" + appInfo.LiveAppName + "/" + streamID + postfix1080 + ".flv"

	return res
}
