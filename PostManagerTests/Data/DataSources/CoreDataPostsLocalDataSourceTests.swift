//
//  CoreDataPostsLocalDataSourceTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/28/26.
//

import XCTest
import CoreData
@testable import PostManager

@MainActor
final class CoreDataPostsLocalDataSourceTests: XCTestCase {

    private var coreDataStack: CoreDataStack!
    private var sut: CoreDataPostsLocalDataSource!

    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack(name: "PostsModel", storeType: .inMemory)
        sut = CoreDataPostsLocalDataSource(coreDataStack: coreDataStack)
    }

    override func tearDown() {
        sut = nil
        coreDataStack = nil
        super.tearDown()
    }

    func test_savePost_저장후_localId로조회된다() async throws {
        let post = Post(
            title: "Test Title",
            body: "Test Body",
            userId: 1,
            syncStatus: .created
        )

        try await sut.savePost(post)
        let fetched = try await sut.fetchPost(localId: post.localId)

        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.title, "Test Title")
        XCTAssertEqual(fetched?.body, "Test Body")
    }

    func test_fetchAllPosts_모든게시글_조회() async throws {
        let post1 = Post(title: "Post 1", body: "Body 1", userId: 1)
        let post2 = Post(title: "Post 2", body: "Body 2", userId: 1)
        try await sut.savePost(post1)
        try await sut.savePost(post2)

        let all = try await sut.fetchAllPosts()

        XCTAssertEqual(all.count, 2)
    }

    func test_deletePost_삭제후_조회되지않음() async throws {
        let post = Post(title: "Test", body: "Body", userId: 1)
        try await sut.savePost(post)

        try await sut.deletePost(localId: post.localId)
        let all = try await sut.fetchAllPosts()

        XCTAssertEqual(all.count, 0)
    }
}
