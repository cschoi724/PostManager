//
//  DashboardSummary.swift
//  PostManager
//
//  Created by 일하는석찬 on 1/24/26.
//

import Foundation

public struct DashboardSummary {
    public let totalCount: Int
    public let offlineCreatedCount: Int
    public let needsSyncCount: Int
    public let recentPosts: [Post]
    
    public init(
        totalCount: Int,
        offlineCreatedCount: Int,
        needsSyncCount: Int,
        recentPosts: [Post]
    ) {
        self.totalCount = totalCount
        self.offlineCreatedCount = offlineCreatedCount
        self.needsSyncCount = needsSyncCount
        self.recentPosts = recentPosts
    }
}
