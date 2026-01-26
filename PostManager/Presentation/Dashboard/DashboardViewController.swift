//
//  DashboardViewController.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit

final class DashboardViewController: UIViewController {
    
    private let viewModel: DashboardViewModel
    
    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "대시보드"
    }
}
