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

type VerifyResult_ struct {
	VerifyId      int64  `json:"verify_id"`
	VerifyResult_ string `json:"verify_result"`
	Verifier      string `json:"verifier"`
	Turn          int16  `json:"turn"`
	AssignTime    *int64 `json:"assign_time,omitempty"`
	ResolveTime   *int64 `json:"resolve_time,omitempty"`
}

type MachineResult_ struct {
	Predicts []*TagPredict `json:"predicts"`
}

type TagPredict struct {
	TagId          int32   `json:"tag_id"`
	TagName        string  `json:"tag_name"`
	Prob           float64 `json:"prob"`
	RiskType       int64   `json:"risk_type"`
	RiskLevel      int64   `json:"risk_level"`
	RiskConfidence int64   `json:"risk_confidence"`
	ModelName      string  `json:"model_name"`
	ServicePsm     string  `json:"service_psm"`
	Hit            bool    `json:"hit"`
	Status         int32   `json:"status"`
}

type EventParam struct {
	AppID     string `json:"app_id"`
	RoomID    string `json:"room_id"`
	UserID    string `json:"user_id"`
	EventName string `json:"event_name"`
	Content   string `json:"content"`
	RequestID string `json:"request_id"`
	DeviceID  string `json:"device_id"`
	Language  string `json:"language"`
}

type RecordCallbackParam struct {
	EventType string `json:"EventType"`
	EventData string `json:"EventData"`
	EventTime string `json:"EventTime"`
	EventId   string `json:"EventId"`
	AppId     string `json:"AppId"`
	Version   string `json:"Version"`
	Signature string `json:"Signature"`
	Noce      string `json:"Noce"`
}

type HandleSudCallbackGetSsTokenReq struct {
	Code string `json:"code"`
}

type HandleSudCallbackUpdateSsTokenReq struct {
	SsToken string `json:"ss_token"`
}

type HandleSudCallbackGetUserInfoReq struct {
	SsToken string `json:"ss_token"`
}

type HandleSudCallbackReportGameInfoReq struct {
	ReportType string `json:"report_type"`
	ReportMsg  string `json:"report_msg"`
	UID        string `json:"uid"`
	SsToken    string `json:"ss_token"`
}

type RtcReviewCallbackReq struct {
	AppID        string `json:"appID"`
	RoomID       string `json:"roomID"`
	UserID       string `json:"userID"`
	ObjectID     string `json:"objectID"`
	MediaType    string `json:"mediaType"`
	ReviewType   string `json:"reviewType"`
	Extra        string `json:"ext"`
	BusinessType int64  `json:"businessType"`
	TaskID       string `json:"taskID"`
	ManualAct    string `json:"manualAct"`
	MachineAct   bool   `json:"machineAct"`
	MachineHit   bool   `json:"machineHit"`
}

type HandleOpenPlatFormReq struct {
	Content   string `json:"content"`
	EventName string `json:"event_name"`
}

type RTCJoinRoomTokenParam struct {
	LoginToken string `json:"login_token" binding:"required"`
	AppID      string `json:"app_id" binding:"required"`
	AppKey     string `json:"app_key" binding:"required"`
	RoomID     string `json:"room_id" binding:"required"`
	UserID     string `json:"user_id" binding:"required"`
	Expire     int64  `json:"expire"`
	Pub        bool   `json:"pub"`
}
