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

package public

const (
	BizIDLive       = "live"
	BizIDKtv        = "ktv"
	BizIDAPIExample = "rtc_api_example"
	BizIDOwc        = "owc"
)

const (
	BidLive       = "BytePlusRTC_bid_live"
	BidKTV        = "BytePlusRTC_bid_ktv"
	BidAPIExample = "BytePlusRTC_bid_api_example"
	BidOwc        = "BytePlusRTC_bid_owc"
)

const (
	CtxSourceApi = "SourceApi"
)

var BidMap = map[string]string{
	BizIDLive:       BidLive,
	BizIDKtv:        BidKTV,
	BizIDAPIExample: BidAPIExample,
	BizIDOwc:        BidOwc,
}

const VideoCommentNum = 10

const HeaderLoginToken = "X-Login-Token"
