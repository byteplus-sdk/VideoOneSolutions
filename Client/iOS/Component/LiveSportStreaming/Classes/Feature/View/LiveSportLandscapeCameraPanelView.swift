// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

/// Landscape multi-camera panel shown as a right-side slide-in list.
public final class LiveSportLandscapeCameraPanelView: UIView {

    public struct Item {
        public let channel: LiveStreamChannel
        public let image: UIImage?

        public init(channel: LiveStreamChannel, image: UIImage?) {
            self.channel = channel
            self.image = image
        }
    }

    public static let preferredWidth: CGFloat = 247

    public var onSelectChannel: ((LiveStreamChannel) -> Void)?

    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let listStackView = UIStackView()
    private var items: [Item] = []
    private var selectedId: String?
    private var isPlaying: Bool = true
    private var itemViews: [LandscapeCameraItemView] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(items: [Item], selectedId: String?, isPlaying: Bool) {
        self.items = items
        self.selectedId = selectedId
        self.isPlaying = isPlaying
        rebuildItems()
    }

    private func setupSubviews() {
        backgroundColor = UIColor(red: 44.0 / 255.0, green: 44.0 / 255.0, blue: 44.0 / 255.0, alpha: 1.0)

        addSubview(titleLabel)
        titleLabel.text = LiveSportL10n("live_sport_multi_camera")
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .white
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        scrollView.addSubview(listStackView)
        listStackView.axis = .vertical
        listStackView.spacing = 0
        listStackView.alignment = .fill
        listStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    private func rebuildItems() {
        itemViews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()
        listStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in items {
            let itemView = LandscapeCameraItemView()
            let isSelected = item.channel.id == selectedId
            itemView.configure(channel: item.channel,
                               image: item.image,
                               selected: isSelected,
                               isPlaying: isPlaying)
            itemView.onTap = { [weak self] in
                self?.onSelectChannel?(item.channel)
            }
            listStackView.addArrangedSubview(itemView)
            itemViews.append(itemView)
        }
    }
}

private final class LandscapeCameraItemView: UIView {

    var onTap: (() -> Void)?

    private let previewContainerView = UIView()
    private let previewImageView = UIImageView()
    private let dimView = UIView()
    private let waveView = LandscapeCameraWaveView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(channel: LiveStreamChannel, image: UIImage?, selected: Bool, isPlaying: Bool) {
        previewImageView.image = image
        titleLabel.text = channel.title
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: selected ? .semibold : .regular)
        titleLabel.alpha = selected ? 1.0 : 0.8
        previewContainerView.layer.borderWidth = selected ? 2 : 0
        previewContainerView.layer.borderColor = UIColor.white.cgColor
        dimView.isHidden = !selected
        if selected && isPlaying {
            waveView.startAnimating()
        } else {
            waveView.stopAnimating()
        }
    }

    private func setupSubviews() {
        addSubview(previewContainerView)
        addSubview(titleLabel)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        previewContainerView.layer.cornerRadius = 4
        previewContainerView.layer.masksToBounds = true
        previewContainerView.isUserInteractionEnabled = false
        previewContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.width.equalTo(80)
            make.height.equalTo(46)
        }

        previewImageView.contentMode = .scaleAspectFill
        previewContainerView.addSubview(previewImageView)
        previewImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.69)
        dimView.isHidden = true
        previewContainerView.addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        previewContainerView.addSubview(waveView)
        waveView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 14, height: 10))
        }

        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(previewContainerView.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview()
            make.centerY.equalTo(previewContainerView)
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}

private final class LandscapeCameraWaveView: UIView {

    private let barLayers: [CAShapeLayer] = (0..<4).map { _ in CAShapeLayer() }
    private var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setupBars()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateBarPaths()
    }

    func startAnimating() {
        guard !isAnimating else { return }
        isHidden = false
        isAnimating = true
        updateBarPaths()
        for (index, layer) in barLayers.enumerated() {
            let animation = CABasicAnimation(keyPath: "transform.scale.y")
            animation.fromValue = 0.45
            animation.toValue = 1.0
            animation.duration = 0.45
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.08
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(animation, forKey: "camera_wave")
        }
    }

    func stopAnimating() {
        isAnimating = false
        isHidden = true
        barLayers.forEach { $0.removeAllAnimations() }
    }

    private func setupBars() {
        barLayers.forEach { layer in
            layer.fillColor = UIColor.white.cgColor
            self.layer.addSublayer(layer)
        }
        isHidden = true
    }

    private func updateBarPaths() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let barWidth: CGFloat = 2
        let spacing: CGFloat = 2
        let heights: [CGFloat] = [0.55, 1.0, 0.75, 0.42]
        let totalWidth = CGFloat(barLayers.count) * barWidth + CGFloat(barLayers.count - 1) * spacing
        let startX = (bounds.width - totalWidth) / 2.0
        for (index, layer) in barLayers.enumerated() {
            let x = startX + CGFloat(index) * (barWidth + spacing)
            let height = max(bounds.height * heights[index], 3)
            let y = (bounds.height - height) / 2.0
            let path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: height),
                                    cornerRadius: barWidth / 2.0)
            layer.path = path.cgPath
        }
    }
}
