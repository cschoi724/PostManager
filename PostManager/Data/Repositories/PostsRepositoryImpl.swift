//
//  PostsRepositoryImpl.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

final class PostsRepositoryImpl: PostsRepository {
    
    func fetchPosts(limit: Int, offset: Int) async throws -> [Post] {
        return []
    }
    
    func fetchPost(localId: UUID) async throws -> Post? {
        return nil
    }
    
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        return Post(title: title, body: body, userId: userId)
    }
    
    func updatePost(localId: UUID, title: String?, body: String?) async throws -> Post {
        return Post(title: title ?? "", body: body ?? "", userId: 1)
    }
    
    func deletePost(localId: UUID) async throws {
    }
    
    func fetchPostsNeedingSync() async throws -> [Post] {
        return []
    }
    
    func syncPendingChanges() async throws {
    }
    
    func fetchAllPosts() async throws -> [Post] {
        return []
    }
    
    func fetchRecentPosts(limit: Int) async throws -> [Post] {
        return []
    }
    
    func observePosts() -> AsyncStream<[Post]> {
        return AsyncStream { continuation in
            continuation.yield([])
            continuation.finish()
        }
    }
}
