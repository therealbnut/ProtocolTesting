//
//  TestRunner.swift
//  ProtocolTesting
//
//  Created by Andrew Bennett on 22/02/2016.
//  Copyright © 2016 TeamBnut. All rights reserved.
//

public final class TestRunner<T> {
    private let instanceGenerators: [()->T]
    private var reporter: TestReporter

    public init(reporter: TestReporter, maximumInstances: Int = 100, nextInstanceGenerator: ()->(()->T)?) {
        self.reporter = reporter
        self.instanceGenerators = {
            var instanceGenerators = Array<() -> T>()
            instanceGenerators.reserveCapacity(maximumInstances)
            for _ in 1 ... maximumInstances {
                guard let instanceGenerator = nextInstanceGenerator() else {
                    continue
                }
                instanceGenerators.append(instanceGenerator)
            }
            return instanceGenerators
            }()
    }

    public func runTest<Status: TestStatusConvertible>(
        context: [String],
        file: String = __FILE__, line: Int = __LINE__,
        test: T throws -> Status)
    {
        for instanceGenerator in instanceGenerators {
            let instance = instanceGenerator()
            let status: TestStatus
            do {
                let convertible = try test(instance)
                status = convertible.testReporterStatus(file: file, line: line)
            }
            catch {
                if let convertible = error as? TestStatusConvertible {
                    status = convertible.testReporterStatus(file: file, line: line)
                }
                else {
                    status = .Failure(file: file, line: line, reason: "unknown error thrown: \"\(error)\"")
                }
            }
            self.reporter.report(context, status: status)
        }
    }

    public func runTest<Status: TestStatusConvertible>(
        context: String,
        file: String = __FILE__, line: Int = __LINE__,
        test: T throws -> Status)
    {
        self.runTest([context], file: file, line: line, test: test)
    }
}
