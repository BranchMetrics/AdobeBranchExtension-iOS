// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AdobeBranchExtension",
    platforms: [
        .iOS(.v12) // Matches podspec platform
    ],
    products: [
        .library(name: "AdobeBranchExtension", targets: ["AdobeBranchExtension"])
    ],
    dependencies: [
        .package(url: "https://github.com/adobe/aepsdk-core-ios.git", from: "5.1.0"),
        .package(url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution", from: "3.13.3")
    ],
    targets: [
        .target(
            name: "AdobeBranchExtension",
            dependencies: [
                .product(name: "AEPCore", package: "aepsdk-core-ios"),
                .product(name: "AEPSignal", package: "aepsdk-core-ios"),
                .product(name: "AEPLifecycle", package: "aepsdk-core-ios"),
                .product(name: "AEPIdentity", package: "aepsdk-core-ios"),
                .product(name: "BranchSDK", package: "ios-branch-deep-linking-attribution")
            ],
            path: "AdobeBranchExtension/Classes", // Source files location 
            publicHeadersPath: "include", // Point to .h files 
            cSettings: [
                .define("ADOBE_BRANCH_VERSION", to: "@\"5.0.0-beta.1\"")
            ]
        )
    ]
)