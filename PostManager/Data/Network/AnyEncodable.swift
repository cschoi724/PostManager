//
//  AnyEncodable.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/26/26.
//

import Foundation

public struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    
    public init<E: Encodable>(_ encodable: E) {
        _encode = encodable.encode
    }
    
    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
