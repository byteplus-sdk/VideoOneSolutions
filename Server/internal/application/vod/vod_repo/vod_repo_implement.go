package vod_repo

import (
	"context"
	"math/rand"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/vod/vod_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
)

const (
	VideoInfo = "video_info"
)

type VodRepoImpl struct{}

func (v *VodRepoImpl) GetVideoInfoListFromTMVideoInfoByUser(ctx context.Context, vid string, offset, pageSize, videoType int) ([]*vod_entity.VideoInfo, error) {
	var resp []*vod_entity.VideoInfo
	query := db.Client.WithContext(ctx).Debug().Table(VideoInfo).Where("video_type = ?", videoType)
	if vid != "" {
		query = query.Where("vid = ?", vid)
	}
	err := query.Order("id asc").Offset(offset).Limit(pageSize).Find(&resp).Error
	if err != nil {
		logs.CtxError(ctx, "DB Op Failed! *Error is: %v", err)
		return nil, err
	}
	//disrupt_order
	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(resp), func(i, j int) {
		resp[i], resp[j] = resp[j], resp[i]
	})
	return resp, nil
}
