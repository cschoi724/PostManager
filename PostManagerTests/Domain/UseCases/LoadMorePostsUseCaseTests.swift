//
//  LoadMorePostsUseCaseTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/24/26.
//

import XCTest
@testable import PostManager

@MainActor
final class LoadMorePostsUseCaseTests: XCTestCase {
    
    func test_오프라인상태에서_호출시_에러반환() async throws {
        let mockRepository = MockPostsRepository()
        let mockNetworkMonitor = MockNetworkMonitor(isOnline: false)
        let useCase = LoadMorePostsUseCaseImpl(
            repository: mockRepository,
            networkMonitor: mockNetworkMonitor
        )
        
        do {
            _ = try await useCase(limit: 10, offset: 0)
            XCTFail("에러가 발생해야 함")
        } catch DomainError.offlineNotAllowed {
        } catch {
            XCTFail("예상한 에러가 아님: \(error)")
        }
        
        XCTAssertEqual(mockRepository.fetchPostsCallCount, 0)
    }
    
    func test_온라인상태에서_호출시_Repository호출() async throws {
        let mockRepository = MockPostsRepository()
        let mockNetworkMonitor = MockNetworkMonitor(isOnline: true)
        let useCase = LoadMorePostsUseCaseImpl(
            repository: mockRepository,
            networkMonitor: mockNetworkMonitor
        )
        
        let expectedPosts = [
            Post(title: "Test", body: "Body", userId: 1)
        ]
        mockRepository.fetchPostsResult = expectedPosts
        
        let result = try await useCase(limit: 10, offset: 0)
        
        XCTAssertEqual(result, expectedPosts)
        XCTAssertEqual(mockRepository.fetchPostsCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchPostsLimit, 10)
        XCTAssertEqual(mockRepository.lastFetchPostsOffset, 0)
    }
}

final class MockPostsRepository: PostsRepository {
    var fetchPostsCallCount = 0
    var lastFetchPostsLimit: Int?
    var lastFetchPostsOffset: Int?
    var fetchPostsResult: [Post] = []
    
    func fetchPosts(limit: Int, offset: Int) async throws -> [Post] {
        fetchPostsCallCount += 1
        lastFetchPostsLimit = limit
        lastFetchPostsOffset = offset
        return fetchPostsResult
    }
    
    func fetchPost(localId: UUID) async throws -> Post? { nil }
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        Post(title: title, body: body, userId: userId)
    }
    func updatePost(localId: UUID, title: String?, body: String?) async throws -> Post {
        Post(title: title ?? "", body: body ?? "", userId: 1)
    }
    func deletePost(localId: UUID) async throws {}
    func fetchPostsNeedingSync() async throws -> [Post] { [] }
    func syncPendingChanges() async throws {}
    func fetchAllPosts() async throws -> [Post] { [] }
    func fetchRecentPosts(limit: Int) async throws -> [Post] { [] }
    func observePosts() -> AsyncStream<[Post]> {
        AsyncStream { _ in }
    }
}

final class MockNetworkMonitor: NetworkMonitor {
    let isOnline: Bool
    
    init(isOnline: Bool) {
        self.isOnline = isOnline
    }
}
