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
