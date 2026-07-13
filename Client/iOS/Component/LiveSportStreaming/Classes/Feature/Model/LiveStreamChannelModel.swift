// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Pull stream protocol options supported by the Live Sport Streaming scene.
public enum StreamProtocol: String, CaseIterable {
    case rtm
    case flvLowLatency
    case flv
    case hls
    case rtmps

    public var displayName: String {
        switch self {
        case .rtm: return LiveSportL10n("live_sport_protocol_rtm")
        case .flvLowLatency: return LiveSportL10n("live_sport_protocol_flv_low_latency")
        case .flv: return LiveSportL10n("live_sport_protocol_flv")
        case .hls: return LiveSportL10n("live_sport_protocol_hls")
        case .rtmps: return LiveSportL10n("live_sport_protocol_rtmps")
        }
    }
}

/// Description for a single live channel that can be selected on the Watch page.
public struct LiveStreamChannel {
    public static let cameraA = "camera_a"
    public static let cameraB = "camera_b"
    public static let cameraC = "camera_c"
    public static let cameraD = "camera_d"

    public let id: String
    public let title: String
    public let coverImageURL: String
    public let streamURL: String
    public let streamProtocol: StreamProtocol
    public let anchorName: String
    public let anchorAvatarURL: String
    public let audienceCount: Int

    public init(id: String,
                title: String,
                coverImageURL: String = "",
                streamURL: String,
                streamProtocol: StreamProtocol = .flvLowLatency,
                anchorName: String = "",
                anchorAvatarURL: String = "",
                audienceCount: Int = 0) {
        self.id = id
        self.title = title
        self.coverImageURL = coverImageURL
        self.streamURL = streamURL
        self.streamProtocol = streamProtocol
        self.anchorName = anchorName
        self.anchorAvatarURL = anchorAvatarURL
        self.audienceCount = audienceCount
    }
}
