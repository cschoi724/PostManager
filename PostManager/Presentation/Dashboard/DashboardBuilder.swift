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
    private let fetchDashboardUseCase: FetchDashboardUseCase
    
    init(fetchDashboardUseCase: FetchDashboardUseCase) {
        self.fetchDashboardUseCase = fetchDashboardUseCase
    }
    
    func build() -> UIViewController {
        let viewController = DashboardViewController()
        return viewController
    }
}
