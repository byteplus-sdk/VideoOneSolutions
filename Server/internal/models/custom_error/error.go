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

package custom_error

import "errors"

var (
	ErrInput                           = NewCustomError(400, errors.New("input format error"))
	ErrUserIsInactive                  = NewCustomError(404, errors.New("user is inactive"))
	ErrUserInUse                       = NewCustomError(413, errors.New("user is in use"))
	ErrUserInRoom                      = NewCustomError(414, errors.New("user is in room"))
	ErrUserIsNotHost                   = NewCustomError(416, errors.New("user is not host"))
	ErrUserIsNotOwner                  = NewCustomError(417, errors.New("user is not room owner"))
	ErrUserNotExist                    = NewCustomError(419, errors.New("user not exist"))
	ErrRoomIsInactive                  = NewCustomError(421, errors.New("room is inactive"))
	ErrRoomNotExist                    = NewCustomError(422, errors.New("room not exist"))
	ErrorTokenExpiry                   = NewCustomError(450, errors.New("login token expired"))
	ErrorTokenEmpty                    = NewCustomError(451, errors.New("login token empty"))
	ErrorTokenUserNotMatch             = NewCustomError(452, errors.New("login token user not match"))
	ErrorReachMicOnLimit               = NewCustomError(472, errors.New("reach mic on limit user count"))
	ErrorUserCantInviteForInviting     = NewCustomError(481, errors.New("user can't be invited because who is inviting"))
	ErrLockRedis                       = NewCustomError(500, errors.New("lock redis room error"))
	ErrUserOnMicExceedLimit            = NewCustomError(506, errors.New("user on mic exceed limit"))
	ErrUserInRoomExceedLimit           = NewCustomError(507, errors.New("user in room exceed limit"))
	ErrRoomAlreadyExist                = NewCustomError(530, errors.New("room already exist"))
	ErrRequestSongRepeat               = NewCustomError(540, errors.New("request song repeat"))
	ErrRequestSongUserRoleNotMatch     = NewCustomError(541, errors.New("user role don't match current song"))
	ErrSongIsNotExist                  = NewCustomError(542, errors.New("song is not exist"))
	ErrRoomStatusNotMatchAction        = NewCustomError(550, errors.New("room status not match current action"))
	ErrRecordNotFound                  = NewCustomError(560, errors.New("record not found"))
	ErrLinkerParamError                = NewCustomError(610, errors.New("linker param error"))
	ErrLinkerNotExist                  = NewCustomError(611, errors.New("linker not exist"))
	ErrUserDoNotHavePermission         = NewCustomError(620, errors.New("you do not have permission"))
	ErrUserLinked                      = NewCustomError(621, errors.New("user is already linkmic"))
	ErrUserInviting                    = NewCustomError(622, errors.New("user is inviting"))
	ErrSceneInvitingConflict           = NewCustomError(632, errors.New("audience apply，host already invite other host or host is invited by others host"))
	ErrSceneInviteeAlreadyInvited      = NewCustomError(634, errors.New("host invite others host,host or others host  already is invited"))
	ErrSceneAudienceHostAlreadyInvited = NewCustomError(638, errors.New("host invite audience，host already is invited"))
	ErrSceneAudienceNotAllowedOrLinked = NewCustomError(642, errors.New("audience link ，room is not allow to link audience or host already link others host"))
	ErrSceneReplyInviteRoomHasAudience = NewCustomError(643, errors.New("host link other host ，room has audience"))
	ErrSceneReplyRoomLinked            = NewCustomError(644, errors.New("host link other host，host already link another host"))
	ErrSceneRepeatInvite               = NewCustomError(645, errors.New("host invite other host，host invite audience repeatedly"))
	ErrStartSingType                   = NewCustomError(646, errors.New("start type must be 1 or 2"))
	ErrStartSingError                  = NewCustomError(647, errors.New("start sing found error"))
	ErrGetAppInfo                      = NewCustomError(800, errors.New("get appInfo error"))
	ErrNotExistAppInfo                 = NewCustomError(801, errors.New("appInfo not exist in redis"))
	ErrCheckTrafficAppID               = NewCustomError(802, errors.New("check traffic appID error"))
	ErrCheckTrafficUpLimit             = NewCustomError(803, errors.New("check traffic up limit"))
	ErrGetBID                          = NewCustomError(806, errors.New("get bid error"))
	ErrLockRoom                        = NewCustomError(809, errors.New("lock room error"))
	ErrMissParam                       = NewCustomError(811, errors.New("required parameter missing"))
	ErrUnknown                         = NewCustomError(999, errors.New("unknown error"))
)

type CustomError struct {
	err  error
	code int
}

func NewCustomError(code int, err error) *CustomError {
	return &CustomError{
		code: code,
		err:  err,
	}
}

func InternalError(err error) *CustomError {
	return &CustomError{
		code: 500,
		err:  err,
	}
}

func (e *CustomError) Error() string {
	return e.err.Error()
}

func (e *CustomError) Code() int {
	return e.code
}

func Equal(src error, trg *CustomError) bool {
	if src == nil {
		return false
	}

	if cerr, ok := src.(*CustomError); ok {
		return cerr.Code() == trg.Code()
	}

	return false
}
