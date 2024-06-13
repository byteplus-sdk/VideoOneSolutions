//
//  ViewController.swift
//  ApiExample
//
//  Created by bytedance on 2023/9/22.
//  Copyright © 2021 bytedance. All rights reserved.
//

import UIKit
import BytePlusRTC

public struct EntryStruct {
    let entryTitle: String
    let className: String
}

@objc(APIViewController)
public class APIViewController: UIViewController {
    public struct GroupStruct {
        let title: String
        let list: [EntryStruct]
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buildUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            self.backButton.isHidden = false
        } else {
            self.backButton.isHidden = true
        }
    }

   func buildUI(){
       self.view.backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 247/255, alpha: 1.0)
       
       self.view.addSubview(backgroundView)
       backgroundView.snp.makeConstraints { make in
           make.top.equalToSuperview()
           make.left.right.equalTo(self.view)
       }
       
       self.view.addSubview(self.backButton)
       self.backButton.snp.makeConstraints { make in
           make.size.equalTo(CGSize(width: 20, height: 20))
           make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
           make.left.equalTo(16)
       }
       
       self.view.addSubview(headerLabel)
       headerLabel.snp.makeConstraints { make in
           make.top.equalTo(backButton.snp.bottom).offset(30)
           make.left.equalTo(backButton)
       }
       
       self.view.addSubview(versionLabel)
       versionLabel.snp.makeConstraints { make in
           make.top.equalTo(headerLabel.snp.bottom).offset(10)
           make.left.equalTo(headerLabel)
       }
       
       self.view.addSubview(self.mainScrollView)
       self.mainScrollView.snp.makeConstraints { make in
           make.top.equalTo(versionLabel.snp.bottom).offset(18)
           make.left.right.bottom.equalTo(self.view)
       }
       
       self.mainScrollView.addSubview(self.mainContentView)
       self.mainContentView.snp.makeConstraints { make in
           make.edges.equalTo(mainScrollView)
           make.width.equalTo(mainScrollView)
       }
       
       var aboveModelView: APIModelView?

       for (index, group) in dataArray.enumerated() {
           let modelView = APIModelView(list: group.list, title: group.title)
           mainContentView.addSubview(modelView)
           modelView.snp.makeConstraints { make in
               make.left.width.equalToSuperview()
               make.height.equalTo(24 + (52 * group.list.count))
               if let aboveView = aboveModelView {
                   make.top.equalTo(aboveView.snp.bottom).offset(16)
               } else {
                   make.top.equalToSuperview()
               }
               if index == dataArray.count - 1 {
                   make.bottom.lessThanOrEqualTo(mainContentView.snp.bottom)
               }
           }
           aboveModelView = modelView
           modelView.buttonAction = { [weak self] entryStruct in
               self?.presentVC(titleName: entryStruct.entryTitle,
                               className: entryStruct.className)
           }
       }
    }
    
    func presentVC(titleName: String, className: String) {
        if NSClassFromString("RTCAPIExample." + className) is UIViewController.Type {
            let classType = NSClassFromString("RTCAPIExample." + className) as! BaseViewController.Type

            let viewController = classType.init()
            viewController.titleText = titleName
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    lazy var dataArray: [GroupStruct] = {
        [GroupStruct(
            title: LocalizedString("label_example_base"),
            list: [
                EntryStruct(entryTitle: LocalizedString("example_quick_start"),
                            className: "QuickStartViewController")
            ]
        ),
         GroupStruct(
            title: LocalizedString("label_example_room"),
            list: [
                EntryStruct(entryTitle: LocalizedString("example_multi_room"),
                            className: "MutiRoomViewController")
            ]
         ),
         GroupStruct(
            title: LocalizedString("label_example_transmission"),
            list: [
                EntryStruct(entryTitle: LocalizedString("example_cross_room_pk"),
                            className: "CrossRoomPKViewController")
            ]
         ),
         GroupStruct(
            title: LocalizedString("label_example_audio"),
            list: [
                EntryStruct(entryTitle: LocalizedString("example_raw_audio_data"),
                            className: "AudioRawDataViewController"),
                EntryStruct(entryTitle: LocalizedString("title_audio_effect_mixing"),
                            className: "AudioEffectMixingViewController"),
                EntryStruct(entryTitle: LocalizedString("title_audio_media_mixing"),
                            className: "AudioMediaMixingViewController"),
                EntryStruct(entryTitle: LocalizedString("example_voice_effect"),
                            className: "SoundEffectsViewController")
            ]
         ),
         GroupStruct(
            title: LocalizedString("label_example_video"),
            list: [
                EntryStruct(entryTitle: LocalizedString("example_picture_in_picture"),
                            className: "PipViewController"),
                EntryStruct(entryTitle: LocalizedString("example_video_config"),
                            className: "CommonVideoConfigViewController"),
                EntryStruct(entryTitle: LocalizedString("example_video_rotation"),
                            className: "VideoRotationViewController")
            ]
         ),
         GroupStruct(
            title: LocalizedString("label_example_important"),
            list: [
                EntryStruct(entryTitle: LocalizedString("title_byte_beauty"),
                            className: "VolcBeautyViewController"),
                EntryStruct(entryTitle: LocalizedString("example_cdn_stream"),
                            className: "PushCDNViewController")
            ]
         ),
         GroupStruct(
            title: LocalizedString("label_example_message"),
            list: [
                EntryStruct(entryTitle: LocalizedString("example_sei_messaging"),
                            className: "SEIViewController"),
                EntryStruct(entryTitle: LocalizedString("example_stream_sync_info"),
                            className: "AudioSEIViewController")
            ]
         )]
    }()
    
    lazy var backButton: UIButton = {
        guard let bundle = Bundle.main.path(forResource: "APIExample", ofType: "bundle"),
              let resourceBundle = Bundle(path: bundle),
              let image = UIImage(named: "back_button", in: resourceBundle, compatibleWith: nil)
        else {
            return UIButton()
        }
        
        let backButton = UIButton()
        backButton.setImage(image, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return backButton
    }()
    
    lazy var backgroundView: UIImageView = {
        guard let bundle = Bundle.main.path(forResource: "APIExample", ofType: "bundle"),
              let resourceBundle = Bundle(path: bundle),
              let image = UIImage(named: "background", in: resourceBundle, compatibleWith: nil)
        else {
            return UIImageView()
        }
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.text = LocalizedString("api_example_name")
        headerLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        headerLabel.textColor = UIColor(red: 17/255, green: 18/255, blue: 1/255, alpha: 1.0)
        headerLabel.sizeToFit()
        return headerLabel
    }()

    lazy var versionLabel: UILabel = {
        let versionLabel = UILabel()
        let experiencingTitle = LocalizedString("sdk_version_%@")
        versionLabel.text = String(format: experiencingTitle, ByteRTCVideo.getSDKVersion())
        versionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        versionLabel.textColor = UIColor(red: 66/255, green: 70/255, blue: 78/255, alpha: 1.0)
        versionLabel.sizeToFit()
        return versionLabel
    }()
    
    lazy var mainScrollView : UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    lazy var mainContentView : UIView = {
        let view = UIView.init()
        view.backgroundColor = .clear
        return view
    }()
}


public class APIModelView: UIView {
    var textLabel: UILabel
    var contentView: UIView
    var buttonAction: ((EntryStruct) -> Void)?
    
    init(list: [EntryStruct], title: String) {
        textLabel = UILabel()
        textLabel.text = title
        textLabel.numberOfLines = 1
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textColor = UIColor(red: 115/255, green: 122/255, blue: 135/255, alpha: 1.0)
        
        contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        super.init(frame: .zero)
        addSubview(textLabel)
        addSubview(contentView)
        layoutUI()
        
        var aboveItemView: APIModelItemView?
        for entryStruct in list {
            let view = APIModelItemView(entryStruct: entryStruct)
            contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.right.left.equalToSuperview()
                make.height.equalTo(52)
                if let aboveView = aboveItemView {
                    make.top.equalTo(aboveView.snp.bottom).offset(0)
                } else {
                    make.top.equalToSuperview()
                }
                aboveItemView = view
            }
            view.buttonAction = { [weak self] entryStruct in
                self?.buttonAction?(entryStruct)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutUI() {
        textLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(32)
            make.height.equalTo(20)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
}

public class APIModelItemView: UIView {
    var textLabel: UILabel
    var innerButton: UIButton
    var buttonAction: ((EntryStruct) -> Void)?
    let curEntryStruct: EntryStruct
    
    init(entryStruct: EntryStruct) {
        curEntryStruct = entryStruct;
        textLabel = UILabel()
        textLabel.text = entryStruct.entryTitle
        textLabel.numberOfLines = 1
        textLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textLabel.textColor = UIColor(red: 22/255, green: 24/255, blue: 1/255, alpha: 1.0)
        
        innerButton = UIButton(type: .custom)
        innerButton.backgroundColor = .clear
        
        super.init(frame: .zero)
        innerButton.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
        
        addSubview(textLabel)
        addSubview(innerButton)
        addSubview(moreImageView)
        addSubview(lineView)
        layoutUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutUI() {
        textLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(moreImageView.snp.left).offset(-5)
        }
        
        innerButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        moreImageView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.bottom.right.equalToSuperview()
        }
    }

    @objc private func handleButtonAction() {
        buttonAction?(curEntryStruct)
    }
    
    lazy var moreImageView: UIImageView = {
        guard let bundle = Bundle.main.path(forResource: "APIExample", ofType: "bundle"),
              let resourceBundle = Bundle(path: bundle),
              let image = UIImage(named: "right_arrow", in: resourceBundle, compatibleWith: nil)
        else {
            return UIImageView()
        }
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 244/255, green: 245/255, blue: 247/255, alpha: 1.0)
        return view
    }()
}
