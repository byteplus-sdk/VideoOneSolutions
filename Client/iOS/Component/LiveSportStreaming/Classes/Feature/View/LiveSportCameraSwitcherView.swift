// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import SnapKit

public final class LiveSportCameraSwitcherView: UIView {

    public struct Item {
        public let channel: LiveStreamChannel
        public let image: UIImage?

        public init(channel: LiveStreamChannel, image: UIImage?) {
            self.channel = channel
            self.image = image
        }
    }

    public var onToggleExpanded: (() -> Void)?
    public var onSelectChannel: ((LiveStreamChannel) -> Void)?

    private let headerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private let contentView = UIView()
    private let collectionView: UICollectionView
    private var contentHeightConstraint: Constraint?
    private var items: [Item] = []
    private var displayItems: [Item] = []
    private var selectedId: String?
    private var isPlaying: Bool = true
    private var isExpanded: Bool = true

    public var preferredHeight: CGFloat {
        isExpanded ? 121 : 41
    }

    public override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    public func configure(items: [Item], selectedId: String?, isPlaying: Bool, isExpanded: Bool) {
        self.items = items
        self.displayItems = items
        self.selectedId = selectedId
        self.isPlaying = isPlaying
        collectionView.reloadData()
        setExpanded(isExpanded, animated: false)
    }

    public func setExpanded(_ expanded: Bool, animated: Bool) {
        guard isExpanded != expanded || !animated else { return }
        isExpanded = expanded
        toggleButton.setImage(LiveSportImage(named: "sport_watcher_arrow_white_up")?.withRenderingMode(.alwaysOriginal), for: .normal)
        contentHeightConstraint?.update(offset: expanded ? 69 : 0)
        let animations = {
            self.contentView.alpha = expanded ? 1.0 : 0.0
            self.contentView.transform = expanded ? .identity : CGAffineTransform(translationX: 0, y: -8)
            self.toggleButton.transform = expanded ? .identity : CGAffineTransform(rotationAngle: .pi)
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.28,
                           delay: 0,
                           usingSpringWithDamping: 0.92,
                           initialSpringVelocity: 0.15,
                           options: [.curveEaseInOut, .beginFromCurrentState],
                           animations: animations)
        } else {
            animations()
        }
    }

    @objc
    private func handleHeaderTap() {
        onToggleExpanded?()
    }

    private func setupSubviews() {
        backgroundColor = UIColor(red: 9.0 / 255.0, green: 18.0 / 255.0, blue: 27.0 / 255.0, alpha: 0.29)
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        addSubview(headerView)

        let headerTap = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap))
        headerView.addGestureRecognizer(headerTap)

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(41)
        }

        iconView.image = LiveSportImage(named: "sport_watcher_mutil_camera")
        iconView.contentMode = .scaleAspectFit
        headerView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 12, height: 12))
        }

        titleLabel.text = LiveSportL10n("live_sport_multi_camera")
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .white
        headerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }

        toggleButton.setImage(LiveSportImage(named: "sport_watcher_arrow_white_up")?.withRenderingMode(.alwaysOriginal), for: .normal)
        toggleButton.imageView?.contentMode = .scaleAspectFit
        toggleButton.isUserInteractionEnabled = false
        headerView.addSubview(toggleButton)
        toggleButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }

        addSubview(contentView)
        contentView.clipsToBounds = true
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-19)
            self.contentHeightConstraint = make.height.equalTo(69).constraint
        }

        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = .zero
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CameraItemCell.self, forCellWithReuseIdentifier: CameraItemCell.reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LiveSportCameraSwitcherView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayItems.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraItemCell.reuseIdentifier,
                                                            for: indexPath) as? CameraItemCell else {
            return UICollectionViewCell()
        }
        let item = displayItems[indexPath.item]
        cell.configure(channel: item.channel,
                       image: item.image,
                       selected: item.channel.id == selectedId,
                       isPlaying: isPlaying)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard displayItems.indices.contains(indexPath.item) else { return }
        onSelectChannel?(displayItems[indexPath.item].channel)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let visibleColumns = min(max(displayItems.count, 1), 4)
        let totalSpacing = CGFloat(max(visibleColumns - 1, 0)) * 12.0
        let width = floor((collectionView.bounds.width - totalSpacing) / CGFloat(visibleColumns))
        return CGSize(width: max(width, 64), height: 69)
    }
}

private final class CameraItemCell: UICollectionViewCell {
    static let reuseIdentifier = "CameraItemCell"

    private let previewContainerView = UIView()
    private let previewImageView = UIImageView()
    private let dimView = UIView()
    private let statusContainerView = UIView()
    private let playIconView = UIImageView()
    private let waveView = CameraWaveView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
        waveView.stopAnimating()
    }

    func configure(channel: LiveStreamChannel, image: UIImage?, selected: Bool, isPlaying: Bool) {
        previewImageView.image = image
        titleLabel.text = channel.title
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: selected ? .semibold : .regular)
        titleLabel.alpha = selected ? 1.0 : 0.8
        previewContainerView.layer.borderWidth = selected ? 2 : 0
        previewContainerView.layer.borderColor = UIColor.white.cgColor
        dimView.isHidden = !selected
        statusContainerView.isHidden = !selected
        playIconView.image = LiveSportImage(named: "sport_video_play")
        playIconView.isHidden = selected && isPlaying
        if selected && isPlaying {
            waveView.startAnimating()
        } else {
            waveView.stopAnimating()
        }
    }

    private func setupSubviews() {
        contentView.addSubview(previewContainerView)
        contentView.addSubview(titleLabel)

        previewContainerView.layer.cornerRadius = 4
        previewContainerView.layer.masksToBounds = true
        previewContainerView.isUserInteractionEnabled = false
        previewContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
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

        previewContainerView.addSubview(statusContainerView)
        statusContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 14, height: 10))
        }

        playIconView.contentMode = .scaleAspectFit
        statusContainerView.addSubview(playIconView)
        playIconView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        statusContainerView.addSubview(waveView)
        waveView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(previewContainerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
    }
}

private final class CameraWaveView: UIView {

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
