package ktv_handler

import (
	"github.com/byteplus/VideoOneServer/internal/application/ktv/ktv_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

type getAudienceListReq struct {
	AppID  string `json:"app_id" binding:"required"`
	RoomID string `json:"room_id" binding:"required"`
}

type getAudienceListResp struct {
	AudienceList []*ktv_service.User `json:"audience_list"`
}

func GetAudienceList(ctx *gin.Context) (resp interface{}, err error) {
	var p getAudienceListReq
	if err = ctx.ShouldBindBodyWith(&p, binding.JSON); err != nil {
		return nil, err
	}

	userFactory := ktv_service.GetUserFactory()

	audienceList, err := userFactory.GetAudiencesWithoutApplyByRoomID(ctx, p.AppID, p.RoomID)
	if err != nil {
		logs.CtxError(ctx, "get audience list failed,error:%s", err)
		return nil, err
	}

	resp = &getAudienceListResp{
		AudienceList: audienceList,
	}

	return resp, nil
}
