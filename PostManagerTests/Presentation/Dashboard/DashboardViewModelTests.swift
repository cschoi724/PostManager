//
//  DashboardViewModelTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/24/26.
//

import XCTest
import RxSwift
@testable import PostManager

@MainActor
final class DashboardViewModelTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func test_초기상태_summary_nil_로딩중아님() async {
        let viewModel = createViewModel()
        let expectation = expectation(description: "초기 상태 확인")
        var receivedState: DashboardViewModel.State?
        
        viewModel.state
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { state in
                receivedState = state
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertNil(receivedState?.summary)
        XCTAssertFalse(receivedState?.isLoading ?? true)
        XCTAssertNil(receivedState?.error)
    }
    
    func test_loadInitial_성공시_summary_업데이트() async {
        let mockSummary = DashboardSummary(
            totalCount: 5,
            offlineCreatedCount: 2,
            needsSyncCount: 3,
            recentPosts: [
                Post(title: "Recent 1", body: "Body 1", userId: 1),
                Post(title: "Recent 2", body: "Body 2", userId: 1)
            ]
        )
        let mockFetchUseCase = MockFetchDashboardUseCase(result: mockSummary)
        let viewModel = createViewModel(fetchDashboardUseCase: mockFetchUseCase)
        
        viewModel.send(.loadInitial)
        let state = await waitForFinalState(viewModel: viewModel, predicate: { $0.summary != nil })
        
        XCTAssertNotNil(state.summary)
        XCTAssertEqual(state.summary?.totalCount, 5)
        XCTAssertEqual(state.summary?.offlineCreatedCount, 2)
        XCTAssertEqual(state.summary?.needsSyncCount, 3)
        XCTAssertEqual(state.summary?.recentPosts.count, 2)
    }
    
    func test_update_성공시_summary_재계산() async {
        let existingPost = Post(localId: UUID(), title: "Original", body: "Body", userId: 1)
        let updatedPost = Post(localId: existingPost.localId, title: "Updated", body: "Updated Body", userId: 1)
        
        let summary = DashboardSummary(
            totalCount: 1,
            offlineCreatedCount: 0,
            needsSyncCount: 0,
            recentPosts: [updatedPost]
        )
        
        let mockFetchUseCase = MockFetchDashboardUseCase(result: summary)
        let mockUpdateUseCase = MockUpdatePostUseCase(result: updatedPost)
        let viewModel = createViewModel(
            fetchDashboardUseCase: mockFetchUseCase,
            updatePostUseCase: mockUpdateUseCase
        )
        
        viewModel.send(.loadInitial)
        _ = await waitForFinalState(viewModel: viewModel, predicate: { $0.summary != nil })
        
        viewModel.send(.update(localId: existingPost.localId, title: "Updated", body: "Updated Body"))
        let state = await waitForFinalState(viewModel: viewModel)
        
        XCTAssertNotNil(state.summary)
        XCTAssertGreaterThan(mockFetchUseCase.callCount, 1, "update 후 summary가 재계산되어야 함")
    }
    
    func test_delete_성공시_summary_재계산() async {
        let postToDelete = Post(localId: UUID(), title: "Delete Me", body: "Body", userId: 1)
        
        let initialSummary = DashboardSummary(
            totalCount: 1,
            offlineCreatedCount: 0,
            needsSyncCount: 0,
            recentPosts: [postToDelete]
        )
        let deletedSummary = DashboardSummary(
            totalCount: 0,
            offlineCreatedCount: 0,
            needsSyncCount: 0,
            recentPosts: []
        )
        
        let mockFetchUseCase = MockFetchDashboardUseCase(result: initialSummary)
        let mockDeleteUseCase = MockDeletePostUseCase()
        let viewModel = createViewModel(
            fetchDashboardUseCase: mockFetchUseCase,
            deletePostUseCase: mockDeleteUseCase
        )
        
        viewModel.send(.loadInitial)
        _ = await waitForFinalState(viewModel: viewModel, predicate: { $0.summary != nil })
        
        let initialCallCount = mockFetchUseCase.callCount
        mockFetchUseCase.result = deletedSummary
        viewModel.send(.delete(localId: postToDelete.localId))
        let state = await waitForFinalState(viewModel: viewModel)
        
        XCTAssertNotNil(state.summary)
        XCTAssertGreaterThan(mockFetchUseCase.callCount, initialCallCount, "delete 후 summary가 재계산되어야 함")
    }
}

extension DashboardViewModelTests {
    
    private func createViewModel(
        fetchDashboardUseCase: FetchDashboardUseCase? = nil,
        updatePostUseCase: UpdatePostUseCase? = nil,
        deletePostUseCase: DeletePostUseCase? = nil,
        postsRepository: PostsRepository? = nil
    ) -> DashboardViewModel {
        let dependency = DashboardViewModel.Dependency(
            fetchDashboardUseCase: fetchDashboardUseCase ?? MockFetchDashboardUseCase(result: DashboardSummary(totalCount: 0, offlineCreatedCount: 0, needsSyncCount: 0, recentPosts: [])),
            updatePostUseCase: updatePostUseCase ?? MockUpdatePostUseCase(result: Post(title: "", body: "", userId: 1)),
            deletePostUseCase: deletePostUseCase ?? MockDeletePostUseCase(),
            postsRepository: postsRepository ?? MockPostsRepositoryForDashboardViewModel()
        )
        return DashboardViewModel(dependency: dependency)
    }
    
    private func waitForFinalState(
        viewModel: DashboardViewModel,
        predicate: ((DashboardViewModel.State) -> Bool)? = nil,
        timeout: TimeInterval = 2.0
    ) async -> DashboardViewModel.State {
        let expectation = expectation(description: "상태 변경 대기")
        var finalState: DashboardViewModel.State?
        
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
        return finalState ?? DashboardViewModel.State()
    }
}

final class MockFetchDashboardUseCase: FetchDashboardUseCase {
    var result: DashboardSummary
    var callCount = 0
    
    init(result: DashboardSummary) {
        self.result = result
    }
    
    func callAsFunction() async throws -> DashboardSummary {
        callCount += 1
        return result
    }
}

final class MockPostsRepositoryForDashboardViewModel: PostsRepository {
    func fetchPosts(limit: Int, offset: Int) async throws -> [Post] {
        return []
    }
    
    func fetchPost(localId: UUID) async throws -> Post? {
        return nil
    }
    
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        return Post(title: title, body: body, userId: userId)
    }
    
    func updatePost(localId: UUID, title: String?, body: String?) async throws -> Post {
        return Post(localId: localId, title: title ?? "", body: body ?? "", userId: 1)
    }
    
    func deletePost(localId: UUID) async throws {
    }
    
    func fetchPostsNeedingSync() async throws -> [Post] {
        return []
    }
    
    func syncPendingChanges() async throws {
    }
    
    func fetchAllPosts() async throws -> [Post] {
        return []
    }
    
    func fetchRecentPosts(limit: Int) async throws -> [Post] {
        return []
    }
    
    func observePosts() -> AsyncStream<[Post]> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
}
