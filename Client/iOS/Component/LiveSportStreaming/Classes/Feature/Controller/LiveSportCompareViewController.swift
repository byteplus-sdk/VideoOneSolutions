// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Live compare page: a top L2 tab bar synced with a horizontally paging scroll
/// view that hosts three sub-pages (low latency, image enhancement, cost
/// saving). Only the visible page plays — a single two-player manager is reused
/// and its render views are re-parented when switching pages.
public final class LiveSportCompareViewController: LiveSportViewController, UIScrollViewDelegate {

    private let lowLatencyDocURL = "https://docs.byteplus.com/en/docs/byteplus-media-live/docs-introduction-to-real-time-media"
    private let enhanceDocURL = "https://docs.byteplus.com/en/docs/byteplus-media-live/docs-implementing-advanced-features-3?_vtm_=a78999.b69280.0_0.0_0.0.163_7654553914111542789#super-resolution"
    private let costDocURL = "https://docs.byteplus.com/en/docs/byteplus-media-live/docs-implementing-advanced-features-3?_vtm_=a78999.b69280.0_0.0_0.0.163_7654553914111542789#953988b6"

    private let tabBar = LiveSportCompareTabBar()
    private let pagerScrollView = UIScrollView()
    private let pagesContainer = UIView()

    private let lowLatencyPage = LiveSportCompareLowLatencyPageView()
    private let enhancePage = LiveSportCompareEnhanceCostPageView(mode: .enhance)
    private let costPage = LiveSportCompareEnhanceCostPageView(mode: .cost)

    private let manager: LiveSportCompareManagerProtocol = LiveSportCompareManager()

    private var currentPageIndex = -1

    private var lowLatencyTopProtocol: StreamProtocol = .rtm
    private var lowLatencyBottomProtocol: StreamProtocol = .rtm
    private var costSameBitrate = false
    private var enhanceSuperResolution = true
    private var enhanceSharpen = true

