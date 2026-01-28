//
//  PostsLocalDataSource.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/26/26.
//

import Foundation
import CoreData
import Combine

protocol PostsLocalDataSource {
    func savePost(_ post: Post) async throws
    func fetchPost(localId: UUID) async throws -> Post?
    func fetchPost(remoteId: Int) async throws -> Post?
    func fetchAllPosts() async throws -> [Post]
    func fetchPostsNeedingSync() async throws -> [Post]
    func deletePost(localId: UUID) async throws
    func permanentlyDeletePost(localId: UUID) async throws
    func observePosts() -> AsyncStream<[Post]>
}

final class CoreDataPostsLocalDataSource: PostsLocalDataSource {
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}

extension CoreDataPostsLocalDataSource {
    func savePost(_ post: Post) async throws {
            let context = coreDataStack.newBackgroundContext()
            try await context.perform {
                let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()

                if let remoteId = post.remoteId {
                    request.predicate = NSPredicate(format: "remoteId == %@", NSNumber(value: remoteId))
                } else {
                    request.predicate = NSPredicate(format: "localId == %@", post.localId as CVarArg)
                }

                request.fetchLimit = 1

                let entity = try context.fetch(request).first ?? PostEntity(context: context)
                entity.update(from: post)

                if context.hasChanges {
                    try self.coreDataStack.save(context: context)
                }
            }
        }

        func fetchPost(localId: UUID) async throws -> Post? {
            let context = coreDataStack.newBackgroundContext()
            return try await context.perform {
                let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
                request.predicate = NSPredicate(format: "localId == %@", localId as CVarArg)
                request.fetchLimit = 1
                return try context.fetch(request).first?.toDomain()
            }
        }

        func fetchPost(remoteId: Int) async throws -> Post? {
            let context = coreDataStack.newBackgroundContext()
            return try await context.perform {
                let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
                request.predicate = NSPredicate(format: "remoteId == %@", NSNumber(value: remoteId))
                request.fetchLimit = 1
                return try context.fetch(request).first?.toDomain()
            }
        }

        func fetchAllPosts() async throws -> [Post] {
            let context = coreDataStack.newBackgroundContext()
            return try await context.perform {
                let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
                request.predicate = NSPredicate(format: "isSoftDeleted == NO")
                request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
                return try context.fetch(request).map { $0.toDomain() }
            }
        }

        func fetchPostsNeedingSync() async throws -> [Post] {
            let context = coreDataStack.newBackgroundContext()
            return try await context.perform {
                let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "syncStatus != %@ AND isSoftDeleted == NO",
                    SyncStatus.synced.rawValue
                )
                request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
                return try context.fetch(request).map { $0.toDomain() }
            }
        }

        func deletePost(localId: UUID) async throws {
            let context = coreDataStack.newBackgroundContext()
            try await context.perform {
                let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
                request.predicate = NSPredicate(format: "localId == %@", localId as CVarArg)
                request.fetchLimit = 1

                if let entity = try context.fetch(request).first {
                    entity.isSoftDeleted = true
                    entity.syncStatus = SyncStatus.deleted.rawValue
                    entity.updatedAt = Date()

                    if context.hasChanges {
                        try self.coreDataStack.save(context: context)
                    }
                }
            }
        }

        func permanentlyDeletePost(localId: UUID) async throws {
            let context = coreDataStack.newBackgroundContext()
            try await context.perform {
                let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
                request.predicate = NSPredicate(format: "localId == %@", localId as CVarArg)

                let results = try context.fetch(request)
                results.forEach { context.delete($0) }

                if context.hasChanges {
                    try self.coreDataStack.save(context: context)
                }
            }
        }

        func observePosts() -> AsyncStream<[Post]> {
            AsyncStream { continuation in
                continuation.finish()
            }
        }
}
