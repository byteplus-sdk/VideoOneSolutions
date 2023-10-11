package vod_openapi

import (
	"context"
	"github.com/byteplus-sdk/byteplus-sdk-golang/service/vod"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_service"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

var vodInstanceMap map[string]*vod.Vod

func GetInstance(ctx context.Context, appID string) *vod.Vod {
	logs.CtxInfo(ctx, "get instance appID:%s", appID)
	if vodInstanceMap == nil {
		vodInstanceMap = make(map[string]*vod.Vod, 10)
	}
	instance, ok := vodInstanceMap[appID]
	if ok {
		return instance
	} else {
		userInfoService := login_service.GetAppInfoService()
		userInfo, err := userInfoService.ReadAppInfoByAppId(ctx, appID)
		if err != nil {
			logs.CtxError(ctx, "get app info error:%s", err)
			return instance
		}
		instance = vod.NewInstance()
		instance.SetAccessKey(userInfo.AccessKey)
		instance.SetSecretKey(userInfo.SecretAccessKey)
		vodInstanceMap[appID] = instance
	}
	return instance
}
