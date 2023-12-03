// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift",
    platforms: [.macOS(.v10_15)],
    products: [
        .plugin(name: "FormatSwift", targets: ["FormatSwift"]),
        .plugin(name: "LintSwift", targets: ["LintSwift"]),
        .plugin(name: "SwiftGen", targets: ["SwiftGen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.2.3"))
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
            url: "https://github.com/nicklockwood/SwiftFormat/releases/download/0.52.10/swiftformat.artifactbundle.zip",
            checksum: "6c11b2d50ee6f914ee87e891ad4e4a32e1f82993a8ccecaebd3285ac767b86ce"
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
            url: "https://github.com/realm/SwiftLint/releases/download/0.54.0/SwiftLintBinary-macos.artifactbundle.zip",
            checksum: "963121d6babf2bf5fd66a21ac9297e86d855cbc9d28322790646b88dceca00f1"
        ),

        // MARK: - SwiftGen

        .plugin(
            name: "SwiftGen",
            capability: .command(
                intent: .custom(
                    verb: "generate-code-for-resources",
                    description: "Creates type-save for all your resources"),
                permissions: [
                    .writeToPackageDirectory(reason: "This command generates source code")
                ]
            ),
            dependencies: ["swiftgen"]
        ),
        .binaryTarget(
            name: "swiftgen",
            url: "https://github.com/SwiftGen/SwiftGen/releases/download/6.6.2/swiftgen-6.6.2.artifactbundle.zip",
            checksum: "7586363e24edcf18c2da3ef90f379e9559c1453f48ef5e8fbc0b818fbbc3a045"
        )
    ]
)
