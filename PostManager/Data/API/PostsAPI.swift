//
//  PostsAPI.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/26/26.
//

import Foundation

enum PostsAPI {
    case getAllPosts(limit: Int, skip: Int)
    case getPost(id: Int)
    case createPost(title: String, body: String, userId: Int)
    case updatePost(id: Int, title: String?, body: String?)
    case deletePost(id: Int)
}

extension PostsAPI: APIRequest {
    var baseURL: URL {
        URL(string: "https://dummyjson.com")!
    }
    
    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var path: String {
        switch self {
        case .getAllPosts:
            return "/posts"
        case .getPost(let id):
            return "/posts/\(id)"
        case .createPost:
            return "/posts/add"
        case .updatePost(let id, _, _):
            return "/posts/\(id)"
        case .deletePost(let id):
            return "/posts/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAllPosts, .getPost:
            return .get
        case .createPost:
            return .post
        case .updatePost:
            return .put
        case .deletePost:
            return .delete
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .getAllPosts(let limit, let skip):
            return [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "skip", value: "\(skip)")
            ]
        case .getPost, .createPost, .updatePost, .deletePost:
            return []
        }
    }
    
    var body: AnyEncodable? {
        switch self {
        case .getAllPosts, .getPost, .deletePost:
            return nil
        case .createPost(let title, let body, let userId):
            return AnyEncodable(CreatePostRequestDTO(title: title, body: body, userId: userId))
        case .updatePost(_, let title, let body):
            return AnyEncodable(UpdatePostRequestDTO(title: title, body: body))
        }
    }
}
