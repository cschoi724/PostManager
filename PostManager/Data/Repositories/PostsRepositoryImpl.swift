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
        if networkMonitor.isOnline {
            // 온라인: 서버에서 가져와서 로컬에 저장
            do {
                let posts = try await remoteDataSource.fetchAllPosts(limit: limit, skip: offset)
                for post in posts {
                    let syncedPost = post.markAsSynced(remoteId: post.remoteId)
                    try await localDataSource.savePost(syncedPost)
                }
                return posts
            } catch {
                // 서버 요청 실패 시 로컬 데이터 반환
                let all = try await localDataSource.fetchAllPosts()
                return Array(all.dropFirst(offset).prefix(limit))
            }
        } else {
            // 오프라인: 로컬에서 가져오기
            let all = try await localDataSource.fetchAllPosts()
            return Array(all.dropFirst(offset).prefix(limit))
        }
    }
    
    func fetchPost(localId: UUID) async throws -> Post? {
        return try await localDataSource.fetchPost(localId: localId)
    }
    
    func fetchAllPosts() async throws -> [Post] {
        if networkMonitor.isOnline {
            // 온라인: 서버에서 가져와서 로컬에 저장
            do {
                let posts = try await remoteDataSource.fetchAllPosts(limit: 100, skip: 0)
                for post in posts {
                    let syncedPost = post.markAsSynced(remoteId: post.remoteId)
                    try await localDataSource.savePost(syncedPost)
                }
                return posts
            } catch {
                // 서버 요청 실패 시 로컬 데이터 반환
                return try await localDataSource.fetchAllPosts()
            }
        } else {
            // 오프라인: 로컬에서 가져오기
            return try await localDataSource.fetchAllPosts()
        }
    }
    
    func fetchRecentPosts(limit: Int) async throws -> [Post] {
        let all = try await fetchAllPosts()
        return Array(all
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(limit))
    }
    
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        // 로컬 우선: 항상 로컬에 먼저 저장
        let post = Post(
            title: title,
            body: body,
            userId: userId,
            syncStatus: .created
        )
        
        try await localDataSource.savePost(post)
        
        // 온라인일 때만 서버에 즉시 전송 시도
        if networkMonitor.isOnline {
            do {
                let remotePost = try await remoteDataSource.createPost(
                    title: title,
                    body: body,
                    userId: userId
                )
                // 서버 전송 성공 시 동기화 상태 업데이트
                let syncedPost = post.markAsSynced(remoteId: remotePost.remoteId)
                try await localDataSource.savePost(syncedPost)
                return syncedPost
            } catch {
                // 서버 전송 실패 시에도 로컬 데이터는 유지
                return post
            }
        }
        
        return post
    }
    
    
    func updatePost(localId: UUID, title: String?, body: String?) async throws -> Post {
        guard let post = try await localDataSource.fetchPost(localId: localId) else {
            throw DomainError.notFound
        }
        
        // 로컬 우선: 항상 로컬에 먼저 업데이트
        let updatedPost = post.with(
            title: title ?? post.title,
            body: body ?? post.body,
            syncStatus: .updated,
            updatedAt: Date()
        )
        try await localDataSource.savePost(updatedPost)
        
        // 온라인이고 remoteId가 있을 때만 서버에 즉시 전송 시도
        if networkMonitor.isOnline, let remoteId = post.remoteId {
            do {
                _ = try await remoteDataSource.updatePost(
                    id: remoteId,
                    title: title,
                    body: body
                )
                // 서버 전송 성공 시 동기화 상태 업데이트
                let syncedPost = updatedPost.markAsSynced(remoteId: remoteId)
                try await localDataSource.savePost(syncedPost)
                return syncedPost
            } catch {
                // 서버 전송 실패 시에도 로컬 데이터는 유지
                return updatedPost
            }
        }
        
        return updatedPost
    }
    
    func deletePost(localId: UUID) async throws {
        guard let post = try await localDataSource.fetchPost(localId: localId) else {
            throw DomainError.notFound
        }
        
        // 로컬 우선: 항상 로컬에 먼저 삭제 플래그 설정
        try await localDataSource.deletePost(localId: localId)
        
        // 온라인이고 remoteId가 있을 때만 서버에 즉시 삭제 요청
        if networkMonitor.isOnline, let remoteId = post.remoteId {
            do {
                _ = try await remoteDataSource.deletePost(id: remoteId)
                // 서버 삭제 성공 시 로컬에서도 완전 삭제
                try await localDataSource.permanentlyDeletePost(localId: localId)
            } catch {
                // 서버 삭제 실패 시에도 로컬 삭제 플래그는 유지
            }
        } else if post.remoteId == nil {
            // remoteId가 없는 로컬 전용 게시글은 즉시 완전 삭제
            try await localDataSource.permanentlyDeletePost(localId: localId)
        }
    }
    
    func fetchPostsNeedingSync() async throws -> [Post] {
        return try await localDataSource.fetchPostsNeedingSync()
    }
    
    func syncPendingChanges() async throws {
        guard networkMonitor.isOnline else {
            return
        }
        
        let postsNeedingSync = try await fetchPostsNeedingSync()
        
        for post in postsNeedingSync {
            do {
                switch post.syncStatus {
                case .created:
                    // 서버에 생성 요청
                    let remotePost = try await remoteDataSource.createPost(
                        title: post.title,
                        body: post.body,
                        userId: post.userId
                    )
                    let syncedPost = post.markAsSynced(remoteId: remotePost.remoteId)
                    try await localDataSource.savePost(syncedPost)
                    
                case .updated:
                    guard let remoteId = post.remoteId else {
                        // remoteId가 없으면 생성으로 처리
                        let remotePost = try await remoteDataSource.createPost(
                            title: post.title,
                            body: post.body,
                            userId: post.userId
                        )
                        let syncedPost = post.markAsSynced(remoteId: remotePost.remoteId)
                        try await localDataSource.savePost(syncedPost)
                        continue
                    }
                    // 서버에 업데이트 요청
                    _ = try await remoteDataSource.updatePost(
                        id: remoteId,
                        title: post.title,
                        body: post.body
                    )
                    let syncedPost = post.markAsSynced(remoteId: remoteId)
                    try await localDataSource.savePost(syncedPost)
                    
                case .deleted:
                    guard let remoteId = post.remoteId else {
                        // remoteId가 없으면 로컬에서만 완전 삭제
                        try await localDataSource.permanentlyDeletePost(localId: post.localId)
                        continue
                    }
                    // 서버에 삭제 요청
                    _ = try await remoteDataSource.deletePost(id: remoteId)
                    // 서버 삭제 성공 시 로컬에서도 완전 삭제
                    try await localDataSource.permanentlyDeletePost(localId: post.localId)
                    
                case .synced:
                    continue
                }
            } catch {
                // 개별 동기화 실패 시에도 다음 항목 계속 처리
                continue
            }
        }
    }
    
    // MARK: - Observe
    
    func observePosts() -> AsyncStream<[Post]> {
        return localDataSource.observePosts()
    }
}
