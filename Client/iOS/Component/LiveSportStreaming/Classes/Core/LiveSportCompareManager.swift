// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Concrete `LiveSportCompareManagerProtocol` that wraps two players and
/// exposes simple delay & bitrate history for charting.
public final class LiveSportCompareManager: LiveSportCompareManagerProtocol {

    public let topPlayer: LiveSportPlayerManagerProtocol
    public let bottomPlayer: LiveSportPlayerManagerProtocol
    public var onMetricsUpdated: (() -> Void)?

    public private(set) var topDelayHistory: [Int] = []
    public private(set) var bottomDelayHistory: [Int] = []
    public private(set) var topBitrateHistory: [Int] = []
    public private(set) var bottomBitrateHistory: [Int] = []

    private var pollingTimer: Timer?
    private let maxHistory: Int = 60

    public init(topPlayer: LiveSportPlayerManagerProtocol = LiveSportPlayerManager(),
                bottomPlayer: LiveSportPlayerManagerProtocol = LiveSportPlayerManager()) {
        self.topPlayer = topPlayer
        self.bottomPlayer = bottomPlayer
    }

    deinit {
        teardown()
    }

    public func apply(config: LiveCompareConfig) {
        topPlayer.setupPlayer(with: config.topStream.streamURL, streamProtocol: config.topStream.streamProtocol)
        topPlayer.setMute(config.topStream.isMuted)
        topPlayer.setSuperResolution(enabled: config.topStream.enableSuperResolution)
        topPlayer.setSharpen(enabled: config.topStream.enableSharpen)
        topPlayer.play()

        bottomPlayer.setupPlayer(with: config.bottomStream.streamURL, streamProtocol: config.bottomStream.streamProtocol)
        bottomPlayer.setMute(config.bottomStream.isMuted)
        bottomPlayer.setSuperResolution(enabled: config.bottomStream.enableSuperResolution)
        bottomPlayer.setSharpen(enabled: config.bottomStream.enableSharpen)
        bottomPlayer.play()

        collectMetrics()
        startPolling()
    }

    public func teardown() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        topPlayer.stop()
        bottomPlayer.stop()
        topDelayHistory.removeAll()
        bottomDelayHistory.removeAll()
        topBitrateHistory.removeAll()
        bottomBitrateHistory.removeAll()
    }

    private func startPolling() {
        pollingTimer?.invalidate()
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.collectMetrics()
        }
        RunLoop.main.add(timer, forMode: .common)
        pollingTimer = timer
    }

    private func collectMetrics() {
        appendCapped(&topDelayHistory, value: topPlayer.currentDelayMs)
        appendCapped(&bottomDelayHistory, value: bottomPlayer.currentDelayMs)
        appendCapped(&topBitrateHistory, value: topPlayer.currentBitrate / 1000)
        appendCapped(&bottomBitrateHistory, value: bottomPlayer.currentBitrate / 1000)
        onMetricsUpdated?()
    }

    private func appendCapped(_ array: inout [Int], value: Int) {
        array.append(value)
        if array.count > maxHistory {
            array.removeFirst(array.count - maxHistory)
        }
    }
}
