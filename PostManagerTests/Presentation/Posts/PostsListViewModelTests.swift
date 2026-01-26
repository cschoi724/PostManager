//
//  PostsListViewModelTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/24/26.
//

import XCTest
import RxSwift
@testable import PostManager

@MainActor
final class PostsListViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func test_초기상태_빈배열_로딩중아님() async {
        let viewModel = createViewModel()
        let expectation = expectation(description: "초기 상태 확인")
        var receivedState: PostsListViewModel.State?
        
        viewModel.state
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { state in
                receivedState = state
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedState?.posts.count, 0)
        XCTAssertFalse(receivedState?.isLoading ?? true)
        XCTAssertNil(receivedState?.error)
    }
    
    func test_loadInitial_성공시_게시글목록_업데이트() async {
        let mockPosts = [
            Post(title: "Test 1", body: "Body 1", userId: 1),
            Post(title: "Test 2", body: "Body 2", userId: 1)
        ]
        let mockFetchUseCase = MockFetchPostsUseCase(result: mockPosts)
        let viewModel = createViewModel(fetchPostsUseCase: mockFetchUseCase)
        
        viewModel.send(.loadInitial)
        let state = await waitForFinalState(viewModel: viewModel, predicate: { !$0.posts.isEmpty })
        
        XCTAssertEqual(state.posts.count, 2)
        XCTAssertEqual(state.posts[0].title, "Test 1")
        XCTAssertEqual(state.posts[1].title, "Test 2")
    }
    
    func test_create_성공시_게시글_추가() async {
        let mockPost = Post(title: "New Post", body: "New Body", userId: 1)
        let mockCreateUseCase = MockCreatePostUseCase(result: mockPost)
        let viewModel = createViewModel(createPostUseCase: mockCreateUseCase)
        
        viewModel.send(.create(title: "New Post", body: "New Body"))
        let state = await waitForFinalState(viewModel: viewModel, predicate: { !$0.posts.isEmpty })
        
        XCTAssertEqual(state.posts.count, 1)
        XCTAssertEqual(state.posts.first?.title, "New Post")
        XCTAssertEqual(state.posts.first?.body, "New Body")
    }
    
    func test_update_성공시_게시글_수정() async {
        let existingPost = Post(localId: UUID(), title: "Original", body: "Body", userId: 1)
        let updatedPost = Post(localId: existingPost.localId, title: "Updated", body: "Updated Body", userId: 1)
        
        let mockUpdateUseCase = MockUpdatePostUseCase(result: updatedPost)
        let mockFetchUseCase = MockFetchPostsUseCase(result: [existingPost])
        let viewModel = createViewModel(
            fetchPostsUseCase: mockFetchUseCase,
            updatePostUseCase: mockUpdateUseCase
        )
        
        viewModel.send(.loadInitial)
        _ = await waitForFinalState(viewModel: viewModel, predicate: { !$0.posts.isEmpty })
        
        viewModel.send(.update(localId: existingPost.localId, title: "Updated", body: "Updated Body"))
        let state = await waitForFinalState(viewModel: viewModel)
        
        let updated = state.posts.first { $0.localId == existingPost.localId }
        XCTAssertEqual(updated?.title, "Updated")
        XCTAssertEqual(updated?.body, "Updated Body")
    }
    
    func test_delete_성공시_게시글_제거() async {
        let postToDelete = Post(localId: UUID(), title: "Delete Me", body: "Body", userId: 1)
        let mockFetchUseCase = MockFetchPostsUseCase(result: [postToDelete])
        let mockDeleteUseCase = MockDeletePostUseCase()
        let viewModel = createViewModel(
            fetchPostsUseCase: mockFetchUseCase,
            deletePostUseCase: mockDeleteUseCase
        )
        
        viewModel.send(.loadInitial)
        _ = await waitForFinalState(viewModel: viewModel, predicate: { !$0.posts.isEmpty })
        
        viewModel.send(.delete(localId: postToDelete.localId))
        let state = await waitForFinalState(viewModel: viewModel)
        
        XCTAssertEqual(state.posts.count, 0)
        XCTAssertNil(state.posts.first { $0.localId == postToDelete.localId })
    }
}

extension PostsListViewModelTests {
    
    private func createViewModel(
        fetchPostsUseCase: FetchPostsUseCase? = nil,
        loadMorePostsUseCase: LoadMorePostsUseCase? = nil,
        createPostUseCase: CreatePostUseCase? = nil,
        updatePostUseCase: UpdatePostUseCase? = nil,
        deletePostUseCase: DeletePostUseCase? = nil
    ) -> PostsListViewModel {
        let dependency = PostsListViewModel.Dependency(
            fetchPostsUseCase: fetchPostsUseCase ?? MockFetchPostsUseCase(result: []),
            loadMorePostsUseCase: loadMorePostsUseCase ?? MockLoadMorePostsUseCase(result: []),
            createPostUseCase: createPostUseCase ?? MockCreatePostUseCase(result: Post(title: "", body: "", userId: 1)),
            updatePostUseCase: updatePostUseCase ?? MockUpdatePostUseCase(result: Post(title: "", body: "", userId: 1)),
            deletePostUseCase: deletePostUseCase ?? MockDeletePostUseCase()
        )
        return PostsListViewModel(dependency: dependency)
    }
    
    private func waitForFinalState(
        viewModel: PostsListViewModel,
        predicate: ((PostsListViewModel.State) -> Bool)? = nil,
        timeout: TimeInterval = 2.0
    ) async -> PostsListViewModel.State {
        let expectation = expectation(description: "상태 변경 대기")
        var finalState: PostsListViewModel.State?
        
        viewModel.state
            .skip(1)
            .filter { state in
                guard state.error == nil else { return false }
                return predicate?(state) ?? true
            }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { state in
                finalState = state
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        await fulfillment(of: [expectation], timeout: timeout)
        return finalState ?? PostsListViewModel.State()
    }
}

final class MockFetchPostsUseCase: FetchPostsUseCase {
    let result: [Post]
    
    init(result: [Post]) {
        self.result = result
    }
    
    func callAsFunction(limit: Int, offset: Int) async throws -> [Post] {
        return result
    }
}

final class MockLoadMorePostsUseCase: LoadMorePostsUseCase {
    let result: [Post]
    
    init(result: [Post]) {
        self.result = result
    }
    
    func callAsFunction(limit: Int, offset: Int) async throws -> [Post] {
        return result
    }
}

final class MockCreatePostUseCase: CreatePostUseCase {
    let result: Post
    
    init(result: Post) {
        self.result = result
    }
    
    func callAsFunction(title: String, body: String, userId: Int) async throws -> Post {
        return result
    }
}

final class MockUpdatePostUseCase: UpdatePostUseCase {
    let result: Post
    
    init(result: Post) {
        self.result = result
    }
    
    func callAsFunction(localId: UUID, title: String?, body: String?) async throws -> Post {
        return result
    }
}

final class MockDeletePostUseCase: DeletePostUseCase {
    func callAsFunction(localId: UUID) async throws {
    }
}
