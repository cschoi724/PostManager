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
