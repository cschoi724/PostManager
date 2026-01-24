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
