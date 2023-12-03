import Foundation
import PackagePlugin
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

@main
struct SwiftGenPlugin {
    enum PluginError: Error {
        case failure(exitCode: Int32)
    }

    func perform(context: Context, configuration: Path) throws {
        try perform(context: context, arguments: [
            "config",
            "run",
            "--config", configuration.string,
        ])
    }

    func perform(context: Context, arguments: [String]) throws {
        let process = Process()
        process.launchPath = try context.tool(named: "swiftgen").path.string
        process.arguments = arguments

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != EXIT_SUCCESS {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("swiftgen invocation failed: \(problem)")
            throw PluginError.failure(exitCode: process.terminationStatus)
        }
    }
}

extension SwiftGenPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let fileManager = FileManager.default

        guard !arguments.isEmpty else {
            try perform(context: context, arguments: arguments)
            return
        }

        let configuration = context.package.directory.appending("swiftgen.yml")
        if fileManager.fileExists(atPath: configuration.string) {
            try perform(context: context, configuration: configuration)
        }

        let targets = context.package.targets.compactMap { $0 as? SourceModuleTarget }
        for target in targets {
            let configuration = target.directory.appending("swiftgen.yml")
            if fileManager.fileExists(atPath: configuration.string) {
                try perform(context: context, configuration: configuration)
            }
        }
    }
}

#if canImport(XcodeProjectPlugin)

extension SwiftGenPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        var argumentExtractor = ArgumentExtractor(arguments)
        let selectedTargetNames = Set(argumentExtractor.extractOption(named: "target"))

        let fileManager = FileManager.default

        guard !argumentExtractor.remainingArguments.isEmpty else {
            try perform(context: context, arguments: argumentExtractor.remainingArguments)
            return
        }

        let configuration = context.xcodeProject.directory.appending("swiftgen.yml")
        if fileManager.fileExists(atPath: configuration.string) {
            try perform(context: context, configuration: configuration)
        }

        let selectedTargets = context.xcodeProject.targets
            .lazy
            .filter { selectedTargetNames.contains($0.displayName) }
            .compactMap { $0 as? SourceModuleTarget }
        for target in selectedTargets {
            let configuration = target.directory.appending("swiftgen.yml")
            if fileManager.fileExists(atPath: configuration.string) {
                try perform(context: context, configuration: configuration)
            }
        }
    }
}

#endif
