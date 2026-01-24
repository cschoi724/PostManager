//
//  AppRouter.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit

public protocol AppRouter: Router {
    func showPostsList()
    func showDashboard()
    func showTabBar()
}

final class AppRouterImpl: AppRouter {
    public let navigationController: UINavigationController
    
    private weak var window: UIWindow?
    private var tabBarController: UITabBarController?
    private let screenFactory: AppScreenFactory
    
    init(
        window: UIWindow,
        screenFactory: AppScreenFactory
    ) {
        self.window = window
        self.screenFactory = screenFactory
        self.navigationController = UINavigationController()
    }
    
    public func start() {
        showTabBar()
    }
    
    public func showTabBar() {
        let tabBarController = UITabBarController()
        self.tabBarController = tabBarController
        
        let postsListVC = screenFactory.makePostsListViewController()
        let dashboardVC = screenFactory.makeDashboardViewController()
        
        let postsListNav = UINavigationController(rootViewController: postsListVC)
        let dashboardNav = UINavigationController(rootViewController: dashboardVC)
        
        postsListNav.tabBarItem = UITabBarItem(
            title: "게시글",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )
        
        dashboardNav.tabBarItem = UITabBarItem(
            title: "대시보드",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        tabBarController.viewControllers = [postsListNav, dashboardNav]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    public func showPostsList() {
        guard let tabBarController = tabBarController else { return }
        tabBarController.selectedIndex = 0
    }
    
    public func showDashboard() {
        guard let tabBarController = tabBarController else { return }
        tabBarController.selectedIndex = 1
    }
}
