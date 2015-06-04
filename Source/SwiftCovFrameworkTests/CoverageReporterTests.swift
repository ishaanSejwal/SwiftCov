//
//  IntegrationTests.swift
//  swiftcov
//
//  Created by Kishikawa Katsumi on 2015/05/31.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import XCTest
import SwiftCovFramework

class CoverageReporterTests: XCTestCase {
    let reportFilenames = ["Calculator.swift.gcov", "Networking.swift.gcov"]
    var fixtureFilePaths: [String] {
        return reportFilenames.map { "./Examples/ExampleFramework/results/" + $0 }
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGenerateCoverageReportIOS() {
        let temporaryDirectory = NSTemporaryDirectory().stringByAppendingPathComponent(NSProcessInfo().globallyUniqueString)
        NSFileManager().createDirectoryAtPath(temporaryDirectory, withIntermediateDirectories: true, attributes: nil, error: nil)

        let reporter = CoverageReporter(outputDirectory: temporaryDirectory, threshold: 0)

        let xcodebuild = Xcodebuild(arguments: ["test",
                                                "-project", "./Examples/ExampleFramework/ExampleFramework.xcodeproj",
                                                "-scheme", "ExampleFramework-iOS",
                                                "-configuration", "Release",
                                                "-sdk", "iphonesimulator",
                                                "-derivedDataPath", temporaryDirectory])
        switch xcodebuild.showBuildSettings() {
        case let .Success(output):
            let buildSettings = BuildSettings(output: output.value)

            switch xcodebuild.buildExecutable() {
            case .Success:
                switch reporter.runCoverageReport(buildSettings: buildSettings) {
                case .Success:
                    Array(zip(reportFilenames, fixtureFilePaths))
                        .map { (reportFilename, fixtureFilePath) -> (String, String) in
                            return (temporaryDirectory.stringByAppendingPathComponent(reportFilename), fixtureFilePath)
                        }
                        .map { (reportFilePath, fixtureFilePath) in
                            XCTAssertEqual(
                                dropFirst(split(NSString(contentsOfFile: reportFilePath, encoding: NSUTF8StringEncoding, error: nil) as! String) { $0 == "\n" }),
                                dropFirst(split(NSString(contentsOfFile: fixtureFilePath, encoding: NSUTF8StringEncoding, error: nil) as! String) { $0 == "\n" }))
                    }
                case let .Failure(error):
                    XCTAssertNotEqual(error.value, EXIT_SUCCESS)
                    XCTFail("Execution failure")
                }
            case let .Failure(error):
                XCTAssertNotEqual(error.value, EXIT_SUCCESS)
                XCTFail("Execution failure")
            }
        case let .Failure(error):
            XCTAssertNotEqual(error.value, EXIT_SUCCESS)
            XCTFail("Execution failure")
        }
    }

    func testGenerateCoverageReportOSX() {
        let temporaryDirectory = NSTemporaryDirectory().stringByAppendingPathComponent(NSProcessInfo().globallyUniqueString)
        NSFileManager().createDirectoryAtPath(temporaryDirectory, withIntermediateDirectories: true, attributes: nil, error: nil)

        let reporter = CoverageReporter(outputDirectory: temporaryDirectory, threshold: 0)

        let xcodebuild = Xcodebuild(arguments: ["test",
                                                "-project", "./Examples/ExampleFramework/ExampleFramework.xcodeproj",
                                                "-scheme", "ExampleFramework-Mac",
                                                "-configuration", "Release",
                                                "-sdk", "macosx",
                                                "-derivedDataPath", temporaryDirectory])
        switch xcodebuild.showBuildSettings() {
        case let .Success(output):
            let buildSettings = BuildSettings(output: output.value)
            
            switch xcodebuild.buildExecutable() {
            case .Success:
                switch reporter.runCoverageReport(buildSettings: buildSettings) {
                case .Success:
                    Array(zip(reportFilenames, fixtureFilePaths))
                        .map { (reportFilename, fixtureFilePath) -> (String, String) in
                            return (temporaryDirectory.stringByAppendingPathComponent(reportFilename), fixtureFilePath)
                        }
                        .map { (reportFilePath, fixtureFilePath) in
                            XCTAssertEqual(
                                dropFirst(split(NSString(contentsOfFile: reportFilePath, encoding: NSUTF8StringEncoding, error: nil) as! String) { $0 == "\n" }),
                                dropFirst(split(NSString(contentsOfFile: fixtureFilePath, encoding: NSUTF8StringEncoding, error: nil) as! String) { $0 == "\n" }))
                    }
                case let .Failure(error):
                    XCTAssertNotEqual(error.value, EXIT_SUCCESS)
                    XCTFail("Execution failure")
                }
            case let .Failure(error):
                XCTAssertNotEqual(error.value, EXIT_SUCCESS)
                XCTFail("Execution failure")
            }
        case let .Failure(error):
            XCTAssertNotEqual(error.value, EXIT_SUCCESS)
            XCTFail("Execution failure")
        }
    }

}
