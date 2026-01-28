//
//  DashboardViewController.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DashboardViewController: UIViewController {
    
    private let viewModel: DashboardViewModel
    private let disposeBag = DisposeBag()
    private let dashboardView = DashboardView()
    
    private var recentPosts: [Post] = []
    
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
        setupBindings()
        viewModel.send(.loadInitial)
    }
}

// MARK: - UI Setup & Binding
extension DashboardViewController {
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "대시보드"
        
        view.addSubview(dashboardView)
        dashboardView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        dashboardView.tableView.delegate = self
        dashboardView.tableView.dataSource = self
    }
    
    private func setupBindings() {
        viewModel.state
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.updateUI(with: state)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(with state: DashboardViewModel.State) {
        if state.isLoading && state.summary == nil {
            dashboardView.showLoading()
        } else if let summary = state.summary {
            dashboardView.hideLoading()
            dashboardView.showContent()
            
            dashboardView.updateStats(
                totalCount: summary.totalCount,
                offlineCreatedCount: summary.offlineCreatedCount,
                needsSyncCount: summary.needsSyncCount
            )
            
            recentPosts = summary.recentPosts
            dashboardView.tableView.reloadData()
            dashboardView.updateTableViewHeight()
        } else {
            dashboardView.showEmptyState()
        }
        
        if let error = state.error {
            let errorMessage = (error as? DomainError)?.localizedDescription ?? error.localizedDescription
            showErrorAlert(message: errorMessage)
        }
    }
    
}

// MARK: - Alert & ActionSheet
extension DashboardViewController {
    
    private func showEditPostAlert(post: Post) {
        let alert = UIAlertController(title: "게시글 수정", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = post.title
            textField.placeholder = "제목"
        }
        
        alert.addTextField { textField in
            textField.text = post.body
            textField.placeholder = "내용"
        }
        
        let updateAction = UIAlertAction(title: "수정", style: .default) { [weak self] _ in
            guard let self = self,
                  let titleField = alert.textFields?[0],
                  let bodyField = alert.textFields?[1],
                  let title = titleField.text,
                  let body = bodyField.text,
                  !title.isEmpty,
                  !body.isEmpty else {
                return
            }
            
            self.viewModel.send(.update(localId: post.localId, title: title, body: body))
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showDeleteConfirmationAlert(post: Post) {
        let alert = UIAlertController(
            title: "게시글 삭제",
            message: "정말 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.send(.delete(localId: post.localId))
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showPostActionSheet(post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정", style: .default) { [weak self] _ in
            self?.showEditPostAlert(post: post)
        }
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.showDeleteConfirmationAlert(post: post)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.viewModel.send(.dismissError)
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DashboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as! PostCell
        let post = recentPosts[indexPath.row]
        cell.configure(title: post.title, body: post.body)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DashboardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = recentPosts[indexPath.row]
        showPostActionSheet(post: post)
    }
}
