// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Centralized pull-stream URLs for the Live Sport Streaming scene.
/// Update endpoints here only.
public enum LiveSportStreamURL {
    public enum WatchQualityOption: String, CaseIterable {
        case quality1080
        case quality720
        case quality540
        case quality480
        case qualityDefault

        public var displayTitle: String {
            switch self {
            case .quality1080:
                return "1080P"
            case .quality720:
                return "720P"
            case .quality540:
                return "540P"
            case .quality480:
                return "480P"
            case .qualityDefault:
                return LiveSportL10n("live_sport_quality_default")
            }
        }
        
        public var urlSuffix: String {
            switch self {
            case .quality1080:
                return "_uhd"
            case .quality720:
                return "_hd"
            case .quality540:
                return "_ld"
            case .quality480:
                return "_sd"
            case .qualityDefault:
                return ""
            }
        }

        public var nominalBitrate: Int? {
            switch self {
            case .quality1080:
                return 3_200_000
            case .quality720:
                return 2_048_000
            case .quality540:
                return 1_638_000
            case .quality480:
                return 1_024_000
            case .qualityDefault:
                return 5_000_000
            }
        }

        public var isDefaultOption: Bool {
            return self == .qualityDefault
        }
    }

    public struct WatchStreamRoute {
        public let quality: WatchQualityOption
        public let displayTitle: String
        public let nominalBitrate: Int?
        public let url: String
        public let streamProtocol: StreamProtocol
        public let isABR: Bool
    }

    private struct WatchQualityConfig {
        let quality: WatchQualityOption
        let url: String
        let nominalBitrate: Int?
    }

    private struct WatchQualityDefinition {
        let quality: WatchQualityOption
        let urlSuffix: String
        let nominalBitrate: Int?
    }

    // 多机位频道
    public static let channelA = "http://pull-videoone.indiafcdn.com/live/sport_camera_a.flv"
    public static let channelB = "http://pull-videoone.indiafcdn.com/live/sport_camera_b.flv"
    public static let channelC = "http://pull-videoone.indiafcdn.com/live/sport_camera_c.flv"
    public static let channelD = "http://pull-videoone.indiafcdn.com/live/sport_camera_d.flv"

    // 编码对比（H.265 / H.264）
    // 相同码率，画质更高
    public static let h265Quality = "http://pull-videoone.indiafcdn.com/live/live_compare_uhd-hevc.flv"
    public static let h264Quality = "http://pull-videoone.indiafcdn.com/live/live_compare_uhd.flv"
    // 相同画质，码率对比
    public static let h265Cost = "http://pull-videoone.indiafcdn.com/live/live_compare_hd-hevc.flv"
    public static let h264Cost = "http://pull-videoone.indiafcdn.com/live/live_compare_uhd.flv"

    // 各协议默认地址
    public static let rtm = "http://pull-videoone.indiafcdn.com/live/live_compare.sdp"
    public static let hls = "http://pull-videoone.indiafcdn.com/live/live_compare.m3u8"
    public static let flv = "http://pull-videoone.indiafcdn.com/live/live_compare.flv"
    public static let rtmps = "rtmp://pull-videoone.indiafcdn.com/live/live_compare"

    public static let watchQualityOptions = WatchQualityOption.allCases

    /// 按协议返回默认拉流地址。
    public static func url(for streamProtocol: StreamProtocol, quality: WatchQualityOption) -> String {
        switch streamProtocol {
        case .rtm: return insertingSuffix(quality.urlSuffix, into: rtm)
        case .hls: return insertingSuffix(quality.urlSuffix, into: hls)
        case .rtmps: return insertingSuffix(quality.urlSuffix, into: rtmps)
        case .flv, .flvLowLatency: return insertingSuffix(quality.urlSuffix, into: flv)
        }
    }

    public static func watchStreamRoute(channel: LiveStreamChannel,
                                        quality: WatchQualityOption,
                                        setting: LiveSetting) -> [WatchStreamRoute] {
        if setting.enableABR {
            return abrWatchRoutes(for: channel, streamProtocol: setting.streamProtocol)
        }

        let originURL = watchURL(for: channel, streamProtocol: setting.streamProtocol)
        if quality.isDefaultOption {
            return [
                WatchStreamRoute(quality: quality,
                                 displayTitle: quality.displayTitle,
                                 nominalBitrate: quality.nominalBitrate,
                                 url: originURL,
                                 streamProtocol: setting.streamProtocol,
                                 isABR: false)
            ]
        }

        let config = qualityConfig(for: channel,
                                   quality: quality,
                                   streamProtocol: setting.streamProtocol)
        return [
            WatchStreamRoute(quality: config?.quality ?? quality,
                             displayTitle: (config?.quality ?? quality).displayTitle,
                             nominalBitrate: config?.nominalBitrate,
                             url: config?.url ?? originURL,
                             streamProtocol: setting.streamProtocol,
                             isABR: false)
        ]
    }

