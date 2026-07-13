// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import TTSDKFramework
import SnapKit

/// Concrete `LiveSportPlayerManagerProtocol` backed by TTSDK `TVLManager`.
///
/// The manager keeps the underlying `TVLManager` lazy and exposes a UIView
/// wrapper so callers can simply embed `renderView` in their hierarchy.
public final class LiveSportPlayerManager: NSObject, LiveSportPlayerManagerProtocol {

    // MARK: - Public

    public let renderView: UIView = UIView()

    public private(set) var currentDelayMs: Int = 0
    public private(set) var currentBitrate: Int = 0

    public var onVideoSizeChanged: ((CGSize) -> Void)?

    // MARK: - Private state

    private var player: TVLManager?
    private var currentURL: String = ""
    private var currentProtocol: StreamProtocol = .flvLowLatency
    private var enableABR: Bool = true
    private var enableSuperResolution: Bool = false
    private var enableSharpen: Bool = false
    private var isMuted: Bool = false

    /// Whether playback is currently active. Source of truth for deciding
    /// whether to auto-pause on background.
    private var isPlaying: Bool = false
    /// Set when playback was paused by the app entering background, so the
    /// foreground transition knows whether to auto-resume.
    private var wasSuspendedByBackground: Bool = false

    // MARK: - Lifecycle

    public override init() {
        super.init()
        renderView.backgroundColor = .black
        registerAppLifecycleObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stop()
    }

    // MARK: - App lifecycle

