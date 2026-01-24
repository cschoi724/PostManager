//
//  CreatePostUseCase.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public protocol CreatePostUseCase {
    func callAsFunction(title: String, body: String, userId: Int) async throws -> Post
}

public final class CreatePostUseCaseImpl: CreatePostUseCase {
    private let repository: PostsRepository
    
    public init(repository: PostsRepository) {
        self.repository = repository
    }
    
    public func callAsFunction(title: String, body: String, userId: Int) async throws -> Post {
        return try await repository.createPost(title: title, body: body, userId: userId)
    }
}
