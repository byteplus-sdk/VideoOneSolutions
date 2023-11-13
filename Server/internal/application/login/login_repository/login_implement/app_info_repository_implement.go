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

package login_implement

import (
	"context"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_entity"
	"github.com/byteplus/VideoOneServer/internal/pkg/db"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli"
	"github.com/byteplus/VideoOneServer/internal/pkg/util"
	"github.com/go-redis/redis/v8"
	"gorm.io/gorm/clause"
)

const (
	AppInfoTable        = "app_info"
	keyPrefixAppInfo    = "rtc_demo:app:app_info:"
	fieldAppKey         = "app_key"
	fieldAppVolcAk      = "volc_ak"
	fieldAppVolcSk      = "volc_sk"
	fieldAppVodSpace    = "vod_space"
	fieldLiveAppName    = "live_app_name"
	fieldLiveStreamKey  = "live_stream_key"
	fieldLivePushDomain = "live_push_domain"
	fieldLivePullDomain = "live_pull_domain"
)

type AppInfoRepositoryImpl struct{}

func (impl *AppInfoRepositoryImpl) Save(ctx context.Context, appInfo *login_entity.AppInfo) error {
	defer util.CheckPanic()
	appInfo.UpdateTime = time.Now()
	err := db.Client.WithContext(ctx).Debug().Table(AppInfoTable).
		Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "app_id"}},
			UpdateAll: true,
		}).Create(&appInfo).Error
	if err != nil {
		return err
	}
	writeRedis(ctx, appInfo)
	return nil
}

func (impl *AppInfoRepositoryImpl) ExistAppInfo(ctx context.Context, appID string) (bool, error) {
	key := redisKey(ctx, appID)
	val, err := redis_cli.Client.Exists(ctx, key).Result()
	switch err {
	case nil:
		return val == 1, nil
	case redis.Nil:
		return false, nil
	default:
		return false, err
	}
}

func (impl *AppInfoRepositoryImpl) GetAppInfoByAppID(ctx context.Context, appID string) (*login_entity.AppInfo, error) {
	key := redisKey(ctx, appID)
	logs.CtxInfo(ctx, "key:%s", key)
	appKey := redis_cli.Client.HGet(ctx, key, fieldAppKey).Val()
	volcAk := redis_cli.Client.HGet(ctx, key, fieldAppVolcAk).Val()
	volcSk := redis_cli.Client.HGet(ctx, key, fieldAppVolcSk).Val()
	vodSpace := redis_cli.Client.HGet(ctx, key, fieldAppVodSpace).Val()
	liveAppName := redis_cli.Client.HGet(ctx, key, fieldLiveAppName).Val()
	liveStreamKey := redis_cli.Client.HGet(ctx, key, fieldLiveStreamKey).Val()
	livePullDomain := redis_cli.Client.HGet(ctx, key, fieldLivePullDomain).Val()
	livePushDomain := redis_cli.Client.HGet(ctx, key, fieldLivePushDomain).Val()
	var appInfo *login_entity.AppInfo
	if appKey != "" && volcAk != "" && volcSk != "" {
		appInfo = &login_entity.AppInfo{
			AppId:           appID,
			AppKey:          appKey,
			AccessKey:       volcAk,
			SecretAccessKey: volcSk,
			VodSpace:        vodSpace,
			LiveAppName:     liveAppName,
			LivePullDomain:  livePullDomain,
			LiveStreamKey:   liveStreamKey,
			LivePushDomain:  livePushDomain,
		}
	} else {
		err := db.Client.WithContext(ctx).Debug().Table(AppInfoTable).
			Where("app_id=?", appID).First(&appInfo).Error
		if err != nil {
			return nil, err

		}
		writeRedis(ctx, appInfo)
	}

	return appInfo, nil
}

func redisKey(ctx context.Context, key string) string {
	return keyPrefixAppInfo + key
}

func writeRedis(ctx context.Context, appInfo *login_entity.AppInfo) {
	key := redisKey(ctx, appInfo.AppId)
	redis_cli.Client.HSet(ctx, key, fieldAppKey, appInfo.AppKey)
	redis_cli.Client.HSet(ctx, key, fieldAppVolcAk, appInfo.AccessKey)
	redis_cli.Client.HSet(ctx, key, fieldAppVolcSk, appInfo.SecretAccessKey)
	redis_cli.Client.HSet(ctx, key, fieldAppVodSpace, appInfo.VodSpace)
	redis_cli.Client.HSet(ctx, key, fieldLivePullDomain, appInfo.LivePullDomain)
	redis_cli.Client.HSet(ctx, key, fieldLivePushDomain, appInfo.LivePushDomain)
	redis_cli.Client.HSet(ctx, key, fieldLiveStreamKey, appInfo.LiveStreamKey)
	redis_cli.Client.HSet(ctx, key, fieldLiveAppName, appInfo.LiveAppName)
	redis_cli.Client.Expire(ctx, key, TokenExpiration)
}
