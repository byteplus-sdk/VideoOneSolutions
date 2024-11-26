// Copyright (c) 2024 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

@objc 
public protocol LiveAddrProtocol : NSObjectProtocol {
    static func generate(_ taskId: String) -> String
}

func generateLiveAddr(taskId: String) -> String{
    guard let clazz = NSClassFromString("RTMPGenerator") as? LiveAddrProtocol.Type else { return "" }
    return clazz.generate(taskId)
}
