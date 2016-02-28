//
//  TestReporter.swift
//  ProtocolTesting
//
//  Created by Andrew Bennett on 22/02/2016.
//  Copyright © 2016 TeamBnut. All rights reserved.
//

public protocol TestReporter {
    mutating func report(context: [String], status: TestStatus)
}

private func createString(fromContext context: [String]) -> String {
    return "'" + context.joinWithSeparator("' > '") + "'"
}

private func createString(fromStatus status: TestStatus) -> String {
    switch status {
    case .Success:
        return "succeeded"
    case let .Failure(file: file, line: line, reason: reason):
        return "failed at \(file):\(line): \"\(reason)\""
    }
}

public class DebugTestReporter: TestReporter, CustomStringConvertible {
    private let queue: dispatch_queue_t
    private var reports: [(context: [String], status: TestStatus)]
    public init(fromReports reports: [(context: [String], status: TestStatus)] = []) {
        self.reports = reports
        self.queue   = dispatch_queue_create("test.reporter.debug", DISPATCH_QUEUE_CONCURRENT)
    }
    public func report(context: [String], status: TestStatus) {
        dispatch_async(dispatch_get_main_queue()) {
            let contextString = createString(fromContext: context)
            let statusString = createString(fromStatus: status)
            print("\(contextString): \(statusString)")
        }
        dispatch_barrier_async(self.queue) { [weak self] in
            self?.reports.append((context: context, status: status))
        }
    }

    public var description: String {
        var reports = [(context: [String], status: TestStatus)]()
        dispatch_sync(self.queue) {
            reports.appendContentsOf(self.reports)
        }
        class StringStream: OutputStreamType {
            var output = ""
            func write(string: String) {
                output.appendContentsOf(string)
            }
        }
        let stream = StringStream()
        let formatter = TestReportStreamFormatter(output: stream)
        for report in reports {
            formatter.report(report.context, status: report.status)
        }
        formatter.updateContext([])
        return stream.output
    }
}
