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

package rtc_openapi

import (
	"net/http"
	"net/url"
	"time"

	"github.com/byteplus-sdk/byteplus-sdk-golang/base"
)

const (
	DefaultRegion          = base.RegionApSingapore
	ServiceVersion20201201 = "2020-12-01"
	ServiceName            = "rtc"
	ServiceHost            = "open.byteplusapi.com"
)

const (
	sendUnicast     = "SendUnicast"     //Point-to-point messages outside the room
	sendRoomUnicast = "SendRoomUnicast" //Peer to peer messages in the room
	sendBroadcast   = "SendBroadcast"   //Broadcast messages in the room
)

var serviceInfo *base.ServiceInfo
var defaultApiInfoList map[string]*base.ApiInfo

type RTC struct {
	*base.Client
}

func NewInstance() *RTC {
	instance := &RTC{}
	instance.Client = base.NewClient(GetServiceInfo(), GetDefaultApiInfoList())
	return instance
}

func GetServiceInfo() *base.ServiceInfo {
	if serviceInfo == nil {
		serviceInfo = &base.ServiceInfo{
			Timeout: 5 * time.Second,
			Host:    GetServiceHost(),
			Header: http.Header{
				"Accept": []string{"application/json"},
			},
			Credentials: base.Credentials{Region: GetDefaultRegion(), Service: ServiceName},
		}
		return serviceInfo
	}
	return serviceInfo
}

func GetDefaultApiInfoList() map[string]*base.ApiInfo {
	if defaultApiInfoList == nil {
		defaultApiInfoList = map[string]*base.ApiInfo{
			sendUnicast: {
				Method: http.MethodPost,
				Path:   "/",
				Query: url.Values{
					"Action":  []string{sendUnicast},
					"Version": []string{ServiceVersion20201201},
				},
			},
			sendRoomUnicast: {
				Method: http.MethodPost,
				Path:   "/",
				Query: url.Values{
					"Action":  []string{sendRoomUnicast},
					"Version": []string{ServiceVersion20201201},
				},
			},
			sendBroadcast: {
				Method: http.MethodPost,
				Path:   "/",
				Query: url.Values{
					"Action":  []string{sendBroadcast},
					"Version": []string{ServiceVersion20201201},
				},
			},
		}
		return defaultApiInfoList
	}
	return defaultApiInfoList
}

func GetServiceHost() string {
	return ServiceHost
}

func GetDefaultRegion() string {
	return DefaultRegion
}
