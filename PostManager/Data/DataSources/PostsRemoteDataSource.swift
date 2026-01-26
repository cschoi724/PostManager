//
//  PostsRemoteDataSource.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/26/26.
//

import Foundation

protocol PostsRemoteDataSource {
    func fetchAllPosts(limit: Int, skip: Int) async throws -> [Post]
    func fetchPost(id: Int) async throws -> Post
    func createPost(title: String, body: String, userId: Int) async throws -> Post
    func updatePost(id: Int, title: String?, body: String?) async throws -> Post
    func deletePost(id: Int) async throws -> Post
}

final class PostsRemoteDataSourceImpl: PostsRemoteDataSource {
    private let networkClient: NetworkClient
    private let decoder: JSONDecoder
    
    init(
        networkClient: NetworkClient,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.networkClient = networkClient
        self.decoder = decoder
    }
    
    func fetchAllPosts(limit: Int, skip: Int) async throws -> [Post] {
        let api = PostsAPI.getAllPosts(limit: limit, skip: skip)
        let response: PostListResponseDTO = try await networkClient.request(api, decoder: decoder)
        return response.posts.map { $0.toDomain() }
    }
    
    func fetchPost(id: Int) async throws -> Post {
        let api = PostsAPI.getPost(id: id)
        let dto: PostDTO = try await networkClient.request(api, decoder: decoder)
        return dto.toDomain()
    }
    
    func createPost(title: String, body: String, userId: Int) async throws -> Post {
        let api = PostsAPI.createPost(title: title, body: body, userId: userId)
        let dto: PostDTO = try await networkClient.request(api, decoder: decoder)
        return dto.toDomain()
    }
    
    func updatePost(id: Int, title: String?, body: String?) async throws -> Post {
        let api = PostsAPI.updatePost(id: id, title: title, body: body)
        let dto: PostDTO = try await networkClient.request(api, decoder: decoder)
        return dto.toDomain()
    }
    
    func deletePost(id: Int) async throws -> Post {
        let api = PostsAPI.deletePost(id: id)
        let dto: PostDTO = try await networkClient.request(api, decoder: decoder)
        return dto.toDomain()
    }
}
