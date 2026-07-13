// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import ToolKit

@objc(LiveSportStreamingEntrance)
public class LiveSportStreamingEntrance: BaseSceneEntrance {

    public override init() {
        super.init()
        self.title = LiveSportL10n("live_sport_scene_name")
        self.des = LiveSportL10n("live_sport_scene_des")
        self.bundleName = "LiveSportStreaming"
        self.iconName = "scene_live_sport"
        self.scenesName = "live_sport"
        self.fontStyle = .light
    }
    
    public override func enter(callback block: @escaping (Bool) -> Void) {
        super.enter(callback: block)
        let mainVC = LiveSportMainViewController()
        DeviceInforTool.topViewController().navigationController?.pushViewController(mainVC, animated: true)
        block(true)
    }
    @objc public override class func prepareEnvironment() {
        // No remote environment preparation is required for the demo scene.
    }
}
