//
//  DashboardSummaryTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/24/26.
//

import XCTest
@testable import PostManager

final class DashboardSummaryTests: XCTestCase {
    
    func test_초기화_모든값_설정() {
        let posts = [
            Post(title: "Test", body: "Body", userId: 1)
        ]
        
        let summary = DashboardSummary(
            totalCount: 10,
            offlineCreatedCount: 3,
            needsSyncCount: 5,
            recentPosts: posts
        )
        
        XCTAssertEqual(summary.totalCount, 10)
        XCTAssertEqual(summary.offlineCreatedCount, 3)
        XCTAssertEqual(summary.needsSyncCount, 5)
        XCTAssertEqual(summary.recentPosts.count, 1)
    }
}
