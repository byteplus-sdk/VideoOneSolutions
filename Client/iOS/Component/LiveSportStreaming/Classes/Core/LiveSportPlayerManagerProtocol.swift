// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

/// Player capability abstraction used by Watch / Compare pages.
public protocol LiveSportPlayerManagerProtocol: AnyObject {
    /// Render view exposed by the underlying player.
    var renderView: UIView { get }

    /// Configure player with stream URL & protocol.
    func setupPlayer(with url: String, streamProtocol: StreamProtocol)

    /// Configure player with one or more watch routes.
    func setupPlayer(routes: [LiveSportStreamURL.WatchStreamRoute])

    /// Start playback.
    func play()

    /// Pause playback.
    func pause()

    /// Stop & release the underlying player.
    func stop()

    /// Switch to a different stream URL & protocol.
    func switchStream(url: String, streamProtocol: StreamProtocol)

    /// Switch to one or more watch routes.
    func switchStream(routes: [LiveSportStreamURL.WatchStreamRoute], defaultQuality: LiveSportStreamURL.WatchQualityOption?)

    /// Toggle super resolution.
    func setSuperResolution(enabled: Bool)

    /// Toggle sharpen.
    func setSharpen(enabled: Bool)

    /// Toggle ABR (multi-resolution adaptive bitrate).
    func setABR(enabled: Bool)

    /// Mute/unmute audio.
    func setMute(_ mute: Bool)

    /// Set render fill mode. `aspectFill` fills the render view (cropping as
    /// needed); otherwise fits the video inside the render view.
    func setRenderFillMode(aspectFill: Bool)

    /// Called when the underlying player reports a video size change.
    var onVideoSizeChanged: ((CGSize) -> Void)? { get set }

    /// Latest measured stream delay in milliseconds (0 if unavailable).
    var currentDelayMs: Int { get }

    /// Latest measured bitrate in bits per second (0 if unavailable).
    var currentBitrate: Int { get }
}
