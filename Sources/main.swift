//
//  main.swift
//  SwiftFilesCombiner
//
//  Created by Erison Veshi on 13.7.24.
//

import Foundation

func combineSwiftFiles(
    in directory: String,
    outputFile: String
) throws {
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(atPath: directory)
    let outputURL = URL(fileURLWithPath: outputFile)
    var combinedContent = ""

    while let filePath = enumerator?.nextObject() as? String {
        if filePath.hasSuffix(".swift") {
            let fullPath = (directory as NSString).appendingPathComponent(filePath)
            combinedContent += "\n\n// File: \(fullPath)\n\n"
            do {
                let content = try String(contentsOfFile: fullPath, encoding: .utf8)
                combinedContent += content
            } catch {
                print("Error reading file \(fullPath): \(error)")
            }
        }
    }

    try combinedContent.write(to: outputURL, atomically: true, encoding: .utf8)
}

// Parse command line arguments
guard CommandLine.arguments.count == 3 else {
    print("Usage: swift script.swift <directory_path> <output_file>")
    exit(1)
}

let directoryPath = CommandLine.arguments[1]
let outputFile = CommandLine.arguments[2]

do {
    try combineSwiftFiles(in: directoryPath, outputFile: outputFile)
    print("Combined Swift files have been written to \(outputFile)")
} catch {
    print("An error occurred: \(error)")
}
print("Hello, World!")