    private static func abrWatchRoutes(for channel: LiveStreamChannel,
                                       streamProtocol: StreamProtocol) -> [WatchStreamRoute] {
        let originRoute = WatchStreamRoute(quality: .qualityDefault,
                                           displayTitle: WatchQualityOption.qualityDefault.displayTitle,
                                           nominalBitrate: WatchQualityOption.qualityDefault.nominalBitrate,
                                           url: watchURL(for: channel, streamProtocol: streamProtocol),
                                           streamProtocol: streamProtocol,
                                           isABR: true)
        let qualityRoutes = watchQualityOptions.map { quality in
            WatchStreamRoute(quality: quality,
                             displayTitle: quality.displayTitle,
                             nominalBitrate: quality.nominalBitrate,
                             url: watchURL(for: channel,
                                           streamProtocol: streamProtocol,
                                           suffix: quality.urlSuffix),
                             streamProtocol: streamProtocol,
                             isABR: true)
        }
        return [originRoute] + qualityRoutes
    }

    private static func qualityConfig(for channel: LiveStreamChannel,
                                      quality: WatchQualityOption,
                                      streamProtocol: StreamProtocol) -> WatchQualityConfig? {
        let qualityURL = watchURL(for: channel,
                                  streamProtocol: streamProtocol,
                                  suffix: quality.urlSuffix)
        return WatchQualityConfig(quality: quality,
                                  url: qualityURL,
                                  nominalBitrate: quality.nominalBitrate)
    }

    private static func watchURL(for channel: LiveStreamChannel,
                                 streamProtocol: StreamProtocol,
                                 suffix: String? = nil) -> String {
        let baseURL = convertedWatchURL(channel.streamURL, to: streamProtocol)
        guard let suffix else {
            return baseURL
        }
        return insertingSuffix(suffix, into: baseURL)
    }

    private static func convertedWatchURL(_ url: String, to streamProtocol: StreamProtocol) -> String {
        switch streamProtocol {
        case .flv, .flvLowLatency:
            return replacingExtension(in: url, with: "flv")
        case .hls:
            return replacingExtension(in: url, with: "m3u8")
        case .rtm:
            return replacingExtension(in: url, with: "sdp")
        case .rtmps:
            return removingPathExtension(from: replacingScheme(in: url, with: "rtmp"))
        }
    }

    private static func replacingScheme(in url: String, with scheme: String) -> String {
        guard var components = URLComponents(string: url) else {
            return url
        }
        components.scheme = scheme
        return components.url?.absoluteString ?? url
    }

    private static func replacingExtension(in url: String, with newExtension: String) -> String {
        guard var components = URLComponents(string: url) else {
            return url
        }

        let path = components.path
        let nsPath = path as NSString
        let basePath = nsPath.deletingPathExtension
        let normalizedBasePath = basePath.isEmpty ? path : basePath
        components.path = normalizedBasePath + ".\(newExtension)"
        return components.url?.absoluteString ?? url
    }

    private static func removingPathExtension(from url: String) -> String {
        guard var components = URLComponents(string: url) else {
            return url
        }

        let path = components.path
        let nsPath = path as NSString
        let basePath = nsPath.deletingPathExtension
        components.path = basePath.isEmpty ? path : basePath
        return components.url?.absoluteString ?? url
    }

    private static func insertingSuffix(_ suffix: String, into url: String) -> String {
        guard !suffix.isEmpty else { return url }
        let fileURL = URL(string: url)
        let pathExtension = fileURL?.pathExtension ?? ""
        guard !pathExtension.isEmpty else {
            return url + suffix
        }

        let extensionSegment = ".\(pathExtension)"
        guard url.hasSuffix(extensionSegment) else {
            return url + suffix
        }
        return String(url.dropLast(extensionSegment.count)) + suffix + extensionSegment
    }
}
