//
//  Post.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public struct Post {
    public let localId: UUID
    public let remoteId: Int?
    public let title: String
    public let body: String
    public let userId: Int
    public let syncStatus: SyncStatus
    public let createdAt: Date
    public let updatedAt: Date
    public let isDeleted: Bool
    
    public init(
        localId: UUID = UUID(),
        remoteId: Int? = nil,
        title: String,
        body: String,
        userId: Int,
        syncStatus: SyncStatus = .created,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDeleted: Bool = false
    ) {
        self.localId = localId
        self.remoteId = remoteId
        self.title = title
        self.body = body
        self.userId = userId
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
    }
    
    public func with(
        remoteId: Int? = nil,
        title: String? = nil,
        body: String? = nil,
        userId: Int? = nil,
        syncStatus: SyncStatus? = nil,
        updatedAt: Date? = nil,
        isDeleted: Bool? = nil
    ) -> Post {
        return Post(
            localId: self.localId,
            remoteId: remoteId ?? self.remoteId,
            title: title ?? self.title,
            body: body ?? self.body,
            userId: userId ?? self.userId,
            syncStatus: syncStatus ?? self.syncStatus,
            createdAt: self.createdAt,
            updatedAt: updatedAt ?? self.updatedAt,
            isDeleted: isDeleted ?? self.isDeleted
        )
    }
    
    public func markAsSynced(remoteId: Int?) -> Post {
        return with(
            remoteId: remoteId,
            syncStatus: SyncStatus.synced
        )
    }
    
    public func markAsDeleted() -> Post {
        return with(
            syncStatus: .deleted,
            updatedAt: Date(),
            isDeleted: true
        )
    }
    
    public var needsSync: Bool {
        syncStatus.needsSync
    }
    
    public var isLocalOnly: Bool {
        remoteId == nil
    }
}

extension Post: Equatable {
    nonisolated public static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.localId == rhs.localId &&
        lhs.remoteId == rhs.remoteId &&
        lhs.title == rhs.title &&
        lhs.body == rhs.body &&
        lhs.userId == rhs.userId &&
        lhs.syncStatus == rhs.syncStatus &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt &&
        lhs.isDeleted == rhs.isDeleted
    }
}
