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
                deletePostUseCase: makeDeletePostUseCase()
            )
        )
    }
    
    func makeDashboardBuilder() -> DashboardBuilder {
        DashboardBuilderImpl(
            fetchDashboardUseCase: makeFetchDashboardUseCase()
        )
    }
}
