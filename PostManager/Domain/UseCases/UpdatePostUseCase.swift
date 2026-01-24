//
//  UpdatePostUseCase.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public protocol UpdatePostUseCase {
    func callAsFunction(localId: UUID, title: String?, body: String?) async throws -> Post
}

public final class UpdatePostUseCaseImpl: UpdatePostUseCase {
    private let repository: PostsRepository
    
    public init(repository: PostsRepository) {
        self.repository = repository
    }
    
    public func callAsFunction(localId: UUID, title: String?, body: String?) async throws -> Post {
        return try await repository.updatePost(localId: localId, title: title, body: body)
    }
}
