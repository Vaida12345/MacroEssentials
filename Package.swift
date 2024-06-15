// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MacroEssentials",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ], products: [
        .library(name: "MacroEssentials", targets: ["MacroEssentials"]),
    ], dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ], targets: [
        .target(name: "MacroEssentials", dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
        ]),
        .testTarget(name: "MacroEssentialsTests", dependencies: ["MacroEssentials"]),
    ], swiftLanguageVersions: [.v6]
)
