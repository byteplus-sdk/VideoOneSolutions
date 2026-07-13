// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

/// A single gift available in the live sport watch gift panel.
public struct LiveSportGift {
    public let id: String
    public let assetName: String
    public let nameKey: String

    public var icon: UIImage? {
        LiveSportImage(named: assetName)
    }

    public var displayName: String {
        LiveSportL10n(nameKey)
    }
}

/// Static catalog of the gifts shown in the gift panel, in display order.
public enum LiveSportGiftCatalog {
    public static let all: [LiveSportGift] = [
        LiveSportGift(id: "like", assetName: "sport_gift_like", nameKey: "live_sport_gift_like"),
        LiveSportGift(id: "ok", assetName: "sport_gift_ok", nameKey: "live_sport_gift_ok"),
        LiveSportGift(id: "goodluck", assetName: "sport_gift_goodluck", nameKey: "live_sport_gift_goodluck"),
        LiveSportGift(id: "glowstick", assetName: "sport_gift_glowstick", nameKey: "live_sport_gift_glowstick"),
        LiveSportGift(id: "lollipop", assetName: "sport_gift_lollipop", nameKey: "live_sport_gift_lollipop"),
        LiveSportGift(id: "cheer", assetName: "sport_gift_cheer", nameKey: "live_sport_gift_cheer"),
        LiveSportGift(id: "partypopper", assetName: "sport_gift_partypopper", nameKey: "live_sport_gift_partypopper"),
        LiveSportGift(id: "fairywand", assetName: "sport_gift_fairywand", nameKey: "live_sport_gift_fairywand"),
        LiveSportGift(id: "pearl", assetName: "sport_gift_pearl", nameKey: "live_sport_gift_pearl"),
        LiveSportGift(id: "privatejet", assetName: "sport_gift_privatejet", nameKey: "live_sport_gift_privatejet"),
        LiveSportGift(id: "sportscar", assetName: "sport_gift_sportscar", nameKey: "live_sport_gift_sportscar"),
        LiveSportGift(id: "rocket", assetName: "sport_gift_rocket", nameKey: "live_sport_gift_rocket")
    ]
}
