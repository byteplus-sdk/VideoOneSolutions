package vod_handler

import (
	"net/http"

	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_service"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/models/response"
	"github.com/byteplus/VideoOneServer/internal/pkg/config"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/gin-gonic/gin"
)

func GenUploadToken(httpCtx *gin.Context) {
	ctx := util.EnsureID(httpCtx)
	appID := httpCtx.Query("AppId")
	expiredTime := httpCtx.Query("expiredTime")
	if expiredTime == "" {
		httpCtx.String(http.StatusBadRequest, response.NewCommonResponse(ctx, "", "", custom_error.ErrInput))
		return
	}
	if appID == "" {
		appID = config.Configs().AppID
	}

	resp, err := vod_service.GenUploadToken(ctx, appID, expiredTime)
	if err != nil {
		httpCtx.String(http.StatusInternalServerError, response.NewCommonResponse(ctx, "", "", custom_error.InternalError(err)))
		return
	}

	httpCtx.String(http.StatusOK, response.NewCommonResponse(ctx, "", resp, nil))
	return
}
