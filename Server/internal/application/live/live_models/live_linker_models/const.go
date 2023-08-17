/*
 * Copyright 2023 CloudWeGo Authors
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

package live_linker_models

//linker
const (
	LinkerStatusNothing          = 1
	LinkerStatusAnchorInvite     = 2
	LinkerStatusAnchorLinked     = 3
	LinkerStatusAudienceInvite   = 4
	LinkerStatusAudienceApplying = 5
	LinkerStatusAudienceLinked   = 6
	LinkerStatusNotValid         = 7
)
const (
	DataStatusNormal = iota
	DataStatusDelete
)

const (
	LinkerSceneAudience = iota
	LinkerSceneAnchor
)

//user
const (
	ErGroupVsUserStatusWaiting = iota
	ErGroupVsUserStatusReady
	ErGroupVsUserStatusLinked
	ErGroupVsUserStatusFinish
)

const (
	ErGroupVsUserSourceActionInvite = iota
	ErGroupVsUserSourceActionApply
)

const (
	SourceActionUnknown = iota
	SourceActionInvite
	SourceActionApply
)

//reply
const (
	ReplyAccept = 1
	ReplyReject = 2
)

//permit
const (
	PermitAccept = 1
	PermitReject = 2
)
