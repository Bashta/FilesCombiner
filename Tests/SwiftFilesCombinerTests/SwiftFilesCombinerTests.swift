//
//  SwiftFilesCombinerTests.swift
//  
//
//  Created by Erison Veshi on 14.7.24.
//

import Foundation
import XCTest

@testable import SwiftFilesCombiner

final class SwiftFilesCombinerTests: XCTestCase {
    let fileManager = FileManager.default
    var tempDirectoryURL: URL!

    override func setUp() {
        super.setUp()
        tempDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? fileManager.removeItem(at: tempDirectoryURL)
        super.tearDown()
    }

    func testEmptyDirectory() throws {
        let outputURL = tempDirectoryURL.appendingPathComponent("output.swift")
        try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: outputURL.path)
        
        XCTAssertTrue(fileManager.fileExists(atPath: outputURL.path))
        let content = try String(contentsOf: outputURL)
        XCTAssertTrue(content.isEmpty)
    }

    func testLargeNumberOfFiles() throws {
        for i in 1...1000 {
            let content = "// File \(i)\nprint(\"Hello from file \(i)\")\n"
            try content.write(to: tempDirectoryURL.appendingPathComponent("file\(i).swift"), atomically: true, encoding: .utf8)
        }
        
        let outputURL = tempDirectoryURL.appendingPathComponent("output.swift")
        try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: outputURL.path)
        
        let content = try String(contentsOf: outputURL)
        let lineCount = content.components(separatedBy: .newlines).count
        
        // Check if the line count is within an expected range
        XCTAssertGreaterThanOrEqual(lineCount, 3000, "Should have at least 3000 lines (1000 files * 3 lines each)")
        XCTAssertLessThanOrEqual(lineCount, 7000, "Should have no more than 7000 lines (accounting for extra lines between files)")
        
        // Check if each file's content is present
        for i in 1...1000 {
            XCTAssertTrue(content.contains("Hello from file \(i)"), "Content from file \(i) should be present")
        }
    }

    func testNestedDirectories() throws {
        let nestedDir = tempDirectoryURL.appendingPathComponent("nested/deeply/directory")
        try fileManager.createDirectory(at: nestedDir, withIntermediateDirectories: true)
        
        try "print(\"Hello from nested file\")".write(to: nestedDir.appendingPathComponent("nested.swift"), atomically: true, encoding: .utf8)
        
        let outputURL = tempDirectoryURL.appendingPathComponent("output.swift")
        try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: outputURL.path)
        
        let content = try String(contentsOf: outputURL)
        XCTAssertTrue(content.contains("Hello from nested file"))
    }

    func testFilePermissions() throws {
        let fileURL = tempDirectoryURL.appendingPathComponent("readonly.swift")
        try "print(\"Read-only file\")".write(to: fileURL, atomically: true, encoding: .utf8)
        try fileManager.setAttributes([.posixPermissions: 0o444], ofItemAtPath: fileURL.path)
        
        let outputURL = tempDirectoryURL.appendingPathComponent("output.swift")
        try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: outputURL.path)
        
        let content = try String(contentsOf: outputURL)
        XCTAssertTrue(content.contains("Read-only file"))
    }

    func testNonSwiftFiles() throws {
        try "Not a Swift file".write(to: tempDirectoryURL.appendingPathComponent("notswift.txt"), atomically: true, encoding: .utf8)
        try "print(\"Swift file\")".write(to: tempDirectoryURL.appendingPathComponent("swift.swift"), atomically: true, encoding: .utf8)
        
        let outputURL = tempDirectoryURL.appendingPathComponent("output.swift")
        try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: outputURL.path)
        
        let content = try String(contentsOf: outputURL)
        XCTAssertTrue(content.contains("Swift file"))
        XCTAssertFalse(content.contains("Not a Swift file"))
    }

    func testSpecialCharactersInFilenames() throws {
        try "print(\"Special chars\")".write(to: tempDirectoryURL.appendingPathComponent("special チャrs.swift"), atomically: true, encoding: .utf8)
        
        let outputURL = tempDirectoryURL.appendingPathComponent("output.swift")
        try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: outputURL.path)
        
        let content = try String(contentsOf: outputURL)
        XCTAssertTrue(content.contains("Special chars"))
    }

    func testDuplicateFileNames() throws {
        let subdir = tempDirectoryURL.appendingPathComponent("subdir")
        try fileManager.createDirectory(at: subdir, withIntermediateDirectories: true)
        
        try "print(\"Root file\")".write(to: tempDirectoryURL.appendingPathComponent("duplicate.swift"), atomically: true, encoding: .utf8)
        try "print(\"Subdir file\")".write(to: subdir.appendingPathComponent("duplicate.swift"), atomically: true, encoding: .utf8)
        
        let outputURL = tempDirectoryURL.appendingPathComponent("output.swift")
        try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: outputURL.path)
        
        let content = try String(contentsOf: outputURL)
        XCTAssertTrue(content.contains("Root file"))
        XCTAssertTrue(content.contains("Subdir file"))
    }

    func testInvalidOutputFilePath() throws {
        XCTAssertThrowsError(try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: "/nonexistent/directory/output.swift"))
    }

    func testSwiftFilesWithSyntaxErrors() throws {
        try "this is not valid Swift code".write(to: tempDirectoryURL.appendingPathComponent("invalid.swift"), atomically: true, encoding: .utf8)
        
        let outputURL = tempDirectoryURL.appendingPathComponent("output.swift")
        try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: outputURL.path)
        
        let content = try String(contentsOf: outputURL)
        XCTAssertTrue(content.contains("this is not valid Swift code"))
    }

    func testEmptySwiftFiles() throws {
        try "".write(to: tempDirectoryURL.appendingPathComponent("empty.swift"), atomically: true, encoding: .utf8)
        
        let outputURL = tempDirectoryURL.appendingPathComponent("output.swift")
        try combineSwiftFiles(in: tempDirectoryURL.path, outputFile: outputURL.path)
        
        let content = try String(contentsOf: outputURL)
        XCTAssertTrue(content.contains("// File:"))
        XCTAssertTrue(content.contains("empty.swift"))
    }
}
