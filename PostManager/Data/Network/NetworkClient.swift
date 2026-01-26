//
//  NetworkClient.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/26/26.
//

import Foundation

public protocol NetworkClient {
    func request<T: Decodable>(_ endpoint: APIRequest, decoder: JSONDecoder) async throws -> T
    func requestData(_ endpoint: APIRequest) async throws -> Data
}

public protocol NetworkRequestAdapter: Sendable {
    func adapt(_ request: URLRequest) -> URLRequest
}

public final class DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    private let logger: NetworkLogger?
    private let encoder: JSONEncoder

    public init(
        session: URLSession = .shared,
        logger: NetworkLogger? = ConsoleNetworkLogger()
    ) {
        self.session = session
        self.logger = logger
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    public func request<T: Decodable>(
        _ endpoint: APIRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await requestData(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error, data)
        }
    }

    public func requestData(_ endpoint: APIRequest) async throws -> Data {
        var urlRequest = try endpoint.buildURLRequest()
        
        if let body = endpoint.body {
            urlRequest.httpBody = try encoder.encode(body)
        }

        logger?.willSend(urlRequest)

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.transport(URLError(.badServerResponse))
            }

            guard (200..<300).contains(http.statusCode) else {
                let error = NetworkError.statusCode(http.statusCode, data)
                logger?.didFail(error, response: http)
                throw error
            }

            logger?.didReceive(data, response: http)
            return data
        } catch let urlError as URLError {
            throw NetworkError.transport(urlError)
        } catch let netError as NetworkError {
            throw netError
        } catch {
            throw error
        }
    }
}
