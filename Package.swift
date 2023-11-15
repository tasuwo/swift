// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "swift",
    platforms: [.macOS(.v10_15)],
    products: [
        .plugin(name: "FormatSwift", targets: ["FormatSwift"]),
        .plugin(name: "LintSwift", targets: ["LintSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.1.4"))
    ],
    targets: [
        // MARK: - Format

        .plugin(
            name: "FormatSwift",
            capability: .command(
                intent: .custom(
                    verb: "format",
                    description: "Formats Swift source files"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Format Swift source files")
                ]
            ),
            dependencies: [
                "swiftformat",
                "SwiftFormatExecuter"
            ]
        ),
        .executableTarget(
            name: "SwiftFormatExecuter",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")],
            resources: [.process("config.swiftformat")]
        ),
        .binaryTarget(
            name: "swiftformat",
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.50.2/swiftformat.artifactbundle.zip",
            checksum: "a61e23a0d32243f4826924a21d7d2b5c64946052e55e9e27387707882570258e"
        ),

        // MARK: - Lint

        .plugin(
            name: "LintSwift",
            capability: .buildTool(),
            dependencies: [
                "SwiftLintBinary",
                "SwiftLintExecuter"
            ]
        ),
        .executableTarget(
            name: "SwiftLintExecuter",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")],
            resources: [.process("swiftlint.yml")]
        ),
        .binaryTarget(
            name: "SwiftLintBinary",
            url: "https://github.com/realm/SwiftLint/releases/download/0.49.1/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "227258fdb2f920f8ce90d4f08d019e1b0db5a4ad2090afa012fd7c2c91716df3"
        ),
    ]
)
