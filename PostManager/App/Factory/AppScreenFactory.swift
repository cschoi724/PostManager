//
//  AppScreenFactory.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit

protocol AppScreenFactory {
    func makePostsListViewController() -> UIViewController
    func makeDashboardViewController() -> UIViewController
}

final class AppScreenFactoryImpl: AppScreenFactory {
    private let diContainer: AppDIContainer
    
    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
    }
    
    func makePostsListViewController() -> UIViewController {
        let builder = diContainer.makePostsBuilder()
        return builder.build()
    }
    
    func makeDashboardViewController() -> UIViewController {
        let builder = diContainer.makeDashboardBuilder()
        return builder.build()
    }
}
