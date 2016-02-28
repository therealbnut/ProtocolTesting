//
//  ProtocolTestingTests.swift
//  ProtocolTestingTests
//
//  Created by Andrew Bennett on 22/02/2016.
//  Copyright © 2016 TeamBnut. All rights reserved.
//

import XCTest
@testable import ProtocolTesting

class ProtocolTestingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let summary = DebugTestReporter(fromReports: [
            (context: ["a"], status: .Success),
            (context: ["a", "a", "a"], status: .Failure(file: "file.swift", line: 120, reason: "it just did")),
            (context: ["a", "a", "b"], status: .Failure(file: "file.swift", line: 123, reason: "it also just did")),
            (context: ["a", "a", "c"], status: .Failure(file: "file.swift", line: 128, reason: "it also just did, as well")),
            (context: ["a", "a", "d"], status: .Success),
            (context: ["a", "a", "e"], status: .Success),
            (context: ["a", "a", "f"], status: .Success),
            (context: ["a", "b", "a"], status: .Success),
            (context: ["a", "b", "b"], status: .Success),
            (context: ["a", "c"], status: .Success),
            (context: ["b", "a"], status: .Success),
        ])
        print(summary)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
