//
//  FetchDashboardUseCase.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public protocol FetchDashboardUseCase {
    func callAsFunction() async throws -> DashboardSummary
}

public final class FetchDashboardUseCaseImpl: FetchDashboardUseCase {
    private let repository: PostsRepository
    
    public init(repository: PostsRepository) {
        self.repository = repository
    }
    
    public func callAsFunction() async throws -> DashboardSummary {
        let allPosts = try await repository.fetchAllPosts()
        let postsNeedingSync = try await repository.fetchPostsNeedingSync()
        let recentPosts = try await repository.fetchRecentPosts(limit: 5)
        
        // 전체 게시글: soft delete 되지 않은 로컬 기준
        let totalCount = allPosts.filter { !$0.isSoftDeleted }.count
        
        // 오프라인 생성: 서버에 아직 반영되지 않은 created
        let offlineCreatedCount = allPosts.filter { $0.syncStatus == .created }.count
        
        // 3동기화 필요: synced 가 아닌 모든 글 (soft delete 포함)
        let needsSyncCount = postsNeedingSync.filter { $0.syncStatus != .synced }.count
        
        return DashboardSummary(
            totalCount: totalCount,
            offlineCreatedCount: offlineCreatedCount,
            needsSyncCount: needsSyncCount,
            recentPosts: recentPosts
        )
    }
}
