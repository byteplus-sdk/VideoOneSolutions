//
//  EffectResource.swift
//  ApiExample
//
//  Created by bytedance on 2023/11/2.
//  Copyright © 2021 bytedance. All rights reserved.
//

import Foundation

class EffectResource {
    
    static func licensePath() -> String {
        let bundleId: String = Bundle.main.bundleIdentifier!
        let underlineBundleId = bundleId.replacingOccurrences(of: ".", with: "_")

        let locations = [
            Bundle.main.resourceURL,
            Bundle.main.url(forResource: "LicenseBag", withExtension: "bundle"),
        ]

        for location in locations {
            guard let location = location else {
                continue
            }

            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: location, includingPropertiesForKeys: nil)

                let licenseUrl = directoryContents.first {
                    let pathExtension = $0.pathExtension
                    let lastPathComponent = $0.lastPathComponent

                    return pathExtension == "licbag"
                        && (lastPathComponent.contains(bundleId) || lastPathComponent.contains(underlineBundleId))
                }

                if let licenseUrl = licenseUrl {
                    return licenseUrl.path
                }
            } catch {
                NSLog("Find license path exception: \(error)")
            }
        }

        NSLog("EffectResource path does not exists in all locations")
        let message = "\(LocalizedString("toast_resource_exist")): Not found in all locations"
        ToastComponents.shared.show(withMessage: message)
        return ""
    }
    
    static func modelPath() -> String {
        let modelPath = Bundle.main.path(forResource: "ModelResource", ofType: "bundle") ?? ""
        checkPathExist(path: modelPath)
        
        return modelPath
    }
    
    static func getByteEffectPortraitPath() -> String {
        let portraitPrefix = Bundle.main.path(forResource: "StickerResource", ofType: "bundle") ?? ""
        let name = "matting_bg"
        let path = "\(portraitPrefix)/stickers/\(name)"
        checkPathExist(path: path)
        
        return path
    }
    
    static func beautyCameraPath() -> String {
        let bundlePath = Bundle.main.path(forResource: "ComposeMakeup", ofType: "bundle") ?? ""
        let beautyCameraPath = "\(bundlePath)/ComposeMakeup/beauty_IOS_lite"
        checkPathExist(path: beautyCameraPath)
        
        return beautyCameraPath
    }
    
    static func reshapeCameraPath() -> String {
        let bundlePath = Bundle.main.path(forResource: "ComposeMakeup", ofType: "bundle") ?? ""
        let reshapeCameraPath = "\(bundlePath)/ComposeMakeup/reshape_lite"
        checkPathExist(path: reshapeCameraPath)
        
        return reshapeCameraPath
    }
    
    static func stickerPath(withName stickerName: String) -> String {
        let bundlePath = Bundle.main.path(forResource: "StickerResource", ofType: "bundle") ?? ""
        let stickerPath = "\(bundlePath)/stickers/\(stickerName)"
        checkPathExist(path: stickerPath)
        
        return stickerPath
    }
    
    static func filterPath(withName filterName: String) -> String {
        let bundlePath = Bundle.main.path(forResource: "FilterResource", ofType: "bundle") ?? ""
        let filterPath = "\(bundlePath)/Filter/\(filterName)"
        checkPathExist(path: filterPath)
        
        return filterPath
    }
    
    static func checkPathExist(path: String) {
        let exist = FileManager.default.fileExists(atPath: path)
        
        if !exist {
            NSLog("EffectResource path does not exist: \n\(path)")
            let message = "\(LocalizedString("toast_resource_exist")):\(path)"
            ToastComponents.shared.show(withMessage: message)
        }
    }
}
