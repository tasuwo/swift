import ArgumentParser
import Foundation

@main
struct SwiftLintExecuter: ParsableCommand {
    @Option
    var path: String

    @Option
    var binaryPath: String

    @Option
    var cachePath: String?

    @Option
    var config = Bundle.module.path(forResource: "swiftlint", ofType: "yml")!

    mutating func run() throws {
        var arguments = [
            "lint",
            "--config", config,
        ]

        if let cachePath = cachePath {
            arguments += ["--cache-path", cachePath]
        }

        arguments.append(path)

        let process = Process()
        process.launchPath = binaryPath
        process.arguments = arguments

        try process.run()
        process.waitUntilExit()

        switch process.terminationStatus {
        case EXIT_SUCCESS:
            break

        default:
            throw ExitCode(process.terminationStatus)
        }
    }
}
