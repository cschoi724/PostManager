//
//  Router.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit

public protocol Router: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
    func dismiss(animated: Bool)
    func pop(animated: Bool)
    func popToRoot(animated: Bool)
}

extension Router {
    public func dismiss(animated: Bool = true) {
        navigationController.dismiss(animated: animated)
    }
    
    public func pop(animated: Bool = true) {
        navigationController.popViewController(animated: animated)
    }
    
    public func popToRoot(animated: Bool = true) {
        navigationController.popToRootViewController(animated: animated)
    }
}
