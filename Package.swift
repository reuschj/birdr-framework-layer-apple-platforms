// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "birdr-framework-layer-apple-platforms",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "BirdrAPIClient",
            targets: ["BirdrAPIClient"]),
        .library(
            name: "BirdrAPIFoundation",
            targets: ["BirdrAPIFoundation"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            name: "BirdrFoundation",
            url: "https://github.com/reuschj/birdr-foundation-swift.git",
            from: "0.0.14"
        ),
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            .upToNextMajor(from: "5.4.0")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BirdrAPIFoundation",
            dependencies: []
        ),
        .target(
            name: "BirdrAPIClient",
            dependencies: [
                .product(name: "BirdrModel", package: "BirdrFoundation"),
                .product(name: "BirdrServiceModel", package: "BirdrFoundation"),
                .product(name: "BirdrUserModel", package: "BirdrFoundation"),
                .product(name: "BirdrFoundation", package: "BirdrFoundation"),
                "Alamofire",
                "BirdrAPIFoundation"
            ]),
        .testTarget(
            name: "BirdrAPIFoundationTests",
            dependencies: ["BirdrAPIFoundation"]),
        .testTarget(
            name: "BirdrAPIClientTests",
            dependencies: ["BirdrAPIClient", "BirdrAPIFoundation"])
    ]
)
