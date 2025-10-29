//
//  BeautyModel.swift
//  ApiExample
//
//  Created by bytedance on 2023/10/31.
//  Copyright © 2021 bytedance. All rights reserved.
//

import Foundation

struct BeautyModel {
    static func sectionList() -> [String] {
        return [getString(key: "beauty"),
                getString(key: "filter"),
                getString(key: "sticker"),
                getString(key: "bgSegment"),]
    }
    
    static func beautyList() -> [[String: Any]] {
        let dic1: [String: Any] = ["index": 0,
                                   "key": "whiten",
                                   "name": getString(key: "whitening"),
                                   "subType": EffectModelSubType.beauty]
        
        let dic2: [String: Any] = ["index": 1,
                                   "key": "smooth",
                                   "name": getString(key: "smooth"),
                                   "subType": EffectModelSubType.beauty]
        
        let dic3: [String: Any] = ["index": 2,
                                   "key": "Internal_Deform_Eye",
                                   "name": getString(key: "deformEye"),
                                   "subType": EffectModelSubType.reshape]
        
        let dic4: [String: Any] = ["index": 3,
                                   "key": "Internal_Deform_Overall",
                                   "name": getString(key: "slimFace"),
                                   "subType": EffectModelSubType.reshape]
        
        return [dic1, dic2, dic3, dic4]
    }
    
    static func stickerList() -> [[String: Any]] {
        let dic1: [String: Any] = ["index": 0,
                                   "key": "stickers_heimaoyanjing",
                                   "name": getString(key: "blackCatGlasses")]
        
        let dic2: [String: Any] = ["index": 1,
                                   "key": "stickers_zhaocaimao",
                                   "name": getString(key: "luckyCat")]
        
        let dic3: [String: Any] = ["index": 2,
                                   "key": "stickers_kejiganqueaixiong",
                                   "name": getString(key: "lovelessBear")]
        
        let dic4: [String: Any] = ["index": 3,
                                   "key": "stickers_mofabaoshi",
                                   "name": getString(key: "magicJewel")]
        
        let dic5: [String: Any] = ["index": 4,
                                   "key": "stickers_caihongtu",
                                   "name": getString(key: "rainbowRabbit")]
        
        let dic6: [String: Any] = ["index": 5,
                                   "key": "stickers_gongzhumianju",
                                   "name": getString(key: "princessMask")]
        
        let dic7: [String: Any] = ["index": 6,
                                   "key": "stickers_huahua",
                                   "name": getString(key: "flowers")]
        
        let dic8: [String: Any] = ["index": 7,
                                   "key": "stickers_tiaowuhuoji",
                                   "name": getString(key: "dancingTurkey")]
        
        return [dic1, dic2, dic3, dic4, dic5, dic6, dic7, dic8]
    }
    
    static func filterList() -> [[String: Any]] {
        let dic1: [String: Any] = ["index": 0,
                                   "key": "Filter_06_03",
                                   "name": getString(key: "peach")]
        
        let dic2: [String: Any] = ["index": 1,
                                   "key": "Filter_37_L5",
                                   "name": getString(key: "crystalClear")]
        
        let dic3: [String: Any] = ["index": 2,
                                   "key": "Filter_35_L3",
                                   "name": getString(key: "nightfall")]
        
        let dic4: [String: Any] = ["index": 3,
                                   "key": "Filter_30_Po8",
                                   "name": getString(key: "cool-toned")]
        
        return [dic1, dic2, dic3, dic4]
    }
    
    static func virtualBackgroundList() -> [[String: Any]] {
        let dic1: [String: Any] = ["index": 0,
                                   "name": getString(key: "solidColor"),
                                   "subType": EffectModelSubType.color]
        
        let dic2: [String: Any] = ["index": 1,
                                   "name": getString(key: "picture"),
                                   "subType": EffectModelSubType.image]
        
        return [dic1, dic2]
    }
}
