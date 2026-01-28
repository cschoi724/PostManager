//
//  PostDTOTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/26/26.
//

import XCTest
@testable import PostManager

final class PostDTOTests: XCTestCase {
    
    func test_toDomain_DTO를도메인엔티티로변환() {
        let dto = PostDTO(
            id: 1,
            title: "Test Title",
            body: "Test Body",
            tags: ["tag1", "tag2"],
            reactions: ReactionsDTO(likes: 10, dislikes: 2),
            views: 100,
            userId: 5,
            isDeleted: false,
            deletedOn: nil
        )
        
        let post = dto.toDomain()
        
        XCTAssertEqual(post.remoteId, 1)
        XCTAssertEqual(post.title, "Test Title")
        XCTAssertEqual(post.body, "Test Body")
        XCTAssertEqual(post.userId, 5)
        XCTAssertEqual(post.syncStatus, .synced)
        XCTAssertEqual(post.isSoftDeleted, false)
        XCTAssertNotNil(post.localId)
    }
    
    func test_toDomain_localId지정시해당ID사용() {
        let dto = PostDTO(
            id: 2,
            title: "Test",
            body: "Body",
            tags: nil,
            reactions: nil,
            views: nil,
            userId: 3,
            isDeleted: nil,
            deletedOn: nil
        )
        let expectedLocalId = UUID()
        
        let post = dto.toDomain(localId: expectedLocalId)
        
        XCTAssertEqual(post.localId, expectedLocalId)
        XCTAssertEqual(post.remoteId, 2)
    }
    
    func test_toDomain_isDeleted가nil일때false로변환() {
        let dto = PostDTO(
            id: 3,
            title: "Test",
            body: "Body",
            tags: nil,
            reactions: nil,
            views: nil,
            userId: 1,
            isDeleted: nil,
            deletedOn: nil
        )
        
        let post = dto.toDomain()
        
        XCTAssertEqual(post.isSoftDeleted, false)
    }
}
