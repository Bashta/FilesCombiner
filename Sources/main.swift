//
//  main.swift
//  SwiftFilesCombiner
//
//  Created by Erison Veshi on 13.7.24.
//

import Foundation

// Function to combine Swift files
func combineSwiftFiles(in directory: String, outputFile: String, fileSystem: FileSystemOperations) throws {
    guard fileSystem.directoryExists(atPath: directory) else {
        throw FileSystemError.directoryNotFound
    }

    guard let enumerator = fileSystem.enumerator(atPath: directory) else {
        throw FileSystemError.failedToCreateEnumerator
    }
    
    var combinedContent = ""

    while let filePath = enumerator.nextObject() as? String {
        if filePath.hasSuffix(".swift") {
            let fullPath = (directory as NSString).appendingPathComponent(filePath)
            combinedContent += "\n\n// File: \(fullPath)\n\n"
            do {
                let content = try fileSystem.contentsOfFile(atPath: fullPath)
                combinedContent += content
            } catch {
                print("Error reading file \(fullPath): \(error)")
            }
        }
    }

    let outputData = combinedContent.data(using: .utf8)
    if !fileSystem.createFile(atPath: outputFile, contents: outputData, attributes: nil) {
        throw FileSystemError.failedToWriteFile
    }
}

// Main execution
let arguments = CommandLine.arguments
let fileManager = FileManager.default

let directoryPath: String
let outputFile: String

switch arguments.count {
case 1: // No arguments provided
    directoryPath = fileManager.currentDirectoryPath
    outputFile = "combined_swift_files.swift"
case 2: // Only output file provided
    directoryPath = fileManager.currentDirectoryPath
    outputFile = arguments[1]
case 3: // Both directory and output file provided
    directoryPath = arguments[1]
    outputFile = arguments[2]
default:
    print("Usage: swift script.swift [<directory_path>] [<output_file>]")
    print("If no arguments are provided, the current directory will be used and the output will be 'combined_swift_files.swift'")
    exit(1)
}

do {
    let realFileSystem = FileSystemOperationsImplemetation()
    try combineSwiftFiles(in: directoryPath, outputFile: outputFile, fileSystem: realFileSystem)
    print("Combined Swift files from '\(directoryPath)' have been written to '\(outputFile)'")
} catch {
    print("An error occurred: \(error)")
}
