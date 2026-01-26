//
//  NetworkLogger.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/26/26.
//

import Foundation

public protocol NetworkLogger {
    func willSend(_ request: URLRequest)
    func didReceive(_ data: Data, response: HTTPURLResponse)
    func didFail(_ error: Error, response: HTTPURLResponse?)
}

public final class ConsoleNetworkLogger: NetworkLogger {
    public init() {}

    public func willSend(_ request: URLRequest) {
        print("[REQ]", request.httpMethod ?? "", request.url?.absoluteString ?? "")
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("   headers:", headers)
        }
        if let body = request.httpBody, let s = String(data: body, encoding: .utf8) {
            print("   body:", s)
        }
    }

    public func didReceive(_ data: Data, response: HTTPURLResponse) {
        print("[RES]", response.statusCode, response.url?.absoluteString ?? "")
        if let s = String(data: data, encoding: .utf8) {
          print("   body:", s)
        }
    }

    public func didFail(_ error: Error, response: HTTPURLResponse?) {
        print("[ERR]", response?.statusCode ?? -1, response?.url?.absoluteString ?? "", error)
    }
}