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
        if networkMonitor.isOnline {
            let remotePosts = try await remoteDataSource.fetchAllPosts(
                limit: 50,
                skip: 0
            )
            try await mergeRemotePosts(remotePosts)
        }
        
        return try await localDataSource.fetchAllPosts()
    }
    
    func fetchRecentPosts(limit: Int) async throws -> [Post] {
        let all = try await fetchAllPosts()
        return Array(all
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(limit))
    }
    
    private func mergeRemotePosts(_ remotePosts: [Post]) async throws {
        let remoteIds = remotePosts.compactMap { $0.remoteId }
        guard !remoteIds.isEmpty else { return }
        
        let localPosts = try await localDataSource.fetchPosts(remoteIds: remoteIds)
        var localByRemoteId: [Int: Post] = [:]
        for post in localPosts {
            guard let id = post.remoteId, localByRemoteId[id] == nil else { continue }
            localByRemoteId[id] = post
        }
        
        for remote in remotePosts {
            guard let remoteId = remote.remoteId else { continue }
            
            if let local = localByRemoteId[remoteId] {
                // 로컬에 pending 변경이 있으면 서버값으로 덮어쓰지 않는다.
                if local.syncStatus != .synced {
                    continue
                }
                
                // soft delete 된 로컬은 그대로 숨김 유지
                if local.isSoftDeleted {
                    continue
                }
                
                // 서버 값과 완전히 동일하면 저장 불필요
                if local.title == remote.title,
                   local.body == remote.body,
                   local.userId == remote.userId {
                    continue
                }
                
                // 정상적인 경우에만 서버 데이터를 로컬에 upsert
                let merged = local.with(
                    title: remote.title,
                    body: remote.body,
                    userId: remote.userId,
                    syncStatus: .synced,
                    updatedAt: Date(),
                    isSoftDeleted: false
                )
                try await localDataSource.savePost(merged)
            } else {
                // 로컬에 없는 경우 새로 추가
                let newLocal = Post(
                    localId: UUID(),
                    remoteId: remoteId,
                    title: remote.title,
                    body: remote.body,
                    userId: remote.userId,
                    syncStatus: .synced,
                    createdAt: Date(),
                    updatedAt: Date(),
                    isSoftDeleted: false
                )
                try await localDataSource.savePost(newLocal)
            }
        }
    }
    
    // MARK: - CRUD
    
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        // 항상 로컬에 먼저 반영 (오프라인/온라인 공통)
        var localPost = Post(
            title: title,
            body: body,
            userId: userId,
            syncStatus: .created,
            createdAt: Date(),
            updatedAt: Date(),
            isSoftDeleted: false
        )
        try await localDataSource.savePost(localPost)
        
        // 오프라인이면 여기서 끝. 나중에 syncPendingChanges()에서 처리.
        guard networkMonitor.isOnline else {
            return localPost
        }
        
        // 온라인이면 서버에 create 시도. 실패해도 앱 플로우는 성공으로 간주하고 pending 상태 유지.
        do {
            let remote = try await remoteDataSource.createPost(
                title: localPost.title,
                body: localPost.body,
                userId: localPost.userId
            )
            
            // 서버가 remoteId 를 돌려줬다면 synced 상태로 승격
            localPost = localPost.with(
                remoteId: remote.remoteId,
                syncStatus: .synced,
                updatedAt: Date()
            )
            try await localDataSource.savePost(localPost)
        } catch {
            // DummyJSON 특성상 실패/무시가 가능하므로, 로컬 pending 상태만 유지하고 에러는 흘려보내지 않는다.
        }
        
        return localPost
    }
    
    func updatePost(localId: UUID, title: String?, body: String?) async throws -> Post {
        guard let current = try await localDataSource.fetchPost(localId: localId) else {
            throw DomainError.notFound
        }
        
        // 로컬 먼저 업데이트 + pendingUpdate 표시
        var updatedLocal = current.with(
            title: title ?? current.title,
            body: body ?? current.body,
            syncStatus: .updated,
            updatedAt: Date()
        )
        try await localDataSource.savePost(updatedLocal)
        
        // 오프라인이면 여기서 끝. 나중에 syncPendingChanges()에서 처리.
        guard networkMonitor.isOnline else {
            return updatedLocal
        }
        
        // 온라인이면 서버에 동기화 시도
        do {
            if let remoteId = updatedLocal.remoteId {
                _ = try await remoteDataSource.updatePost(
                    id: remoteId,
                    title: updatedLocal.title,
                    body: updatedLocal.body
                )
                
                // 서버까지 반영 완료 → synced
                updatedLocal = updatedLocal.with(
                    syncStatus: .synced,
                    updatedAt: Date()
                )
                try await localDataSource.savePost(updatedLocal)
            } else {
                // 아직 서버에 없는 로컬 전용 글이면 create 로 승격
                let remote = try await remoteDataSource.createPost(
                    title: updatedLocal.title,
                    body: updatedLocal.body,
                    userId: updatedLocal.userId
                )
                
                updatedLocal = updatedLocal.with(
                    remoteId: remote.remoteId,
                    syncStatus: .synced,
                    updatedAt: Date()
                )
                try await localDataSource.savePost(updatedLocal)
            }
        } catch {
            // 서버 동기화 실패 시에도 로컬 변경은 유지하고, 여전히 .updated(pending) 상태로 남겨둔다.
        }
        
        return updatedLocal
    }
    
    func deletePost(localId: UUID) async throws {
        guard let post = try await localDataSource.fetchPost(localId: localId) else {
            throw DomainError.notFound
        }
        
        // 소프트 삭제 + pendingDelete 표시
        try await localDataSource.deletePost(localId: localId)
        
        // 오프라인이면 여기서 끝. tombstone + syncStatus.deleted 가 남는다.
        guard networkMonitor.isOnline else {
            return
        }
        
        // 온라인이면 서버에 delete 시도 (실패해도 soft delete 유지)
        do {
            if let remoteId = post.remoteId {
                _ = try await remoteDataSource.deletePost(id: remoteId)
            }
            
            // 서버 삭제까지 성공했다면 로컬에서도 완전히 제거
            try await localDataSource.permanentlyDeletePost(localId: localId)
        } catch {
            // 실패 시에도 tombstone 은 그대로 유지해서 다음 syncPendingChanges() 때 다시 시도 가능하게 둔다.
        }
    }
    
    // MARK: - Sync
    
    func fetchPostsNeedingSync() async throws -> [Post] {
        return try await localDataSource.fetchPostsNeedingSync()
    }
    
    func syncPendingChanges() async throws {
        // 오프라인이면 아무 것도 하지 않는다.
        guard networkMonitor.isOnline else { return }
        
        let pending = try await localDataSource.fetchPostsNeedingSync()
        
        for post in pending {
            do {
                switch post.syncStatus {
                case .created:
                    // 아직 서버에 없는 새 글 → POST
                    let remote = try await remoteDataSource.createPost(
                        title: post.title,
                        body: post.body,
                        userId: post.userId
                    )
                    
                    let synced = post.with(
                        remoteId: remote.remoteId,
                        syncStatus: .synced,
                        updatedAt: Date()
                    )
                    try await localDataSource.savePost(synced)
                    
                case .updated:
                    if let remoteId = post.remoteId {
                        // 서버에도 있는 글 업데이트 → PUT
                        _ = try await remoteDataSource.updatePost(
                            id: remoteId,
                            title: post.title,
                            body: post.body
                        )
                        
                        let synced = post.with(
                            syncStatus: .synced,
                            updatedAt: Date()
                        )
                        try await localDataSource.savePost(synced)
                    } else {
                        // remoteId 없는 updated 는 사실상 create 와 동일하게 취급
                        let remote = try await remoteDataSource.createPost(
                            title: post.title,
                            body: post.body,
                            userId: post.userId
                        )
                        
                        let synced = post.with(
                            remoteId: remote.remoteId,
                            syncStatus: .synced,
                            updatedAt: Date()
                        )
                        try await localDataSource.savePost(synced)
                    }
                    
                case .deleted:
                    // tombstone 상태의 글 삭제 처리
                    if let remoteId = post.remoteId {
                        _ = try await remoteDataSource.deletePost(id: remoteId)
                    }
                    
                    // 서버까지 반영되었으므로 로컬에서도 완전 삭제
                    try await localDataSource.permanentlyDeletePost(localId: post.localId)
                    
                case .synced:
                    continue
                }
            } catch {
                // 개별 항목 실패는 전체 동기화를 중단시키지 않는다. (다음 sync 때 재시도)
                continue
            }
        }
    }
    
    func observePosts() -> AsyncStream<[Post]> {
        return localDataSource.observePosts()
    }
}
