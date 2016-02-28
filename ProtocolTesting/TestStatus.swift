//
//  TestStatus.swift
//  ProtocolTesting
//
//  Created by Andrew Bennett on 22/02/2016.
//  Copyright © 2016 TeamBnut. All rights reserved.
//

public enum TestStatus: CustomStringConvertible {
    case Success
    case Failure(file: String, line: Int, reason: String)

    public var succeeded: Bool {
        if case .Success = self {
            return true
        }
        return false
    }

    public var description: String {
        switch self {
        case .Success:
            return "success"
        case let .Failure(file: file, line: line, reason: reason):
            return "failure @\(file):\(line): \(reason)"
        }
    }
}

public protocol TestStatusConvertible {
    func testReporterStatus(file file: String, line: Int) -> TestStatus
}

extension TestStatus: TestStatusConvertible {
    public func testReporterStatus(file file: String, line: Int) -> TestStatus {
        return self
    }
}

extension Bool: TestStatusConvertible {
    public func testReporterStatus(file file: String, line: Int) -> TestStatus {
        if self {
            return .Success
        }
        return .Failure(file: file, line: line, reason: "test returned TestStatus 'false')")
    }
}
