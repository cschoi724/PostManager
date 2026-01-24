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
