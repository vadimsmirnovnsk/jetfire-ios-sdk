// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Jetfire",
	platforms: [
		.iOS(.v13),
	],
    products: [
        .library(
            name: "Jetfire",
            targets: ["Jetfire"]),
    ],
	dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.4")),
		.package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.10.0"),
		.package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.0"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.2"))
	],
    targets: [
        .target(
            name: "Jetfire",
            dependencies: [
				.product(name: "Alamofire", package: "Alamofire"),
				.product(name: "SDWebImage", package: "SDWebImage"),
				.product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "OrderedCollections", package: "swift-collections")
			],
			path: "Sources",
			exclude: ["Jetfire/Model/protocol.proto"]
		),
        .testTarget(
            name: "JetfireTests",
            dependencies: ["Jetfire"],
			resources: [
				.copy("JetfireService-Info.plist")
		]),
    ]
)