    private var topPlaying = true
    private var bottomPlaying = true
    private var topMuted = false
    private var bottomMuted = true

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 246.0 / 255.0, green: 248.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
        setupSubviews()
        bindCallbacks()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentPageIndex < 0 {
            activate(pageIndex: 0)
            tabBar.setSelected(index: 0, animated: false)
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            manager.onMetricsUpdated = nil
            manager.teardown()
        }
    }

    // MARK: - Setup

    private func setupSubviews() {
        view.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        pagerScrollView.isPagingEnabled = true
        pagerScrollView.showsHorizontalScrollIndicator = false
        pagerScrollView.alwaysBounceVertical = false
        pagerScrollView.delegate = self
        view.addSubview(pagerScrollView)
        pagerScrollView.snp.makeConstraints { make in
            make.top.equalTo(tabBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        pagerScrollView.addSubview(pagesContainer)
        pagesContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(pagerScrollView.snp.height)
        }

        let pages = [lowLatencyPage, enhancePage, costPage]
        var previous: UIView?
        for page in pages {
            pagesContainer.addSubview(page)
            page.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(pagerScrollView.snp.width)
                if let previous = previous {
                    make.leading.equalTo(previous.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            previous = page
        }
        previous?.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }
    }

    private func bindCallbacks() {
        manager.onMetricsUpdated = { [weak self] in
            self?.updateBadges()
        }

        lowLatencyPage.infoCard.onDoc = { [weak self] in
            self?.openExternalDocument(self?.lowLatencyDocURL)
        }
        enhancePage.infoCard.onDoc = { [weak self] in
            self?.openExternalDocument(self?.enhanceDocURL)
        }
        costPage.infoCard.onDoc = { [weak self] in
            self?.openExternalDocument(self?.costDocURL)
        }

        tabBar.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        tabBar.onSelect = { [weak self] index in
            self?.selectPage(index, animated: true)
        }

        lowLatencyPage.onProtocolSelect = { [weak self] isTop, proto in
            guard let self = self else { return }
            if isTop {
                self.lowLatencyTopProtocol = proto
                self.manager.topPlayer.switchStream(url: self.streamURL(for: proto), streamProtocol: proto)
            } else {
                self.lowLatencyBottomProtocol = proto
                self.manager.bottomPlayer.switchStream(url: self.streamURL(for: proto), streamProtocol: proto)
            }
        }

        enhancePage.onSuperResolution = { [weak self] enabled in
            self?.enhanceSuperResolution = enabled
            self?.manager.topPlayer.setSuperResolution(enabled: enabled)
        }
        enhancePage.onSharpen = { [weak self] enabled in
            self?.enhanceSharpen = enabled
            self?.manager.topPlayer.setSharpen(enabled: enabled)
        }

        costPage.onCostModeSelect = { [weak self] index in
            guard let self = self else { return }
            self.costSameBitrate = index == 1
            self.activate(pageIndex: 2)
        }

        bindTile(lowLatencyPage.topTile, isTop: true)
        bindTile(lowLatencyPage.bottomTile, isTop: false)
        bindTile(enhancePage.topTile, isTop: true)
        bindTile(enhancePage.bottomTile, isTop: false)
        bindTile(costPage.topTile, isTop: true)
        bindTile(costPage.bottomTile, isTop: false)
    }

    private func bindTile(_ tile: LiveSportCompareVideoTile, isTop: Bool) {
        tile.onPlayPause = { [weak self, weak tile] in
            guard let self = self, let tile = tile else { return }
            if isTop {
                self.topPlaying.toggle()
                if self.topPlaying { self.manager.topPlayer.play() } else { self.manager.topPlayer.pause() }
                tile.setPlaying(self.topPlaying)
            } else {
                self.bottomPlaying.toggle()
                if self.bottomPlaying { self.manager.bottomPlayer.play() } else { self.manager.bottomPlayer.pause() }
                tile.setPlaying(self.bottomPlaying)
            }
        }
        tile.onMute = { [weak self, weak tile] in
            guard let self = self, let tile = tile else { return }
            if isTop {
                self.topMuted.toggle()
                self.manager.topPlayer.setMute(self.topMuted)
                tile.setMuted(self.topMuted)
            } else {
                self.bottomMuted.toggle()
                self.manager.bottomPlayer.setMute(self.bottomMuted)
                tile.setMuted(self.bottomMuted)
            }
        }
    }

    // MARK: - Paging

    private func selectPage(_ index: Int, animated: Bool) {
        let width = pagerScrollView.bounds.width
        guard width > 0 else { return }
        pagerScrollView.setContentOffset(CGPoint(x: CGFloat(index) * width, y: 0), animated: animated)
        if !animated {
            finalizePage(index)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        finalizePage(currentVisibleIndex())
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        finalizePage(currentVisibleIndex())
    }

    private func currentVisibleIndex() -> Int {
        let width = pagerScrollView.bounds.width
        guard width > 0 else { return 0 }
        return Int((pagerScrollView.contentOffset.x + width / 2) / width)
    }

    private func finalizePage(_ index: Int) {
        guard index != currentPageIndex else { return }
        tabBar.setSelected(index: index, animated: true)
        activate(pageIndex: index)
    }

    // MARK: - Activation

    private func activate(pageIndex: Int) {
        manager.teardown()
        currentPageIndex = pageIndex

        let page = pageView(at: pageIndex)
        let topTile = page.topTile
        let bottomTile = page.bottomTile

        let topRender = manager.topPlayer.renderView
        let bottomRender = manager.bottomPlayer.renderView
        topTile.attach(renderView: topRender)
        bottomTile.attach(renderView: bottomRender)

        topPlaying = true
        bottomPlaying = true
        topMuted = false
        bottomMuted = true

        manager.apply(config: makeConfig(for: pageIndex))

        topTile.setPlaying(topPlaying)
        bottomTile.setPlaying(bottomPlaying)
        topTile.setMuted(topMuted)
        bottomTile.setMuted(bottomMuted)
        updateBadges()
    }

    private func pageView(at index: Int) -> CompareVideoPage {
        switch index {
        case 1: return enhancePage
        case 2: return costPage
        default: return lowLatencyPage
        }
    }

    private func makeConfig(for index: Int) -> LiveCompareConfig {
        switch index {
        case 1:
            let top = CompareStreamConfig(label: "Enhanced",
                                          streamURL: streamURL(for: .flvLowLatency, quality: .quality540),
                                          streamProtocol: .flvLowLatency,
                                          isMuted: topMuted,
                                          enableSuperResolution: enhanceSuperResolution,
                                          enableSharpen: enhanceSharpen)
            let bottom = CompareStreamConfig(label: "Original",
                                             streamURL: streamURL(for: .flvLowLatency, quality: .quality540),
                                             streamProtocol: .flvLowLatency,
                                             isMuted: bottomMuted)
            return LiveCompareConfig(scene: .imageEnhancement, topStream: top, bottomStream: bottom)
        case 2:
            let topURL = costSameBitrate ? LiveSportStreamURL.h265Quality : LiveSportStreamURL.h265Cost
            let top = CompareStreamConfig(label: "H.265",
                                          streamURL: topURL,
                                          streamProtocol: .flvLowLatency,
                                          isMuted: topMuted,
                                          codec: "H265",
                                          nominalBitrate: costSameBitrate ? 2000 : 1400)
            
            let bottomURL = costSameBitrate ? LiveSportStreamURL.h264Quality : LiveSportStreamURL.h264Cost
            let bottom = CompareStreamConfig(label: "H.264",
                                             streamURL: bottomURL,
                                             streamProtocol: .flvLowLatency,
                                             isMuted: bottomMuted,
                                             codec: "H264",
                                             nominalBitrate: 2000)
            return LiveCompareConfig(scene: .costSaving, topStream: top, bottomStream: bottom)
        default:
            let top = CompareStreamConfig(label: "Top",
                                          streamURL: streamURL(for: lowLatencyTopProtocol),
                                          streamProtocol: lowLatencyTopProtocol,
                                          isMuted: topMuted)
            let bottom = CompareStreamConfig(label: "Bottom",
                                             streamURL: streamURL(for: lowLatencyBottomProtocol),
                                             streamProtocol: lowLatencyBottomProtocol,
                                             isMuted: bottomMuted)
            return LiveCompareConfig(scene: .lowLatency, topStream: top, bottomStream: bottom)
        }
    }

    private func streamURL(for proto: StreamProtocol, quality: LiveSportStreamURL.WatchQualityOption = .quality720) -> String {
        return LiveSportStreamURL.url(for: proto, quality: quality)
    }

    private func openExternalDocument(_ urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    // MARK: - Metrics

    private func updateBadges() {
        guard currentPageIndex >= 0 else { return }
        let page = pageView(at: currentPageIndex)
        switch currentPageIndex {
        case 1:
            page.topTile.setLeadingBadge(LiveSportL10n("live_sport_compare_processed"))
            page.bottomTile.setLeadingBadge(LiveSportL10n("live_sport_compare_original"))
            page.topTile.setTrailingBadge(nil)
            page.bottomTile.setTrailingBadge(nil)
        case 2:
            page.topTile.setLeadingBadge(formattedBitrateBadge(manager.topPlayer.currentBitrate))
            page.bottomTile.setLeadingBadge(formattedBitrateBadge(manager.bottomPlayer.currentBitrate))
            page.topTile.setTrailingBadge("H.265")
            page.bottomTile.setTrailingBadge("H.264")
        default:
            page.topTile.setLeadingBadge(formattedDelayBadge(manager.topPlayer.currentDelayMs))
            page.bottomTile.setLeadingBadge(formattedDelayBadge(manager.bottomPlayer.currentDelayMs))
            page.topTile.setTrailingBadge(nil)
            page.bottomTile.setTrailingBadge(nil)
        }
    }

    private func formattedBitrateBadge(_ bitrate: Int) -> String {
        guard bitrate > 100 else { return "--" }
        let kbps = Double(bitrate) / 1000.0
        return String(format: LiveSportL10n("live_sport_compare_realtime_bitrate"), locale: Locale.current, kbps)
    }

    private func formattedDelayBadge(_ delayMs: Int) -> String {
        guard delayMs > 0 else { return "--" }
        let seconds = Double(delayMs) / 1000.0
        return String(format: LiveSportL10n("live_sport_compare_realtime_delay"), locale: Locale.current, seconds)
    }
}

/// Common interface exposed by the compare sub-pages so the controller can
/// re-parent render views and update badges uniformly.
public protocol CompareVideoPage: UIView {
    var topTile: LiveSportCompareVideoTile { get }
    var bottomTile: LiveSportCompareVideoTile { get }
}

extension LiveSportCompareLowLatencyPageView: CompareVideoPage {}
extension LiveSportCompareEnhanceCostPageView: CompareVideoPage {}
