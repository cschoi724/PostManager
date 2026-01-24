//
//  DeletePostUseCase.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public protocol DeletePostUseCase {
    func callAsFunction(localId: UUID) async throws
}

public final class DeletePostUseCaseImpl: DeletePostUseCase {
    private let repository: PostsRepository
    
    public init(repository: PostsRepository) {
        self.repository = repository
    }
    
    public func callAsFunction(localId: UUID) async throws {
        try await repository.deletePost(localId: localId)
    }
}
