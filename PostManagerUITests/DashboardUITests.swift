//
//  DashboardUITests.swift
//  PostManagerUITests
//
//  Created by 일하는석찬 on 1/24/26.
//

import XCTest

final class DashboardUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    @MainActor
    func test_대시보드_화면표시() throws {
        let tabBar = app.tabBars.firstMatch
        let dashboardTab = tabBar.buttons["대시보드"]
        
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 2.0))
        dashboardTab.tap()
        
        let navigationBar = app.navigationBars["대시보드"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 2.0))
        
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 2.0))
        
        let totalCountLabel = scrollView.staticTexts.containing(NSPredicate(format: "label CONTAINS '전체 게시글'")).firstMatch
        let offlineCreatedLabel = scrollView.staticTexts.containing(NSPredicate(format: "label CONTAINS '오프라인 생성'")).firstMatch
        let needsSyncLabel = scrollView.staticTexts.containing(NSPredicate(format: "label CONTAINS '동기화 필요'")).firstMatch
        
        XCTAssertTrue(totalCountLabel.waitForExistence(timeout: 3.0))
        XCTAssertTrue(offlineCreatedLabel.waitForExistence(timeout: 3.0))
        XCTAssertTrue(needsSyncLabel.waitForExistence(timeout: 3.0))
    }
}
