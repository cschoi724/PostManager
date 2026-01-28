//
//  PostTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/24/26.
//

import XCTest
@testable import PostManager

final class PostTests: XCTestCase {
    
    func test_초기화_기본값_설정() {
        let post = Post(
            title: "Test Title",
            body: "Test Body",
            userId: 1
        )
        
        XCTAssertNotNil(post.localId)
        XCTAssertNil(post.remoteId)
        XCTAssertEqual(post.title, "Test Title")
        XCTAssertEqual(post.body, "Test Body")
        XCTAssertEqual(post.userId, 1)
        XCTAssertEqual(post.syncStatus, .created)
        XCTAssertFalse(post.isSoftDeleted)
    }
    
    func test_with_메서드_불변성_유지() {
        let original = Post(
            title: "Original",
            body: "Body",
            userId: 1
        )
        
        let modified = original.with(
            title: "Modified",
            syncStatus: .synced
        )
        
        XCTAssertEqual(original.localId, modified.localId)
        XCTAssertEqual(modified.title, "Modified")
        XCTAssertEqual(modified.body, "Body")
        XCTAssertEqual(modified.syncStatus, .synced)
        XCTAssertEqual(original.title, "Original")
    }
    
    func test_markAsSynced_remoteId설정_동기화상태변경() {
        let post = Post(
            title: "Test",
            body: "Body",
            userId: 1,
            syncStatus: .created
        )
        
        let synced = post.markAsSynced(remoteId: 123)
        
        XCTAssertEqual(synced.remoteId, 123)
        XCTAssertEqual(synced.syncStatus, .synced)
    }
    
    func test_markAsSynced_remoteId_nil_가능() {
        let post = Post(
            title: "Test",
            body: "Body",
            userId: 1,
            syncStatus: .created
        )
        
        let synced = post.markAsSynced(remoteId: nil)
        
        XCTAssertNil(synced.remoteId)
        XCTAssertEqual(synced.syncStatus, .synced)
    }
    
    func test_markAsDeleted_삭제상태_설정() {
        let post = Post(
            title: "Test",
            body: "Body",
            userId: 1,
            syncStatus: .created
        )
        
        let deleted = post.markAsDeleted()
        
        XCTAssertTrue(deleted.isSoftDeleted)
        XCTAssertEqual(deleted.syncStatus, .deleted)
        XCTAssertFalse(post.isSoftDeleted)
    }
    
    func test_needsSync_동기화필요상태_true반환() {
        XCTAssertTrue(Post(title: "Test", body: "Body", userId: 1, syncStatus: .created).needsSync)
        XCTAssertTrue(Post(title: "Test", body: "Body", userId: 1, syncStatus: .updated).needsSync)
        XCTAssertTrue(Post(title: "Test", body: "Body", userId: 1, syncStatus: .deleted).needsSync)
    }
    
    func test_needsSync_동기화완료상태_false반환() {
        XCTAssertFalse(Post(title: "Test", body: "Body", userId: 1, syncStatus: .synced).needsSync)
    }
    
    func test_isLocalOnly_remoteId없으면_true반환() {
        let localPost = Post(
            title: "Test",
            body: "Body",
            userId: 1
        )
        XCTAssertTrue(localPost.isLocalOnly)
    }
    
    func test_isLocalOnly_remoteId있으면_false반환() {
        let syncedPost = Post(
            remoteId: 123,
            title: "Test",
            body: "Body",
            userId: 1,
            syncStatus: .synced
        )
        XCTAssertFalse(syncedPost.isLocalOnly)
    }
    
    func test_Equatable_동일한값이면_true반환() {
        let localId = UUID()
        let date = Date()
        
        let post1 = Post(
            localId: localId,
            remoteId: 123,
            title: "Test",
            body: "Body",
            userId: 1,
            syncStatus: .synced,
            createdAt: date,
            updatedAt: date
        )
        
        let post2 = Post(
            localId: localId,
            remoteId: 123,
            title: "Test",
            body: "Body",
            userId: 1,
            syncStatus: .synced,
            createdAt: date,
            updatedAt: date
        )
        
        XCTAssertEqual(post1, post2)
    }
}
