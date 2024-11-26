// Copyright (c) 2024 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

@objc
public protocol RTCTokenProtocol: NSObjectProtocol {
    static func rtcAppId() -> String
    static func generateToken(roomId: String, userId: String, completion: @escaping (String?) -> Void)
}

func rtcAppId() -> String {
    guard let clazz = NSClassFromString("TokenGenerator") as? RTCTokenProtocol.Type else {
        return ""
    }

    return clazz.rtcAppId()
}

// To obtain the token, it is recommended to obtain it from the server
func generateToken(roomId: String, userId: String, completion: @escaping (String?) -> Void) {
    guard let clazz = NSClassFromString("TokenGenerator") as? RTCTokenProtocol.Type else {
        completion("")
        return
    }

    return clazz.generateToken(roomId: roomId, userId: userId, completion: completion)
}
