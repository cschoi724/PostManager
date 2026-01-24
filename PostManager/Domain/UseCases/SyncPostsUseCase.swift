//
//  SyncPostsUseCase.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public protocol SyncPostsUseCase {
    func callAsFunction() async throws
}

public final class SyncPostsUseCaseImpl: SyncPostsUseCase {
    private let repository: PostsRepository
    
    public init(repository: PostsRepository) {
        self.repository = repository
    }
    
    public func callAsFunction() async throws {
        try await repository.syncPendingChanges()
    }
}
