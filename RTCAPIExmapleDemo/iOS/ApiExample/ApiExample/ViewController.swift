//
//  ViewController.swift
//  ApiExample
//
//  Created by bytedance on 2023/9/22.
//  Copyright © 2021 bytedance. All rights reserved.
//

import UIKit
import SnapKit
import BytePlusRTC

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buildUI()
    }

   func buildUI(){
       self.view.backgroundColor = .white
       
       self.view.addSubview(logoImageView)

       logoImageView.snp.makeConstraints { make in
           make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
           make.centerX.equalTo(self.view)
       }
       
       self.view.addSubview(backgroundView)

       backgroundView.snp.makeConstraints { make in
           make.top.equalTo(logoImageView.snp.bottom).offset(20)
           make.left.right.equalTo(self.view)
       }
       
       self.view.addSubview(headerLabel)

       headerLabel.snp.makeConstraints { make in
           make.top.equalTo(backgroundView).offset(20)
           make.left.equalTo(self.view).offset(10)
       }
       
       self.view.addSubview(versionLabel)
       versionLabel.snp.makeConstraints { make in
           make.top.equalTo(headerLabel.snp.bottom).offset(10)
           make.left.equalTo(headerLabel)
       }
       
       self.view.addSubview(self.tableview)
       self.tableview.snp.makeConstraints { make in
           make.top.equalTo(versionLabel.snp.bottom)
           make.left.right.bottom.equalTo(self.view)
       }
    }
    
    lazy var dataArray : [[String:[[String:String]]]] = {
      
        let dic0 = [getString(key: "funNameQuickStart"):"QuickStartViewController"];
        let grpup0 = [getString(key: "categoryNameBasicFun"):[dic0]]
        
        let dic1 = [getString(key: "funNameMultiRoom"):"MutiRoomViewController"];
        let grpup1 = [getString(key: "categoryNameRoomMange"):[dic1]]

        let dic2 = [getString(key: "funNameCrossRoomPK"):"CrossRoomPKViewController"]
        let grpup2 = [getString(key: "categoryNameAudioVideoTrans"):[dic2]]
        
        let dic31 = [getString(key: "funNameRawAudioData"):"AudioRawDataViewController"]
        let dic32 = [getString(key: "funNameAudioEffectPlayer"):"AudioEffectMixingViewController"]
        let dic33 = [getString(key: "funNameMediaPlayer"):"AudioMediaMixingViewController"]
        let dic34 = [getString(key: "funNameSoundEffect"):"SoundEffectsViewController"]
        let externalAudioItem = [getString(key: "funNameExternalAudioSource"):"CustomAudioCaptureViewController"]
        let grpup3 = [getString(key: "categoryNameAudioManage"):[dic31,dic32,dic33,dic34,externalAudioItem]]
        
        let pipItem = [getString(key: "funNamePictureInPicture"):"PipViewController"]
        let commonItem = [getString(key: "funNameCommonVideoConfig"):"CommonVideoConfigViewController"]
        let rotationItem = [getString(key: "funNameVideoRotation"):"VideoRotationViewController"]
        let screenShareItem = [getString(key: "funNameScreenShare"):"ScreenShareViewController"]
        let customVideoCaptureItem = [getString(key: "funNameCustomVideoCapture"):"CustomVideoCaptureViewController"]
        let customVideoRenderItem = [getString(key: "funNameCustomVideoRender"):"CustomVideoRenderViewController"]
        let customVideoEncodeItem = [getString(key: "funNameCustomVideoEncode"):"CustomVideoEncodeVideoCaptureViewController"]

        let grpup4 = [getString(key: "categoryNameVideoManage"):[pipItem,commonItem,rotationItem,screenShareItem,customVideoCaptureItem,customVideoRenderItem,customVideoEncodeItem]]
        
        let dic51 = [getString(key: "funNamePushCDN"):"PushCDNViewController"]
        let grpup5 = [getString(key: "categoryNameLive"):[dic51]]
        
        let dic62 = [getString(key: "funNameThirdBeauty"):"BeautyViewController"]
        let pullItem = [getString(key: "funNamePullRTMP"):"PullRTMPViewController"]
        let grpup6 = [getString(key: "categoryNameImportantComp"):[dic62,pullItem]]
        
        let seiItem = [getString(key: "funNameSEI"):"SEIViewController"]
        let externalSeiItem = [getString(key: "funNameExternalVideoWithSEI"):"ExternalVidoeSourceSEIViewController"]
        let seiAudioItem = [getString(key: "funNameSEIWithAudioFrame"):"AudioSEIViewController"]

        let messageGroup = [getString(key: "categoryNameMessageManage"):[seiItem,externalSeiItem,seiAudioItem]]

        let dataArray = [grpup0,grpup1,grpup2,grpup3,grpup4,grpup5,grpup6,messageGroup]
        
        return dataArray
    }()
    
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "volc_logo")
        return imageView
    }()
    
    lazy var backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "background")
        return imageView
    }()
    
    lazy var headerLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.text = "VERTC API Example"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        headerLabel.textColor = UIColor.black
        headerLabel.sizeToFit()
        return headerLabel
    }()

    lazy var versionLabel: UILabel = {
        let versionLabel = UILabel()
        versionLabel.text = "SDK Version" + ByteRTCEngine.getSDKVersion()
        versionLabel.font = UIFont.systemFont(ofSize: 16)
        versionLabel.textColor = UIColor.black
        versionLabel.sizeToFit()
        return versionLabel
    }()
    
    lazy var tableview : UITableView = {
        let tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "viewControllerCell")
        
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    

    // MARK: delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dic = dataArray[section]
        let values = dic.values.first
        return values?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dic:[String:[[String:String]]] = self.dataArray[section]
        let title = dic.keys.first
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewControllerCell", for: indexPath)
        let dic:[String:[[String:String]]] = self.dataArray[indexPath.section]
    
        let array:[[String:String]] = dic.values.first!
        
        let cellInfo = Array(array)[indexPath.row]
        
        cell.textLabel?.text = cellInfo.keys.first

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dic:[String:[[String:String]]] = self.dataArray[indexPath.section]
    
        let array:[[String:String]] = dic.values.first!
        
        let cellInfo = Array(array)[indexPath.row]
        
        let className = cellInfo.values.first! as String
                
        if NSClassFromString("ApiExample." + className) is UIViewController.Type {
            let classType = NSClassFromString("ApiExample." + className) as! BaseViewController.Type
   
            let viewController = classType.init()
            viewController.titleText = cellInfo.keys.first!
            let nav:UINavigationController = UINavigationController.init(rootViewController: viewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
}
