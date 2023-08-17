package live_handler

import (
	"context"
	"encoding/json"

	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/public"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

type getActiveLiveRoomListReq struct {
	LoginToken string `json:"login_token"`
}

type getActiveLiveRoomListResp struct {
	LiveRoomList []*live_return_models.Room `json:"live_room_list"`
}

func (eh *EventHandler) GetActiveLiveRoomList(ctx context.Context, param *public.EventParam) (resp interface{}, err error) {
	logs.CtxInfo(ctx, "liveGetActiveLiveRoomList param:%+v", param)
	var p getActiveLiveRoomListReq
	if err := json.Unmarshal([]byte(param.Content), &p); err != nil {
		logs.CtxWarn(ctx, "input format error, err: %v", err)
		return nil, custom_error.ErrInput
	}

	rooms, err := live_util.GetReturnActiveRooms(ctx, param.AppID)
	if err != nil {
		logs.CtxError(ctx, "get rooms failed,error:%s", err)
		return nil, err
	}
	resp = &getActiveLiveRoomListResp{
		LiveRoomList: rooms,
	}

	return resp, nil

}
