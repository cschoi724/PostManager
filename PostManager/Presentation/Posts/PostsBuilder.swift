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
    private let dependency: PostsListViewModel.Dependency
    
    init(dependency: PostsListViewModel.Dependency) {
        self.dependency = dependency
    }
    
    func build() -> UIViewController {
        let viewModel = PostsListViewModel(dependency: dependency)
        let viewController = PostsListViewController(viewModel: viewModel)
        return viewController
    }
}
