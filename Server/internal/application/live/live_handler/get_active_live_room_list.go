package live_handler

import (
	"github.com/byteplus/VideoOneServer/internal/application/live/live_models/live_return_models"
	"github.com/byteplus/VideoOneServer/internal/application/live/live_util"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type getActiveLiveRoomListReq struct {
	AppID string `json:"app_id" binding:"required"`
}

type getActiveLiveRoomListResp struct {
	LiveRoomList []*live_return_models.Room `json:"live_room_list"`
}

func GetActiveLiveRoomList(ctx *gin.Context) (resp interface{}, err error) {
	var p getActiveLiveRoomListReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		logs.CtxError(ctx, "param error,err:"+err.Error())
		return nil, err
	}

	rooms, err := live_util.GetReturnActiveRooms(ctx, p.AppID)
	if err != nil {
		logs.CtxError(ctx, "get rooms failed,error:%s", err)
		return nil, err
	}
	resp = &getActiveLiveRoomListResp{
		LiveRoomList: rooms,
	}

	return resp, nil

}
