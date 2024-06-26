//
//  BaseViewController.swift
//  ApiExample
//
//  Created by bytedance on 2023/9/28.
//  Copyright © 2021 bytedance. All rights reserved.
//

import UIKit

class BaseViewController : UIViewController {
    @objc var titleText :String = "" {
        didSet {
            self.titleLabel.text = titleText;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    deinit {
        print("class: \(type(of: self)) func: \(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        
        self.view.addSubview(self.topView)
        self.topView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            
            let topSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
            make.height.equalTo(44 + topSafeArea)
        }
        
        self.topView.addSubview(self.backButton)
        self.backButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.left.equalTo(16)
            make.bottom.equalTo(self.topView).offset(-10)
        }
        
        self.topView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.topView)
            make.centerY.equalTo(self.backButton)
        }
        
        self.topView.addSubview(self.lineView)
        self.lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.bottom.right.equalToSuperview()
        }
    }

    override func orientationDidChang(_ isLandscape: Bool) {
        super.orientationDidChang(isLandscape)
        self.topView.snp.updateConstraints { make in
            let topSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
            make.height.equalTo(isLandscape ? 44 : 44 + topSafeArea)
        }
    }
    
    // MARK: Private method
    @objc func buttonTapped() {
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: Lazy laod
    public lazy var topView : UIView = {
        let topView:UIView = UIView.init()
        topView.backgroundColor = .white
        return topView
    }()
    
    lazy var backButton: UIButton = {
        guard let bundle = Bundle.main.path(forResource: "APIExample", ofType: "bundle"),
              let resourceBundle = Bundle(path: bundle),
              let image = UIImage(named: "back_button", in: resourceBundle, compatibleWith: nil)
        else {
            return UIButton()
        }
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        return titleLabel
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 247/255, alpha: 1.0)
        return view
    }()
}
