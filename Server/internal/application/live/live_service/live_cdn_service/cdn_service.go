/*
 * Copyright (c) 2023 BytePlus Pte. Ltd.
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
	"crypto/md5"
	"encoding/hex"
	"strconv"
	"time"

	"github.com/byteplus/VideoOneServer/internal/pkg/config"
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

func GenPushUrl(streamID string) string {
	expireTime := strconv.FormatInt(time.Now().Add(12*time.Hour).Unix(), 10)
	hasher := md5.New()

	hasher.Write([]byte("/" + config.Configs().LiveAppName + "/" + streamID + config.Configs().LiveStreamKey + expireTime))
	secret := hex.EncodeToString(hasher.Sum(nil))

	return config.Configs().LivePushDomain + "/" + config.Configs().LiveAppName + "/" + streamID + "?expire=" + expireTime + "&sign=" + secret
}

const StreamSuffix = ".flv"

func GenPullUrl(streamID string) map[string]string {
	configs := config.Configs()
	res := make(map[string]string)
	res[resolutionOrigin] = configs.LivePullDomain + "/" + configs.LiveAppName + "/" + streamID + StreamSuffix
	res[resolution480] = configs.LivePullDomain + "/" + configs.LiveAppName + "/" + streamID + postfix480 + StreamSuffix
	res[resolution540] = configs.LivePullDomain + "/" + configs.LiveAppName + "/" + streamID + postfix540 + StreamSuffix
	res[resolution720] = configs.LivePullDomain + "/" + configs.LiveAppName + "/" + streamID + postfix720 + StreamSuffix
	res[resolution1080] = configs.LivePullDomain + "/" + configs.LiveAppName + "/" + streamID + postfix1080 + StreamSuffix

	return res
}
