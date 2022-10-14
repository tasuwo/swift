import Foundation
import PackagePlugin
#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin
#endif

protocol Context {
    var pluginWorkDirectory: Path { get }
    func tool(named name: String) throws -> PluginContext.Tool
}

extension PluginContext: Context {}

#if canImport(XcodeProjectPlugin)
extension XcodePluginContext: Context {}
#endif
