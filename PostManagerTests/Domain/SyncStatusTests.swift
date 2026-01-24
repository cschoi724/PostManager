//
//  SyncStatusTests.swift
//  PostManagerTests
//
//  Created by 일하는석찬 on 1/24/26.
//

import XCTest
@testable import PostManager

final class SyncStatusTests: XCTestCase {
    
    func test_needsSync_동기화완료상태는_false반환() {
        XCTAssertFalse(SyncStatus.synced.needsSync)
    }
    
    func test_needsSync_변경상태는_true반환() {
        XCTAssertTrue(SyncStatus.created.needsSync)
        XCTAssertTrue(SyncStatus.updated.needsSync)
        XCTAssertTrue(SyncStatus.deleted.needsSync)
    }
    
    func test_Codable_직렬화_역직렬화_성공() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let statuses: [SyncStatus] = [.synced, .created, .updated, .deleted]
        
        for status in statuses {
            let data = try encoder.encode(status)
            let decoded = try decoder.decode(SyncStatus.self, from: data)
            XCTAssertEqual(status, decoded)
        }
    }
}
