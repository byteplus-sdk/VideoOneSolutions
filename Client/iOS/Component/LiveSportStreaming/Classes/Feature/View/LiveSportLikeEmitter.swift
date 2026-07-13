// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Full-bounds passthrough overlay that renders the double-tap "like" effects:
/// a short burst flash at the finger, a snowflake float rising from the screen's
/// bottom-right corner, and a transient combo badge near the top. It never
/// intercepts touches so the underlying gestures keep working.
public final class LiveSportLikeEmitter: UIView {

    private enum Metrics {
        static let burstSize: CGFloat = 48
        static let burstHold: TimeInterval = 0.15
        static let burstPopDuration: TimeInterval = 0.05
        static let burstFadeDuration: TimeInterval = 0.3

        static let floatSize: CGFloat = 36
        /// Figma node 4513:87593 corridor width.
        static let floatCorridorWidth: CGFloat = 63
        static let floatBottomMargin: CGFloat = 64
        static let floatRightMargin: CGFloat = 16

        /// Gap between the top of the burst icon and the combo badge.
        static let comboGapAboveBurst: CGFloat = 8
        static let comboIdleHideDelay: TimeInterval = 0.6
        static let comboFadeDuration: TimeInterval = 0.25
    }

    private let comboLabel = UILabel()
    private var comboHideWorkItem: DispatchWorkItem?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setupComboBadge()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Burst

    /// Places `icon` at `point` in this view's coordinate space, holds briefly,
    /// then alpha-fades and removes it.
    public func emitBurst(icon: UIImage?, at point: CGPoint) {
        guard let icon = icon else { return }
        let burstView = UIImageView(image: icon)
        burstView.contentMode = .scaleAspectFit
        burstView.frame = CGRect(x: 0, y: 0, width: Metrics.burstSize, height: Metrics.burstSize)
        burstView.center = point
        burstView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        addSubview(burstView)

        UIView.animate(withDuration: Metrics.burstPopDuration,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            burstView.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.burstHold) {
            UIView.animate(withDuration: Metrics.burstFadeDuration,
                           delay: 0,
                           options: [.curveEaseIn, .beginFromCurrentState]) {
                burstView.alpha = 0
            } completion: { _ in
                burstView.removeFromSuperview()
            }
        }
    }

    // MARK: - Snowflake float

    /// Spawns `icon` at the bottom-right (inset by safe area) and animates it up
    /// a swaying snowflake path while rotating, scaling, and fading out.
    public func emitFloat(icon: UIImage?) {
        guard let icon = icon, bounds.height > 0 else { return }

        let floatView = UIImageView(image: icon)
        floatView.contentMode = .scaleAspectFit
        floatView.frame = CGRect(x: 0, y: 0, width: Metrics.floatSize, height: Metrics.floatSize)

        let originX = bounds.width - safeAreaInsets.right - Metrics.floatRightMargin - Metrics.floatSize / 2
        let originY = bounds.height - safeAreaInsets.bottom - Metrics.floatBottomMargin
        let origin = CGPoint(x: originX, y: originY)
        floatView.center = origin
        addSubview(floatView)

        let riseHeight = min(CGFloat.random(in: 200...320), originY - safeAreaInsets.top)
        let duration = Double.random(in: 2.5...3.0)

        let path = makeSnowflakePath(from: origin, riseHeight: riseHeight)

        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.path = path.cgPath
        positionAnimation.duration = duration
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        positionAnimation.calculationMode = .paced

        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        let rotationDirection: CGFloat = Bool.random() ? 1 : -1
        rotation.toValue = rotationDirection * CGFloat.random(in: 0.1...0.5)
        rotation.duration = duration

        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.values = [0.6, 1.1, 1.0, 0.9]
        scale.keyTimes = [0.0, 0.2, 0.5, 1.0]
        scale.duration = duration

        let fade = CAKeyframeAnimation(keyPath: "opacity")
        fade.values = [0.0, 1.0, 1.0, 0.0]
        fade.keyTimes = [0.0, 0.12, 0.7, 1.0]
        fade.duration = duration

        let group = CAAnimationGroup()
        group.animations = [positionAnimation, rotation, scale, fade]
        group.duration = duration
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        floatView.layer.add(group, forKey: "like_snowflake")

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            floatView.removeFromSuperview()
        }
    }

    /// Samples a sine wave so the icon sways left/right as it rises — the
    /// "snowflake" motion implied by the Figma corridor.
    private func makeSnowflakePath(from origin: CGPoint, riseHeight: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: origin)

        let amplitude = Metrics.floatCorridorWidth / 2
        let phase = CGFloat.random(in: 0...(2 * .pi))
        let waves = CGFloat.random(in: 1.5...2.5)
        let steps = 24

        for step in 1...steps {
            let progress = CGFloat(step) / CGFloat(steps)
            let y = origin.y - riseHeight * progress
            // Sway decays slightly as it rises so the top of the corridor is tighter.
            let sway = amplitude * (1.0 - progress * 0.35) * sin(phase + waves * .pi * progress)
            let x = origin.x - amplitude * 0.5 + sway
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }

    // MARK: - Combo badge

    private func setupComboBadge() {
        comboLabel.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        comboLabel.textColor = .white
        comboLabel.textAlignment = .center
        comboLabel.alpha = 0
        comboLabel.layer.shadowColor = UIColor.black.cgColor
        comboLabel.layer.shadowOpacity = 0.35
        comboLabel.layer.shadowRadius = 3
        comboLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        addSubview(comboLabel)
    }

    /// Updates the combo badge to `x<count>`, positions it just above the burst
    /// icon at `point`, makes it visible, and resets the idle hide timer.
    public func updateCombo(count: Int, at point: CGPoint) {
        comboHideWorkItem?.cancel()
        comboLabel.layer.removeAllAnimations()
        comboLabel.transform = .identity

        comboLabel.text = "x\(count)"
        comboLabel.sizeToFit()
        comboLabel.center = CGPoint(x: point.x,
                                    y: point.y - Metrics.burstSize / 2 - Metrics.comboGapAboveBurst - comboLabel.bounds.height / 2)

        comboLabel.alpha = 1
        comboLabel.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        UIView.animate(withDuration: 0.18,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: [.beginFromCurrentState]) {
            self.comboLabel.transform = .identity
        }

        let hideWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: Metrics.comboFadeDuration,
                           delay: 0,
                           options: [.curveEaseIn, .beginFromCurrentState]) {
                self.comboLabel.alpha = 0
            }
        }
        comboHideWorkItem = hideWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.comboIdleHideDelay, execute: hideWorkItem)
    }

    /// Cancels any pending hide and immediately clears the badge.
    public func resetCombo() {
        comboHideWorkItem?.cancel()
        comboHideWorkItem = nil
        comboLabel.layer.removeAllAnimations()
        comboLabel.alpha = 0
    }
}
