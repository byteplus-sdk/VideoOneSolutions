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

package response

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
)

type CommonResponse struct {
	MessageType string      `json:"message_type"`
	Code        int         `json:"code"`
	RequestID   string      `json:"request_id"`
	Message     string      `json:"message"`
	Timestamp   int64       `json:"timestamp"`
	Response    interface{} `json:"response"`
}

func newCommonResponse(code int, message, requestID string, response interface{}) string {
	c := &CommonResponse{
		MessageType: "return",
		RequestID:   requestID,
		Code:        code,
		Message:     message,
		Timestamp:   time.Now().UnixNano(),
		Response:    response,
	}
	resByte, err := json.Marshal(c)
	if err != nil {
		logs.Warn("json marshal error, err: %v", err)
	}
	return string(resByte)
}

func NewCommonResponse(ctx context.Context, requestID string, response interface{}, err error) string {
	if err == nil {
		return newCommonResponse(200, "ok", requestID, response)
	}
	defer util.CheckPanic()
	logs.CtxError(ctx, "find unknown err:%s", err)
	if cerr, ok := err.(*custom_error.CustomError); ok {
		return newCommonResponse(cerr.Code(), cerr.Error(), requestID, nil)
	}

	logs.CtxError(ctx, "new response failed,requestID:%s,response:%#v,err:%s", requestID, response, err)
	return ""
}

type VodCommonResponse struct {
	CommonResponse
	ResponseMetadata *ResponseMetadata `json:"responseMetadata,omitempty"`
}

func NewVodCommonResponse(ctx context.Context, requestID string, response interface{}, err error) string {
	if err == nil {
		return newVodCommonResponse(http.StatusOK, "ok", requestID, response)
	}
	defer util.CheckPanic()
	if cerr, ok := err.(*custom_error.CustomError); ok {
		return newVodCommonResponse(cerr.Code(), cerr.Error(), requestID, nil)
	}

	logs.CtxError(ctx, "request failed, requestID:%s,response:%#v,err:%s", requestID, response, err)
	return ""
}

func newVodCommonResponse(code int, message, requestID string, response interface{}) string {
	c := &VodCommonResponse{
		CommonResponse: CommonResponse{
			MessageType: "return",
			RequestID:   requestID,
			Code:        code,
			Message:     message,
			Timestamp:   time.Now().UnixNano(),
			Response:    response,
		},
		ResponseMetadata: &ResponseMetadata{
			RequestId: requestID,
			Action:    "",
			Version:   "",
			Service:   "mpaas",
			Region:    "",
			Error:     nil,
		},
	}
	if code != http.StatusOK {
		c.ResponseMetadata.Error = &ResponseError{
			Code:    "InternalError",
			Message: message,
		}
	}
	resByte, err := json.Marshal(c)
	if err != nil {
		logs.Warn("json marshal error, err: %v", err)
	}
	return string(resByte)
}

type ResponseMetadata struct {
	RequestId string         `json:"requestId"`
	Action    string         `json:"action"`
	Version   string         `json:"version"`
	Service   string         `json:"service"`
	Region    string         `json:"region"`
	Error     *ResponseError `json:"error,omitempty"`
}

type ResponseError struct {
	Code    string `json:"code,omitempty"`
	Message string ` json:"message,omitempty"`
}

func (x *ResponseError) String() string {
	return x.Message
}
