// Copyright (c) 2025 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// A single chat or system message displayed in the Live watch interaction area.
public struct LiveChatMessage {
    public let id: String
    public let userId: String
    public let userName: String
    public let userLevel: Int
    public let content: String
    public let timestamp: TimeInterval
    public let isSystemMessage: Bool

    public init(id: String = UUID().uuidString,
                userId: String = "",
                userName: String = "",
                userLevel: Int = 0,
                content: String,
                timestamp: TimeInterval = Date().timeIntervalSince1970,
                isSystemMessage: Bool = false) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userLevel = userLevel
        self.content = content
        self.timestamp = timestamp
        self.isSystemMessage = isSystemMessage
    }
}
