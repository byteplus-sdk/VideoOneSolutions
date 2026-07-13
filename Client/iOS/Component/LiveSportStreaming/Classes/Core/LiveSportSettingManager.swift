// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Singleton storage for `LiveSetting` backed by `UserDefaults`.
public final class LiveSportSettingManager: LiveSportSettingManagerProtocol {

    private enum URLPlaybackClass {
        case httpFLV
        case httpHLS
        case httpSDP
        case rtmpFamily
    }

    public struct InferredPlayback {
        public let streamProtocol: StreamProtocol
        public let supportsLowLatencyToggle: Bool

        public init(streamProtocol: StreamProtocol, supportsLowLatencyToggle: Bool) {
            self.streamProtocol = streamProtocol
            self.supportsLowLatencyToggle = supportsLowLatencyToggle
        }
    }

    public static let shared = LiveSportSettingManager()

    private let defaultsKey = "com.byteplus.livesport.streaming.setting"
    private let defaults: UserDefaults

    public private(set) var currentSetting: LiveSetting

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.dictionary(forKey: defaultsKey) {
            self.currentSetting = LiveSportSettingManager.decodeSetting(from: data)
        } else {
            self.currentSetting = LiveSetting()
        }
    }

    // MARK: - LiveSportSettingManagerProtocol

    public func update(setting: LiveSetting) {
        var setting = setting
        if setting.streamProtocol == .rtm {
            setting.enableABR = false
        }
        currentSetting = setting
        defaults.set(LiveSportSettingManager.encodeSetting(setting), forKey: defaultsKey)
    }

    public func inferPlayback(from url: String) -> InferredPlayback? {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let playbackClass = playbackClass(for: trimmed) else { return nil }

        switch playbackClass {
        case .httpFLV:
            return InferredPlayback(streamProtocol: .flv, supportsLowLatencyToggle: true)
        case .httpHLS:
            return InferredPlayback(streamProtocol: .hls, supportsLowLatencyToggle: false)
        case .httpSDP:
            return InferredPlayback(streamProtocol: .rtm, supportsLowLatencyToggle: false)
        case .rtmpFamily:
            return InferredPlayback(streamProtocol: .rtmps, supportsLowLatencyToggle: false)
        }
    }

    public func resolveExperienceSetting(from setting: LiveSetting) -> LiveSetting? {
        let trimmedURL = setting.customStreamURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let inferredPlayback = inferPlayback(from: trimmedURL) else {
            return nil
        }

        var resolved = setting
        resolved.customStreamURL = trimmedURL
        if inferredPlayback.supportsLowLatencyToggle {
            resolved.streamProtocol = setting.streamProtocol == .flvLowLatency ? .flvLowLatency : .flv
        } else {
            resolved.streamProtocol = inferredPlayback.streamProtocol
        }
        resolved.enableABR = false
        return resolved
    }

    /// Returns true when the input string is a syntactically reasonable URL
    /// (http/https/rtmp(s)) and is not a VOD URL.
    public func validateStreamURL(_ url: String) -> Bool {
        inferPlayback(from: url) != nil
    }

    /// Heuristic: URLs ending in `.mp4` or `.mov` are considered VOD assets.
    public func isVODURL(_ url: String) -> Bool {
        let lower = url.lowercased()
        let trimmed = lower.split(separator: "?").first.map(String.init) ?? lower
        let vodExtensions = [".mp4", ".m4v", ".mov", ".mkv", ".webm"]
        return vodExtensions.contains { trimmed.hasSuffix($0) }
    }

    private func playbackClass(for url: String) -> URLPlaybackClass? {
        guard !url.isEmpty,
              let parsed = URL(string: url),
              let scheme = parsed.scheme?.lowercased() else {
            return nil
        }

        guard !isVODURL(url) else { return nil }

        let normalizedPath = parsed.path.lowercased()
        switch scheme {
        case "http", "https":
            if normalizedPath.hasSuffix(".flv") {
                return .httpFLV
            }
            if normalizedPath.hasSuffix(".m3u8") {
                return .httpHLS
            }
            if normalizedPath.hasSuffix(".sdp") {
                return .httpSDP
            }
            return nil
        case "rtmp", "rtmps":
            return pathHasFileSuffix(normalizedPath) ? nil : .rtmpFamily
        default:
            return nil
        }
    }

    private func pathHasFileSuffix(_ path: String) -> Bool {
        guard !path.isEmpty else { return false }
        let lastSegment = path.split(separator: "/").last.map(String.init) ?? path
        guard !lastSegment.isEmpty else { return false }
        return lastSegment.contains(".")
    }

    // MARK: - Persistence helpers

    private static func encodeSetting(_ setting: LiveSetting) -> [String: Any] {
        return [
            "streamProtocol": setting.streamProtocol.rawValue,
            "enableABR": setting.enableABR,
            "enableSuperResolution": setting.enableSuperResolution,
            "enableSharpen": setting.enableSharpen,
            "customStreamURL": setting.customStreamURL
        ]
    }

    private static func decodeSetting(from dict: [String: Any]) -> LiveSetting {
        let proto = (dict["streamProtocol"] as? String).flatMap { StreamProtocol(rawValue: $0) } ?? .flvLowLatency
        return LiveSetting(
            streamProtocol: proto,
            enableABR: dict["enableABR"] as? Bool ?? true,
            enableSuperResolution: dict["enableSuperResolution"] as? Bool ?? false,
            enableSharpen: dict["enableSharpen"] as? Bool ?? false,
            customStreamURL: dict["customStreamURL"] as? String ?? ""
        )
    }
}
