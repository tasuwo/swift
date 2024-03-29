import Foundation
import PackagePlugin
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

@main
struct LintSwiftPlugin {
    enum PluginError: Error {
        case failure(exitCode: Int32)
    }

    func createBuildCommands(context: Context, targetName: String, inputPath: String) throws -> [Command] {
         var arguments: [CustomStringConvertible] = [
            "--path", inputPath,
            "--binary-path", try context.tool(named: "swiftlint").path.string,
        ]

        if ProcessInfo.processInfo.environment["CI_XCODE_CLOUD"] == "TRUE" {
            arguments.append("--no-cache")
        } else {
            arguments.append("--cache-path")
            arguments.append(context.pluginWorkDirectory.appending(["swiftlint.cache"]).string)
        }

        return [
            .buildCommand(
                displayName: "Running SwiftLint for \(targetName)",
                executable: try context.tool(named: "SwiftLintExecuter").path,
                arguments: arguments
            )
        ]
    }
}

extension LintSwiftPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        return try createBuildCommands(context: context, targetName: target.name, inputPath: target.directory.string)
    }
}

#if canImport(XcodeProjectPlugin)

extension LintSwiftPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        return try createBuildCommands(context: context, targetName: target.displayName, inputPath: context.xcodeProject.directory.string)
    }
}

#endif
