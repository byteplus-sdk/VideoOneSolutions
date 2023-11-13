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

package rtc_openapi

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/byteplus-sdk/byteplus-sdk-golang/base"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

const (
	FromServer = "server"
)

func (client *RTC) RtsSendUnicast(ctx context.Context, appID, userID, message string) error {
	logs.CtxInfo(ctx, "ak,sk,rts_host,region:%s,%s,%s,%s", client.ServiceInfo.Credentials.AccessKeyID, client.ServiceInfo.Credentials.SecretAccessKey, client.ServiceInfo.Host, client.ServiceInfo.Credentials.Region)
	logs.CtxInfo(ctx, "sendUnicast,appID:%s,userID:%s,message:%s", appID, userID, message)

	param := &sendUnicastParam{
		AppID:   appID,
		From:    FromServer,
		To:      userID,
		Binary:  false,
		Message: message,
	}
	p, _ := json.Marshal(param)
	resp, code, err := client.Json(sendUnicast, nil, string(p))
	if err != nil || code != 200 {
		if err == nil {
			err = errors.New("net error")
		}
		logs.CtxError(ctx, "sendUnicast failed,appID:%s,userID:%s,error:%s", appID, userID, err)
		return errors.New(err.Error())
	}

	r := &base.CommonResponse{}

	if err = json.Unmarshal(resp, r); err != nil {
		logs.CtxInfo(ctx, "json unmarshal common response failed,resp:%s,error:%s", string(resp), err)
		return err
	}

	logs.CtxInfo(ctx, "sendUnicast response: %#v", r)
	if r.Result == nil {
		return errors.New(r.ResponseMetadata.Error.Message)
	}
	return nil
}

func (client *RTC) RtsSendRoomUnicast(ctx context.Context, appID, roomID, userID, message string) error {
	logs.CtxInfo(ctx, "sendRoomUnicast,appID:%s,roomID:%s,userID:%s,message:%s", appID, roomID, userID, message)

	param := &sendRoomUnicastParam{
		AppID:   appID,
		RoomID:  roomID,
		From:    FromServer,
		To:      userID,
		Binary:  false,
		Message: message,
	}
	p, _ := json.Marshal(param)
	resp, code, err := client.Json(sendRoomUnicast, nil, string(p))
	if err != nil || code != 200 {
		if err == nil {
			err = errors.New("net error")
		}
		logs.CtxError(ctx, "sendRoomUnicast failed,appID:%s,roomID:%s,userID:%s,error:%s", appID, roomID, userID, err)
		return errors.New(err.Error())
	}

	r := &base.CommonResponse{}

	if err = json.Unmarshal(resp, r); err != nil {
		logs.CtxInfo(ctx, "json unmarshal common response failed,resp:%s,error:%s", string(resp), err)
		return err
	}

	logs.CtxInfo(ctx, "sendRoomUnicast response: %#v", r)
	if r.Result == nil {
		return errors.New(r.ResponseMetadata.Error.Message)
	}
	return nil
}

func (client *RTC) RtsSendBroadcast(ctx context.Context, appID, roomID, message string) error {
	logs.CtxInfo(ctx, "sendRoomBroadcast,appID:%s,roomID:%s,message:%s", appID, roomID, message)

	param := &sendBroadcastParam{
		AppID:   appID,
		RoomID:  roomID,
		From:    FromServer,
		Binary:  false,
		Message: message,
	}
	p, _ := json.Marshal(param)
	resp, code, err := client.Json(sendBroadcast, nil, string(p))
	if err != nil || code != 200 {
		if err == nil {
			err = errors.New("net error")
		}
		logs.CtxError(ctx, "sendRoomBroadcast failed,appID:%s,roomID:%s,error:%s", appID, roomID, err)
		return errors.New(err.Error())
	}

	r := &base.CommonResponse{}

	if err = json.Unmarshal(resp, r); err != nil {
		logs.CtxInfo(ctx, "json unmarshal common response failed,resp:%s,error:%s", string(resp), err)
		return err
	}

	if r.Result == nil {
		return errors.New(r.ResponseMetadata.Error.Message)
	}
	return nil
}
