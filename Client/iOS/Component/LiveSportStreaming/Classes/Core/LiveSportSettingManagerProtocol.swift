// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Persistence + validation for `LiveSetting`.
public protocol LiveSportSettingManagerProtocol: AnyObject {
    var currentSetting: LiveSetting { get }
    func update(setting: LiveSetting)
    func inferPlayback(from url: String) -> LiveSportSettingManager.InferredPlayback?
    func resolveExperienceSetting(from setting: LiveSetting) -> LiveSetting?
    func validateStreamURL(_ url: String) -> Bool
    func isVODURL(_ url: String) -> Bool
}
