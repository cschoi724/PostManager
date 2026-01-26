//
//  PostsRemoteDataSourceTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/26/26.
//

import XCTest
@testable import PostManager

@MainActor
final class PostsRemoteDataSourceTests: XCTestCase {
    
    func test_fetchAllPosts_성공시게시글목록반환() async throws {
        let mockResponse = PostListResponseDTO(
            posts: [
                PostDTO(id: 1, title: "Title 1", body: "Body 1", tags: nil, reactions: nil, views: nil, userId: 1, isDeleted: nil, deletedOn: nil),
                PostDTO(id: 2, title: "Title 2", body: "Body 2", tags: nil, reactions: nil, views: nil, userId: 1, isDeleted: nil, deletedOn: nil)
            ],
            total: 2,
            skip: 0,
            limit: 10
        )
        let mockNetworkClient = MockNetworkClient(response: mockResponse)
        let dataSource = PostsRemoteDataSourceImpl(networkClient: mockNetworkClient)
        
        let posts = try await dataSource.fetchAllPosts(limit: 10, skip: 0)
        
        XCTAssertEqual(posts.count, 2)
        XCTAssertEqual(posts[0].remoteId, 1)
        XCTAssertEqual(posts[0].title, "Title 1")
        XCTAssertEqual(posts[1].remoteId, 2)
        XCTAssertEqual(posts[1].title, "Title 2")
    }
    
    func test_fetchPost_성공시단일게시글반환() async throws {
        let mockDTO = PostDTO(
            id: 5,
            title: "Single Post",
            body: "Single Body",
            tags: nil,
            reactions: nil,
            views: nil,
            userId: 2,
            isDeleted: nil,
            deletedOn: nil
        )
        let mockNetworkClient = MockNetworkClient(response: mockDTO)
        let dataSource = PostsRemoteDataSourceImpl(networkClient: mockNetworkClient)
        
        let post = try await dataSource.fetchPost(id: 5)
        
        XCTAssertEqual(post.remoteId, 5)
        XCTAssertEqual(post.title, "Single Post")
        XCTAssertEqual(post.body, "Single Body")
        XCTAssertEqual(post.userId, 2)
    }
    
    func test_createPost_성공시생성된게시글반환() async throws {
        let mockDTO = PostDTO(
            id: 10,
            title: "New Post",
            body: "New Body",
            tags: nil,
            reactions: nil,
            views: nil,
            userId: 3,
            isDeleted: nil,
            deletedOn: nil
        )
        let mockNetworkClient = MockNetworkClient(response: mockDTO)
        let dataSource = PostsRemoteDataSourceImpl(networkClient: mockNetworkClient)
        
        let post = try await dataSource.createPost(title: "New Post", body: "New Body", userId: 3)
        
        XCTAssertEqual(post.remoteId, 10)
        XCTAssertEqual(post.title, "New Post")
        XCTAssertEqual(post.body, "New Body")
        XCTAssertEqual(post.userId, 3)
    }
}

private final class MockNetworkClient: NetworkClient {
    private let response: Any
    
    init<T: Decodable>(response: T) {
        self.response = response
    }
    
    func request<T: Decodable>(_ endpoint: APIRequest, decoder: JSONDecoder) async throws -> T {
        guard let typedResponse = response as? T else {
            throw NSError(domain: "MockNetworkClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Type mismatch"])
        }
        return typedResponse
    }
    
    func requestData(_ endpoint: APIRequest) async throws -> Data {
        throw NSError(domain: "MockNetworkClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }
}
