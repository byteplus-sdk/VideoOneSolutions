// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

#import "MDAdGlobalSettings.h"

static BOOL _adsEnabled = NO;
static NSInteger const _hideDuringAdTag = 42;

static NSString *_prerollTag = @"https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_preroll_skippable&sz=640x480&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&correlator=";

static NSString *_midrollTag = @"https://pubads.g.doubleclick.net/gampad/ads?slotname=/21775744923/external/vmap_skip_ad_samples&sz=640x480&ciu_szs=300x250&cust_params=sample_ar%3Dmidskiponly&url=&unviewed_position_start=1&output=xml_vast3&impl=s&env=vp&gdfp_req=1&ad_rule=0&vad_type=linear&vpos=midroll&pod=1&ppos=1&min_ad_duration=0&max_ad_duration=30000&vrid=1445984&cmsid=496&video_doc_id=short_onecue&kfa=0&tfcd=0";

static NSString *_postrollTag = @"https://pubads.g.doubleclick.net/gampad/ads?slotname=/21775744923/external/vmap_ad_samples&sz=640x480&ciu_szs=300x250&cust_params=sample_ar%3Dpremidpost&url=&unviewed_position_start=1&output=xml_vast3&impl=s&env=vp&gdfp_req=1&ad_rule=0&vad_type=linear&vpos=postroll&pod=3&ppos=1&lip=true&min_ad_duration=0&max_ad_duration=30000&vrid=1264775&cmsid=496&video_doc_id=short_onecue&kfa=0&tfcd=0";

@implementation MDAdGlobalSettings

+ (BOOL)adsEnabled {
    return _adsEnabled;
}

+ (NSInteger)hideDuringAdTag {
    return _hideDuringAdTag;
}

+ (void)setAdsEnabled:(BOOL)adsEnabled {
    _adsEnabled = adsEnabled;
}

+ (NSString *)prerollTag {
    return _prerollTag;
}

+ (NSString *)midrollTag {
    return _midrollTag;
}

+ (NSString *)postrollTag {
    return _postrollTag;
}

@end
