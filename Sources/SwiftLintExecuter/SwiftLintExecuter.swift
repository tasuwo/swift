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

    @Flag
    var noCache = false

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

        if noCache {
            arguments += ["--no-cache"]
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
