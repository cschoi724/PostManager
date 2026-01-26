//
//  NetworkError.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/26/26.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case transport(URLError)
    case statusCode(Int, Data?)
    case decoding(Error, Data?)
}
