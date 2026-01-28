//
//  PostEntity.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/27/26.
//

import Foundation
import CoreData

@objc(PostEntity)
final class PostEntity: NSManagedObject {
    @NSManaged var localId: UUID
    @NSManaged var remoteId: NSNumber?
    @NSManaged var title: String
    @NSManaged var body: String
    @NSManaged var userId: Int64
    @NSManaged var syncStatus: String
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
    @NSManaged var isSoftDeleted: Bool
}

extension PostEntity {

    @nonobjc
    class func fetchRequest() -> NSFetchRequest<PostEntity> {
        NSFetchRequest<PostEntity>(entityName: "PostEntity")
    }
}

extension PostEntity {
    
    func update(from post: Post) {
        localId = post.localId
        if let remoteId = post.remoteId {
            self.remoteId = NSNumber(value: remoteId)
        } else {
            self.remoteId = nil
        }
        title = post.title
        body = post.body
        userId = Int64(post.userId)
        syncStatus = post.syncStatus.rawValue
        createdAt = post.createdAt
        updatedAt = post.updatedAt
        isSoftDeleted = post.isDeleted
    }
    
    func toDomain() -> Post {
        return Post(
            localId: localId,
            remoteId: remoteId.map { $0.intValue },
            title: title,
            body: body,
            userId: Int(userId),
            syncStatus: SyncStatus(rawValue: syncStatus) ?? .created,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isSoftDeleted
        )
    }
}
