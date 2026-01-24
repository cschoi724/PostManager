//
//  SyncStatus.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public enum SyncStatus: String, Codable, Equatable {
    case synced
    case created
    case updated
    case deleted
    
    public var needsSync: Bool {
        self != .synced
    }
}
