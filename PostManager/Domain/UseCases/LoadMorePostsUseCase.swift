//
//  LoadMorePostsUseCase.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public protocol LoadMorePostsUseCase {
    func callAsFunction(limit: Int, offset: Int) async throws -> [Post]
}

public final class LoadMorePostsUseCaseImpl: LoadMorePostsUseCase {
    private let repository: PostsRepository
    private let networkMonitor: NetworkMonitor
    
    public init(repository: PostsRepository, networkMonitor: NetworkMonitor) {
        self.repository = repository
        self.networkMonitor = networkMonitor
    }
    
    public func callAsFunction(limit: Int, offset: Int) async throws -> [Post] {
        guard networkMonitor.isOnline else {
            throw DomainError.offlineNotAllowed
        }
        
        return try await repository.fetchPosts(limit: limit, offset: offset)
    }
}
