//
//  DashboardView.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit
import SnapKit
import Then

final class DashboardView: UIView {
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = true
    }
    
    private let contentView = UIView()
    
    private let statsStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 12
    }
    
    let totalCountCard = StatCardView()
    let offlineCreatedCard = StatCardView()
    let needsSyncCard = StatCardView()
    
    let recentPostsLabel = UILabel().then {
        $0.text = "최근 게시글"
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .label
    }
    
    let tableView = UITableView().then {
        $0.separatorStyle = .singleLine
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 80
        $0.isScrollEnabled = false
        $0.register(PostCell.self, forCellReuseIdentifier: PostCell.identifier)
        $0.backgroundColor = .clear
    }
    
    private var tableViewHeightConstraint: Constraint?
    
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
        $0.text = "데이터가 없습니다"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
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
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(statsStackView)
        contentView.addSubview(recentPostsLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(loadingView)
        contentView.addSubview(emptyStateView)
        
        statsStackView.addArrangedSubview(totalCountCard)
        statsStackView.addArrangedSubview(offlineCreatedCard)
        statsStackView.addArrangedSubview(needsSyncCard)
        
        loadingView.addSubview(loadingIndicator)
        emptyStateView.addSubview(emptyStateLabel)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        statsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        recentPostsLabel.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(recentPostsLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            tableViewHeightConstraint = make.height.equalTo(0).constraint
            make.bottom.equalToSuperview().inset(16)
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
    }
    
    func showLoading() {
        loadingView.isHidden = false
        contentView.isHidden = true
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingView.isHidden = true
        contentView.isHidden = false
        loadingIndicator.stopAnimating()
    }
    
    func showEmptyState() {
        emptyStateView.isHidden = false
        contentView.isHidden = true
    }
    
    func showContent() {
        emptyStateView.isHidden = true
        contentView.isHidden = false
    }
    
    func updateStats(totalCount: Int, offlineCreatedCount: Int, needsSyncCount: Int) {
        totalCountCard.configure(title: "전체 게시글", value: "\(totalCount)")
        offlineCreatedCard.configure(title: "오프라인 생성", value: "\(offlineCreatedCount)")
        needsSyncCard.configure(title: "동기화 필요", value: "\(needsSyncCount)")
    }
    
    func updateTableViewHeight() {
        guard tableViewHeightConstraint != nil else { return }
        
        tableView.layoutIfNeeded()
        let height = max(tableView.contentSize.height, 0)
        tableViewHeightConstraint?.update(offset: height)
    }
}
