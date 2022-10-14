import ArgumentParser
import Foundation

@main
struct SwiftFormatExecuter: ParsableCommand {
    @Argument
    var directories: [String]

    @Option
    var path: String

    @Option
    var exclude: String?

    @Option
    var cachePath: String?

    @Option
    var config = Bundle.module.path(forResource: "config", ofType: "swiftformat")!

    @Option
    var swiftVersion: String?

    mutating func run() throws {
        var arguments = directories + [
            "--config", config,
        ]

        if let cachePath = cachePath {
            arguments += ["--cache", cachePath]
        }

        if let swiftVersion = swiftVersion {
            arguments += ["--swiftversion", swiftVersion]
        }

        if let exclude = exclude {
            arguments += ["--exclude", exclude]
        }

        let process = Process()
        process.launchPath = path
        process.arguments = arguments

        try process.run()
        process.waitUntilExit()

        switch process.terminationStatus {
        case EXIT_SUCCESS:
            break

        case 1:
            // lint failure
            throw ExitCode.failure

        default:
            throw ExitCode(process.terminationStatus)
        }
    }
}
