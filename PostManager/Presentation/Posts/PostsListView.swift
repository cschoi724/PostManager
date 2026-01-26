//
//  PostsListView.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit
import SnapKit
import Then

final class PostsListView: UIView {
    
    let tableView = UITableView().then {
        $0.separatorStyle = .singleLine
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 80
        $0.register(PostCell.self, forCellReuseIdentifier: PostCell.identifier)
    }
    
    private let loadingView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.isHidden = true
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }
    
    private let emptyStateView = UIView().then {
        $0.isHidden = true
    }
    
    private let emptyStateLabel = UILabel().then {
        $0.text = "게시글이 없습니다"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
    }
    
    private let errorView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.isHidden = true
    }
    
    private let errorLabel = UILabel().then {
        $0.text = "오류가 발생했습니다"
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .systemRed
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(tableView)
        addSubview(loadingView)
        addSubview(emptyStateView)
        addSubview(errorView)
        
        loadingView.addSubview(loadingIndicator)
        emptyStateView.addSubview(emptyStateLabel)
        errorView.addSubview(errorLabel)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        errorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
    func showLoading() {
        loadingView.isHidden = false
        tableView.isHidden = true
        emptyStateView.isHidden = true
        errorView.isHidden = true
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingView.isHidden = true
        loadingIndicator.stopAnimating()
    }
    
    func showEmptyState() {
        tableView.isHidden = true
        emptyStateView.isHidden = false
        errorView.isHidden = true
        hideLoading()
    }
    
    func showContent() {
        tableView.isHidden = false
        emptyStateView.isHidden = true
        errorView.isHidden = true
        hideLoading()
    }
    
    func showLoadingMore() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        footerView.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        tableView.tableFooterView = footerView
    }
    
    func hideLoadingMore() {
        tableView.tableFooterView = nil
    }
    
    func showError(message: String) {
        errorLabel.text = message
        errorView.isHidden = false
        tableView.isHidden = true
        emptyStateView.isHidden = true
        hideLoading()
    }
    
    func hideError() {
        errorView.isHidden = true
    }
}
