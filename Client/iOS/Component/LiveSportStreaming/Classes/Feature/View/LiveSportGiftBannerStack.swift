// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// A single send-gift banner: avatar + sender name + "送出{gift}" subtitle on a
/// rounded gradient pill, with the gift icon overlapping the trailing edge.
/// Visual reference: Figma node 5728-89787.
final class LiveSportGiftBannerView: UIView {

    private let pillView = UIView()
    private let pillGradientLayer = CAGradientLayer()
    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let giftIconView = UIImageView()
    private let countLabel = UILabel()

    /// Identity of the gift this banner currently represents, used to aggregate
    /// repeated sends of the same gift into a single banner.
    private(set) var giftID: String?
    /// How many times this gift has been sent while the banner is alive. The
    /// `xN` count is shown only from 2 onward.
    private(set) var count: Int = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(senderName: String, gift: LiveSportGift, avatar: UIImage?) {
        giftID = gift.id
        count = 1
        nameLabel.text = senderName
        subtitleLabel.text = String(format: LiveSportL10n("live_sport_gift_sent_prefix"), gift.displayName)
        giftIconView.image = gift.icon
        avatarView.image = avatar
        updateCountLabel()
    }

    /// Bumps the combo multiplier by one and refreshes the `xN` label.
    func incrementCount() {
        count += 1
        updateCountLabel()
    }

    private func updateCountLabel() {
        if count >= 2 {
            countLabel.text = "x\(count)"
            countLabel.isHidden = false
        } else {
            countLabel.text = nil
            countLabel.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pillGradientLayer.frame = pillView.bounds
    }

    private func setupSubviews() {
        pillView.layer.cornerRadius = 21
        pillView.clipsToBounds = true
        pillGradientLayer.colors = [
            UIColor(red: 81.0 / 255.0, green: 78.0 / 255.0, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 49.0 / 255.0, green: 156.0 / 255.0, blue: 1.0, alpha: 0.06).cgColor
        ]
        pillGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        pillGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        pillView.layer.insertSublayer(pillGradientLayer, at: 0)
        addSubview(pillView)
        pillView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.height.equalTo(42)
            make.trailing.equalToSuperview().offset(-32)
        }

        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.cornerRadius = 18
        avatarView.clipsToBounds = true
        avatarView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        pillView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(3)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = .white
        pillView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(6)
            make.top.equalToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        pillView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(1)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        giftIconView.contentMode = .scaleAspectFit
        addSubview(giftIconView)
        giftIconView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        countLabel.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        countLabel.textColor = UIColor(red: 1.0, green: 209.0 / 255.0, blue: 92.0 / 255.0, alpha: 1.0)
        countLabel.isHidden = true
        addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.leading.equalTo(giftIconView.snp.trailing).offset(2)
            make.centerY.equalToSuperview()
        }
    }
}

/// Manages up to two send-gift banners in two fixed vertical slots. A new
/// banner enters the top slot; the previous top banner moves to the second
/// slot; the previous second banner fades out and is removed.
public final class LiveSportGiftBannerStack: UIView {

    /// How banners fill the two slots relative to the stack's frame.
    /// `topDown` places the newest banner at the top (portrait, anchored to the
    /// chat top); `bottomUp` places the newest at the bottom so it sits just
    /// above the landscape bottom controls.
    public enum Direction {
        case topDown
        case bottomUp
    }

    private let bannerHeight: CGFloat = 42
    private let slotSpacing: CGFloat = 6
    private let bannerWidth: CGFloat = 202
    private let displayLifetime: TimeInterval = 4.0

    /// Height the stack occupies when both slots are filled; also the fallback
    /// used to position bottom-up banners before the first layout pass.
    private var twoSlotHeight: CGFloat { bannerHeight * 2 + slotSpacing }

    /// Direction in which the two slots stack. Changing it re-lays out any
    /// currently visible banners.
    public var direction: Direction = .topDown {
        didSet {
            guard direction != oldValue else { return }
            repositionBanners()
        }
    }

