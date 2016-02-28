//
//  TestReportStreamFormatter.swift
//  ProtocolTesting
//
//  Created by Andrew Bennett on 27/02/2016.
//  Copyright © 2016 TeamBnut. All rights reserved.
//

public class TestReportStreamFormatter<Output: OutputStreamType>: TestReporter {
    private var state: [(context: String, success: Int, failure: Int)] = []
    private var followsNewline: Bool = true

    public var output: Output

    public init(output: Output) {
        self.output  = output
    }

    private func _closeContext(context: ArraySlice<String>) {
        // context to close
        let scoresEndIndex = self.state.endIndex
        let scoresStartIndex = min(context.endIndex, scoresEndIndex)
        let range = scoresStartIndex ..< scoresEndIndex

        for index in range.reverse() {
            let success = self.state[index].success
            let failure = self.state[index].failure
            if success + failure > 1 || index == 0 {
                if !self.followsNewline {
                    self.output.write("\n")
                    self.followsNewline = true
                }
                self.output.write(String(count: index+1, repeatedValue: Character("\t")))
                self.output.write("score: \(success) / \(success+failure)\n")
                self.followsNewline = true
            }
        }
        self.state.removeRange(range)
    }

    private func _openContext(context: ArraySlice<String>) {
        let range = self.state.endIndex ..< context.endIndex
        for index in range {
            if !self.followsNewline {
                self.output.write("\n")
                self.followsNewline = true
            }
            self.output.write(String(count: index, repeatedValue: Character("\t")))
            self.output.write("\"\(context[index])\"")
            self.output.write(":\n")
            self.state.append((context[index],0,0))
            self.followsNewline = true
        }
    }

    public func updateContext(context: [String]) {
        let commonContext = context.prefix(sharedWith: self.state.lazy.map{$0.context})
        self._closeContext(commonContext)
        self._openContext(context[context.indices])
    }

    public func report(context: [String], status: TestStatus) {
        let commonContext = context.prefix(sharedWith: self.state.lazy.map{$0.context})
        self._closeContext(commonContext)
        let wasEmpty = self.state.isEmpty
        self._openContext(context.dropLast())

        if self.followsNewline {
            self.output.write(String(count: self.state.count, repeatedValue: Character("\t")))
            self.followsNewline = false
        }
        if let last = context.last {
            if !status.succeeded || wasEmpty {
                self.output.write("\"\(last)\"")
                if status.succeeded {
                    self.output.write(": ")
                }
                self.followsNewline = false
            }
            self.state.append((last,0,0))
        }

        switch status {
        case .Success:
            for index in self.state.indices { self.state[index].success += 1 }
            self.output.write("✔")
            self.followsNewline = false
        case let .Failure(file: file, line: line, reason: reason):
            for index in self.state.indices { self.state[index].failure += 1 }
            self.output.write(" failed @ \(file):\(line)\n")

            let indent = String(count: self.state.count, repeatedValue: Character("\t"))
            self.output.write(indent)
            self.output.write(
                reason.characters.lazy
                    .split { $0 == "\n" }
                    .map { String($0) }
                    .joinWithSeparator("\n\(indent)"))
            self.output.write("\n")
            self.followsNewline = true
        }
    }
}

extension CollectionType where Generator.Element: Equatable {
    private func prefix<S: SequenceType where S.Generator.Element == Generator.Element>
        (sharedWith sequence: S) -> SubSequence
    {
        var looped = false
        for (index, value) in zip(self.indices, sequence) {
            if value != self[index] {
                return self[self.startIndex ..< index]
            }
            looped = true
        }
        return looped ? self[self.indices] : self[self.startIndex ..< self.startIndex]
    }
}
