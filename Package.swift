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
		.package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.10.0"),
		.package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.0"),
		.package(name: "SwiftProtobuf", url: "https://github.com/apple/swift-protobuf.git", from: "1.17.0"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.2"))
	],
    targets: [
        .target(
            name: "Jetfire",
            dependencies: [
				.product(name: "SDWebImage", package: "SDWebImage"),
				.product(name: "SwiftProtobuf", package: "SwiftProtobuf"),
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
