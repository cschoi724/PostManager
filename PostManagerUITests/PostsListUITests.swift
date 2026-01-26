//
//  PostsListUITests.swift
//  PostManagerUITests
//
//  Created by 일하는석찬 on 1/24/26.
//

import XCTest

final class PostsListUITests: XCTestCase {
    
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
    func test_게시글리스트_화면표시() throws {
        let tabBar = app.tabBars.firstMatch
        let postsTab = tabBar.buttons["게시글"]
        
        XCTAssertTrue(postsTab.waitForExistence(timeout: 2.0))
        postsTab.tap()
        
        let navigationBar = app.navigationBars["게시글"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 2.0))
        
        let addButton = navigationBar.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2.0))
    }
    
    @MainActor
    func test_게시글_생성() throws {
        let tabBar = app.tabBars.firstMatch
        let postsTab = tabBar.buttons["게시글"]
        XCTAssertTrue(postsTab.waitForExistence(timeout: 2.0))
        postsTab.tap()
        
        let navigationBar = app.navigationBars["게시글"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 2.0))
        
        let addButton = navigationBar.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2.0))
        addButton.tap()
        
        let alert = app.alerts["게시글 작성"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2.0))
        
        let titleField = alert.textFields.firstMatch
        let bodyField = alert.textFields.element(boundBy: 1)
        
        titleField.tap()
        titleField.typeText("UI 테스트 게시글")
        
        bodyField.tap()
        bodyField.typeText("UI 테스트 내용입니다")
        
        let createButton = alert.buttons["작성"]
        createButton.tap()
        
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 2.0))
        
        let createdCell = tableView.cells.containing(NSPredicate(format: "label CONTAINS 'UI 테스트 게시글'")).firstMatch
        XCTAssertTrue(createdCell.waitForExistence(timeout: 3.0))
    }
}
