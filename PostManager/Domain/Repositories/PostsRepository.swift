//
//  PostsRepository.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public protocol PostsRepository {
    func fetchPosts(limit: Int, offset: Int) async throws -> [Post]
    func fetchPost(localId: UUID) async throws -> Post?
    
    func createPost(title: String, body: String, userId: Int) async throws -> Post
    func updatePost(localId: UUID, title: String?, body: String?) async throws -> Post
    func deletePost(localId: UUID) async throws
    
    func fetchPostsNeedingSync() async throws -> [Post]
    func syncPendingChanges() async throws
    
    func fetchAllPosts() async throws -> [Post]
    func fetchRecentPosts(limit: Int) async throws -> [Post]
    
    func observePosts() -> AsyncStream<[Post]>
}
