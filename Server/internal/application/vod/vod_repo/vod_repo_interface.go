package vod_repo

import (
	"context"

	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_entity"
)

var vodRepo VodRepoInterface

func GetVodRepo() VodRepoInterface {
	if vodRepo == nil {
		vodRepo = &VodRepoImpl{}
	}
	return vodRepo
}

type VodRepoInterface interface {
	GetVideoInfoListFromTMVideoInfoByUser(ctx context.Context, vid string, offset, pageSize, videoType int) ([]*vod_entity.VideoInfo, error)
}
