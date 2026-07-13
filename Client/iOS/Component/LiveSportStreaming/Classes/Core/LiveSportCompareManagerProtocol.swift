// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Compare orchestration capabilities.
public protocol LiveSportCompareManagerProtocol: AnyObject {
    var topPlayer: LiveSportPlayerManagerProtocol { get }
    var bottomPlayer: LiveSportPlayerManagerProtocol { get }
    /// Called when compare metrics are refreshed.
    var onMetricsUpdated: (() -> Void)? { get set }

    /// Apply a compare configuration & start both players.
    func apply(config: LiveCompareConfig)

    /// Stop & destroy both players.
    func teardown()

    /// Latest collected delay history (in milliseconds) for top stream.
    var topDelayHistory: [Int] { get }
    /// Latest collected delay history (in milliseconds) for bottom stream.
    var bottomDelayHistory: [Int] { get }

    /// Latest collected bitrate history (kbps) for top stream.
    var topBitrateHistory: [Int] { get }
    /// Latest collected bitrate history (kbps) for bottom stream.
    var bottomBitrateHistory: [Int] { get }
}
