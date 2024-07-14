# SwiftFilesCombiner

SwiftFilesCombiner is a command-line utility designed to simplify the process of combining multiple Swift files into a single file. This tool is particularly useful for developers who need to merge multiple Swift source files for code review, submission, or any other purpose that requires a consolidated view of the codebase.

## Features

- Recursively scans a specified directory for Swift files
- Combines all found Swift files into a single output file
- Preserves file paths in comments for easy reference
- Handles potential errors gracefully

## Installation

SwiftFilesCombiner can be easily installed using Homebrew:
```
brew tap bashta/tap
brew install swiftfilescombiner
```

## Usage

After installation, you can use SwiftFilesCombiner from the command line with two arguments:
`swiftfilescombiner <directory_path> <output_file>`

Where:
- `<directory_path>` is the path to the directory containing Swift files you want to combine
- `<output_file>` is the path and filename where you want the combined content to be saved

Example:

`swiftfilescombiner ~/Projects/MySwiftApp ~/Desktop/CombinedSwiftFiles.swift`

## Building from Source

If you prefer to build SwiftFilesCombiner from source:

1. Clone the repository: `git clone https://github.com/bashta/SwiftFilesCombiner.git`
2. Navigate to the project directory: `cd SwiftFilesCombiner`
3. Build the project: `swift build -c release`
4. The executable will be located in `.build/release/SwiftFilesCombiner`

## Contributing

Contributions to SwiftFilesCombiner are welcome! Please feel free to submit a Pull Request.

## License

SwiftFilesCombiner is available under the MIT license. See the LICENSE file for more info.

## Support

If you encounter any issues or have any questions, please file an issue on the GitHub repository.

## Authors

- Erison Veshi (@bashta) 