    /// Index 0 is the top slot, index 1 is the second slot.
    private var banners: [LiveSportGiftBannerView] = []
    private var dismissWorkItems: [LiveSportGiftBannerView: DispatchWorkItem] = [:]

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // Bottom-up positioning depends on the stack's height, which is only
        // known after layout, so re-pin the slots whenever the bounds change.
        if direction == .bottomUp {
            repositionBanners()
        }
    }

    public func clear() {
        dismissWorkItems.values.forEach { $0.cancel() }
        dismissWorkItems.removeAll()
        banners.forEach { $0.removeFromSuperview() }
        banners.removeAll()
    }

    public func show(senderName: String, gift: LiveSportGift, avatar: UIImage?) {
        // Combo aggregation: if a visible banner already represents this gift,
        // bump its multiplier, move it to the top slot, and reset its lifetime
        // instead of creating a new banner.
        if let existing = banners.first(where: { $0.giftID == gift.id }) {
            existing.incrementCount()
            if let index = banners.firstIndex(of: existing), index != 0 {
                banners.remove(at: index)
                banners.insert(existing, at: 0)
            }
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseOut, .beginFromCurrentState]) {
                self.repositionBanners()
            }
            scheduleDismiss(for: existing)
            return
        }

        let banner = LiveSportGiftBannerView()
        banner.configure(senderName: senderName, gift: gift, avatar: avatar)
        addSubview(banner)
        banner.frame = frameForSlot(0)

        // Slide-in from the leading edge with a fade.
        banner.alpha = 0
        banner.transform = CGAffineTransform(translationX: -16, y: 0)

        // Evict the oldest if already at capacity.
        let overflow: LiveSportGiftBannerView? = banners.count >= 2 ? banners.last : nil
        if let overflow = overflow {
            banners.removeLast()
            fadeOutAndRemove(overflow)
        }

        banners.insert(banner, at: 0)

        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            banner.alpha = 1
            banner.transform = .identity
            self.repositionBanners()
        }

        scheduleDismiss(for: banner)
    }

    private func repositionBanners() {
        for (index, banner) in banners.enumerated() {
            banner.frame = frameForSlot(index)
        }
    }

    private func frameForSlot(_ slot: Int) -> CGRect {
        let step = bannerHeight + slotSpacing
        switch direction {
        case .topDown:
            let y = CGFloat(slot) * step
            return CGRect(x: 0, y: y, width: bannerWidth, height: bannerHeight)
        case .bottomUp:
            // Slot 0 (newest) sits at the bottom of the stack; lower slots rise.
            let baseline = max(bounds.height, twoSlotHeight)
            let y = baseline - bannerHeight - CGFloat(slot) * step
            return CGRect(x: 0, y: y, width: bannerWidth, height: bannerHeight)
        }
    }

    private func scheduleDismiss(for banner: LiveSportGiftBannerView) {
        // Cancel any pending dismissal so re-scheduling truly resets the lifetime
        // (used by combo aggregation when the same gift is sent again).
        dismissWorkItems[banner]?.cancel()
        let workItem = DispatchWorkItem { [weak self, weak banner] in
            guard let self = self, let banner = banner else { return }
            guard let index = self.banners.firstIndex(of: banner) else { return }
            self.banners.remove(at: index)
            self.fadeOutAndRemove(banner)
            UIView.animate(withDuration: 0.25) {
                self.repositionBanners()
            }
        }
        dismissWorkItems[banner] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + displayLifetime, execute: workItem)
    }

    private func fadeOutAndRemove(_ banner: LiveSportGiftBannerView) {
        dismissWorkItems[banner]?.cancel()
        dismissWorkItems[banner] = nil
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseIn, .beginFromCurrentState],
                       animations: {
            banner.alpha = 0
        }, completion: { _ in
            banner.removeFromSuperview()
        })
    }
}
