//
//  PostsListViewController.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit

final class PostsListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "게시글"
    }
}
