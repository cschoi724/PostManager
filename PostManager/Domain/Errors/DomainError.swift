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
    
    public var localizedDescription: String {
        switch self {
        case .offlineNotAllowed:
            return "오프라인에서는 추가 로드를 할 수 없습니다"
        case .notFound:
            return "게시글을 찾을 수 없습니다"
        case .invalidInput:
            return "입력값이 올바르지 않습니다"
        }
    }
}
