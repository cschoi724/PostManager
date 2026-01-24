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
