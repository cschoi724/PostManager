//
//  AppDIContainer+BuilderFactory.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit

extension AppDIContainer {
    
    func makePostsBuilder() -> PostsBuilder {
        PostsBuilderImpl(
            dependency: PostsListViewModel.Dependency(
                fetchPostsUseCase: makeFetchPostsUseCase(),
                loadMorePostsUseCase: makeLoadMorePostsUseCase(),
                createPostUseCase: makeCreatePostUseCase(),
                updatePostUseCase: makeUpdatePostUseCase(),
                deletePostUseCase: makeDeletePostUseCase(),
                postsRepository: makePostsRepository()
            )
        )
    }
    
    func makeDashboardBuilder() -> DashboardBuilder {
        DashboardBuilderImpl(
            dependency: DashboardViewModel.Dependency(
                fetchDashboardUseCase: makeFetchDashboardUseCase(),
                updatePostUseCase: makeUpdatePostUseCase(),
                deletePostUseCase: makeDeletePostUseCase(),
                postsRepository: makePostsRepository()
            )
        )
    }
}
