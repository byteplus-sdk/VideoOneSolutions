package ktv_handler

import (
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type getAudienceListReq struct {
	RoomID     string `json:"room_id"`
	LoginToken string `json:"login_token"`
}

type getAudienceListResp struct {
	AudienceList []*ktv_service.User `json:"audience_list"`
}

func (eh *EventHandler) GetAudienceList(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "ktvGetAudienceList param:%+v", param)
	var p getAudienceListReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	if p.RoomID == "" {
		logs.CtxError(ctx, "input error, param:%v", p)
		return nil, custom_error.ErrInput
	}

	userFactory := ktv_service.GetUserFactory()

	audienceList, err := userFactory.GetAudiencesWithoutApplyByRoomID(ctx, param.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get audience list failed,error:%s", err)
		return nil, err
	}

	resp = &getAudienceListResp{
		AudienceList: audienceList,
	}

	return resp, nil
}
