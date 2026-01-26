//
//  DashboardViewModel.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation
import RxSwift
import RxCocoa

final class DashboardViewModel {
    
    struct State {
        var summary: DashboardSummary?
        var isLoading: Bool = false
        var error: Error? = nil
    }
    
    enum Action {
        case loadInitial
        case update(localId: UUID, title: String, body: String)
        case delete(localId: UUID)
        case dismissError
    }
    
    struct Dependency {
        let fetchDashboardUseCase: FetchDashboardUseCase
        let updatePostUseCase: UpdatePostUseCase
        let deletePostUseCase: DeletePostUseCase
        let postsRepository: PostsRepository
    }
    
    private let dependency: Dependency
    private let stateSubject = BehaviorSubject<State>(value: State())
    private let disposeBag = DisposeBag()
    
    var state: Observable<State> {
        stateSubject.asObservable()
    }
    
    init(dependency: Dependency) {
        self.dependency = dependency
        observePostsChanges()
    }
    
    func send(_ action: Action) {
        switch action {
        case .loadInitial:
            loadInitial()
        case .update(let localId, let title, let body):
            updatePost(localId: localId, title: title, body: body)
        case .delete(let localId):
            deletePost(localId: localId)
        case .dismissError:
            dismissError()
        }
    }
}

extension DashboardViewModel {
    
    private func observePostsChanges() {
        let postsStream = dependency.postsRepository.observePosts()
        
        Task {
            for await _ in postsStream {
                await refreshSummary()
            }
        }
    }
    
    private func refreshSummary() async {
        do {
            let summary = try await dependency.fetchDashboardUseCase()
            await MainActor.run {
                var currentState = try? stateSubject.value()
                currentState?.summary = summary
                currentState?.isLoading = false
                currentState?.error = nil
                if let currentState = currentState {
                    stateSubject.onNext(currentState)
                }
            }
        } catch {
            await MainActor.run {
                var currentState = try? stateSubject.value()
                currentState?.isLoading = false
                currentState?.error = error
                if let currentState = currentState {
                    stateSubject.onNext(currentState)
                }
            }
        }
    }
}

extension DashboardViewModel {
    
    private func loadInitial() {
        guard var currentState = try? stateSubject.value(), !currentState.isLoading else { return }
        
        currentState.isLoading = true
        currentState.error = nil
        stateSubject.onNext(currentState)
        
        Task {
            await refreshSummary()
        }
    }
    
    private func updatePost(localId: UUID, title: String, body: String) {
        guard var currentState = try? stateSubject.value(), !currentState.isLoading else { return }
        
        currentState.isLoading = true
        stateSubject.onNext(currentState)
        
        Task {
            do {
                _ = try await dependency.updatePostUseCase(localId: localId, title: title, body: body)
                await refreshSummary()
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
                await refreshSummary()
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
