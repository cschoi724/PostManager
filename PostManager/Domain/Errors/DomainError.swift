//
//  DomainError.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public enum DomainError: Error {
    case offlineNotAllowed
    case notFound
    case invalidInput
}
