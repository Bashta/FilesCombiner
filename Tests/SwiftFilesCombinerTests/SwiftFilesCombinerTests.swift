//
//  SwiftFilesCombinerTests.swift
//  
//
//  Created by Erison Veshi on 14.7.24.
//

import Foundation
import XCTest

@testable import SwiftFilesCombiner

class SwiftFilesCombinerTests: XCTestCase {
    var mockFileSystem: FileSystemOperationsMock!
    let baseDir = "/test"
    let outputFile = "/test/output.swift"

    override func setUp() {
        super.setUp()
        mockFileSystem = FileSystemOperationsMock()
        mockFileSystem.directories.insert(baseDir)
        mockFileSystem.enumeratorPaths = []
    }

    func testOnlyNonSwiftFiles() throws {
        mockFileSystem.files = [
            "\(baseDir)/file1.txt": "Not a Swift file",
            "\(baseDir)/file2.md": "Another non-Swift file"
        ]
        mockFileSystem.enumeratorPaths = ["file1.txt", "file2.md"]
        
        try combineSwiftFiles(in: baseDir, outputFile: outputFile, fileSystem: mockFileSystem)
        
        XCTAssertTrue(mockFileSystem.fileExists(atPath: outputFile))
        let output = try mockFileSystem.contentsOfFile(atPath: outputFile)
        XCTAssertTrue(output.isEmpty)
    }

    func testMixOfSwiftAndNonSwiftFiles() throws {
        mockFileSystem.files = [
            "\(baseDir)/file1.swift": "print(\"Swift file 1\")",
            "\(baseDir)/file2.txt": "Not a Swift file",
            "\(baseDir)/file3.swift": "print(\"Swift file 2\")"
        ]
        mockFileSystem.enumeratorPaths = ["file1.swift", "file2.txt", "file3.swift"]
        
        try combineSwiftFiles(in: baseDir, outputFile: outputFile, fileSystem: mockFileSystem)
        
        XCTAssertTrue(mockFileSystem.fileExists(atPath: outputFile))
        let output = try mockFileSystem.contentsOfFile(atPath: outputFile)
        XCTAssertTrue(output.contains("Swift file 1"))
        XCTAssertTrue(output.contains("Swift file 2"))
        XCTAssertFalse(output.contains("Not a Swift file"))
    }

    func testNestedDirectories() throws {
        mockFileSystem.directories.insert("\(baseDir)/nested")
        mockFileSystem.directories.insert("\(baseDir)/deeply/nested")
        mockFileSystem.files = [
            "\(baseDir)/file1.swift": "print(\"Root file\")",
            "\(baseDir)/nested/file2.swift": "print(\"Nested file\")",
            "\(baseDir)/deeply/nested/file3.swift": "print(\"Deeply nested file\")"
        ]
        mockFileSystem.enumeratorPaths = ["file1.swift", "nested/file2.swift", "deeply/nested/file3.swift"]
        
        try combineSwiftFiles(in: baseDir, outputFile: outputFile, fileSystem: mockFileSystem)
        
        XCTAssertTrue(mockFileSystem.fileExists(atPath: outputFile))
        let output = try mockFileSystem.contentsOfFile(atPath: outputFile)
        XCTAssertTrue(output.contains("Root file"))
        XCTAssertTrue(output.contains("Nested file"))
        XCTAssertTrue(output.contains("Deeply nested file"))
    }

    func testLargeNumberOfFiles() throws {
        for i in 1...1000 {
            mockFileSystem.files["\(baseDir)/file\(i).swift"] = "print(\"File \(i)\")"
            mockFileSystem.enumeratorPaths.append("file\(i).swift")
        }
        
        try combineSwiftFiles(in: baseDir, outputFile: outputFile, fileSystem: mockFileSystem)
        
        XCTAssertTrue(mockFileSystem.fileExists(atPath: outputFile))
        let output = try mockFileSystem.contentsOfFile(atPath: outputFile)
        XCTAssertEqual(output.components(separatedBy: "print(").count, 1001) // 1000 files + 1 (split adds one)
    }

    func testFileWithSpecialCharactersInName() throws {
        mockFileSystem.files = [
            "\(baseDir)/file with spaces.swift": "print(\"Spaces\")",
            "\(baseDir)/file_with_underscores.swift": "print(\"Underscores\")",
            "\(baseDir)/file-with-dashes.swift": "print(\"Dashes\")",
            "\(baseDir)/file😀with😀emojis.swift": "print(\"Emojis\")"
        ]
        mockFileSystem.enumeratorPaths = ["file with spaces.swift", "file_with_underscores.swift", "file-with-dashes.swift", "file😀with😀emojis.swift"]
        
        try combineSwiftFiles(in: baseDir, outputFile: outputFile, fileSystem: mockFileSystem)
        
        XCTAssertTrue(mockFileSystem.fileExists(atPath: outputFile))
        let output = try mockFileSystem.contentsOfFile(atPath: outputFile)
        XCTAssertTrue(output.contains("Spaces"))
        XCTAssertTrue(output.contains("Underscores"))
        XCTAssertTrue(output.contains("Dashes"))
        XCTAssertTrue(output.contains("Emojis"))
    }

    func testEmptySwiftFile() throws {
        mockFileSystem.files = [
            "\(baseDir)/empty.swift": "",
            "\(baseDir)/nonempty.swift": "print(\"Not empty\")"
        ]
        mockFileSystem.enumeratorPaths = ["empty.swift", "nonempty.swift"]
        
        try combineSwiftFiles(in: baseDir, outputFile: outputFile, fileSystem: mockFileSystem)
        
        XCTAssertTrue(mockFileSystem.fileExists(atPath: outputFile))
        let output = try mockFileSystem.contentsOfFile(atPath: outputFile)
        XCTAssertTrue(output.contains("// File: \(baseDir)/empty.swift"))
        XCTAssertTrue(output.contains("Not empty"))
    }

    func testNonExistentInputDirectory() {
        XCTAssertThrowsError(try combineSwiftFiles(in: "/nonexistent", outputFile: outputFile, fileSystem: mockFileSystem)) { error in
            XCTAssertEqual(error as? FileSystemError, .directoryNotFound)
        }
    }

    func testExistingEmptyDirectory() throws {
        XCTAssertNoThrow(try combineSwiftFiles(in: baseDir, outputFile: outputFile, fileSystem: mockFileSystem))
        
        XCTAssertTrue(mockFileSystem.fileExists(atPath: outputFile))
        let output = try mockFileSystem.contentsOfFile(atPath: outputFile)
        XCTAssertTrue(output.isEmpty)
    }
    
    func testCurrentDirectoryAsInput() throws {
        // Setup the mock file system with the current directory
        let currentDir = FileManager.default.currentDirectoryPath
        mockFileSystem.directories.insert(currentDir)
        mockFileSystem.files = [
            "\(currentDir)/file1.swift": "print(\"Current directory file\")",
            "\(currentDir)/file2.txt": "Not a Swift file"
        ]
        mockFileSystem.enumeratorPaths = ["file1.swift", "file2.txt"]
        
        let outputFile = "\(currentDir)/output.swift"
        
        // Call combineSwiftFiles without specifying a directory
        try combineSwiftFiles(in: currentDir, outputFile: outputFile, fileSystem: mockFileSystem)
        
        XCTAssertTrue(mockFileSystem.fileExists(atPath: outputFile))
        let output = try mockFileSystem.contentsOfFile(atPath: outputFile)
        XCTAssertTrue(output.contains("Current directory file"))
        XCTAssertFalse(output.contains("Not a Swift file"))
    }
}
