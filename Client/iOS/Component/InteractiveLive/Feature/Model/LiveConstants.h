//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#ifndef LiveConstants_h
#define LiveConstants_h

typedef NS_ENUM(NSInteger, LiveUserRole) {
    LiveUserRoleAudience = 1,
    LiveUserRoleHost = 2,
};

typedef NS_ENUM(NSInteger, LiveInteractStatus) {
    LiveInteractStatusOther = 0,
    LiveInteractStatusInviting = 1,
    LiveInteractStatusApplying = 2,
    LiveInteractStatusAudienceLink = 3,
    LiveInteractStatusHostLink = 4,
};

#endif /* LiveConstants_h */
