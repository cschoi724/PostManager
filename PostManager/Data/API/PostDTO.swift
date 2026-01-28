//
//  PostDTO.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/26/26.
//

import Foundation

struct PostDTO: Codable {
    let id: Int
    let title: String
    let body: String
    let tags: [String]?
    let reactions: ReactionsDTO?
    let views: Int?
    let userId: Int
    let isDeleted: Bool?
    let deletedOn: String?
}

struct ReactionsDTO: Codable {
    let likes: Int
    let dislikes: Int
}

struct PostListResponseDTO: Codable {
    let posts: [PostDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

struct CreatePostRequestDTO: Codable {
    let title: String
    let body: String
    let userId: Int
}

struct UpdatePostRequestDTO: Codable {
    let title: String?
    let body: String?
}

extension PostDTO {
    func toDomain(localId: UUID? = nil) -> Post {
        return Post(
            localId: localId ?? UUID(),
            remoteId: id,
            title: title,
            body: body,
            userId: userId,
            syncStatus: .synced,
            createdAt: Date(),
            updatedAt: Date(),
            isSoftDeleted: isDeleted ?? false
        )
    }
}
