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

package login_service

import (
	"context"
	"crypto/md5"
	"encoding/hex"
	"errors"
	"math"
	"math/rand"
	"strconv"
	"time"

	"github.com/byteplus/VideoOneServer/internal/application/login/login_entity"
	"github.com/byteplus/VideoOneServer/internal/application/login/login_repository/login_facade"
	"github.com/byteplus/VideoOneServer/internal/models/custom_error"
	"github.com/byteplus/VideoOneServer/internal/pkg/logs"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli/general"
	"github.com/byteplus/VideoOneServer/internal/pkg/redis_cli/lock"
)

const (
	chars             = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	userNameLen       = 6
	maxRetryTimes     = 3
	retryBackOff      = 8 * time.Millisecond
	localUserIDLength = 8
	TokenExpiration   = 24 * 7 * time.Hour
)

const (
	retryDelay    = 8 * time.Millisecond
	maxRetryDelay = 128 * time.Millisecond
	maxRetryNum   = 10
)

func init() {
	rand.Seed(time.Now().UnixNano())
}

type UserService struct {
	userRepo       login_facade.UserRepositoryInterface
	loginTokenRepo login_facade.LoginTokenRepositoryInterface
}

var userService *UserService

func GetUserService() *UserService {
	if userService == nil {
		userService = &UserService{
			userRepo:       login_facade.GetUserRepository(),
			loginTokenRepo: login_facade.GetLoginTokenRepository(),
		}
	}
	return userService
}

func (s *UserService) Login(ctx context.Context, userID, token string) error {
	err := s.loginTokenRepo.Save(ctx, &login_entity.LoginToken{
		Token:      token,
		UserID:     userID,
		CreateTime: time.Now().UnixNano(),
	})
	if err != nil {
		return custom_error.InternalError(err)
	}
	return nil
}

func (s *UserService) GetUserID(ctx context.Context, token string) string {
	return s.loginTokenRepo.GetUserID(ctx, token)
}

func (s *UserService) SetUserName(ctx context.Context, userID, userName string) error {
	user := &login_entity.UserProfile{
		UserID:   userID,
		UserName: userName,
	}

	err := s.userRepo.Save(ctx, user)
	if err != nil {
		logs.CtxError(ctx, "failed to set user name, err: %v", err)
		return custom_error.InternalError(err)
	}

	logs.CtxInfo(ctx, "set user name: %v", userName)
	return nil
}

func (s *UserService) GetUserName(ctx context.Context, userID string) (string, error) {
	user, err := s.userRepo.GetUser(ctx, userID)
	if user == nil {
		logs.CtxWarn(ctx, "user not exist")
		return "", nil
	}

	if err != nil {
		logs.CtxError(ctx, "failed to get user, err: %v", err)
		return "", custom_error.InternalError(err)
	}

	logs.CtxInfo(ctx, "get user name: %v", user.UserName)

	return user.UserName, nil
}

func (s *UserService) CheckLoginToken(ctx context.Context, token string) error {
	if token == "" {
		logs.CtxWarn(ctx, "empty token")
		return custom_error.ErrorTokenEmpty
	}

	var exist bool
	var err error

	for i := 0; i < maxRetryTimes; i++ {
		exist, err = s.loginTokenRepo.ExistToken(ctx, token)
		if err == nil {
			break
		}

		if i < maxRetryTimes {
			retryDelay := time.Duration(math.Pow(2, float64(i))) * retryBackOff
			time.Sleep(retryDelay)
		}
	}

	if err != nil {
		logs.CtxError(ctx, "get token failed, err: %v", err)
		return custom_error.InternalError(err)
	}

	if !exist {
		logs.CtxWarn(ctx, "login token expiry")
		return custom_error.ErrorTokenExpiry
	}

	return nil
}

func (s *UserService) GenerateLocalUserIDWithRetry(ctx context.Context) (string, error) {
	userID, err := s.generateLocalUserID(ctx)
	for i := 0; userID == 0 && i <= maxRetryNum; i++ {
		backOff := time.Duration(int64(math.Pow(2, float64(i)))) * retryDelay
		if backOff > maxRetryDelay {
			backOff = maxRetryDelay
		}
		time.Sleep(backOff)
		userID, err = s.generateLocalUserID(ctx)
	}
	if userID == 0 {
		logs.CtxError(ctx, "failed to generate userID, err: %s", err)
		return "", custom_error.InternalError(errors.New("make user err"))
	}
	return strconv.FormatInt(userID, 10), nil
}

func (s *UserService) generateLocalUserID(ctx context.Context) (int64, error) {
	ok, lt := lock.LockLocalUserIDAssign(ctx)
	if !ok {
		return 0, custom_error.ErrLockRedis
	}

	defer lock.UnLockLocalUserIDAssign(ctx, lt)

	userID, err := general.GetGeneratedUserID(ctx)
	if err != nil {
		return 0, custom_error.InternalError(err)
	}

	baseline := int64(math.Pow10(localUserIDLength))
	minUserID := int64(math.Pow10(localUserIDLength - 1))

	if userID == 0 {
		userID = time.Now().Unix() % baseline
	} else {
		userID = (userID + 1) % baseline
	}

	if userID < minUserID {
		userID += minUserID
	}

	general.SetGeneratedUserID(ctx, userID)

	return userID, nil
}

func (s *UserService) GenerateLocalLoginToken(_ context.Context, userID string, createdTime int64) string {
	strCreateTime := strconv.FormatInt(createdTime, 10)
	text := userID + strCreateTime

	hasher := md5.New()
	hasher.Write([]byte(text))

	return hex.EncodeToString(hasher.Sum(nil))
}
