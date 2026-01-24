//
//  FetchDashboardUseCaseTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/24/26.
//

import XCTest
@testable import PostManager

@MainActor
final class FetchDashboardUseCaseTests: XCTestCase {
    
    func test_통계정보_정확히_집계() async throws {
        let mockRepository = MockPostsRepositoryForDashboard()
        let useCase = FetchDashboardUseCaseImpl(repository: mockRepository)
        
        let result = try await useCase()
        
        XCTAssertEqual(result.totalCount, 5)
        XCTAssertEqual(result.offlineCreatedCount, 2)
        XCTAssertEqual(result.needsSyncCount, 3)
        XCTAssertEqual(result.recentPosts.count, 5)
    }
    
    func test_최근게시글_5개_제한() async throws {
        let mockRepository = MockPostsRepositoryForDashboard()
        let useCase = FetchDashboardUseCaseImpl(repository: mockRepository)
        
        let result = try await useCase()
        
        XCTAssertEqual(result.recentPosts.count, 5)
        XCTAssertEqual(mockRepository.fetchRecentPostsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchRecentPostsLimit, 5)
    }
}

final class MockPostsRepositoryForDashboard: PostsRepository {
    var fetchRecentPostsCallCount = 0
    var lastFetchRecentPostsLimit: Int?
    
    func fetchAllPosts() async throws -> [Post] {
        return [
            Post(remoteId: 1, title: "Synced", body: "Body", userId: 1, syncStatus: .synced),
            Post(title: "Offline Created 1", body: "Body", userId: 1, syncStatus: .created),
            Post(remoteId: 2, title: "Updated", body: "Body", userId: 1, syncStatus: .updated),
            Post(title: "Offline Created 2", body: "Body", userId: 1, syncStatus: .created),
            Post(remoteId: 3, title: "Deleted", body: "Body", userId: 1, syncStatus: .deleted)
        ]
    }
    
    func fetchPostsNeedingSync() async throws -> [Post] {
        return [
            Post(title: "Created", body: "Body", userId: 1, syncStatus: .created),
            Post(remoteId: 2, title: "Updated", body: "Body", userId: 1, syncStatus: .updated),
            Post(remoteId: 3, title: "Deleted", body: "Body", userId: 1, syncStatus: .deleted)
        ]
    }
    
    func fetchRecentPosts(limit: Int) async throws -> [Post] {
        fetchRecentPostsCallCount += 1
        lastFetchRecentPostsLimit = limit
        return Array(try await fetchAllPosts().prefix(limit))
    }
    
    func fetchPosts(limit: Int, offset: Int) async throws -> [Post] { [] }
    func fetchPost(localId: UUID) async throws -> Post? { nil }
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        Post(title: title, body: body, userId: userId)
    }
    func updatePost(localId: UUID, title: String?, body: String?) async throws -> Post {
        Post(title: title ?? "", body: body ?? "", userId: 1)
    }
    func deletePost(localId: UUID) async throws {}
    func syncPendingChanges() async throws {}
    func observePosts() -> AsyncStream<[Post]> {
        AsyncStream { _ in }
    }
}
