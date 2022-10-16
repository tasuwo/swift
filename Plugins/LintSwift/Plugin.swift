import Foundation
import PackagePlugin

@main
struct LintSwiftPlugin {
    enum PluginError: Error {
        case failure(exitCode: Int32)
    }

    func createBuildCommands(context: Context, targetName: String, inputPath: String) throws -> [Command] {
        return [
            .buildCommand(
                displayName: "Running SwiftLint for \(targetName)",
                executable: try context.tool(named: "SwiftLintExecuter").path,
                arguments: [
                    "--path", inputPath,
                    "--binary-path", try context.tool(named: "swiftlint").path.string,
                    "--cache-path", context.pluginWorkDirectory.appending(["swiftlint.cache"]).string,
                ]
            )
        ]
    }
}

extension LintSwiftPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        return try createBuildCommands(context: context, targetName: target.name, inputPath: target.directory.string)
    }
}
