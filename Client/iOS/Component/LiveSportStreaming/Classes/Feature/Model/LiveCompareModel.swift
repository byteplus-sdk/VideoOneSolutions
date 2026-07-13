// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Tab/scene identifier used by the Compare page.
public enum CompareScene: Int {
    case lowLatency
    case imageEnhancement
    case costSaving
}

/// Single side of a compare configuration (top or bottom player).
public struct CompareStreamConfig {
    public var label: String
    public var streamURL: String
    public var streamProtocol: StreamProtocol
    public var isMuted: Bool
    public var enableSuperResolution: Bool
    public var enableSharpen: Bool
    public var codec: String
    public var nominalBitrate: Int

    public init(label: String,
                streamURL: String,
                streamProtocol: StreamProtocol,
                isMuted: Bool = true,
                enableSuperResolution: Bool = false,
                enableSharpen: Bool = false,
                codec: String = "H264",
                nominalBitrate: Int = 0) {
        self.label = label
        self.streamURL = streamURL
        self.streamProtocol = streamProtocol
        self.isMuted = isMuted
        self.enableSuperResolution = enableSuperResolution
        self.enableSharpen = enableSharpen
        self.codec = codec
        self.nominalBitrate = nominalBitrate
    }
}

/// Compare configuration that contains both top and bottom streams plus the scene type.
public struct LiveCompareConfig {
    public var scene: CompareScene
    public var topStream: CompareStreamConfig
    public var bottomStream: CompareStreamConfig

    public init(scene: CompareScene,
                topStream: CompareStreamConfig,
                bottomStream: CompareStreamConfig) {
        self.scene = scene
        self.topStream = topStream
        self.bottomStream = bottomStream
    }
}
