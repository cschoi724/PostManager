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
