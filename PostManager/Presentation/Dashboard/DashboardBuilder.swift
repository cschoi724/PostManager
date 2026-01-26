//
//  DashboardBuilder.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit

protocol DashboardBuilder {
    func build() -> UIViewController
}

final class DashboardBuilderImpl: DashboardBuilder {
    private let dependency: DashboardViewModel.Dependency
    
    init(dependency: DashboardViewModel.Dependency) {
        self.dependency = dependency
    }
    
    func build() -> UIViewController {
        let viewModel = DashboardViewModel(dependency: dependency)
        let viewController = DashboardViewController(viewModel: viewModel)
        return viewController
    }
}
