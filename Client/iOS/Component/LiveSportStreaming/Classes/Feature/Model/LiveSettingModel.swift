// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Persisted player settings used by `LiveSportSettingManager`.
public struct LiveSetting {
    public var streamProtocol: StreamProtocol
    public var enableABR: Bool
    public var enableSuperResolution: Bool
    public var enableSharpen: Bool
    public var customStreamURL: String

    public init(streamProtocol: StreamProtocol = .flvLowLatency,
                enableABR: Bool = true,
                enableSuperResolution: Bool = false,
                enableSharpen: Bool = false,
                customStreamURL: String = "") {
        self.streamProtocol = streamProtocol
        self.enableABR = enableABR
        self.enableSuperResolution = enableSuperResolution
        self.enableSharpen = enableSharpen
        self.customStreamURL = customStreamURL
    }
}
