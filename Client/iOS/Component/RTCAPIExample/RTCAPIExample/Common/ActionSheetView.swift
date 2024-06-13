//
//  ActionSheetView.swift
//  ApiExample
//
//  Created by bytedance on 2023/10/13.
//  Copyright © 2021 bytedance. All rights reserved.
//

import UIKit

class ActionSheetView: UIView {
    
    weak var presentingViewController: UIViewController?
    var title: String?
    var optionArray: [String]?
    var defaultIndex: Int?
    var selectedIndex: Int?
    
    var didSelectOption: ((Int) -> Void)?
    
    init(title: String, optionArray: [String], defaultIndex: Int) {
        super.init(frame: CGRect.zero)
        
        self.layer.cornerRadius = 5
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        self.addSubview(selectedOptionField)
        selectedOptionField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.bottom.right.equalToSuperview().offset(-2)
            make.left.equalTo(titleLabel.snp.right).offset(10)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showOptions))
        selectedOptionField.isUserInteractionEnabled = true
        selectedOptionField.addGestureRecognizer(tapGesture)
        
        self.title = title
        self.optionArray = optionArray
        self.defaultIndex = defaultIndex
        self.selectedIndex = defaultIndex
        titleLabel.text = title + ":"
        updateSelectedOption()
        
        if let bundle = Bundle.main.path(forResource: "APIExample", ofType: "bundle") {
            let resourceBundle = Bundle(path: bundle)
            if let image = UIImage(named: "down_arrow", in: resourceBundle, compatibleWith: nil) {
                let viewContainer = UIView()
                let imageView = UIImageView(image: image)
                imageView.isUserInteractionEnabled = true
                viewContainer.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.height.equalTo(16)
                    make.edges.equalTo(UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
                }
                
                self.addSubview(viewContainer)
                viewContainer.snp.makeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview().offset(-2)
                }
            }
        }
    }
    
    @objc private func showOptions() {
        guard let array = optionArray else {
            return
        }
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for (index, option) in array.enumerated() {
            let action = UIAlertAction(title: option, style: .default) { [weak self] _ in
                self?.selectedIndex = index
                self?.didSelectOption?(index)
                self?.updateSelectedOption()
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: LocalizedString("button_cancel"), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self
            presenter.sourceRect = self.bounds
        }
        
        presentingViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func updateSelectedOption() {
        if let index = selectedIndex, let option = optionArray?[index] {
            selectedOptionField.text = option
        } else {
            selectedOptionField.text = ""
        }
    }
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        return lbl
    }()
    
    private let selectedOptionField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        return field
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
