# 🔀 SwiftFilesCombiner
SwiftFilesCombiner is a command-line utility designed to simplify the process of combining multiple Swift files into a single file. This tool is particularly useful for developers who need to merge multiple Swift source files for code review, submission, or any other purpose that requires a consolidated view of the codebase.

## ✨ Features
- 🔍 Recursively scans a specified directory for Swift files
- 🔗 Combines all found Swift files into a single output file
- 💼 Preserves file paths in comments for easy reference
- 🛡️ Handles potential errors gracefully
- 🏠 Uses current directory as default input if no directory is specified

## 📥 Installation
SwiftFilesCombiner can be easily installed using Homebrew:
```
brew tap bashta/tap
brew install swiftfilescombiner
```

## 🚀 Usage
- After installation, you can use SwiftFilesCombiner from the command line with flexible arguments:
`swiftfilescombiner [<directory_path>] [<output_file>]`

Where:
- `<directory_path>` (optional) is the path to the directory containing Swift files you want to combine. If not provided, the current directory is used.
- `<output_file>` (optional) is the path and filename where you want the combined content to be saved. If not provided, it defaults to 'combined_swift_files.swift' in the current directory.

## Examples
```
# Uses current directory, outputs to current directory
swiftfilescombiner

# Uses current directory, outputs to desktop
swiftfilescombiner -d
# Uses specified input directory, outputs to desktop
swiftfilescombiner input_dir -d
# Uses current directory, outputs to desktop with specified filename
swiftfilescombiner -d output.swift
# Uses specified input and output, but puts output on desktop
swiftfilescombiner input_dir output.swift -d
```

## 🛠️ Building from Source
If you prefer to build SwiftFilesCombiner from source:

- Clone the repository: git clone `https://github.com/bashta/SwiftFilesCombiner.git`
- Navigate to the project directory: `cd SwiftFilesCombiner`
- Build the project: `swift build -c release`
- The executable will be located in `.build/release/SwiftFilesCombiner`

## 🤝 Contributing
Contributions to SwiftFilesCombiner are welcome! Please feel free to submit a Pull Request.

## 📄 License
SwiftFilesCombiner is available under the MIT license. See the LICENSE file for more info.

## 💬 Support
If you encounter any issues or have any questions, please file an issue on the GitHub repository.

## 👨‍💻 Authors
Erison Veshi [bashta](https://github.com/severeduck)

## Thanks to
Y [severeduck](https://github.com/severeduck)

##  🎉 What's New in v0.0.3
- 🏠 Current directory is now used as default input if no directory is specified
- 🔧 Improved argument handling for more flexible usage
- 📝 Default output file name when not specified: 'combined_swift_files.swift'
- 🐛 Enhanced error handling and improved stability
- 🧪 Expanded test coverage for better reliability

#### Made with <3 and a pinch of sillyness!
