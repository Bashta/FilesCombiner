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
guard CommandLine.arguments.count == 3 else {
    print("Usage: swift script.swift <directory_path> <output_file>")
    exit(1)
}

let directoryPath = CommandLine.arguments[1]
let outputFile = CommandLine.arguments[2]

do {
    let realFileSystem = FileSystemOperationsImplemetation()
    try combineSwiftFiles(in: directoryPath, outputFile: outputFile, fileSystem: realFileSystem)
    print("Combined Swift files have been written to \(outputFile)")
} catch {
    print("An error occurred: \(error)")
}
