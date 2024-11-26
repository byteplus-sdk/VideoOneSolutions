//
//  Tool.swift
//  ApiExample
//
//  Created by bytedance on 2023/10/7.
//  Copyright © 2021 bytedance. All rights reserved.
//

import Foundation

// User name & room name regularity
let inputRegex = "^[a-zA-Z0-9@._-]{1,128}$"

// Check whether the user name or room name is legal
func checkValid(_ string: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: inputRegex, options: [])
        let results = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        return results.count > 0
    } catch {
        print("Invalid regex: \(error.localizedDescription)")
        return false
    }
}

// Get safaArea
func getSafeAreaInsets() -> UIEdgeInsets {
    if #available(iOS 11.0, *) {
        return UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets.zero
    } else {
        return UIEdgeInsets.zero
    }
}

func LocalizedString(_ key: String) -> String {
    return Localizator.localizedString(forKey: key, bundleName: HomeBundleName)
}
