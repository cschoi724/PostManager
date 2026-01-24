//
//  FetchPostUseCase.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public protocol FetchPostUseCase {
    func callAsFunction(localId: UUID) async throws -> Post?
}

public final class FetchPostUseCaseImpl: FetchPostUseCase {
    private let repository: PostsRepository
    
    public init(repository: PostsRepository) {
        self.repository = repository
    }
    
    public func callAsFunction(localId: UUID) async throws -> Post? {
        return try await repository.fetchPost(localId: localId)
    }
}
