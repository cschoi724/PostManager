//
//  FetchPostsUseCase.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public protocol FetchPostsUseCase {
    func callAsFunction(limit: Int, offset: Int) async throws -> [Post]
}

public final class FetchPostsUseCaseImpl: FetchPostsUseCase {
    private let repository: PostsRepository
    
    public init(repository: PostsRepository) {
        self.repository = repository
    }
    
    public func callAsFunction(limit: Int, offset: Int) async throws -> [Post] {
        return try await repository.fetchPosts(limit: limit, offset: offset)
    }
}
