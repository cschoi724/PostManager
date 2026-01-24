//
//  SceneDelegate.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appRouter: AppRouter?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let diContainer = AppDIContainer()
        let screenFactory = AppScreenFactoryImpl(diContainer: diContainer)
        
        let appRouter = AppRouterImpl(
            window: window,
            screenFactory: screenFactory
        )
        self.appRouter = appRouter
        
        appRouter.start()
    }
}

