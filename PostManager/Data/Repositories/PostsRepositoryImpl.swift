//
//  PostsRepositoryImpl.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

final class PostsRepositoryImpl: PostsRepository {
    
    private let remoteDataSource: PostsRemoteDataSource
    private let localDataSource: PostsLocalDataSource
    private let networkMonitor: NetworkMonitor
    
    init(
        remoteDataSource: PostsRemoteDataSource,
        localDataSource: PostsLocalDataSource,
        networkMonitor: NetworkMonitor
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }
    
    func fetchPosts(limit: Int, offset: Int) async throws -> [Post] {
        let all = try await localDataSource.fetchAllPosts()
        return Array(all.dropFirst(offset).prefix(limit))
    }
    
    func fetchPost(localId: UUID) async throws -> Post? {
        return try await localDataSource.fetchPost(localId: localId)
    }
    
    func fetchAllPosts() async throws -> [Post] {
        return try await localDataSource.fetchAllPosts()
    }
    
    func fetchRecentPosts(limit: Int) async throws -> [Post] {
        let all = try await fetchAllPosts()
        return Array(all
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(limit))
    }
    
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        let post = Post(
            title: title,
            body: body,
            userId: userId,
            syncStatus: .created
        )
        
        try await localDataSource.savePost(post)
        return post
    }
    
    
    func updatePost(localId: UUID, title: String?, body: String?) async throws -> Post {
        guard let post = try await localDataSource.fetchPost(localId: localId) else {
            throw DomainError.notFound
        }
        
        let updatedPost = post.with(
            title: title ?? post.title,
            body: body ?? post.body,
            syncStatus: .updated,
            updatedAt: Date()
        )
        try await localDataSource.savePost(updatedPost)
        return updatedPost
    }
    
    func deletePost(localId: UUID) async throws {
        guard let post = try await localDataSource.fetchPost(localId: localId) else {
            throw DomainError.notFound
        }
        
        try await localDataSource.deletePost(localId: localId)
    }
    
    func fetchPostsNeedingSync() async throws -> [Post] {
        return try await localDataSource.fetchPostsNeedingSync()
    }
    
    func syncPendingChanges() async throws {
        guard networkMonitor.isOnline else {
            return
        }
    }
    
    func observePosts() -> AsyncStream<[Post]> {
        return localDataSource.observePosts()
    }
}
