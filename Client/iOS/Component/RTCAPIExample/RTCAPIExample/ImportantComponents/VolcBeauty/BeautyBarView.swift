//
//  BeautyBarView.swift
//  ApiExample
//
//  Created by bytedance on 2023/10/31.
//  Copyright © 2021 bytedance. All rights reserved.
//

import UIKit
import SnapKit

protocol BeautyBarViewDelegate: NSObjectProtocol {
    func beautyBarView(barView: BeautyBarView, didClickedEffect model: EffectModel)
    func beautyBarView(barView: BeautyBarView, didChangeEffectValue model: EffectModel)
}

class BeautyBarView: UIView {
    
    weak var delegate: BeautyBarViewDelegate?
    
    var segment: UISegmentedControl!
    var sliderLabel: UILabel!
    var slider: UISlider!
    var buttonListView: UIView!
    
    var dataArray = [[EffectModel]]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        // Segment
        segment = UISegmentedControl(items: BeautyModel.sectionList())
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        self.addSubview(segment)
        segment.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        
        // SliderLabel
        sliderLabel = UILabel()
        sliderLabel.font = UIFont.systemFont(ofSize: 17)
        sliderLabel.text = LocalizedString("label_beauty_intensity")
        self.addSubview(sliderLabel)
        sliderLabel.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(segment.snp.bottom).offset(35)
        }
        
        // Slider
        slider = UISlider()
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        self.addSubview(slider)
        slider.snp.makeConstraints { make in
            make.centerY.equalTo(sliderLabel)
            make.left.equalTo(sliderLabel.snp.right).offset(30)
            make.right.equalTo(-20)
        }
        
        // Button list view
        buttonListView = UIView()
        self.addSubview(buttonListView)
        buttonListView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(segment.snp.bottom).offset(90)
            make.bottom.equalTo(self)
            make.right.equalTo(-20)
        }
        
        loadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private action
    @objc func buttonClicked(button: UIButton) {
        for case let subButton as EffectButton in buttonListView.subviews {
            if subButton == button {
                switch segment.selectedSegmentIndex {
                case 0:  // Beauty
                    subButton.isSelected = true
                    subButton.model!.selected = true
                    slider.value = subButton.model!.value
                case 1:  // Filter
                    subButton.isSelected = true
                    subButton.model!.selected = true
                    subButton.model!.value = 0
                    slider.value = subButton.model!.value
                case 2, 3:  // Stickers, background segmentation
                    subButton.isSelected = !subButton.isSelected
                    subButton.model!.selected = subButton.isSelected
                default:
                    // Error
                    break
                }
                
                (delegate)?.beautyBarView(barView: self, didClickedEffect: subButton.model!)
            } else {
                subButton.isSelected = false
                subButton.model!.selected = false
            }
        }
    }
    
    
    @objc func segmentValueChanged(segment: UISegmentedControl) {
        let modelArray = dataArray[segment.selectedSegmentIndex]
        
        buttonListView.subviews.forEach { $0.removeFromSuperview() }
        
        for i in 0..<modelArray.count {
            let model = modelArray[i]
            let button = EffectButton()
            button.model = model
            
            button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            
            buttonListView.addSubview(button)
            
            let row = i / 4
            let col = i % 4
            button.snp.makeConstraints { make in
                make.top.equalTo(row * (30 + 36))
                make.centerX.equalTo(buttonListView).multipliedBy(0.5 * CGFloat(col) + 0.25)
                make.width.equalTo(70)
                make.height.equalTo(36)
            }
        }
        
        switch segment.selectedSegmentIndex {
        case 0:  // Beauty
            buttonListView.snp.updateConstraints { make in
                make.top.equalTo(segment.snp.bottom).offset(90)
            }
            sliderLabel.text = LocalizedString("label_beauty_intensity")
            sliderLabel.isHidden = false
            slider.isHidden = false
            
            if let button = buttonListView.subviews.first as? EffectButton {
                button.isSelected = true
                let model = modelArray[0]
                slider.value = Float(model.value)
            }
            
        case 1:  // Filter
            buttonListView.snp.updateConstraints { make in
                make.top.equalTo(segment.snp.bottom).offset(90)
            }
            sliderLabel.text = LocalizedString("label_filter_intensity")
            sliderLabel.isHidden = false
            slider.isHidden = false
            
            var selected = false
            for case let button as EffectButton in buttonListView.subviews {
                if button.model!.selected {
                    button.isSelected = true
                    slider.value = Float(button.model!.value)
                    selected = true
                }
            }
            
            if !selected {
                // If it has not been selected before, it defaults to the first one.
                if let button = buttonListView.subviews.first as? EffectButton {
                    button.isSelected = true
                    let model = modelArray[0]
                    slider.value = Float(model.value)
                }
            }
            
        case 2:  // Sticker
            buttonListView.snp.updateConstraints { make in
                make.top.equalTo(segment.snp.bottom).offset(36)
            }
            sliderLabel.isHidden = true
            slider.isHidden = true
            
            for case let button as EffectButton in buttonListView.subviews {
                button.isSelected = button.model!.selected
            }
            
        case 3:  // Background segmentation
            buttonListView.snp.updateConstraints { make in
                make.top.equalTo(segment.snp.bottom).offset(36)
            }
            sliderLabel.isHidden = true
            slider.isHidden = true
            
            var selected = false
            for case let button as EffectButton in buttonListView.subviews {
                if button.model!.selected {
                    button.isSelected = true
                    selected = true
                }
            }
            
            if !selected {
                // It has not been selected before, the default is the first one
                if let button = buttonListView.subviews.first as? EffectButton {
                    button.isSelected = false
                }
            }
            
        default:
            break
        }
    }
    
    @objc func sliderValueChanged(slider: UISlider) {
        for case let button as EffectButton in buttonListView.subviews {
            if button.isSelected {
                button.model!.value = slider.value
                (delegate)?.beautyBarView(barView: self, didChangeEffectValue: button.model!)
            }
        }
    }
    
    func loadData() {
        var jsonList = [[Dictionary<String, Any>]]()
        jsonList.append(BeautyModel.beautyList())
        jsonList.append(BeautyModel.filterList())
        jsonList.append(BeautyModel.stickerList())
        jsonList.append(BeautyModel.virtualBackgroundList())
        
        for i in 0..<jsonList.count {
            let sectionList = jsonList[i]
            var modelList = [EffectModel]()
            for j in 0..<sectionList.count {
                let model = EffectModel()
                model.type = EffectModelType(rawValue: i)!
                model.selected = false
                model.value = 0
                model.name = sectionList[j]["name"] as? String
                model.key = sectionList[j]["key"] as? String
                model.subType = sectionList[j]["subType"] as? EffectModelSubType
                modelList.append(model)
            }
            dataArray.append(modelList)
        }
        
        segmentValueChanged(segment: segment)
    }
    
}
