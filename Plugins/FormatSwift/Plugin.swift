import Foundation
import PackagePlugin
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

@main
struct FormatSwiftPlugin {
    enum PluginError: Error {
        case failure(exitCode: Int32)
    }

    func perform(context: Context, inputPaths: [String], arguments: [String]) throws {
        let launchPath = try context.tool(named: "SwiftFormatExecuter").path.string
        let arguments = inputPaths + [
            "--path", try context.tool(named: "swiftformat").path.string,
            "--cache-path", context.pluginWorkDirectory.appending(["swiftformat.cache"]).string,
        ] + arguments

        let process = Process()
        process.launchPath = launchPath
        process.arguments = arguments

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != EXIT_SUCCESS {
            throw PluginError.failure(exitCode: process.terminationStatus)
        }
    }
}

extension FormatSwiftPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        var argumentExtractor = ArgumentExtractor(arguments)

        let selectedTargets = argumentExtractor.extractOption(named: "target")

        let inputPaths = selectedTargets.isEmpty
            ? [context.package.directory.string]
            : try context.package.targets(named: selectedTargets).map(\.directory.string)

        let swiftVersion = argumentExtractor.extractOption(named: "swift-version").last
            ?? "\(context.package.toolsVersion.major).\(context.package.toolsVersion.minor)"
        let arguments = ["--swift-version", swiftVersion] + argumentExtractor.remainingArguments

        try perform(context: context, inputPaths: inputPaths, arguments: arguments)
    }
}

#if canImport(XcodeProjectPlugin)

extension FormatSwiftPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        var argumentExtractor = ArgumentExtractor(arguments)

        let selectedTargetNames = Set(argumentExtractor.extractOption(named: "target"))
        let inputPaths = context.xcodeProject.targets.lazy
            .filter { selectedTargetNames.contains($0.displayName) }
            .flatMap(\.inputFiles)
            .map(\.path.string)
            .filter { $0.hasSuffix(".swift") }

        try perform(context: context, inputPaths: Array(inputPaths), arguments: argumentExtractor.remainingArguments)
    }
}

#endif
