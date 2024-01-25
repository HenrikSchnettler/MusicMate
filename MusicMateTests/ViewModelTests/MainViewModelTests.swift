//
//  MainViewModelTests.swift
//  MusicMateTests
//
//  Created by Henrik Schnettler on 16.01.24.
//

import XCTest
@testable import MusicMate // Replace with your app's module name

import XCTest
import Combine

// MainViewModelTests class contains unit tests for testing the MainViewModel's behavior.
final class MainViewModelTests: XCTestCase {
    
    var viewModel: MainViewModel! // Instance of the ViewModel under test.
    var mockNetworkMonitor: MockNetworkMonitor! // Mock instance of the NetworkMonitor.
    var cancellables: Set<AnyCancellable>! // Set to store Combine cancellables.

    // setUpWithError is called before the execution of each test method in the class.
    override func setUpWithError() throws {
        super.setUp()
        mockNetworkMonitor = MockNetworkMonitor() // Initialize the mock network monitor.
        viewModel = MainViewModel(networkMonitor: mockNetworkMonitor) // Initialize the ViewModel with the mock network monitor.
        cancellables = [] // Initialize the set of cancellables.
    }

    // tearDownWithError is called after the execution of each test method in the class.
    override func tearDownWithError() throws {
        viewModel = nil // Clear the ViewModel.
        mockNetworkMonitor = nil // Clear the mock network monitor.
        cancellables = nil // Clear the cancellables set.
        super.tearDown()
    }

    // Tests if the isConnectedToNetwork property is true when the network status is cellular.
    func testIsConnectedToNetwork_WhenConnectedToCellular() throws {
        let expectation = XCTestExpectation(description: "Network status update to cellular")
        
        // Observe changes to the isConnectedToNetwork property.
        viewModel.$isConnectedToNetwork
            .dropFirst() // Skip the initial value.
            .sink { isConnected in
                XCTAssertTrue(isConnected) // Assert that isConnectedToNetwork is true.
                expectation.fulfill() // Fulfill the expectation when the assertion passes.
            }
            .store(in: &cancellables)

        mockNetworkMonitor.networkStatus = .cellular // Change the mock network status to cellular.

        // Wait a moment to allow for asynchronous update.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.wait(for: [expectation], timeout: 1.0) // Wait for the expectation to be fulfilled.
        }
    }
    
    // Tests if the isConnectedToNetwork property is true when the network status is wifi.
    func testIsConnectedToNetwork_WhenConnectedToWifi() throws {
        let expectation = XCTestExpectation(description: "Network status update to wifi")
        
        // Observe changes to the isConnectedToNetwork property.
        viewModel.$isConnectedToNetwork
            .dropFirst() // Skip the initial value.
            .sink { isConnected in
                XCTAssertTrue(isConnected) // Assert that isConnectedToNetwork is true.
                expectation.fulfill() // Fulfill the expectation when the assertion passes.
            }
            .store(in: &cancellables)

        mockNetworkMonitor.networkStatus = .wifi // Change the mock network status to wifi.

        // Wait a moment to allow for asynchronous update.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.wait(for: [expectation], timeout: 1.0) // Wait for the expectation to be fulfilled.
        }
    }

    // Tests if the isConnectedToNetwork property is false when the network is disconnected.
    func testIsConnectedToNetwork_WhenDisconnected() throws {
        let expectation = XCTestExpectation(description: "Network status update to disconnected")
        
        // Observe changes to the isConnectedToNetwork property.
        viewModel.$isConnectedToNetwork
            .dropFirst() // Skip the initial value.
            .sink { isConnected in
                XCTAssertFalse(isConnected) // Assert that isConnectedToNetwork is false.
                expectation.fulfill() // Fulfill the expectation when the assertion passes.
            }
            .store(in: &cancellables)

        mockNetworkMonitor.networkStatus = .disconnected // Change the mock network status to disconnected.

        // Wait a moment to allow for asynchronous update.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.wait(for: [expectation], timeout: 1.0) // Wait for the expectation to be fulfilled.
        }
    }
}
