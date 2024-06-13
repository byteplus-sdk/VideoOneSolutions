//
//  EffectModel.swift
//  ApiExample
//
//  Created by bytedance on 2023/10/31.
//  Copyright © 2021 bytedance. All rights reserved.
//

import Foundation

enum EffectModelType: Int {
    case beauty = 0
    case filter = 1
    case sticker = 2
    case virtual = 3
}

enum EffectModelSubType: Int {
    case beauty = 0
    case reshape = 1
    case color = 2
    case image = 3
}

class EffectModel: NSObject {
    var type: EffectModelType = .beauty
    var subType:EffectModelSubType?
    var value: Float = 0.0
    var selected: Bool = false
    var name: String?
    var key: String?
}
