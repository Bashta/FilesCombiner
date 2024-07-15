//
//  main.swift
//  SwiftFilesCombiner
//
//  Created by Erison Veshi on 13.7.24.
//

import Foundation

func combineSwiftFiles(in directory: String, outputFile: String, fileSystem: FileSystemOperations) throws {
    guard fileSystem.directoryExists(atPath: directory) else {
        throw FileSystemError.directoryNotFound
    }

    guard let enumerator = fileSystem.enumerator(atPath: directory) else {
        throw FileSystemError.failedToCreateEnumerator
    }
    
    var combinedContent = readCombinedContent(in: directory, enumerator: enumerator, fileSystem: fileSystem)

    let outputData = combinedContent.data(using: .utf8)
    if !fileSystem.createFile(atPath: outputFile, contents: outputData, attributes: nil) {
        throw FileSystemError.failedToWriteFile
    }
}

func readCombinedContent(in directory: String, enumerator: FileManager.DirectoryEnumerator, fileSystem: FileSystemOperations) -> String {
    var result = ""
    
    while let filePath = enumerator.nextObject() as? String {
        if filePath.hasSuffix(".swift") {
            let fullPath = (directory as NSString).appendingPathComponent(filePath)
            result += "\n\n// File: \(fullPath)\n\n"
            do {
                let content = try fileSystem.contentsOfFile(atPath: fullPath)
                result += content
            } catch {
                print("Error reading file \(fullPath): \(error)")
            }
        }
    }
    
    return result
}

enum ArgumentError: Error {
    case desktopNotFound
}

func parseArguments(_ args: [String], fileSystem: FileSystemOperations) throws -> (String, String) {
    var directoryPath = FileManager.default.currentDirectoryPath
    var outputFile = "combined_swift_files.swift"
    var useDesktop = false
    
    var i = 0
    while i < args.count {
        switch args[i] {
        case "-d", "--desktop":
            useDesktop = true
        default:
            if args[i].hasPrefix("-") {
                // Ignore unknown flags
            } else if directoryPath == FileManager.default.currentDirectoryPath {
                directoryPath = args[i]
            } else if outputFile == "combined_swift_files.swift" {
                outputFile = args[i]
            }
            // Ignore any additional arguments
        }
        i += 1
    }
    
    if useDesktop {
        guard let desktopPath = fileSystem.getDesktopPath() else {
            throw ArgumentError.desktopNotFound
        }
        outputFile = (desktopPath as NSString).appendingPathComponent(outputFile)
    }
    
    return (directoryPath, outputFile)
}

// Main execution
do {
    let realFileSystem = FileSystemOperationsImplemetation()
    let args = Array(CommandLine.arguments.dropFirst()) // Remove the first argument (program name)
    let (directoryPath, outputFile) = try parseArguments(args, fileSystem: realFileSystem)
    
    print("Input Directory: \(directoryPath)")
    print("Output File: \(outputFile)")
    
    try combineSwiftFiles(in: directoryPath, outputFile: outputFile, fileSystem: realFileSystem)
    print("Combined Swift files from '\(directoryPath)' have been written to '\(outputFile)'")
} catch {
    print("An error occurred: \(error)")
    exit(1)
}
