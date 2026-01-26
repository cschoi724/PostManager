//
//  PostsRepositoryImpl.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

final class PostsRepositoryImpl: PostsRepository {
    
    private let remoteDataSource: PostsRemoteDataSource
    
    init(remoteDataSource: PostsRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchPosts(limit: Int, offset: Int) async throws -> [Post] {
        return try await remoteDataSource.fetchAllPosts(limit: limit, skip: offset)
    }
    
    func fetchPost(localId: UUID) async throws -> Post? {
        // 아직 로컬 저장소가 없으므로 단일 조회는 전체 목록 기반으로 간단히 구현
        let posts = try await remoteDataSource.fetchAllPosts(limit: 1, skip: 0)
        return posts.first { $0.localId == localId }
    }
    
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        return try await remoteDataSource.createPost(title: title, body: body, userId: userId)
    }
    
    func updatePost(localId: UUID, title: String?, body: String?) async throws -> Post {
        
        // TODO: 로컬 DB 도입 시 localId -> remoteId 매핑 후 원격 업데이트로 교체
        // 현재는 네트워크 동작이 없는 단순 에코 구현
        return Post(
            localId: localId,
            title: title ?? "",
            body: body ?? "",
            userId: 1,
            syncStatus: .updated
        )
    }
    
    func deletePost(localId: UUID) async throws {
        // TODO: 로컬 DB 도입 시 remoteId 조회 후 remote delete + 로컬 플래그 처리
        _ = localId
    }
    
    func fetchPostsNeedingSync() async throws -> [Post] {
        // 아직 동기화 큐가 없으므로 빈 배열 반환
        return []
    }
    
    func syncPendingChanges() async throws {
        // 동기화 큐 도입 전까지는 아무 작업도 하지 않음
    }
    
    func fetchAllPosts() async throws -> [Post] {
        // 대시보드용 전체 개수 계산을 위해 충분히 큰 limit 사용
        return try await remoteDataSource.fetchAllPosts(limit: 100, skip: 0)
    }
    
    func fetchRecentPosts(limit: Int) async throws -> [Post] {
        let all = try await fetchAllPosts()
        return all
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(limit)
            .map { $0 }
    }
    
    func observePosts() -> AsyncStream<[Post]> {
        // 아직 변경 스트림이 없으므로, 대시보드는 초기 로드 기준으로만 동작
        return AsyncStream { continuation in
            continuation.yield([])
            continuation.finish()
        }
    }
}
