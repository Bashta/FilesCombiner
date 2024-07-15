//
//  FileSystemOperations.swift
//  SwiftFilesCombiner
//
//  Created by Erison Veshi on 14.7.24.
//

import Foundation

// MARK: - Interface

protocol FileSystemOperations {
    func enumerator(atPath path: String) -> FileManager.DirectoryEnumerator?
    func contentsOfFile(atPath path: String) throws -> String
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool
    func fileExists(atPath path: String) -> Bool
    func directoryExists(atPath path: String) -> Bool
    func getDesktopPath() -> String?
}

enum FileSystemError: Error, Equatable {
    case fileNotFound(String)
    case failedToCreateEnumerator
    case failedToWriteFile
    case directoryNotFound
}

// MARK: - Base Implementation

class FileSystemOperationsImplemetation: FileSystemOperations {
    let fileManager = FileManager.default
    
    func enumerator(atPath path: String) -> FileManager.DirectoryEnumerator? {
        return fileManager.enumerator(atPath: path)
    }
    
    func contentsOfFile(atPath path: String) throws -> String {
        return try String(contentsOfFile: path, encoding: .utf8)
    }
    
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
        return fileManager.createFile(atPath: path, contents: data, attributes: attr)
    }
    
    func fileExists(atPath path: String) -> Bool {
        return fileManager.fileExists(atPath: path)
    }
    
    func directoryExists(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func getDesktopPath() -> String? {
        return NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first
    }
}

// MARK: - Mock Implementation

class FileSystemOperationsMock: FileSystemOperations {
    var files: [String: String] = [:]
    var enumeratorPaths: [String] = []
    var directories: Set<String> = []
    var desktopPathOverride: String?
    
    func enumerator(atPath path: String) -> FileManager.DirectoryEnumerator? {
        return MockDirectoryEnumerator(paths: enumeratorPaths)
    }
    
    func contentsOfFile(atPath path: String) throws -> String {
        guard let content = files[path] else {
            throw FileSystemError.fileNotFound(path)
        }
        return content
    }
    
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]?) -> Bool {
        if let data = data, let content = String(data: data, encoding: .utf8) {
            files[path] = content
            return true
        }
        return false
    }
    
    func fileExists(atPath path: String) -> Bool {
        return files[path] != nil
    }
    
    func directoryExists(atPath path: String) -> Bool {
        return directories.contains(path)
    }
    
    func getDesktopPath() -> String? {
            return desktopPathOverride ?? NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first
    }
}

class MockDirectoryEnumerator: FileManager.DirectoryEnumerator {
    private var paths: [String]
    private var index: Int = 0
    
    init(paths: [String]) {
        self.paths = paths
    }
    
    override func nextObject() -> Any? {
        guard index < paths.count else { return nil }
        let path = paths[index]
        index += 1
        return path
    }
}
