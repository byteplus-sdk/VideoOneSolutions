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
        return [LocalizedString("label_beauty_title"),
                LocalizedString("label_filter_title"),
                LocalizedString("label_sticker_title"),
                LocalizedString("label_virtual_title")]
    }
    
    static func beautyList() -> [[String: Any]] {
        let dic1: [String: Any] = ["index": 0,
                                   "key": "whiten",
                                   "name": LocalizedString("label_beauty_whiten_title"),
                                   "subType": EffectModelSubType.beauty]
        
        let dic2: [String: Any] = ["index": 1,
                                   "key": "smooth",
                                   "name": LocalizedString("label_beauty_smooth_title"),
                                   "subType": EffectModelSubType.beauty]
        
        return [dic1, dic2]
    }
    
    static func stickerList() -> [[String: Any]] {
        let dic1: [String: Any] = ["index": 0,
                                   "key": "huanlongshu",
                                   "name": LocalizedString("label_sticker_0_title")]
        
        let dic2: [String: Any] = ["index": 1,
                                   "key": "gongzhumianju",
                                   "name": LocalizedString("label_sticker_1_title")]
        
        let dic3: [String: Any] = ["index": 2,
                                   "key": "haoqilongbao",
                                   "name": LocalizedString("label_sticker_2_title")]
        
        let dic4: [String: Any] = ["index": 3,
                                   "key": "eldermakup",
                                   "name": LocalizedString("label_sticker_3_title")]
        
        let dic5: [String: Any] = ["index": 4,
                                   "key": "heimaoyanjing",
                                   "name": LocalizedString("label_sticker_4_title")]
        
        let dic6: [String: Any] = ["index": 5,
                                   "key": "huahua",
                                   "name": LocalizedString("label_sticker_5_title")]
        
        let dic7: [String: Any] = ["index": 6,
                                   "key": "huanletuchiluobo",
                                   "name": LocalizedString("label_sticker_6_title")]
        
        let dic8: [String: Any] = ["index": 7,
                                   "key": "jiamian",
                                   "name": LocalizedString("label_sticker_7_title")]
        
        return [dic1, dic2, dic3, dic4, dic5, dic6, dic7, dic8]
    }
    
    static func filterList() -> [[String: Any]] {
        let dic1: [String: Any] = ["index": 0,
                                   "key": "Filter_06_03",
                                   "name": LocalizedString("label_filter_0603_title")]
        
        let dic2: [String: Any] = ["index": 1,
                                   "key": "Filter_37_L5",
                                   "name": LocalizedString("label_filter_37l5_title")]
        
        let dic3: [String: Any] = ["index": 2,
                                   "key": "Filter_35_L3",
                                   "name": LocalizedString("label_filter_35l3_title")]
        
        let dic4: [String: Any] = ["index": 3,
                                   "key": "Filter_30_Po8",
                                   "name": LocalizedString("label_filter_308_title")]
        
        return [dic1, dic2, dic3, dic4]
    }
    
    static func virtualBackgroundList() -> [[String: Any]] {
        let dic1: [String: Any] = ["index": 0,
                                   "name": LocalizedString("label_virtual_color_title"),
                                   "subType": EffectModelSubType.color]
        
        let dic2: [String: Any] = ["index": 1,
                                   "name": LocalizedString("label_virtual_image_title"),
                                   "subType": EffectModelSubType.image]
        
        return [dic1, dic2]
    }
}