    private func registerAppLifecycleObservers() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(handleAppWillResignActive),
                           name: UIApplication.willResignActiveNotification,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(handleAppDidBecomeActive),
                           name: UIApplication.didBecomeActiveNotification,
                           object: nil)
    }

    @objc private func handleAppWillResignActive() {
        guard isPlaying else { return }
        pause()
        wasSuspendedByBackground = true
    }

    @objc private func handleAppDidBecomeActive() {
        guard wasSuspendedByBackground else { return }
        wasSuspendedByBackground = false
        play()
    }

    // MARK: - Player setup

    private func ensurePlayer() -> TVLManager {
        if let player = player {
            return player
        }
        let newPlayer = TVLManager(type: VeLivePlayerTypeOwn)
        newPlayer.setObserver(self)
        let config = VeLivePlayerConfiguration()
        config.enableSei = true
        config.enableHardwareDecode = true
        config.enableStatisticsCallback = true
        newPlayer.setConfig(config)
        let view = newPlayer.playerView
        view.translatesAutoresizingMaskIntoConstraints = false
        renderView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(renderView)
        }
        player = newPlayer
        return newPlayer
    }

    private func streamFormat(for streamProtocol: StreamProtocol) -> VeLivePlayerFormat {
        switch streamProtocol {
        case .rtm:
            return .RTM
        case .hls:
            return .HLS
        case .flv, .flvLowLatency, .rtmps:
            return .FLV
        }
    }

    private func streamTransportProtocol(for url: String) -> VeLivePlayerProtocol {
        if let scheme = URL(string: url)?.scheme?.lowercased(), scheme == "https" || scheme == "rtmps" {
            return .TLS
        }
        return .TCP
    }

    private func playerResolution(for quality: LiveSportStreamURL.WatchQualityOption) -> VeLivePlayerResolution {
        switch quality {
        case .qualityDefault:
            return .origin
        case .quality1080:
            return .UHD
        case .quality720:
            return .HD
        case .quality540:
            return .SD
        case .quality480:
            return .LD
        }
    }

    private func buildStreamData(url: String, streamProtocol: StreamProtocol) -> VeLivePlayerStreamData {
        let stream = VeLivePlayerStream()
        stream.url = url
        stream.type = .main
        stream.format = streamFormat(for: streamProtocol)
        stream.protocol = streamTransportProtocol(for: url)

        let data = VeLivePlayerStreamData()
        data.mainStream = [stream]
        data.defaultFormat = stream.format
        data.defaultProtocol = stream.protocol
        return data
    }

    private func buildStreamData(routes: [LiveSportStreamURL.WatchStreamRoute], defaultQuality: LiveSportStreamURL.WatchQualityOption?) -> VeLivePlayerStreamData {
        var defaultStream: VeLivePlayerStream? = nil
        let streams = routes.compactMap { route -> VeLivePlayerStream? in
            guard !route.url.isEmpty else { return nil }
            let stream = VeLivePlayerStream()
            stream.url = route.url
            stream.type = .main
            stream.format = streamFormat(for: route.streamProtocol)
            stream.protocol = streamTransportProtocol(for: route.url)
            stream.resolution = playerResolution(for: route.quality)
            if let nominalBitrate = route.nominalBitrate {
                stream.bitrate = numericCast(nominalBitrate / 1000)
            }
            if route.quality == defaultQuality {
                defaultStream = stream
            }
            return stream
        }

        let data = VeLivePlayerStreamData()
        data.mainStream = streams
        if defaultStream == nil {
            defaultStream = streams.first
        }
        data.defaultFormat = defaultStream!.format
        data.defaultProtocol = defaultStream!.protocol
        data.defaultResolution = defaultStream!.resolution
        data.enableABR = enableABR
        return data
    }

    // MARK: - LiveSportPlayerManagerProtocol

    public func setupPlayer(with url: String, streamProtocol: StreamProtocol) {
        currentURL = url
        currentProtocol = streamProtocol
        let player = ensurePlayer()
        applyLowLatencyFlvIfNeeded()
        let data = buildStreamData(url: url, streamProtocol: streamProtocol)
        player.setPlay(data)
        applyCachedToggles()
    }

    public func setupPlayer(routes: [LiveSportStreamURL.WatchStreamRoute]) {
        guard let firstRoute = routes.first else { return }
        currentURL = firstRoute.url
        currentProtocol = firstRoute.streamProtocol
        let player = ensurePlayer()
        applyLowLatencyFlvIfNeeded()
        let data = buildStreamData(routes: routes, defaultQuality: nil)
        player.setPlay(data)
        applyCachedToggles()
    }

    public func play() {
        ensurePlayer().play()
        isPlaying = true
    }

    public func pause() {
        player?.stop()
        isPlaying = false
    }

    public func stop() {
        player?.stop()
        player?.destroy()
        player = nil
        renderView.subviews.forEach { $0.removeFromSuperview() }
        currentDelayMs = 0
        currentBitrate = 0
        isPlaying = false
    }

    public func switchStream(url: String, streamProtocol: StreamProtocol) {
        guard !url.isEmpty else { return }
        currentURL = url
        currentProtocol = streamProtocol
        let player = ensurePlayer()
        player.stop()
        applyLowLatencyFlvIfNeeded()
        player.setPlay(buildStreamData(url: url, streamProtocol: streamProtocol))
        applyCachedToggles()
        player.play()
        isPlaying = true
    }
    public func switchStream(routes: [LiveSportStreamURL.WatchStreamRoute], defaultQuality: LiveSportStreamURL.WatchQualityOption?) {
        guard let firstRoute = routes.first, !firstRoute.url.isEmpty else { return }
        currentURL = firstRoute.url
        currentProtocol = firstRoute.streamProtocol
        let player = ensurePlayer()
        player.stop()
        applyLowLatencyFlvIfNeeded()
        player.setPlay(buildStreamData(routes: routes, defaultQuality: defaultQuality))
        applyCachedToggles()
        player.play()
        isPlaying = true
    }

    public func setSuperResolution(enabled: Bool) {
        enableSuperResolution = enabled
        player?.setEnableSuperResolution(enabled)
    }

    public func setSharpen(enabled: Bool) {
        enableSharpen = enabled
        player?.setEnableSharpen(enabled)
    }

    public func setABR(enabled: Bool) {
        enableABR = enabled
    }

    public func setMute(_ mute: Bool) {
        isMuted = mute
        player?.setMute(mute)
    }

    public func setRenderFillMode(aspectFill: Bool) {
        player?.setRenderFillMode(aspectFill ? .aspectFill : .aspectFit)
    }

    private func applyCachedToggles() {
        player?.setMute(isMuted)
        setSuperResolution(enabled: enableSuperResolution)
        setSharpen(enabled: enableSharpen)
    }

    /// Mirrors the TTSDK low-latency FLV property:
    /// `setProperty:@"VeLivePlayerKeySetParamsLowLatencyFlv"
    ///             value:@{ @"EnableLowLatencyFLV": @(1 or 0) }`.
    private func applyLowLatencyFlvIfNeeded() {
        player?.setProperty("VeLivePlayerKeySetParamsLowLatencyFlv",
                            value: ["EnableLowLatencyFLV": currentProtocol == .flvLowLatency ? 1 : 0])
    }
}

extension LiveSportPlayerManager: VeLivePlayerObserver {
    public func onStatistics(_ player: TVLManager, statistics: VeLivePlayerStatistics) {
        currentDelayMs = Int(statistics.delayMs)
        currentBitrate = Int(statistics.bitrate) * 1000
    }

    public func onVideoSizeChanged(_ player: TVLManager, width: Int32, height: Int32) {
        let size = CGSize(width: Int(width), height: Int(height))
        DispatchQueue.main.async { [weak self] in
            self?.onVideoSizeChanged?(size)
        }
    }
}
