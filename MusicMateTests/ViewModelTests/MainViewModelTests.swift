//
//  MainViewModelTests.swift
//  MusicMateTests
//
//  Created by Henrik Schnettler on 16.01.24.
//

import XCTest
@testable import MusicMate // Replace with your app's module name

// MainViewModelTests
final class MainViewModelTests: XCTestCase {
    
    var viewModel: MainViewModel!
    var mockNetworkMonitor: MockNetworkMonitor!

    override func setUpWithError() throws {
        super.setUp()
        mockNetworkMonitor = MockNetworkMonitor()
        viewModel = MainViewModel(networkMonitor: mockNetworkMonitor)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkMonitor = nil
        super.tearDown()
    }

    func testIsConnectedToNetwork_WhenConnected() throws {
        // Arrange
        mockNetworkMonitor.mockNetworkStatus = .wifi // or .cellular

        // Act & Assert
        XCTAssertTrue(viewModel.isConnectedToNetwork)
    }

    func testIsConnectedToNetwork_WhenDisconnected() throws {
        // Arrange
        mockNetworkMonitor.mockNetworkStatus = .disconnected

        // Act & Assert
        XCTAssertFalse(viewModel.isConnectedToNetwork)
    }
}

