//
//  PostsListViewModel.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation
import RxSwift
import RxCocoa

final class PostsListViewModel {
    
    struct State {
        var posts: [Post] = []
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var error: Error? = nil
        var canLoadMore: Bool = true
    }
    
    enum Action {
        case loadInitial
        case loadMore
        case create(title: String, body: String)
        case update(localId: UUID, title: String, body: String)
        case delete(localId: UUID)
        case dismissError
    }
    
    struct Dependency {
        let fetchPostsUseCase: FetchPostsUseCase
        let loadMorePostsUseCase: LoadMorePostsUseCase
        let createPostUseCase: CreatePostUseCase
        let updatePostUseCase: UpdatePostUseCase
        let deletePostUseCase: DeletePostUseCase
    }
    
    private let dependency: Dependency
    private let stateSubject = BehaviorSubject<State>(value: State())
    private let disposeBag = DisposeBag()
    private var isLoadingMore = false
    private let pageLimit = 10
    
    var state: Observable<State> {
        stateSubject.asObservable()
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func send(_ action: Action) {
        switch action {
        case .loadInitial:
            loadInitial()
        case .loadMore:
            loadMore()
        case .create(let title, let body):
            createPost(title: title, body: body)
        case .update(let localId, let title, let body):
            updatePost(localId: localId, title: title, body: body)
        case .delete(let localId):
            deletePost(localId: localId)
        case .dismissError:
            dismissError()
        }
    }
}

extension PostsListViewModel {
    
    private func loadInitial() {
        guard var currentState = try? stateSubject.value(), !currentState.isLoading else { return }
        
        currentState.isLoading = true
        currentState.error = nil
        stateSubject.onNext(currentState)
        
        Task {
            do {
                let posts = try await dependency.fetchPostsUseCase(limit: pageLimit, offset: 0)
                var newState = try stateSubject.value()
                newState.posts = posts
                newState.isLoading = false
                newState.canLoadMore = posts.count >= pageLimit
                stateSubject.onNext(newState)
            } catch {
                var newState = try? stateSubject.value()
                newState?.isLoading = false
                newState?.error = error
                if let newState = newState {
                    stateSubject.onNext(newState)
                }
            }
        }
    }
    
    private func loadMore() {
        guard var currentState = try? stateSubject.value(),
              !currentState.isLoadingMore,
              !isLoadingMore,
              currentState.canLoadMore else { return }
        
        isLoadingMore = true
        currentState.isLoadingMore = true
        stateSubject.onNext(currentState)
        
        Task {
            do {
                let offset = currentState.posts.count
                let posts = try await dependency.loadMorePostsUseCase(limit: pageLimit, offset: offset)
                var newState = try stateSubject.value()
                newState.posts.append(contentsOf: posts)
                newState.isLoadingMore = false
                newState.canLoadMore = posts.count >= pageLimit
                isLoadingMore = false
                stateSubject.onNext(newState)
            } catch {
                var newState = try? stateSubject.value()
                newState?.isLoadingMore = false
                newState?.error = error
                isLoadingMore = false
                if let newState = newState {
                    stateSubject.onNext(newState)
                }
            }
        }
    }
    
    private func createPost(title: String, body: String) {
        guard var currentState = try? stateSubject.value(), !currentState.isLoading else { return }
        
        currentState.isLoading = true
        stateSubject.onNext(currentState)
        
        Task {
            do {
                let newPost = try await dependency.createPostUseCase(title: title, body: body, userId: 1)
                var newState = try stateSubject.value()
                newState.posts.insert(newPost, at: 0)
                newState.isLoading = false
                stateSubject.onNext(newState)
            } catch {
                var newState = try? stateSubject.value()
                newState?.isLoading = false
                newState?.error = error
                if let newState = newState {
                    stateSubject.onNext(newState)
                }
            }
        }
    }
    
    private func updatePost(localId: UUID, title: String, body: String) {
        guard var currentState = try? stateSubject.value(), !currentState.isLoading else { return }
        
        currentState.isLoading = true
        stateSubject.onNext(currentState)
        
        Task {
            do {
                let updatedPost = try await dependency.updatePostUseCase(localId: localId, title: title, body: body)
                var newState = try stateSubject.value()
                if let index = newState.posts.firstIndex(where: { $0.localId == localId }) {
                    newState.posts[index] = updatedPost
                }
                newState.isLoading = false
                stateSubject.onNext(newState)
            } catch {
                var newState = try? stateSubject.value()
                newState?.isLoading = false
                newState?.error = error
                if let newState = newState {
                    stateSubject.onNext(newState)
                }
            }
        }
    }
    
    private func deletePost(localId: UUID) {
        guard var currentState = try? stateSubject.value(), !currentState.isLoading else { return }
        
        currentState.isLoading = true
        stateSubject.onNext(currentState)
        
        Task {
            do {
                try await dependency.deletePostUseCase(localId: localId)
                var newState = try stateSubject.value()
                newState.posts.removeAll { $0.localId == localId }
                newState.isLoading = false
                stateSubject.onNext(newState)
            } catch {
                var newState = try? stateSubject.value()
                newState?.isLoading = false
                newState?.error = error
                if let newState = newState {
                    stateSubject.onNext(newState)
                }
            }
        }
    }
    
    private func dismissError() {
        guard var currentState = try? stateSubject.value() else { return }
        currentState.error = nil
        stateSubject.onNext(currentState)
    }
}
