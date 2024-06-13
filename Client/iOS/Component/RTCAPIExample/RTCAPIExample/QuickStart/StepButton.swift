//
//  StepButton.swift
//  ApiExample
//
//  Created by bytedance on 2023/11/3.
//  Copyright © 2021 bytedance. All rights reserved.
//

import SnapKit
import UIKit

class StepButton: UIButton {

    var textLabel: UILabel
    var innerButton: UIButton
    var buttonAction: (() -> Void)?

    init(labelText: String, buttonText: String) {
        textLabel = UILabel()
        textLabel.text = labelText
        textLabel.numberOfLines = 2
        textLabel.font = UIFont.systemFont(ofSize: 14)
        
        innerButton = UIButton(type: .custom)
        innerButton.titleLabel?.adjustsFontSizeToFitWidth = true
        innerButton.titleLabel?.numberOfLines = 1;
        innerButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        innerButton.setTitle(buttonText, for: .normal)
        innerButton.backgroundColor = .systemBlue
        innerButton.setTitleColor(.white, for: .normal)
        innerButton.layer.cornerRadius = 5
        innerButton.layer.masksToBounds = true
        
        super.init(frame: .zero)
        
        addSubview(textLabel)
        addSubview(innerButton)
        innerButton.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
        
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutUI() {
        textLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(innerButton.snp.left).offset(-5)
        }
        
        innerButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(144)
            make.height.equalTo(30)
        }
    }

    @objc private func handleButtonAction() {
        buttonAction?()
    }
}
