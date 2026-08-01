// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AdobeBranchExtension",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "AdobeBranchExtension",
            targets: ["AdobeBranchExtension"])
    ],
    dependencies: [
        .package(url: "https://github.com/BranchMetrics/ios-branch-sdk-spm", .upToNextMajor(from: "3.13.3")),
        .package(url: "https://github.com/adobe/aepsdk-core-ios.git", .upToNextMajor(from: "5.7.0")),
        .package(url: "https://github.com/adobe/aepsdk-edge-ios.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/adobe/aepsdk-edgeidentity-ios.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "AdobeBranchExtension",
            dependencies: [
                .product(name: "BranchSDK", package: "ios-branch-sdk-spm"),
                .product(name: "AEPCore", package: "aepsdk-core-ios"),
                .product(name: "AEPServices", package: "aepsdk-core-ios"),
                .product(name: "AEPIdentity", package: "aepsdk-core-ios"),
                .product(name: "AEPEdge", package: "aepsdk-edge-ios"),
                .product(name: "AEPEdgeIdentity", package: "aepsdk-edgeidentity-ios")
            ],
            path: "AdobeBranchExtension/Classes",
            publicHeadersPath: "include", // Point this to your new folder
            cSettings: [
                .headerSearchPath("."),
                .define("ADOBE_BRANCH_VERSION", to: "@\"4.1.1\"")
            ]
        )
    ]
)