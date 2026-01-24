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
        
        let totalCount = allPosts.count
        let offlineCreatedCount = allPosts.filter { $0.isLocalOnly }.count
        let needsSyncCount = postsNeedingSync.count
        
        return DashboardSummary(
            totalCount: totalCount,
            offlineCreatedCount: offlineCreatedCount,
            needsSyncCount: needsSyncCount,
            recentPosts: recentPosts
        )
    }
}
