// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import ToolKit

private let liveSportResourceBundleName = "LiveSportStreaming"

@inline(__always)
func LiveSportL10n(_ key: String) -> String {
    Localizator.localizedString(forKey: key, bundleName: liveSportResourceBundleName)
}

@inline(__always)
func LiveSportImage(named name: String) -> UIImage? {
    guard let bundlePath = Bundle.main.path(forResource: liveSportResourceBundleName, ofType: "bundle"),
          let bundle = Bundle(path: bundlePath) else {
        return UIImage(named: name)
    }
    return UIImage(named: name, in: bundle, compatibleWith: nil)
}
