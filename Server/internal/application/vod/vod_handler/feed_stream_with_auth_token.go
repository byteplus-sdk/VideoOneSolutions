package vod_handler

import (
	"net/http"

	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_models"
	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/gin-gonic/gin"
)

func GetFeedStreamWithPlayAuthToken(httpCtx *gin.Context) {
	ctx := util.EnsureID(httpCtx)
	req := &vod_models.GetFeedStreamRequest{}
	err := httpCtx.ShouldBindJSON(req)
	if err != nil {
		logs.CtxError(ctx, "param error,err:%s", err)
		httpCtx.String(http.StatusBadRequest, response.NewVodCommonResponse(ctx, "", "", custom_error.ErrInput))
		return
	}

	if req.PageSize <= 0 || req.PageSize > 100 {
		req.PageSize = 100
	}
	if req.AppID == "" {
		req.AppID = config.Configs().AppID
	}

	resp, err := vod_service.GetFeedStreamWithPlayAuthToken(ctx, req)
	if err != nil {
		logs.CtxError(ctx, "GetFeedStreamWithPlayAuthToken err: %s", err)
		httpCtx.String(http.StatusInternalServerError, response.NewVodCommonResponse(ctx, "", "", custom_error.InternalError(err)))
		return
	}
	httpCtx.String(http.StatusOK, response.NewVodCommonResponse(ctx, "", resp, nil))
	return
}
