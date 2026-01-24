//
//  PostsBuilder.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit

protocol PostsBuilder {
    func build() -> UIViewController
}

final class PostsBuilderImpl: PostsBuilder {
    private let fetchPostsUseCase: FetchPostsUseCase
    private let loadMorePostsUseCase: LoadMorePostsUseCase
    private let fetchPostUseCase: FetchPostUseCase
    private let createPostUseCase: CreatePostUseCase
    private let updatePostUseCase: UpdatePostUseCase
    private let deletePostUseCase: DeletePostUseCase
    
    init(
        fetchPostsUseCase: FetchPostsUseCase,
        loadMorePostsUseCase: LoadMorePostsUseCase,
        fetchPostUseCase: FetchPostUseCase,
        createPostUseCase: CreatePostUseCase,
        updatePostUseCase: UpdatePostUseCase,
        deletePostUseCase: DeletePostUseCase
    ) {
        self.fetchPostsUseCase = fetchPostsUseCase
        self.loadMorePostsUseCase = loadMorePostsUseCase
        self.fetchPostUseCase = fetchPostUseCase
        self.createPostUseCase = createPostUseCase
        self.updatePostUseCase = updatePostUseCase
        self.deletePostUseCase = deletePostUseCase
    }
    
    func build() -> UIViewController {
        let viewController = PostsListViewController()
        return viewController
    }
}
